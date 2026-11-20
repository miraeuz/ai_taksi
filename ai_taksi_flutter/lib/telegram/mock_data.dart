/// Offline fixtures only. Route names and the pilot's people/vehicles are not live inventory.
/// The production FastAPI backend remains limited to its previously implemented routes.
class DemoPlace {
  final String id, name, subtitle, category;
  const DemoPlace(this.id, this.name, this.subtitle, this.category);
}

const origins = <DemoPlace>[
  DemoPlace('kosonsoy', 'Kosonsoy', 'Tuman markazi', 'Tuman'),
  DemoPlace('toraqorgon', 'To‘raqo‘rg‘on', 'Markaziy bekat · namuna', 'Tuman'),
  DemoPlace('chust', 'Chust', 'Shahar markazi · namuna', 'Tuman'),
  DemoPlace('yangiqorgon', 'Yangiqo‘rg‘on', 'Markaziy bekat · namuna', 'Tuman'),
  DemoPlace('pop', 'Pop', 'Markaziy bekat · namuna', 'Tuman'),
  DemoPlace('namangan', 'Namangan', 'Shahar markazi', 'Shahar'),
];

const destinations = <DemoPlace>[
  DemoPlace('yuksalish', 'Yuksalish · NamDU kampusi', 'Davlatobod, Yuksalish massivi', 'Universitet'),
  DemoPlace('namdu', 'Namangan davlat universiteti', 'Asosiy kampus · NamDU', 'Universitet'),
  DemoPlace('texnika', 'Namangan davlat texnika universiteti', 'NamDTU', 'Universitet'),
  DemoPlace('pedagogika', 'Namangan davlat pedagogika instituti', 'Pedagogika yo‘nalishlari', 'Universitet'),
  DemoPlace('ubs', 'University of Business and Science', 'Namangan kampusi', 'Universitet'),
  DemoPlace('davlatobod', 'Davlatobod markazi', 'Shahar hududi', 'Shahar'),
  DemoPlace('shahar', 'Namangan shahar markazi', 'Markaziy hudud', 'Shahar'),
  DemoPlace('vokzal', 'Namangan temir yo‘l vokzali', 'Vokzal', 'Transport'),
  DemoPlace('avtovokzal', 'Namangan avtovokzali', 'Avtovokzal · namuna', 'Transport'),
  DemoPlace('bozor', 'Chorsu bozori', 'Savdo hududi · namuna', 'Shahar'),
  DemoPlace('shifoxona', 'Namangan tibbiyot markazi', 'Tibbiyot hududi · namuna', 'Shahar'),
];

const pickupPoints = <String>[
  'Kosonsoy markazi', 'Kosonsoy dehqon bozori', 'Kosonsoy janub',
  '29-maktab oldi · namuna', 'To‘raqo‘rg‘on bekati · namuna',
  'Yangiqo‘rg‘on chorrahasi · namuna', 'Namangan kirish', 'Davlatobod bekati',
];

