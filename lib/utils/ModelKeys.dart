class CommonKeys {
  static String id = 'id';
  static String status = 'status';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';
}
class BookRoomKeys{
  static String roomId = "roomId";
  static String paymentId = "paymentId";
  static String mobile = "mobile";
  static String amount = "amount";
  static String proof = "proof";
  static String checkInDate = "checkInDate";
  static String checkOutDate = "checkOutDate";
}
class UserKeys {
  static String name = 'name';
  static String email = 'email';
  static String contactNo = 'contactNo';
  static String profileImg = 'profileImg';
  static String loginType = 'loginType';
  static String isAdmin = 'isAdmin';
  static String isDemoAdmin = "isDemoAdmin";
  static String favouritePlacesList = 'favouritePlacesList';
  static String fcmToken = 'fcmToken';
}

class CategoryKeys {
  static String name = "name";
  static String image = "image";
}

class StateKeys {
  static String name = "name";
  static String image = "image";
}

class PlaceKeys {
  static String categoryId = "categoryId";
  static String name = "name";
  static String image = "image";
  static String stateId = "stateId";
  static String cityId = "cityId";
  static String hotelId = "hotelId";
  static String quantity = "quantity";
  static String price = "price";
  static String facilities = "facilities";
  static String address = "address";
  static String secondaryImages = "secondaryImages";
  static String favourites = "favourites";
  static String rating = 'rating';
  static String description = 'description';
  static String caseSearch = 'caseSearch';
  static String latitude = 'latitude';
  static String longitude = 'longitude';
  static String userId = 'userId';
  static String placeId = 'placeId';
  static String starId = 'starId';
  static String distance = 'distance';
}

class PlacesRequestKeys{
  static String userId = "userId";
  static String placeData = "placeData";
}

class ReviewKeys {
  static String comment = 'comment';
  static String placeId = 'placeId';
  static String updatedAt = 'updatedAt';
  static String userId = 'userId';
  static String rating = 'rating';
}

class DashboardKeys {
  static String latestPlaces = 'latestPlaces';
  static String popularPlaces = 'popularPlaces';
  static String categoryPlaces = 'categoryPlaces';
  static String category = "category";
  static String places = "places";
  static String nearByPlaces = 'nearByPlaces';
}
