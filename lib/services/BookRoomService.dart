import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_hotel/models/BookRoomModel.dart';
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

class BookRoomService extends BaseService {
  BookRoomService() {
    ref = db.collection('bookRoom');
  }

  Future<List<BookRoomModel>> getBookRooms({required String id,required DateTime checkInDate}) async {
    DateTime startDate = checkInDate;
    DateTime endDate = checkInDate.add(Duration(days: 1));

    QuerySnapshot snapshot = await ref!
        .where(BookRoomKeys.roomId, isEqualTo: id)
        .orderBy(CommonKeys.updatedAt, descending: true)
        .get();

    List<BookRoomModel> filteredRooms = snapshot.docs
        .map((doc) => BookRoomModel.fromJson(doc.data() as Map<String, dynamic>))
        .where((room) =>
    room.checkInDate!.isBefore(endDate) &&
        room.checkOutDate!.isAfter(startDate))
        .toList();

    return filteredRooms;
  }


  // Future<List<BookRoomModel>> getBookRooms({required String id}) async {
  //   DateTime startDate = DateTime.now();
  //   DateTime endDate = DateTime.now().add(Duration(days: 2));
  //
  //   Query queryCheckIn = ref!
  //       .where(BookRoomKeys.roomId, isEqualTo: id)
  //       .where(BookRoomKeys.checkInDate, isGreaterThanOrEqualTo: startDate);
  //      // .orderBy(CommonKeys.createdAt, descending: true);
  //
  //   Query queryCheckOut = ref!
  //       .where(BookRoomKeys.roomId, isEqualTo: id)
  //       .where(BookRoomKeys.checkOutDate, isLessThanOrEqualTo: endDate);
  //     //  .orderBy(CommonKeys.createdAt, descending: true);
  //
  //   // Perform the queries asynchronously
  //   QuerySnapshot checkInSnapshot = await queryCheckIn.get();
  //   QuerySnapshot checkOutSnapshot = await queryCheckOut.get();
  //
  //   // Merge the results
  //   List<BookRoomModel> mergedResults = [];
  //   mergedResults.addAll(checkInSnapshot.docs.map((doc) => BookRoomModel.fromJson(doc.data() as Map<String, dynamic>)));
  //   mergedResults.addAll(checkOutSnapshot.docs.map((doc) => BookRoomModel.fromJson(doc.data() as Map<String, dynamic>)));
  //
  //   // Sort the merged results by updatedAt
  //   mergedResults.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
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
