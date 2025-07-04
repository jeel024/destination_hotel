import 'dart:io';
import 'package:destination_hotel/models/CityModel.dart';
import 'package:destination_hotel/models/hotelModel.dart';

import '../components/SendNotification.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/CategoryModel.dart';
import '../models/PlaceModel.dart';
import '../models/StateModel.dart';
import '../services/FileStorageService.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import 'GoogleMapScreen.dart';

class AddHotelScreen extends StatefulWidget {
  final PlaceModel? placeModel;
  final Function()? onUpdate;

  AddHotelScreen({this.placeModel,this.onUpdate});

  @override
  AddHotelScreenState createState() => AddHotelScreenState();
}

class AddHotelScreenState extends State<AddHotelScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController hotelNameController = TextEditingController();
  TextEditingController placeAddressController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController distanceController = TextEditingController();

  List<CategoryModel> categoryList = [];
  List<PlaceModel> placeList = [];
  List<StateModel> stateList = [];
  List starList = ["3 Star","5 Star","7 Star"];
  String? categoryId;
  String? starId;
  String? placeId;
  
  

  XFile? primaryImage;
  List<XFile> secondaryImages = [];
  
  HotelModel hotelModel = HotelModel();

  bool isUpdate = false;
  int status = 1;

  LatLng? latLng;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    placeList = await placeService.getPlaces();

    print(getStringAsync(USER_EMAIL));
    hotelModel = await hotelService.userByEmail(getStringAsync(USER_EMAIL));
    
    isUpdate = true;//widget.placeModel != null;
    if (isUpdate) {
      hotelNameController.text = hotelModel.name.validate();
      distanceController.text = hotelModel.distance.toString();
      status = hotelModel.status.validate();
      starId = hotelModel.starId;
     
      
      
      if (placeList.any((element) => element.id == hotelModel.placeId)) {
        placeId = hotelModel.placeId.validate();
      }
      placeAddressController.text = hotelModel.address.validate();
      latLng = LatLng(hotelModel.latitude.validate(), hotelModel.longitude.validate());
      descriptionController.text = hotelModel.description.validate();
    }
    setState(() {});
  }

  Future<void> save() async {
    appStore.setLoading(true);

    hotelModel.userId = getStringAsync(USER_ID);
    hotelModel.name = hotelNameController.text.trim();
    hotelModel.distance = distanceController.text.trim();
    hotelModel.updatedAt = DateTime.now();
    hotelModel.status = status;
    hotelModel.address = placeAddressController.text.trim();
    hotelModel.latitude = double.parse(latLng!.latitude.toStringAsFixed(5));
    hotelModel.longitude = double.parse(latLng!.longitude.toStringAsFixed(5));
    hotelModel.placeId = placeId;
    hotelModel.starId = starId;
    hotelModel.caseSearch = hotelNameController.text.trim().setSearchParam();
    hotelModel.description = descriptionController.text.trim();
    hotelModel.favourites = 0;
    hotelModel.rating = 0;
print("object");
    if (isUpdate) {
      hotelModel.id = hotelModel.id;
      hotelModel.createdAt = hotelModel.createdAt;
      hotelModel.image = hotelModel.image;
      hotelModel.secondaryImages = hotelModel.secondaryImages;
      hotelModel.favourites = hotelModel.favourites ?? 0;
      hotelModel.rating = hotelModel.rating ?? 0;
    } else {
      hotelModel.createdAt = DateTime.now();
    }

    if (primaryImage != null) {
      await uploadFile(bytes: await primaryImage!.readAsBytes(), prefix: mPlacesStoragePath).then((path) async {
        hotelModel.image = path;
      }).catchError((e) {
        toast(e.toString());
      });
    }

    if (secondaryImages.isNotEmpty) {
      List<String> list = [];
      Future.forEach(secondaryImages, (XFile element) async {
        await uploadFile(bytes:await element.readAsBytes(), prefix: mPlacesStoragePath).then((path) async {
          list.add(path);
        }).catchError((e) {
          toast(e.toString());
        });
      }).then((value) async {
        hotelModel.secondaryImages = list;
        await addHotel(hotelModel);
      });
    } else {
      await addHotel(hotelModel);
    }
  }

  Future addHotel(HotelModel hotelModel) async {
    if (isUpdate) {
      await hotelService.updateDocument(hotelModel.toJson(), hotelModel.id).then((value) {
        appStore.setLoading(false);
        finish(context);
        toast("Hotel Updated");
        widget.onUpdate?.call();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      await hotelService.addDocument(hotelModel.toJson()).then((value) async {
        appStore.setLoading(false);
        finish(context);
        toast("Hotel Added");
        widget.onUpdate?.call();
         if (getBoolAsync(IS_NOTIFICATION_ON, defaultValue: defaultIsNotificationOn)) {
           await userService.getUsers().then((value) {
             if(value.isNotEmpty){
               value.forEach((element) {
                 // if(element.fcmToken!=null && element.fcmToken!.isNotEmpty){
                 //   sendPushMessageToWeb(element.fcmToken!,hotelModel.name.validate(),catName);
                 // }
               });
             }
           }).catchError((e){
             log(e);
           });
         }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget getPrimaryImage() {
    if (primaryImage != null) {
      return Image.file(File(primaryImage!.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center);
    } else if (isUpdate && hotelModel.image.validate().isNotEmpty) {
      return cachedImage(hotelModel.image.validate(), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center);
    } else {
      return SizedBox(height: 100);
    }
  }

  Widget getSecondaryImages() {
    if (secondaryImages.isNotEmpty) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: secondaryImages.map((image) {
          return Stack(
            children: [
              Image.file(File(image.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.highlight_remove, color: Colors.white).onTap(() {
                  secondaryImages.remove(image);
                  setState(() {});
                }),
              )
            ],
          );
        }).toList(),
      );
    } else if (isUpdate && (hotelModel.secondaryImages ?? []).isNotEmpty) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: hotelModel.secondaryImages!.map((image) {
          return Stack(
            children: [
              cachedImage(image, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center),
              Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.highlight_remove, color: Colors.white).onTap(() async {
                    hotelModel.secondaryImages!.remove(image);
                    setState(() {});
                  })),
            ],
          );
        }).toList(),
      );
    } else {
      return SizedBox(height: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Hotel")),
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: ScrollController(),
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hotel Name", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: hotelNameController,
                    autoFocus: false,
                    textFieldType: TextFieldType.NAME,
                    keyboardType: TextInputType.name,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: language.placeName),
                  )
                  ,
                  16.height,
                  Text("Distance", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: distanceController,
                    autoFocus: false,
                    textFieldType: TextFieldType.PHONE,
                    keyboardType: TextInputType.number,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: language.placeName),
                  ),
                  16.height,
                  Text("Place", style: primaryTextStyle()),
                  8.height,
                  placeList.isNotEmpty
                      ? DropdownButtonFormField<String>(
                          dropdownColor: Theme.of(context).cardColor,
                          value: placeId,
                          decoration: commonInputDecoration(),
                          items: placeList.map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name.validate(), style: primaryTextStyle()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            placeId = value!;
                            setState(() {});
                          },
                          validator: (s) {
                            if (s == null) return errorThisFieldRequired;
                            return null;
                          },
                        )
                      : Text(language.noDataFound, style: primaryTextStyle(size: 14)),16.height,
                  Text("Rating", style: primaryTextStyle()),
                  8.height,
                  starList.isNotEmpty
                      ? DropdownButtonFormField<String>(
                          dropdownColor: Theme.of(context).cardColor,
                          value: starId,
                          decoration: commonInputDecoration(),
                          items: starList.map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item, style: primaryTextStyle()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            starId = value!;
                            setState(() {});
                          },
                          validator: (s) {
                            if (s == null) return errorThisFieldRequired;
                            return null;
                          },
                        )
                      : Text(language.noDataFound, style: primaryTextStyle(size: 14)),
                  16.height,
                  Text(language.placeAddress, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: placeAddressController,
                    autoFocus: false,
                    maxLines: 3,
                    minLines: 3,
                    readOnly: true,
                    textFieldType: TextFieldType.ADDRESS,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: language.placeAddress),
                    onTap: () async {
                      PickResult? result = await GoogleMapScreen().launch(context);
                      if(result!=null) {
                        placeAddressController.text = result.formattedAddress.validate();
                        latLng = LatLng(result.geometry!.location.lat.validate(), result.geometry!.location.lng.validate());
                        setState(() {});
                      }
                    },
                  ),
                  16.height,
                  Text(language.description, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: descriptionController,
                    autoFocus: false,
                    maxLines: 5,
                    minLines: 5,
                    textFieldType: TextFieldType.OTHER,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: language.description),
                  ),
                  16.height,
                  Text(language.primaryImage, style: primaryTextStyle()),
                  8.height,
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: radius(defaultRadius),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButtonWidget(
                              child: Text(language.browse, style: primaryTextStyle(color: Colors.white)),
                              color: primaryColor.withOpacity(0.5),
                              hoverColor: primaryColor,
                              splashColor: primaryColor,
                              focusColor: primaryColor,
                              elevation: 0,
                              onTap: () async {
                                primaryImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
                                setState(() {});
                              },
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            ),
                            16.width,
                            Text(language.clear, style: primaryTextStyle(decoration: TextDecoration.underline)).onTap(() async {
                              if (primaryImage != null) {
                                primaryImage = null;
                              } else if (isUpdate && hotelModel.image != null) {
                                hotelModel.image = null;
                                setState(() {});
                              }
                              setState(() {});
                            }),
                          ],
                        ),
                        8.height,
                        getPrimaryImage(),
                      ],
                    ),
                  ),
                  16.height,
                  Text(language.secondaryImages, style: primaryTextStyle()),
                  8.height,
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: radius(defaultRadius),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButtonWidget(
                              child: Text(language.browse, style: primaryTextStyle(color: Colors.white)),
                              elevation: 0,
                              color: primaryColor.withOpacity(0.5),
                              hoverColor: primaryColor,
                              splashColor: primaryColor,
                              focusColor: primaryColor,
                              onTap: () async {
                                secondaryImages = await ImagePicker().pickMultiImage(imageQuality: 100);
                                setState(() {});
                              },
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            ),
                            16.width,
                            Text(language.clear, style: primaryTextStyle(decoration: TextDecoration.underline)).onTap(() async {
                              if (secondaryImages.isNotEmpty) {
                                secondaryImages = [];
                                setState(() {});
                              } else if (isUpdate && hotelModel.secondaryImages != null) {
                                hotelModel.secondaryImages = [];
                                setState(() {});
                              }
                            }),
                          ],
                        ),
                        8.height,
                        getSecondaryImages(),
                      ],
                    ),
                  ),
                  24.height,
                  Align(
                      alignment: Alignment.center,
                      child: dialogPrimaryButton(language.save, () {
                        if (formKey.currentState!.validate()) {
                          print("object");

                          if(latLng==null) return toast(language.enterValidAddress);
                          if (primaryImage != null || (isUpdate && hotelModel.image != null)) {
                            save();
                          } else {
                            toast(language.selectPrimaryImage);
                          }
                        }
                      }))
                ],
              ),
            ),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
