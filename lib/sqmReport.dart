// ignore_for_file: prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("Week"), value: "week"),
    DropdownMenuItem(child: Text("Month"), value: "month"),
    DropdownMenuItem(child: Text("Year"), value: "year"),
  ];
  return menuItems;
}

class SQMReport extends StatefulWidget {
  const SQMReport({super.key});

  @override
  State<SQMReport> createState() => _SQMReportState();
}

class _SQMReportState extends State<SQMReport> {
  String selectedValue = 'week';
  var firestore = FirebaseFirestore.instance;
  List data = [];

  getMarker() async {
    var snapshot = await firestore.collection('jobs').get();

    //get all data
    var y = snapshot.docs.map((e) => e.data());
    var x = y.toList();

    x.forEach((element) {
      print(element['weekOfYear']);
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Sqm Report')),
      body: Column(children: [
        Center(
          child: SizedBox(
              width: media.width * 0.5,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type Year',
                ),
              )),
        ),
        DropdownButton(
          value: selectedValue,
          items: dropdownItems,
          onChanged: (value) {
            setState(() {
              selectedValue = value!;
            });
          },
        ),
        ElevatedButton(
            onPressed: (() {
              getMarker();
            }),
            child: const Text('Generate')),
        ElevatedButton(
          onPressed: (() {
            Navigator.of(context).pushNamed('form');
          }),
          child: const Text('New Job'),
        ),
      ]),
    );
  }
}
