import 'package:destination_hotel/models/hotelModel.dart';
import 'package:destination_hotel/utils/Extensions/Widget_extensions.dart';
import 'package:destination_hotel/utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../main.dart';
import '../../utils/AppConstant.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/Commons.dart';
import '../../utils/Extensions/text_styles.dart';

class HotelComponent extends StatefulWidget {
  final placeId;

  HotelComponent({required this.placeId});

  @override
  HotelComponentState createState() => HotelComponentState();
}

class HotelComponentState extends State<HotelComponent> {
  List<HotelModel> hotelList = [];
  ScrollController _scrollController = ScrollController();

  bool isLast = true;

  int filterRatingLength = 6;
  int selectedRatingIndex = 0;
  bool isReviewExist = false;

  @override
  void initState() {
    super.initState();
    init();
    _scrollController.addListener(() async {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      if (maxScroll == currentScroll) {
        if (!isLast) {
          init();
        }
      }
    });
  }

  void init({double? rating}) async {
    appStore.setLoading(true);

    await hotelService.getHotelsByPlaceId(id: widget.placeId).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      hotelList.addAll(value);
      print(hotelList);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 16),
        child: Stack(
          children: [
            hotelList.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.all(16),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: hotelList.length,
                    itemBuilder: (context, index) {
                      HotelModel mData = hotelList[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            child: cachedImage(mData.image.validate(),
                                    fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(5),
                          ),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(mData.name.validate(),
                                  style: boldTextStyle(
                                    size: 17,
                                  )),
                              Text(
                                "Like a ${mData.starId!.validate().toString().substring(0, 1)}"
                                "⭐",
                                style: secondaryTextStyle(),
                              ),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${mData.address.toString()}",
                                      style: secondaryTextStyle()),
                                  4.height,
                                  Text(
                                      "${mData.distance!.toString()} km away",
                                      style: primaryTextStyle()),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  MapsLauncher.launchCoordinates(
                                      mData.latitude.validate(),
                                      mData.longitude.validate());
                                },
                                child: CircleAvatar(
                                  child: Icon(Icons.location_pin,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(height: 24);
                    },
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().visible(appStore.isLoading),
          ],
        ),
      );
    });
  }
}