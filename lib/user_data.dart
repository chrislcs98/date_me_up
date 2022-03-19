import 'dart:typed_data';

class UserData {
  late final String id, name, location;
  String? image;
  late final DateTime birthDate;
  late int? age;
  String? locationPrefs = "";
  List<dynamic>? agePrefs = List.filled(2, "");
  List<dynamic>? interests = [];

  UserData({ required this.id, required this.name, required this.location, required this.birthDate, this.image, this.age, this.locationPrefs, this.agePrefs, this.interests });
}