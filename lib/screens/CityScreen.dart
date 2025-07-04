import 'package:destination_hotel/models/CityModel.dart';

import '../main.dart';
import '../models/StateModel.dart';
import '../screens/ViewAllScreen.dart';
import '../utils/AppImages.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import 'package:flutter/material.dart';

class CityScreen extends StatefulWidget {
  final StateModel stateModel;

  CityScreen({required this.stateModel});

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stateModel.name ?? ""),
        leading:  Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Image.asset(ic_appLogo_transparent, height: 10)),
        centerTitle: true,

      ),

      body: FutureBuilder<List<CityModel>>(
        future: cityService.fetchCityList(list: [],stateId: widget.stateModel.id ?? ""),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null && snapshot.data!.isEmpty) return emptyWidget();
            return AnimationLimiter(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemBuilder: (context, index) {
                  CityModel item = snapshot.data![index];
                  return AnimationConfiguration.staggeredGrid(
                    columnCount: 1,
                    duration: Duration(milliseconds: 1000),
                    position: index,
                    child: ScaleAnimation(
                      scale: 0.5,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            ViewAllScreen(name: item.name.validate(),cityId: item.id).launch(context);

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
    );
  }
}
