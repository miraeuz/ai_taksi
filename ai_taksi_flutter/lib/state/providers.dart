import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api.dart';
import '../models/models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final repositoryProvider = Provider<ApiRepository>((ref) => ApiRepository(ref.watch(apiClientProvider)));
final authProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
class AuthController extends AsyncNotifier<AppUser?> {
  @override Future<AppUser?> build() async {
    final client = ref.read(apiClientProvider);
    if (await client.store.read(key: 'refresh') == null) return null;
    try { return await ref.read(repositoryProvider).me(); } catch (_) { return null; }
  }
  Future<void> verify(String phone, String code, String purpose, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => (await ref.read(repositoryProvider).verifyOtp(phone, code, purpose, name)).user);
  }
  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async { await ref.read(repositoryProvider).logout(); return null; });
  }
}
final schedulesProvider = FutureProvider.autoDispose<List<Schedule>>((ref) => ref.watch(repositoryProvider).schedules());
final confirmationsProvider = FutureProvider.autoDispose<List<Confirmation>>((ref) => ref.watch(repositoryProvider).confirmations());
final driverPricesProvider = FutureProvider.autoDispose<List<DriverPrice>>((ref) => ref.watch(repositoryProvider).prices());
final driverOffersProvider = FutureProvider.autoDispose<List<DriverOffer>>((ref) => ref.watch(repositoryProvider).offers());
