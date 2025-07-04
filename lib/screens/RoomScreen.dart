import 'package:destination_hotel/models/RoomModel.dart';
import 'package:destination_hotel/screens/CityScreen.dart';
import 'package:destination_hotel/utils/AppColor.dart';
import 'package:destination_hotel/utils/AppConstant.dart';
import 'package:destination_hotel/utils/Extensions/shared_pref.dart';

import '../main.dart';
import '../models/StateModel.dart';
import '../screens/ViewAllScreen.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import 'package:flutter/material.dart';

import 'AddRoomScreen.dart';

class RoomScreen extends StatefulWidget {
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<RoomModel>>(
        future: roomService.getRoomsByHotelId(id: getStringAsync(USER_ID)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null && snapshot.data!.isEmpty) return emptyWidget();
            return AnimationLimiter(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemBuilder: (context, index) {
                  RoomModel item = snapshot.data![index];
                  return AnimationConfiguration.staggeredGrid(
                    columnCount: 1,
                    duration: Duration(milliseconds: 1000),
                    position: index,
                    child: ScaleAnimation(
                      scale: 0.5,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            AddRoomScreen(roomModel:  item,).launch(context);
                         //   ViewAllScreen(name: item.name.validate(),stateId: item.id).launch(context);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              cachedImage(
                                item.image.validate(),
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(defaultRadius),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: radius(defaultRadius),
                                    border: Border.all(color: appStore.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.transparent),
                                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.9),
                                    ])),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  item.name.validate(),
                                  style: boldTextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ).paddingOnly(bottom: 8, left: 8, right: 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasData) {
            return errorWidget(text: snapshot.error.toString());
          } else {
            return loaderWidget();
          }
        },
      ),
      floatingActionButton: GestureDetector(onTap: () {
        AddRoomScreen().launch(context);
      },child: Container(padding: EdgeInsets.all(12),decoration: BoxDecoration(color: primaryColor,borderRadius: BorderRadius.circular(10)),child: Text("Add Room"))),
    );
  }
}