const weekdays = <String>['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

class MockVehicle {
  final String id, model, group, note;
  final int seats, fare;
  final double rating;
  final bool electric;
  const MockVehicle(this.id, this.model, this.group, this.note, this.seats, this.fare,
      this.rating, {this.electric = false});
}

const mockVehicles = <MockVehicle>[
  MockVehicle('cobalt', 'Chevrolet Cobalt', 'Yengil', 'Standart · 3 o‘rin', 3, 32000, 4.8),
  MockVehicle('onix', 'Chevrolet Onix', 'Yengil', 'Comfort · konditsioner', 3, 39000, 4.9),
  MockVehicle('byd', 'BYD e2', 'Yengil', 'Elektr · qulay', 3, 42000, 4.9, electric: true),
  MockVehicle('damas', 'Chevrolet Damas', 'Damas', 'Talabalar uchun', 8, 20000, 4.9),
  MockVehicle('sprinter', 'Mercedes Sprinter', 'Avtobus', 'Minibus · keng salon', 14, 19000, 4.8),
  MockVehicle('isuzu', 'Isuzu SAZ', 'Avtobus', '22 o‘rinli avtobus', 22, 17000, 4.7),
  MockVehicle('yutong', 'Yutong', 'Avtobus', '28 o‘rinli avtobus', 28, 15000, 4.8),
];

class MockOffer {
  final String id, originId, destinationId, driver, vehicleId, plate, departure,
      pickup, date, description;
  final int seats, price, minutesLeft;
  final double rating;
  const MockOffer({required this.id, required this.originId, required this.destinationId,
    required this.driver, required this.vehicleId, required this.plate,
    required this.departure, required this.pickup, required this.date,
    required this.seats, required this.price, required this.rating,
    required this.minutesLeft, this.description = ''});
}

const mockOffers = <MockOffer>[
  MockOffer(id:'A-201',originId:'kosonsoy',destinationId:'yuksalish',driver:'Sherzod',vehicleId:'damas',plate:'01 A 123 BC',departure:'10:40',pickup:'Kosonsoy markazi',date:'Du · 23 noy',seats:8,price:20000,rating:4.9,minutesLeft:5,description:'Yuksalishdagi yangi kampus'),
  MockOffer(id:'A-202',originId:'kosonsoy',destinationId:'namdu',driver:'Islom',vehicleId:'damas',plate:'50 B 227 CA',departure:'11:20',pickup:'Kosonsoy dehqon bozori',date:'Du · 23 noy',seats:7,price:21000,rating:4.8,minutesLeft:7),
  MockOffer(id:'A-203',originId:'toraqorgon',destinationId:'texnika',driver:'Javohir',vehicleId:'cobalt',plate:'50 A 443 BK',departure:'07:30',pickup:'To‘raqo‘rg‘on bekati · namuna',date:'Se · 24 noy',seats:3,price:33000,rating:4.9,minutesLeft:9),
  MockOffer(id:'A-204',originId:'chust',destinationId:'pedagogika',driver:'Dilshod',vehicleId:'sprinter',plate:'50 M 556 BA',departure:'08:10',pickup:'Chust markazi',date:'Ch · 25 noy',seats:12,price:19000,rating:4.8,minutesLeft:6),
  MockOffer(id:'A-205',originId:'kosonsoy',destinationId:'ubs',driver:'Komil',vehicleId:'onix',plate:'50 N 102 BB',departure:'07:45',pickup:'Kosonsoy janub',date:'Du · 23 noy',seats:3,price:38000,rating:5.0,minutesLeft:12),
  MockOffer(id:'A-206',originId:'kosonsoy',destinationId:'davlatobod',driver:'Oybek',vehicleId:'isuzu',plate:'50 R 872 BC',departure:'06:50',pickup:'Kosonsoy markazi',date:'Pa · 26 noy',seats:20,price:16000,rating:4.7,minutesLeft:11),
  MockOffer(id:'A-207',originId:'yangiqorgon',destinationId:'vokzal',driver:'Ulug‘bek',vehicleId:'byd',plate:'50 S 113 NA',departure:'09:30',pickup:'Yangiqo‘rg‘on markazi',date:'Ju · 27 noy',seats:3,price:41000,rating:4.9,minutesLeft:14),
  MockOffer(id:'A-208',originId:'pop',destinationId:'avtovokzal',driver:'Alisher',vehicleId:'yutong',plate:'50 K 378 BC',departure:'08:00',pickup:'Pop markazi',date:'Sh · 28 noy',seats:24,price:15000,rating:4.8,minutesLeft:10),
  MockOffer(id:'A-209',originId:'namangan',destinationId:'shifoxona',driver:'Sardor',vehicleId:'cobalt',plate:'50 H 992 BB',departure:'12:30',pickup:'Namangan markazi',date:'Du · 23 noy',seats:2,price:12000,rating:4.8,minutesLeft:13),
  MockOffer(id:'A-210',originId:'kosonsoy',destinationId:'shahar',driver:'Bekzod',vehicleId:'damas',plate:'50 A 111 AB',departure:'16:10',pickup:'Kosonsoy markazi',date:'Se · 24 noy',seats:6,price:23000,rating:4.7,minutesLeft:8),
  MockOffer(id:'A-211',originId:'toraqorgon',destinationId:'yuksalish',driver:'Farrux',vehicleId:'sprinter',plate:'50 G 431 DA',departure:'09:10',pickup:'To‘raqo‘rg‘on bekati · namuna',date:'Ch · 25 noy',seats:11,price:20000,rating:4.9,minutesLeft:5),
  MockOffer(id:'A-212',originId:'chust',destinationId:'bozor',driver:'Akmal',vehicleId:'damas',plate:'50 P 557 BB',departure:'15:30',pickup:'Chust markazi',date:'Pa · 26 noy',seats:8,price:22000,rating:4.8,minutesLeft:7),
];

class MockHistory {
  final String date, route, driver, vehicle;
  final int fare;
  const MockHistory(this.date,this.route,this.driver,this.vehicle,this.fare);
}

const mockHistory = <MockHistory>[
  MockHistory('18 noy', 'Kosonsoy → Yuksalish', 'Sherzod', 'Damas', 20000),
  MockHistory('16 noy', 'Kosonsoy → NamDU', 'Islom', 'Damas', 21000),
  MockHistory('13 noy', 'To‘raqo‘rg‘on → NamDTU', 'Javohir', 'Cobalt', 33000),
  MockHistory('11 noy', 'Kosonsoy → Davlatobod', 'Oybek', 'Isuzu', 16000),
  MockHistory('09 noy', 'Kosonsoy → Namangan', 'Komil', 'Onix', 38000),
  MockHistory('06 noy', 'Chust → NamDU', 'Dilshod', 'Sprinter', 19000),
  MockHistory('04 noy', 'Yangiqo‘rg‘on → Vokzal', 'Ulug‘bek', 'BYD', 41000),
  MockHistory('02 noy', 'Kosonsoy → Yuksalish', 'Sherzod', 'Damas', 20000),
  MockHistory('30 okt', 'Kosonsoy → NamDU', 'Islom', 'Damas', 21000),
  MockHistory('28 okt', 'Pop → Avtovokzal', 'Alisher', 'Yutong', 15000),
];

class MockMessage {
  final String author, body, time;
  const MockMessage(this.author,this.body,this.time);
}

const initialMessages = <MockMessage>[
  MockMessage('Sherzod', 'Assalomu alaykum! Bekatga 10:40 da yetib boraman.', '10:28'),
  MockMessage('Aziza', 'Rahmat, kutyapman.', '10:29'),
  MockMessage('Sherzod', 'Damas, oq rang. Raqam 01 A 123 BC.', '10:31'),
];

String placeName(String id) {
  for (final place in [...origins,...destinations]) {
    if (place.id == id) return place.name;
  }
  return id;
}
MockVehicle vehicleFor(String id) => mockVehicles.firstWhere((v)=>v.id==id,
  orElse:()=>mockVehicles[3]);
