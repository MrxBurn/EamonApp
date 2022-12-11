// ignore_for_file: unused_import, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eamon_app/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

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

  DateTime confirmedDateValue = DateTime.now();
  String confirmedGeolocationValue = '';

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
  _pickImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  }

  //Add data on submission
  _submitData(double workedHours) {
    jobs.add({
      'dateTime': dateValue,
      'geolocation': geolocationValue,
      'docketNumber': docketNumberValue,
      'notes': notesValue,
      'serviceCallValue': serviceCallValue,
      'sqmValue': sqmValue,
      'confirmedDate': confirmedDateValue,
      'confirmedGeolocationValue': confirmedGeolocationValue,
      'hoursWorked': workedHours
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
      body: Center(
          child: Container(
        width: media.width * 0.5,
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              onTap: () {
                dateValue = DateTime.now();
                startDateTimeText.text = dateValue.toString();
              },
              controller: startDateTimeText,
              validator: ((value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Date & Time';
                }
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Date & Time',
                hintText: 'Press to add date',
              ),
            ),
            TextFormField(
              onTap: () {
                _determinePosition().then((value) => {
                      startGeolocationText.text = value.toString(),
                      geolocationValue = value.toString()
                    });
              },
              controller: startGeolocationText,
              validator: ((value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter geolocation';
                }
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Geolocation',
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
            // TODO: Add photo upload feature for docket
            ElevatedButton(
                onPressed: () {
                  _pickImage();
                },
                child: const Text('Upload photo')),
            // TODO: Upload photos of damage
            TextFormField(
              validator: ((value) {
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
            // TODO: Add photo upload of each item fitted
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
                  endDateTimeText.text = confirmedDateValue.toString();

                  setState(() {
                    _determinePosition().then((value) => {
                          endGeolocationText.text = value.toString(),
                          confirmedGeolocationValue = endGeolocationText.text
                        });
                  });
                },
                child: const Text('Finish Job')),
            TextFormField(
              enabled: false,
              controller: endDateTimeText,
              validator: ((value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Date & Time';
                }
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Date & Time',
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
                  labelText: 'Geolocation',
                )),

            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  //calculate number of hours worked
                  final hours =
                      confirmedDateValue.difference(dateValue).inMinutes / 60;
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Loading, please wait')));

                    _submitData(hours);
                  }
                },
                child: const Text('Submit')),
          ]),
        ),
      )),
    );
  }
}
