import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyInfoModel {
  final String babyName;
  final DateTime dueDate;
  final String gender;
  final String id;
  final String ended;

  const PregnancyInfoModel({
    required this.babyName,
    required this.dueDate,
    required this.gender,
    required this.id,
    required this.ended,
  });

  factory PregnancyInfoModel.fromJson(Map<String, dynamic> json, id) {
    Timestamp timestamp = json["DueDate"] as Timestamp;
    final DateTime dateTime = timestamp.toDate();
    return PregnancyInfoModel(
      babyName: json["Baby's name"],
      dueDate: DateTime.parse(dateTime.toString()),
      gender: json["Gender"],
      ended: json["ended"],
      id: id,
    );
  }
//

//
}
