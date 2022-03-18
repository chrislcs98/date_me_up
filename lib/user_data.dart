class UserData {
  late final String id, name, location;
  late final DateTime birthDate;
  late int? age;
  String? locationPrefs = "";
  List<dynamic>? agePrefs = List.filled(2, "");
  List<dynamic>? interests = [];

  UserData({ required this.id, required this.name, required this.location, required this.birthDate, this.age, this.locationPrefs, this.agePrefs, this.interests });
}