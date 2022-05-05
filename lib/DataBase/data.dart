import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Service serviceFromJson(String str) => Service.fromJson(json.decode(str));
String serviceToJson(Service data) => json.encode(data.toJson());
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class Service {
  Service({
    required this.id,
    required this.name,
    required this.localization,
    required this.price,
    required this.service,
    required this.date,
    required this.situation,
    required this.time,
  });

  String id;
  String name;
  String localization;
  int price;
  String service;
  DateTime date;
  String situation;
  DateTime time;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        name: json["name"],
        localization: json["localization"],
        price: json["price"],
        service: json["service"],
        date: DateTime.parse(json["date"]),
        situation: json["situation"],
        time: DateTime.parse(json["time"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "localization": localization,
        "price": price,
        "service": service,
        "date": date.toIso8601String(),
        "situation": situation,
        "time": time.toIso8601String(),
      };

  //to map function
  Map<String, dynamic> toMap() {
    return {
      'id': getRandomString(15),
      'name': name,
      'localization': localization,
      'price': price,
      'service': service,
      'date': date,
      'situation': situation,
      'time': time,
    };
  }

  //Recebe os Dados do firebase e transforma no modelo de serviço
  factory Service.fromFirebaseToModel(QueryDocumentSnapshot<Object?> snapshot) {
    Service serviceInfo = Service(
      id: snapshot['id'],
      name: snapshot['name'],
      localization: snapshot['localization'],
      price: snapshot['price'],
      service: snapshot['service'],
      date: snapshot["date"].toDate(),
      situation: snapshot['situation'],
      time: snapshot["time"].toDate(),
    );
    return serviceInfo;
  }
}
