import 'dart:io';

import '../models/RoomModel.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class AddRoomScreen extends StatefulWidget {
  final RoomModel? roomModel;
  final Function()? onUpdate;

  AddRoomScreen({this.roomModel,this.onUpdate});

  @override
  AddRoomScreenState createState() => AddRoomScreenState();
}

class AddRoomScreenState extends State<AddRoomScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController roomNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController numberOfRoomController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  List<TextEditingController> facilityList = [];

  List<CategoryModel> categoryList = [];
  List<PlaceModel> placeList = [];
  List<StateModel> stateList = [];
  List starList = ["3 Star","5 Star","7 Star"];
  String? categoryId;
  String? starId;
  String? hotelId;

  XFile? primaryImage;
  List<XFile> secondaryImages = [];

  RoomModel roomModel = RoomModel();

  bool isUpdate = false;
  int status = 1;

  LatLng? latLng;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {

    print(getStringAsync(USER_EMAIL));
   // roomModel = await roomService.userByEmail(getStringAsync(USER_EMAIL));

    isUpdate = widget.roomModel != null;

    if (isUpdate) {
      roomModel = widget.roomModel!;
      roomNameController.text = roomModel.name.validate();
      numberOfRoomController.text = roomModel.quantity.toString();
      priceController.text = roomModel.price.toString();
      status = roomModel.status.validate();

      for(var i in roomModel.facilities ?? [])
        {
          facilityList.add(TextEditingController(text: i));
        }

        hotelId = roomModel.hotelId.validate();


      descriptionController.text = roomModel.description.validate();
    }
    else
      {
        hotelId = getStringAsync(USER_ID);
        for(int i =0;i<3;i++)
          {
            facilityList.add(TextEditingController());
          }
        //facilityList = List.filled(3, TextEditingController(),growable: true);
      }
    setState(() {});
  }

  Future<void> save() async {
    appStore.setLoading(true);

    roomModel.name = roomNameController.text.trim();
    roomModel.quantity = numberOfRoomController.text.trim().toInt();
    roomModel.price = priceController.text.trim().toInt();
    roomModel.updatedAt = DateTime.now();
    roomModel.status = status;
    roomModel.hotelId = hotelId;
    roomModel.description = descriptionController.text.trim();
    List facility = [];

    for(TextEditingController i in facilityList  )
    {
        facility.add(i.text);
    }
    roomModel.facilities = List.from(facility);
    print("object");
    if (isUpdate) {
      roomModel.id = roomModel.id;
      roomModel.createdAt = roomModel.createdAt;
      roomModel.image = roomModel.image;
      roomModel.secondaryImages = roomModel.secondaryImages;
    } else {
      roomModel.createdAt = DateTime.now();
    }

    if (primaryImage != null) {
      await uploadFile(bytes: await primaryImage!.readAsBytes(), prefix: mRoomStoragePath).then((path) async {
        roomModel.image = path;
      }).catchError((e) {
        toast(e.toString());
      });
    }

    if (secondaryImages.isNotEmpty) {
      List<String> list = [];
      Future.forEach(secondaryImages, (XFile element) async {
        await uploadFile(bytes:await element.readAsBytes(), prefix: mRoomStoragePath).then((path) async {
          list.add(path);
        }).catchError((e) {
          toast(e.toString());
        });
      }).then((value) async {
        roomModel.secondaryImages = list;
        await addRoom(roomModel);
      });
    } else {
      await addRoom(roomModel);
    }
  }

  Future addRoom(RoomModel roomModel) async {
    if (isUpdate) {
      await roomService.updateDocument(roomModel.toJson(), roomModel.id).then((value) {
        appStore.setLoading(false);
        finish(context);
        toast("Room Updated");
        widget.onUpdate?.call();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      await roomService.addDocument(roomModel.toJson()).then((value) async {
        appStore.setLoading(false);
        finish(context);
        toast("Room Added");
        widget.onUpdate?.call();
        if (getBoolAsync(IS_NOTIFICATION_ON, defaultValue: defaultIsNotificationOn)) {
          await userService.getUsers().then((value) {
            if(value.isNotEmpty){
              value.forEach((element) {
                // if(element.fcmToken!=null && element.fcmToken!.isNotEmpty){
                //   sendPushMessageToWeb(element.fcmToken!,roomModel.name.validate(),catName);
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
    } else if (isUpdate && roomModel.image.validate().isNotEmpty) {
      return cachedImage(roomModel.image.validate(), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center);
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
    } else if (isUpdate && (roomModel.secondaryImages ?? []).isNotEmpty) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: roomModel.secondaryImages!.map((image) {
          return Stack(
            children: [
              cachedImage(image, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center),
              Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.highlight_remove, color: Colors.white).onTap(() async {
                    roomModel.secondaryImages!.remove(image);
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
      appBar: AppBar(title: Text("Room Details")),
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
                  Text("Room Name", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: roomNameController,
                    autoFocus: false,
                    textFieldType: TextFieldType.NAME,
                    keyboardType: TextInputType.name,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Room Name"),
                  ),
                  16.height,
                  Text("Facility Details", style: primaryTextStyle()),
                  Column(children: List.generate(facilityList.length, (index) => Column(
                    children: [
                      12.height,
                      AppTextField(
                        controller: facilityList[index],
                        autoFocus: false,
                        textFieldType: TextFieldType.OTHER,
                        keyboardType: TextInputType.text,
                        errorThisFieldRequired: errorThisFieldRequired,
                        decoration: commonInputDecoration(hintText: "Facility Details"),
                      ),
                    ],
                  )),),
                  16.height,
                  Align(alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        facilityList.add(TextEditingController());
                        setState(() { });
                      },
                      child: Container(padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),border: Border.all(color: primaryColor)),
                        child: Row(mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add),
                            Text(" Add More Details ", style: primaryTextStyle()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  16.height,
                  Text("Number Of Rooms", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: numberOfRoomController,
                    autoFocus: false,
                    textFieldType: TextFieldType.OTHER,
                    keyboardType: TextInputType.number,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Number Of Rooms"),
                  ),16.height,
                  Text("Price", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: priceController,
                    autoFocus: false,
                    textFieldType: TextFieldType.OTHER,
                    keyboardType: TextInputType.number,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Price"),
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
                              } else if (isUpdate && roomModel.image != null) {
                                roomModel.image = null;
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
                              } else if (isUpdate && roomModel.secondaryImages != null) {
                                roomModel.secondaryImages = [];
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

                          if (primaryImage != null || (isUpdate && roomModel.image != null)) {
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
