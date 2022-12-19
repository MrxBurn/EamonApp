// ignore_for_file: prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
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
  List<int> weeks = [];
  var dates = <Map<String, dynamic>>[];

  var firestore = FirebaseFirestore.instance;

  getMarker() async {
    var snapshot = await firestore.collection('jobs').get();

    //get all data
    var data = snapshot.docs.map((e) => e.data());
    var datesData = data.toList();

    for (var element in datesData) {
      dates.add(
          {'week': element['weekOfYear'], 'sqmValue': element['sqmValue']});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (int i = 1; i <= 52; i++) {
      weeks.add(i);
    }
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
