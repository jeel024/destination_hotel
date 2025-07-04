import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ModelKeys.dart';

class CityModel {
  String? id;
  String? stateId;
  String? name;
  String? image;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  CityModel({
    this.id,
    this.stateId,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json[CommonKeys.id],
      stateId: json[PlaceKeys.stateId],
      name: json[StateKeys.name],
      image: json[StateKeys.image],
      status: json[CommonKeys.status],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[PlaceKeys.stateId] = this.stateId;
    data[StateKeys.name] = this.name;
    data[StateKeys.image] = this.image;
    data[CommonKeys.status] = this.status;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    return data;
  }
}
