import 'package:eamon_app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';

class JobForm extends StatefulWidget {
  const JobForm({super.key});

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController startDateTimeText = TextEditingController();
  TextEditingController endDateTimeText = TextEditingController();
  TextEditingController startGeolocationText = TextEditingController();
  TextEditingController endGeolocationText = TextEditingController();
  String initialPosition = '';
  String finalPosition = '';
  bool isChecked = false;
//Geolocation function
  Future<Position> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return position;
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
                startDateTimeText.text = DateTime.now().toString();
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
                _determinePosition().then(
                    (value) => {startGeolocationText.text = value.toString()});
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
              },
            ),
            isChecked
                ? TextFormField(
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
                  endDateTimeText.text = DateTime.now().toString();
                  setState(() {
                    _determinePosition().then((value) =>
                        {endGeolocationText.text = value.toString()});
                  });
                },
                child: const Text('Finish Job')),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
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
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Loading, please wait')));
                  }
                  print(_determinePosition());
                },
                child: const Text('Submit')),
          ]),
        ),
      )),
    );
  }
}
