import 'package:destination_hotel/models/RoomModel.dart';
import 'package:destination_hotel/screens/BookedRoom.dart';
import 'package:destination_hotel/utils/Extensions/Colors.dart';
import 'package:destination_hotel/utils/Extensions/Widget_extensions.dart';
import 'package:destination_hotel/utils/Extensions/int_extensions.dart';
import 'package:destination_hotel/utils/Extensions/shared_pref.dart';
import 'package:destination_hotel/utils/Extensions/text_styles.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/BookRoomModel.dart';
import '../utils/Common.dart';
import '../utils/AppConstant.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchCont = TextEditingController();
  List<RoomModel>? roomList;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    init(DateTime.now());
  }

  List<DateTime> dateRangesFormat = [];

  List<String> generateDateRanges(int numberOfDays) {
    List<String> dateRanges = [];

    DateTime today = DateTime.now().subtract(Duration(days: 15));

    for (int i = 0; i < numberOfDays; i++) {
      dateRangesFormat.add(today.add(Duration(days: i)));
      DateTime currentDate = today.add(Duration(days: i));
      DateTime nextDate = currentDate.add(Duration(days: 1));
      String formattedCurrentDate = DateFormat('dd-MMM').format(currentDate);
      String formattedNextDate = DateFormat('dd-MMM').format(nextDate);
      dateRanges.add('$formattedCurrentDate - $formattedNextDate');
    }

    return dateRanges;
  }

  List<List<BookRoomModel>> listOfRooms = [];

  List bookedRooms = [];

  double amount = 0;

  void init(DateTime date) async {
    amount = 0;
    bookedRooms = [];
    listOfRooms = [];
    appStore.setLoading(true);
    await roomService
        .getRoomsByHotelId(id: getStringAsync(USER_ID))
        .then((value) async {
      appStore.setLoading(false);
      roomList = value;
      for (RoomModel i in roomList ?? []) {
        await bookRoomService
            .getBookRooms(id: i.id.toString(), checkInDate: date)
            .then(
          (value) {
            listOfRooms.add(value);
          },
        );
      }

      for (int j = 0; j < listOfRooms.length; j++) {
        bookedRooms.add(0);
        for (BookRoomModel i in listOfRooms[j]) {
          bookedRooms[j] += i.quantity;
          amount += i.amount!.toDouble();
        }
      }

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      children: [
        FilterWidget(dateRanges: generateDateRanges(30)),
        appStore.isLoading
            ? loaderWidget()
            : roomList != null
                ? Column(
                    children: [
                      10.height,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                            color: cardDarkColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Text(
                              "₹ ${amount}",
                              style: primaryTextStyle(size: 25),
                            ),
                            10.height,
                            Text("Total Earnings"),
                          ],
                        ),
                      ),
                      14.height,
                      Column(
                        children: List.generate(
                            roomList!.length,
                            (index) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      roomList![index].name ?? "",
                                      style: primaryTextStyle(),
                                    ),
                                    10.height,
                                    GestureDetector(
                                      onTap: () {
                                        BookedRoom(
                                          roomName: roomList![index].name ?? "",
                                          bookRoomList: listOfRooms[index],
                                        ).launch(context);
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                color: cardDarkColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    bookedRooms[index]
                                                        .toString(),
                                                    style: primaryTextStyle()),
                                                8.height,
                                                Text("Booked Rooms",
                                                    style: primaryTextStyle()),
                                              ],
                                            ),
                                          )),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                color: cardDarkColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    roomList![index]
                                                        .quantity
                                                        .toString(),
                                                    style: primaryTextStyle()),
                                                8.height,
                                                Text("Total Rooms",
                                                    style: primaryTextStyle()),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    20.height
                                  ],
                                )),
                      ),
                    ],
                  )
                : emptyWidget()
      ],
    );
  }

  Widget FilterWidget({required List dateRanges}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(
              dateRanges.length,
              (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        selectedDate = dateRangesFormat[index];
                        print(dateRangesFormat[index]);
                        appStore.setLoading(true);
                        setState(() {});

                        init(dateRangesFormat[index]);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: dateRangesFormat[index] != selectedDate
                            ? Colors.black
                            : Colors
                                .white, // Set button background color to green
                      ),
                      child: Text(
                        dateRanges[index],
                        style: TextStyle(
                            color: dateRangesFormat[index] == selectedDate
                                ? Colors.black
                                : Colors.white),
                      ),
                    ),
                  ))),
    );
  }
}
