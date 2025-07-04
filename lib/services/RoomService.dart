import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_hotel/models/RoomModel.dart';
import '../models/hotelModel.dart';
import '../utils/Common.dart';
import '../utils/Extensions/shared_pref.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../models/DashboardResponse.dart';
import '../models/PlaceModel.dart';
import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';
import 'BaseService.dart';

class RoomService extends BaseService {
  RoomService() {
    ref = db.collection('rooms');
  }


  Future<List<RoomModel>> getRoomsByHotelId({required String id}) async {

    // Query query = ref!
    //     .where(PlaceKeys.hotelId, isEqualTo: id)
    //     .where(BookRoomKeys.checkInDate, isGreaterThanOrEqualTo: DateTime.now())
    //     .where(BookRoomKeys.checkOutDate, isLessThanOrEqualTo: DateTime.now().add(Duration(days: 2)))
    //     .orderBy(CommonKeys.updatedAt, descending: true);
    Query query = ref!.where(PlaceKeys.hotelId, isEqualTo: id).orderBy(CommonKeys.updatedAt, descending: true);

    return await query.get().then((x) {
      return x.docs.map((y) => RoomModel.fromJson(y.data() as Map<String, dynamic>)).toList();
    });
  }
  // Future<List<RoomModel>> getRoomsByHotelId({required String id}) async {
  //   DateTime startDate = DateTime.now();
  //   DateTime endDate = DateTime.now().add(Duration(days: 2));
  //
  //   Query queryCheckIn = ref!
  //       .where(PlaceKeys.hotelId, isEqualTo: id)
  //       .where(BookRoomKeys.checkInDate, isGreaterThanOrEqualTo: startDate);
  //       // .orderBy(CommonKeys.updatedAt, descending: true);
  //
  //   Query queryCheckOut = ref!
  //       .where(PlaceKeys.hotelId, isEqualTo: id)
  //       .where(BookRoomKeys.checkOutDate, isLessThanOrEqualTo: endDate);
  //       // .orderBy(CommonKeys.updatedAt, descending: true);
  //
  //   QuerySnapshot checkInSnapshot = await queryCheckIn.get();
  //   QuerySnapshot checkOutSnapshot = await queryCheckOut.get();
  //
  //   List<RoomModel> mergedResults = [];
  //   mergedResults.addAll(checkInSnapshot.docs.map((doc) => RoomModel.fromJson(doc.data() as Map<String, dynamic>)));
  //   mergedResults.addAll(checkOutSnapshot.docs.map((doc) => RoomModel.fromJson(doc.data() as Map<String, dynamic>)));
  //
  //
  //   return mergedResults;
  // }


  Future<List<PlaceModel>> getHomePlacesByCategory(String? catId) {
    return ref!
        .where(CommonKeys.status, isEqualTo: 1)
        .where(PlaceKeys.categoryId, isEqualTo: catId)
        .orderBy(CommonKeys.createdAt, descending: true)
        .limit(homePlaceLimit)
        .get()
        .then((value) => value.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> latestPlaces() {
    return ref!
        .where(CommonKeys.status, isEqualTo: 1)
        .orderBy(CommonKeys.createdAt, descending: true)
        .limit(homePlaceLimit)
        .get()
        .then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> popularPlaces() {
    return ref!.where(CommonKeys.status, isEqualTo: 1).orderBy(PlaceKeys.rating, descending: true).limit(homePlaceLimit).get().then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> nearByPlaces(Position position, {bool isViewAll = false}) async {
    List<PlaceModel> list = [];
    await ref!.get().then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList()).then((List<PlaceModel> value) {
      if (value.isNotEmpty) {
        value.forEach((element) {
          if (calculateDistanceKm(position.latitude, position.longitude, element.latitude, element.longitude) <= getDoubleAsync(NEAR_BY_PLACE_DISTANCE)) {
            if (isViewAll || list.length < homePlaceLimit) {
              list.add(element);
            }
          }
        });
      }
    });
    return list;
  }

  Future<List<PlaceModel>> searchPlaces(String? caseSearch) {
    return ref!
        .where(CommonKeys.status, isEqualTo: 1)
        .where(PlaceKeys.caseSearch, arrayContains: caseSearch)
        .orderBy(CommonKeys.createdAt, descending: true)
        .get()
        .then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }
}
