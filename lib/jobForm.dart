// ignore_for_file: unused_import, file_names, unrelated_type_equality_checks, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eamon_app/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localstorage/localstorage.dart';

class JobForm extends StatefulWidget {
  const JobForm({super.key});

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  //form values
  DateTime dateValue = DateTime.now();
  String geolocationValue = '';
  String docketNumberValue = '';
  String notesValue = '';
  String serviceCallValue = '';
  String sqmValue = '';

  //Docket Images
  List<Uint8List> docketPhotoList = [];
  List<File> docketPhotoNames = [];
  List<String> docketImagesUrl = [];

  //Damaged or Incorrectly Measured Products
  List<Uint8List> damagedPhotoList = [];
  List<File> damagedPhotoNames = [];
  List<String> damagedImagesUrl = [];

  //Fitted Items
  List<Uint8List> fittedItemsPhotoList = [];
  List<File> fittedItemsPhotoNames = [];
  List<String> fittedItemsImagesUrl = [];
  XFile? photo;
  var bytes;

  //All photos required uploaded check
  bool docketPhotosUploaded = false;
  bool fittedItemsPhotosUploaded = false;

  DateTime confirmedDateValue = DateTime.now();
  String confirmedGeolocationValue = '';

  //Local Storage
  LocalStorage localStorage = LocalStorage('jobStart');
  bool isConfirmPressed = false;
  //Form controllers
  final _formKey = GlobalKey<FormState>();
  TextEditingController startDateTimeText = TextEditingController();
  TextEditingController endDateTimeText = TextEditingController();
  TextEditingController startGeolocationText = TextEditingController();
  TextEditingController endGeolocationText = TextEditingController();
  String initialPosition = '';
  String finalPosition = '';
  bool isChecked = false;
  final ImagePicker _picker = ImagePicker();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference jobs = FirebaseFirestore.instance.collection('jobs');

//Geolocation function
  Future<Position> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return position;
  }

  //Image Pick Function
  _pickImage(List photos, List photoNames) async {
    //get the photo from camera
    photo = await _picker.pickImage(source: ImageSource.camera);
    photoNames.add(File(photo!.name));
    bytes = await XFile(photo!.path).readAsBytes();
    //add the photo to list of photos
    setState(() {
      photos.add(bytes);
    });
  }

  //Add data on submission

  //Upload images
  _uploadImgAndSubmit(
      List<Uint8List?> pDocketPhotos,
      List<Uint8List?> pDamagedPhotos,
      List<Uint8List?> pFittedItemsPhotos,
      double workedHours) async {
    if (pDocketPhotos.isNotEmpty) {
      for (int i = 0; i < pDocketPhotos.length; i++) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('docketPhotos/${docketPhotoNames[i]}');
        TaskSnapshot taskSnapshot = await storageRef.putData(
            pDocketPhotos[i]!,
            SettableMetadata(
              contentType: "image/jpeg",
            ));
        docketImagesUrl.add(await (taskSnapshot).ref.getDownloadURL());
      }
    }
    if (pDamagedPhotos.isNotEmpty) {
      for (int i = 0; i < pDamagedPhotos.length; i++) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('damaged_incorrectly_products/${damagedPhotoNames[i]}');
        TaskSnapshot taskSnapshot = await storageRef.putData(
            pDamagedPhotos[i]!,
            SettableMetadata(
              contentType: "image/jpeg",
            ));
        damagedImagesUrl.add(await (taskSnapshot).ref.getDownloadURL());
      }
    }
    if (pFittedItemsPhotos.isNotEmpty) {
      fittedItemsPhotosUploaded = true;
      for (int i = 0; i < pFittedItemsPhotos.length; i++) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('fitted_items/${fittedItemsPhotoNames[i]}');
        TaskSnapshot taskSnapshot = await storageRef.putData(
            pFittedItemsPhotos[i]!,
            SettableMetadata(
              contentType: "image/jpeg",
            ));
        fittedItemsImagesUrl.add(await (taskSnapshot).ref.getDownloadURL());
      }
    }

    jobs.add({
      'dateTime': dateValue,
      'geolocation': geolocationValue,
      'docketNumber': docketNumberValue,
      'notes': notesValue,
      'serviceCallValue': serviceCallValue == true ? serviceCallValue : false,
      'sqmValue': sqmValue,
      'confirmedDate': confirmedDateValue,
      'confirmedGeolocationValue': confirmedGeolocationValue,
      'hoursWorked': workedHours,
      'docketImages': docketImagesUrl,
      'fittedImages': fittedItemsImagesUrl,
      'damagedImages': damagedImagesUrl,
      'weekOfYear': Jiffy(confirmedDateValue).week,
      'year': Jiffy(confirmedDateValue).year,
      'month': Jiffy(confirmedDateValue).month
    });
  }

  @override
  void initState() {
    super.initState();

    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: const Text('Form')),
        body: SingleChildScrollView(
          child: FutureBuilder(
              future: localStorage.ready,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  if (localStorage.getItem('buttonPressed') != null &&
                      localStorage.getItem('startTime') != null) {
                    isConfirmPressed = localStorage.getItem('buttonPressed');
                    startDateTimeText.text = localStorage.getItem('startTime');
                    startGeolocationText.text =
                        localStorage.getItem('startLocation');
                  }
                  return Center(
                      child: Container(
                    width: media.width * 0.5,
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        ElevatedButton(
                            onPressed: isConfirmPressed == false
                                ? () {
                                    dateValue = DateTime.now();
                                    startDateTimeText.text =
                                        dateValue.toString();

                                    localStorage.setItem(
                                        'startTime', dateValue.toString());
                                    _determinePosition().then((value) => {
                                          geolocationValue = value.toString(),
                                          startGeolocationText.text =
                                              geolocationValue,
                                          localStorage.setItem('startLocation',
                                              geolocationValue),
                                        });
                                    //confirm button already pressed logic
                                    isConfirmPressed = true;
                                    localStorage.setItem(
                                        'buttonPressed', isConfirmPressed);
                                  }
                                : null,
                            child: const Text('Confirm Time & Geolocation')),
                        TextFormField(
                          enabled: false,
                          controller: startDateTimeText,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Date & Time';
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Start Date & Time',
                          ),
                        ),
                        TextFormField(
                          enabled: false,
                          onTap: () {},
                          controller: startGeolocationText,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter geolocation';
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Start Geolocation',
                            hintText: 'Press to add geolocation',
                          ),
                        ),
                        TextFormField(
                          onChanged: (value) {
                            docketNumberValue = value;
                          },
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Docker Number';
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Docket Number',
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: docketPhotoList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Card(
                                      child:
                                          Image.memory(docketPhotoList[index])),
                                );
                              }),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pickImage(docketPhotoList, docketPhotoNames);
                            },
                            child: const Text('Upload Docket')),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: damagedPhotoList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Card(
                                      child: Image.memory(
                                          damagedPhotoList[index])),
                                );
                              }),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pickImage(damagedPhotoList, damagedPhotoNames);
                            },
                            child: const Text('Upload Damaged&Incorrect')),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fittedItemsPhotoList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Card(
                                      child: Image.memory(
                                          fittedItemsPhotoList[index])),
                                );
                              }),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pickImage(
                                  fittedItemsPhotoList, fittedItemsPhotoNames);
                            },
                            child: const Text('Upload Fitted')),
                        CheckboxListTile(
                          title: const Text("Service Call"), //    <-- label
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                            serviceCallValue = value.toString();
                          },
                        ),
                        isChecked == false
                            ? TextFormField(
                                onChanged: (value) {
                                  sqmValue = value;
                                },
                                validator: ((value) {
                                  return null;
                                }),
                                decoration: const InputDecoration(
                                  labelText: 'Sqm Value',
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              confirmedDateValue = DateTime.now();
                              endDateTimeText.text =
                                  confirmedDateValue.toString();
                              setState(() {
                                _determinePosition().then((value) => {
                                      endGeolocationText.text =
                                          value.toString(),
                                      confirmedGeolocationValue =
                                          endGeolocationText.text
                                    });
                              });
                            },
                            child: const Text('Finish Job')),
                        TextFormField(
                          enabled: true,
                          controller: endDateTimeText,
                          validator: ((value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Date & Time';
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'End Date & Time',
                          ),
                        ),
                        TextFormField(
                            enabled: false,
                            controller: endGeolocationText,
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return 'Please finish job';
                              }
                              return null;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Confirmed Geolocation',
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              //calculate number of hours worked
                              final hours = confirmedDateValue
                                      .difference(dateValue)
                                      .inMinutes /
                                  60;
                              if (_formKey.currentState!.validate()) {
                                if (docketPhotoList.isNotEmpty &&
                                    fittedItemsPhotoList.isNotEmpty) {
                                  docketPhotosUploaded = true;
                                  fittedItemsPhotosUploaded = true;
                                } else {
                                  docketPhotosUploaded = false;
                                  fittedItemsPhotosUploaded = false;
                                }

                                if (docketPhotosUploaded == true &&
                                    fittedItemsPhotosUploaded == true) {
                                  _uploadImgAndSubmit(
                                      docketPhotoList,
                                      damagedPhotoList,
                                      fittedItemsPhotoList,
                                      hours);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: const Text(
                                              'Uploaded Successfully!'),
                                          action: SnackBarAction(
                                              textColor: Colors.green,
                                              label: 'Success',
                                              onPressed: () {})));
                                  //Navigate to Home Page
                                  //Delete local storage

                                  localStorage.deleteItem('buttonPressed');

                                  localStorage.deleteItem('startTime');

                                  localStorage.deleteItem('startLocation');
                                  Navigator.of(context)
                                      .pushReplacementNamed('home');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: const Text(
                                            'Please upload docket and/or items fitted photos'),
                                        action: SnackBarAction(
                                            textColor: Colors.red,
                                            label: 'Error',
                                            onPressed: () {})),
                                  );
                                }
                              }
                            },
                            child: const Text('Submit')),
                      ]),
                    ),
                  ));
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ));
  }
}
