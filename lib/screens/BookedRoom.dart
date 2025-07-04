import 'package:destination_hotel/screens/ZoomImageScreen.dart';
import 'package:destination_hotel/utils/AppColor.dart';
import 'package:destination_hotel/utils/Extensions/Colors.dart';
import 'package:destination_hotel/utils/Extensions/Widget_extensions.dart';
import 'package:destination_hotel/utils/Extensions/int_extensions.dart';
import 'package:destination_hotel/utils/Extensions/text_styles.dart';
import 'package:flutter/material.dart';

import '../models/BookRoomModel.dart';

class BookedRoom extends StatefulWidget {
  List<BookRoomModel>? bookRoomList;
  String? roomName;

  BookedRoom({required this.bookRoomList, required this.roomName});

  @override
  State<BookedRoom> createState() => _BookedRoomState();
}

class _BookedRoomState extends State<BookedRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName.toString()),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children:
            List.generate(widget.bookRoomList!.length, (index) {
              BookRoomModel data = widget.bookRoomList![index];
              return Container(padding: EdgeInsets.all(15),margin: EdgeInsets.all(8),decoration: BoxDecoration(color: cardDarkColor,borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Guest Name",style: primaryTextStyle(size: 12),),
                  Text(data.name.toString()),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Mobile No.",style: primaryTextStyle(size: 12),),
                            Text("${data.mobile!.toString()}"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Number Of Rooms",style: primaryTextStyle(size: 12),),
                            Text("${data.quantity!.toString()}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CheckIn Date ",style: primaryTextStyle(size: 12),),
                            Text("${data.checkInDate!.day.toString()}"+"-${data.checkInDate!.month.toString()}-"+"${data.checkInDate!.year.toString()}"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("CheckOut Date ",style: primaryTextStyle(size: 12),),
                            Text("${data.checkOutDate!.day.toString()}"+"-${data.checkOutDate!.month.toString()}-"+"${data.checkOutDate!.year.toString()}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Payment Id",style: primaryTextStyle(size: 12),),
                            Text("${data.paymentId!.toString()}"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Proof",style: primaryTextStyle(size: 12),),
                            2.height,
                            InkWell(onTap: () {
                              ZoomImageScreen(image: data.proof,).launch(context);
                            },child: Icon(Icons.downloading_outlined))
                          ],
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            );
            }),
      ),
    );
  }
}
