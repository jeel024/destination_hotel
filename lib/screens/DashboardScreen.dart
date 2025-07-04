
import '../main.dart';
import '../screens/LogInScreen.dart';
import '../screens/PlaceDetailScreen.dart';
import '../utils/AppConstant.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../utils/AppImages.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../utils/AppColor.dart';
import 'CategoryScreen.dart';
import 'FavouriteScreen.dart';
import 'RoomScreen.dart';
import 'HomeScreen.dart';
import 'SearchScreen.dart';
import 'SettingScreen.dart';
import 'RoomScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final tabs = [];

  @override
  void initState() {
    super.initState();
    init();
    LiveStream().on('UpdateLoginScreen', (p0) {
      tabs.clear();
      init();
      setState(() {});
    });
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification) {
      String? notId = notification.notification.additionalData!["id"];
      if (notId.validate().isNotEmpty) {
        appStore.setSelectedPlaceId(notId.validate());
        PlaceDetailScreen(placeId: notId.toString()).launch(context);
      }
    });
  }

  void init() async {
    tabs.add(HomeScreen());
    tabs.add(RoomScreen());
    tabs.add(SettingScreen());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  BottomNavigationBarItem bottomBarItem(IconData icon) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 22),
      activeIcon: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: !appStore.isLoggedIn && _currentIndex == FAVOURITE_INDEX && !appStore.isDarkMode ? Colors.white : primaryColor, borderRadius: radius(defaultRadius)),
        child: Icon(icon, size: 22),
      ),
      label: "",
    );
  }

  String getTitle() {
    String title = language.appName;
     if (_currentIndex == ROOM_INDEX) {
      title = "Rooms";
    } else if (_currentIndex == SETTING_INDEX) {
      title = language.settings;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_currentIndex != FAVOURITE_INDEX || appStore.isLoggedIn)
          ? AppBar(
              title: Text(getTitle()),
             // leading:  Padding(padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4), child: Image.asset("assets/logo5.png", height: 40,width: 40,)),
            //  centerTitle: true,

            )
          : null,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: !appStore.isLoggedIn && _currentIndex == FAVOURITE_INDEX && !appStore.isDarkMode ? primaryColor : context.cardColor,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        elevation: 5,
        selectedIconTheme: IconThemeData(size: 18),
        selectedItemColor: !appStore.isLoggedIn && _currentIndex == FAVOURITE_INDEX && !appStore.isDarkMode ? primaryColor : Colors.white,
        iconSize: 22,
        unselectedItemColor: !appStore.isLoggedIn && _currentIndex == FAVOURITE_INDEX && !appStore.isDarkMode ? Colors.white : Colors.grey.withOpacity(0.6),
        showSelectedLabels: false,
        items: [
          bottomBarItem(Icons.home_outlined),
          bottomBarItem(Feather.compass),
          bottomBarItem(Icons.settings_outlined),
        ],
        onTap: (index) {
          _currentIndex = index;
          appStore.setLoading(false);
          setState(() {});
        },
      ),
    );
  }
}
