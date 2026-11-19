import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override String toString() => message;
}
class ApiClient {
  final Dio dio;
  final FlutterSecureStorage store;
  Future<String?>? _refreshing;
  ApiClient({Dio? dio, FlutterSecureStorage? store}) : dio = dio ?? Dio(BaseOptions(baseUrl: apiBaseUrl, connectTimeout: const Duration(seconds: 12), receiveTimeout: const Duration(seconds: 12))), store = store ?? const FlutterSecureStorage() {
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await this.store.read(key: 'access');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401 || error.requestOptions.extra['retried'] == true || error.requestOptions.path.contains('/auth/')) {
          return handler.next(error);
        }
        try {
          final token = await _refreshOnce();
          if (token == null) return handler.next(error);
          final request = error.requestOptions;
          request.extra['retried'] = true;
          request.headers['Authorization'] = 'Bearer $token';
          return handler.resolve(await this.dio.fetch<dynamic>(request));
        } catch (_) { return handler.next(error); }
      },
    ));
  }
  Future<String?> _refreshOnce() async {
    if (_refreshing != null) return _refreshing!;
    _refreshing = _refreshImpl();
    try { return await _refreshing; } finally { _refreshing = null; }
  }
  Future<String?> _refreshImpl() async {
    final saved = await store.read(key: 'refresh');
    if (saved == null) return null;
    try {
      // Separate Dio: never recursively enter the authentication interceptor.
      final response = await Dio(BaseOptions(baseUrl: dio.options.baseUrl)).post('/auth/refresh', data: {'refresh_token': saved});
      final pair = AuthTokens.fromJson(jsonMap(response.data));
      await saveTokens(pair);
      return pair.access;
    } catch (_) {
      await clearTokens();
      return null;
    }
  }
  Future<void> saveTokens(AuthTokens tokens) async {
    await store.write(key: 'access', value: tokens.access);
    await store.write(key: 'refresh', value: tokens.refresh);
  }
  Future<void> clearTokens() async {
    await store.delete(key: 'access');
    await store.delete(key: 'refresh');
  }
  Future<T> call<T>(Future<Response<dynamic>> Function() f, T Function(dynamic) parse) async {
    try { return parse((await f()).data); }
    on DioException catch (e) {
      final payload = e.response?.data;
      final detail = payload is Map ? payload['detail'] : null;
      throw ApiException(detail is String ? detail : 'So‘rov bajarilmadi (${e.response?.statusCode ?? 'tarmoq'}).');
    }
  }
}
class ApiRepository {
  final ApiClient client;
  ApiRepository(this.client);
  Future<void> requestOtp(String phone, String purpose) => client.call(() => client.dio.post('/auth/request-otp', data: {'phone': phone, 'purpose': purpose}), (_) => null);
  Future<AuthTokens> verifyOtp(String phone, String code, String purpose, String name) async {
    final pair = await client.call(() => client.dio.post('/auth/verify-otp', data: {'phone': phone, 'code': code, 'purpose': purpose, if (purpose == 'signup') 'name': name}), (j) => AuthTokens.fromJson(jsonMap(j)));
    await client.saveTokens(pair);
    return pair;
  }
  Future<AppUser> me() => client.call(() => client.dio.get('/auth/me'), (j) => AppUser.fromJson(jsonMap(j)));
  Future<void> logout() async {
    final refresh = await client.store.read(key: 'refresh');
    try { if (refresh != null) await client.dio.post('/auth/logout', data: {'refresh_token': refresh}); } catch (_) { /* Always clear local state. */ }
    await client.clearTokens();
  }
  Future<List<Schedule>> schedules() => client.call(() => client.dio.get('/rider/schedules'), (j) => jsonList(j).map(Schedule.fromJson).toList());
  Future<Schedule> createSchedule(Map<String, dynamic> data) => client.call(() => client.dio.post('/rider/schedules', data: data), (j) => Schedule.fromJson(jsonMap(j)));
  Future<void> deleteSchedule(int id) => client.call(() => client.dio.delete('/rider/schedules/$id'), (_) => null);
  Future<List<Confirmation>> confirmations() => client.call(() => client.dio.get('/rider/confirmations/today'), (j) => jsonList(j).map(Confirmation.fromJson).toList());
  Future<Confirmation> answer(int id, String status) => client.call(() => client.dio.post('/rider/confirmations/$id', data: {'status': status}), (j) => Confirmation.fromJson(jsonMap(j)));
  Future<List<DriverPrice>> prices() => client.call(() => client.dio.get('/driver/prices'), (j) => jsonList(j).map(DriverPrice.fromJson).toList());
  Future<DriverPrice> setPrice(int route, int min, int max, double value) => client.call(() => client.dio.put('/driver/prices', data: {'route_id': route, 'min_riders': min, 'max_riders': max, 'price_per_person': value}), (j) => DriverPrice.fromJson(jsonMap(j)));
  Future<List<DriverOffer>> offers() => client.call(() => client.dio.get('/driver/offers'), (j) => jsonList(j).map(DriverOffer.fromJson).toList());
  Future<DriverOffer> respondOffer(int id, bool accept) => client.call(() => client.dio.post('/driver/offers/$id/${accept ? 'accept' : 'decline'}'), (j) => DriverOffer.fromJson(jsonMap(j)));
  Future<void> confirmTrip(int id) => client.call(() => client.dio.post('/rider/trips/$id/confirm'), (_) => null);
}
