import '../services/AuthServices.dart';
import '../utils/AppConstant.dart';
import '../utils/AppImages.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../components/ThemeDialog.dart';
import '../main.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/SettingItemWidget.dart';
import '../utils/Extensions/text_styles.dart';
import 'AddPlaceScreen.dart';
import 'ChangePasswordScreen.dart';
import 'LogInScreen.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on('UpdateLoginScreen', (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    cachedImage(getStringAsync(USER_PROFILE), fit: BoxFit.cover),
                    8.height,
                    Text(getStringAsync(USER_NAME), style: boldTextStyle(size: 20)),
                    8.height.visible(isLoggedInWithApp()),
                    AppButtonWidget(
                      color: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Edit Hotel Details", style: boldTextStyle(color: whiteColor)),
                          4.width,
                          Icon(Icons.navigate_next, color: whiteColor),
                        ],
                      ),
                      onTap: () {
                        AddHotelScreen().launch(context);
                      },
                    ).visible(isLoggedInWithApp()),
                    24.height,
                  ],
                ).visible(appStore.isLoggedIn),
                Container(
                  height: 35,
                  width: context.width(),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldSecondaryDark : primaryColor.withOpacity(0.2)),
                  child: Text(language.generalSetting, style: boldTextStyle(), textAlign: TextAlign.start),
                ),
                SettingItemWidget(
                  leading: ImageIcon(AssetImage(ic_theme)),
                  title: language.appTheme,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ThemeDialog(onUpdate: () {
                            setStatusBarColorWidget(Colors.transparent);
                            setState(() {});
                          });
                        });
                  },
                ),
                SettingItemWidget(
                  leading: ImageIcon(AssetImage(ic_lock)),
                  title: language.changePassword,
                  onTap: () {
                    ChangePasswordScreen().launch(context);
                  },
                ).visible(appStore.isLoggedIn && isLoggedInWithApp()),
                Container(
                  height: 35,
                  width: context.width(),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldSecondaryDark : primaryColor.withOpacity(0.2)),
                  child: Text(language.others, style: boldTextStyle(), textAlign: TextAlign.start),
                ),
                SettingItemWidget(
                  leading: ImageIcon(AssetImage(ic_privacy)),
                  title: language.privacyPolicy,
                  onTap: () {

                    mLaunchUrl("https://www.freeprivacypolicy.com/live/9c37a77c-1ec7-4b9d-89b9-055fa37aa6fa");
                  },
                ),
                SettingItemWidget(
                  leading: ImageIcon(AssetImage(ic_terms_condition)),
                  title: language.termsAndConditions,
                  onTap: () {
                    mLaunchUrl("https://www.freeprivacypolicy.com/live/1dabc3c3-f0d7-47b0-8cea-3c57a049c6b6");
                  },
                ),
                SettingItemWidget(
                  leading: ImageIcon(AssetImage(ic_help_support)),
                  title: language.helpAndSupport,
                  onTap: () {
                    mLaunchUrl(getStringAsync(HELP_AND_SUPPORT));
                  },
                ),

                SettingItemWidget(
                  leading: ImageIcon(AssetImage(ic_delete_account)),
                  title: "Delete Hotel",
                  onTap: () async {
                    commonConfirmationDialog(context,message: language.deleteAccountMsg, onUpdate: () async {
                      await deleteUser(getStringAsync(USER_EMAIL), getStringAsync(USER_PASSWORD));
                      logout(context);
                    },isDeleteDialog: true);
                  },
                ).visible(appStore.isLoggedIn),
                appStore.isLoggedIn
                    ? SettingItemWidget(
                        leading: ImageIcon(AssetImage(ic_logout)),
                        title: language.logout,
                        onTap: () {
                          commonConfirmationDialog(context,message: language.logoutConfirmation, onUpdate: () async {
                            await logout(context);
                          });
                        },
                      )
                    : SettingItemWidget(
                        leading: ImageIcon(AssetImage(ic_login)),
                        title: language.signIn,
                        onTap: () {
                          LoginScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                        },
                      ),
              ],
            ),
          ),
          Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
        ],
      ),
    );
  }
}
