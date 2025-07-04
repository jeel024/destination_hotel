import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ModelKeys.dart';

class BookRoomModel {
  String? id;
  String? hotelId;
  String? roomId;
  String? paymentId;
  String? name;
  String? proof;
  int? quantity;
  int? amount;
  String? mobile;
  String? email;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  BookRoomModel({
    this.id,
    this.hotelId,
    this.roomId,
    this.paymentId,
    this.name,
    this.quantity,
    this.proof,
    this.amount,
    this.mobile,
    this.email,
    this.checkInDate,
    this.checkOutDate,
    this.createdAt,
    this.updatedAt,
  });

  factory BookRoomModel.fromJson(Map<String, dynamic> json) {
    return BookRoomModel(
      id: json[CommonKeys.id],
      hotelId: json[PlaceKeys.hotelId],
      roomId: json[BookRoomKeys.roomId],
      paymentId: json[BookRoomKeys.paymentId],
      name: json[PlaceKeys.name],
      email: json[UserKeys.email],
      mobile: json[BookRoomKeys.mobile],
      amount: json[BookRoomKeys.amount],
      quantity: json[PlaceKeys.quantity],
      proof: json[BookRoomKeys.proof],
      checkInDate: json[BookRoomKeys.checkInDate] != null ? (json[BookRoomKeys.checkInDate] as Timestamp).toDate() : null,
      checkOutDate: json[BookRoomKeys.checkOutDate] != null ? (json[BookRoomKeys.checkOutDate] as Timestamp).toDate() : null,
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[PlaceKeys.hotelId] = this.hotelId;
    data[BookRoomKeys.paymentId] = this.paymentId;
    data[BookRoomKeys.roomId] = this.roomId;
    data[BookRoomKeys.checkInDate] = this.checkInDate;
    data[BookRoomKeys.checkOutDate] = this.checkOutDate;
    data[BookRoomKeys.amount] = this.amount;
    data[BookRoomKeys.proof] = this.proof;
    data[PlaceKeys.name] = this.name;
    data[UserKeys.email] = this.email;
    data[BookRoomKeys.mobile] = this.mobile;
    data[PlaceKeys.quantity] = this.quantity;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    return data;
  }
}
