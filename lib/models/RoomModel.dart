import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ModelKeys.dart';

class RoomModel {
  String? id;
  String? hotelId;
  String? name;
  String? image;
  int? status;
  int? quantity;
  int? price;
  String? description;
  List<dynamic>? secondaryImages;
  List<dynamic>? facilities;
  DateTime? createdAt;
  DateTime? updatedAt;

  RoomModel({
    this.id,
    this.hotelId,
    this.name,
    this.image,
    this.status,
    this.quantity,
    this.price,
    this.description,
    this.secondaryImages,
    this.facilities,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json[CommonKeys.id],
      hotelId: json[PlaceKeys.hotelId],
      name: json[PlaceKeys.name],
      image: json[PlaceKeys.image],
      status: json[CommonKeys.status],
      quantity: json[PlaceKeys.quantity],
      price: json[PlaceKeys.price],
      description: json[PlaceKeys.description],
      secondaryImages: json[PlaceKeys.secondaryImages],
      facilities: json[PlaceKeys.facilities],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[PlaceKeys.hotelId] = this.hotelId;
    data[PlaceKeys.name] = this.name;
    data[PlaceKeys.image] = this.image;
    data[CommonKeys.status] = this.status;
    data[PlaceKeys.quantity] = this.quantity;
    data[PlaceKeys.price] = this.price;
    data[PlaceKeys.description] = this.description;
    data[PlaceKeys.secondaryImages] = this.secondaryImages;
    data[PlaceKeys.facilities] = this.facilities;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    return data;
  }
}
