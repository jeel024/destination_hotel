import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/CityModel.dart';
import '../services/BaseService.dart';

import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';

class CityService extends BaseService {
  CityService() {
    ref = db.collection('city');
  }

  Future<List<CityModel>> getCity() {
    return ref!.where(CommonKeys.status,isEqualTo: 1).orderBy(CommonKeys.createdAt, descending: true).get().then((value) => value.docs.map((e) => CityModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<CityModel>> fetchCityList({required List<CityModel> list, String? stateId,}) async {
    Query query;

    QuerySnapshot querySnapshot;
    List<CityModel> filterList = [];

    if(stateId != null){
      query = ref!.where(PlaceKeys.stateId, isEqualTo: stateId).orderBy(CommonKeys.createdAt, descending: true);
    }
    else
      {
        query = ref!.orderBy(CommonKeys.createdAt, descending: true);

      }
    if (list.isEmpty) {
      querySnapshot = await query.limit(perPageLimit).get();

    } else {
      querySnapshot = await query.startAfterDocument(await ref!.doc(list[list.length - 1].id).get()).limit(perPageLimit).get();
    }

    List<CityModel> data = querySnapshot.docs.map((e) => CityModel.fromJson(e.data() as Map<String, dynamic>)).toList();

    /// Eliminate duplicate data
    for (int i = 0; i < data.length; i++) {
      if (!list.any((element) => element.id == data[i].id)) {
        filterList.add(data[i]);
      }
    }

    return filterList;
  }

  Future<int> totalCity({required String id}) {
    return ref!.where(PlaceKeys.stateId , isEqualTo: id).get().then((x) => x.docs.length);
  }
}
