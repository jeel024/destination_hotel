import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ModelKeys.dart';

class HotelModel {
  String? id;
  String? userId;
  String? name;
  String? email;
  String? image;
  int? status;
  String? placeId;
  String? starId;
  dynamic distance;
  String? address;
  double? latitude;
  double? longitude;
  int? favourites;
  num? rating;
  String? description;
  List<dynamic>? secondaryImages;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? caseSearch;

  HotelModel({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.image,
    this.status,
    this.placeId,
    this.starId,
    this.distance,
    this.address,
    this.latitude,
    this.longitude,
    this.favourites,
    this.rating,
    this.description,
    this.secondaryImages,
    this.createdAt,
    this.updatedAt,
    this.caseSearch,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json[CommonKeys.id],
      userId: json[PlaceKeys.userId],
      name: json[PlaceKeys.name],
      email: json[UserKeys.email],
      image: json[PlaceKeys.image],
      status: json[CommonKeys.status],
      placeId: json[PlaceKeys.placeId],
      starId: json[PlaceKeys.starId],
      distance: json[PlaceKeys.distance],
      address: json[PlaceKeys.address],
      latitude: json[PlaceKeys.latitude],
      longitude: json[PlaceKeys.longitude],
      favourites: json[PlaceKeys.favourites],
      rating: json[PlaceKeys.rating],
      description: json[PlaceKeys.description],
      secondaryImages: json[PlaceKeys.secondaryImages],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
      caseSearch: json[PlaceKeys.caseSearch] != null ? List<String>.from(json[PlaceKeys.caseSearch]) : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[PlaceKeys.userId] = this.userId;
    data[PlaceKeys.name] = this.name;
    data[UserKeys.email] = this.email;
    data[PlaceKeys.image] = this.image;
    data[CommonKeys.status] = this.status;
    data[PlaceKeys.placeId] = this.placeId;
    data[PlaceKeys.starId] = this.starId;
    data[PlaceKeys.distance] = this.distance;
    data[PlaceKeys.address] = this.address;
    data[PlaceKeys.latitude] = this.latitude;
    data[PlaceKeys.longitude] = this.longitude;
    data[PlaceKeys.favourites] = this.favourites;
    data[PlaceKeys.rating] = this.rating;
    data[PlaceKeys.description] = this.description;
    data[PlaceKeys.secondaryImages] = this.secondaryImages;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data[PlaceKeys.caseSearch] = this.caseSearch;
    return data;
  }
}
