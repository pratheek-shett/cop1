import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grantha_mithra/Pages/EditDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';

class StudentAt extends StatefulWidget {
  const StudentAt({Key? key}) : super(key: key);

  @override
  State<StudentAt> createState() => _StudentAtState();
}

class _StudentAtState extends State<StudentAt> {
  TextEditingController studentnameController = TextEditingController();
  TextEditingController GenderController = TextEditingController();
  TextEditingController ClassController = TextEditingController();
  TextEditingController SchoolNameController = TextEditingController();
  TextEditingController PhoneNumberController = TextEditingController();
  TextEditingController EventNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController selectedEventController = TextEditingController();
  List<Map<String, dynamic>> filteredEventData = [];
  List<Map<String, dynamic>> eventData = [];
  List<Map<String, dynamic>> fetchAttendence = [];
  List<Map<String, dynamic>> attendence = [];
  late int selected_event_id;

  bool isSearchFocused = false;
  String? selectedName;
  String? selectedDate;
  String? selectedGender;
  @override
  void initState() {
    super.initState();
    fetchData();
    Attendence();
    filteredEventData = eventData;
    fetchAttendence = attendence;
  }
  Future<void> Attendence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final wait = await Dio().get(
        'http://139.59.29.21:8080/panchayat/students/all',
        options: Options(headers: {'Authorization': token}),
      );

      if (wait.statusCode == 200) {
        final responseData =wait.data['data'];
        if (responseData is List<dynamic>) {
          setState(() {
            fetchAttendence= List<Map<String, dynamic>>.from(responseData.reversed);
            attendence = fetchAttendence;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to fetch data'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
    }
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await Dio().get(
        'http://139.59.29.21:8080/panchayat/events/all',
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData is List<dynamic>) {
          setState(() {
            eventData.clear(); // Clear the list before fetching new data
            final List<Map<String, dynamic>> fetchedData =
            List<Map<String, dynamic>>.from(responseData);

            eventData.addAll(fetchedData); // Add fetchedData to eventData
            filteredEventData = eventData; // Update filteredEventData as well
          });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to fetch data'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        bottomOpacity: 0,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 0),
                ),
                Container(
                  margin: EdgeInsets.only(left: 13),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF9B429),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.black,
                    size: 23,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Dialog(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add Event',
                                style: TextStyle(
                                  fontFamily: 'Bold',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              TextField(
                                controller: studentnameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),
                              SizedBox(height: 10.0),
                              DropdownButtonFormField<String>(
                                value: selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                                items:
                                ['Male', 'Female', 'Other'].map((gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                              ),
                              TextField(
                                controller: PhoneNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Number',
                                ),
                              ),
                              SizedBox(height: 10.0),
                              TextField(
                                controller: ClassController,
                                decoration: InputDecoration(
                                  labelText: 'Class',
                                ),
                              ),
                              TextField(
                                controller: SchoolNameController,
                                decoration: InputDecoration(
                                  labelText: 'School Name',
                                ),
                              ),
                              SizedBox(height: 20.0),
                              TypeAheadFormField<String>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: selectedEventController,
                                  decoration: InputDecoration(
                                    labelText: 'Select Event',
                                  ),
                                ),
                                suggestionsCallback: (pattern) async {
                                  // Modify the filter logic based on your requirements
                                  return eventData
                                      .where((event) =>
                                  event['name'].toLowerCase().contains(
                                      pattern.toLowerCase()) ||
                                      event['date']
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()))
                                      .map((event) =>
                                  '${event['name']} - ${event['date']}')
                                      .toList();
                                },
                                itemBuilder: (context, String suggestion) {
                                  final eventName = suggestion.split(' - ')[0];
                                  final eventDate = suggestion.split(' - ')[1];
                                  return ListTile(
                                    title: Text('$eventName - $eventDate'),
                                  );
                                },
                                onSuggestionSelected: (String suggestion) {
                                  final selectedEvent = eventData.firstWhere(
                                          (event) =>
                                      '${event['name']} - ${event['date']}' ==
                                          suggestion);
                                  setState(() {
                                    selectedEventController.text = suggestion;
                                    final eventId = selectedEvent['id'];
                                    // Access the event ID using event['id']
                                    // Do whatever you need with the event ID
                                    selected_event_id = eventId;
                                    print('Selected event ID: $eventId');
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select an event';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: _saveForm,
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffF9B429),
                                  onPrimary: Colors.black,
                                ),
                                child: Text('Submit'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Color(0xffF9B429),
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Student Report",
                style: TextStyle(
                  fontFamily: 'Bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  wordSpacing: 7,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.search,
                      color: isSearchFocused ? Colors.grey : Colors.black,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Event Name',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          fetchAttendence = attendence.where((attendence) {
                            final name = attendence['name'].toString().toLowerCase();
                            final eventName = attendence['event_name'].toString().toLowerCase();
                            final phone = attendence['phone'].toString().toLowerCase();

                            return name.contains(value.toLowerCase()) ||
                                eventName.contains(value.toLowerCase()) ||
                                phone.contains(value.toLowerCase());
                          }).toList();
                        });
                      },

                      onTap: () {
                        setState(() {
                          isSearchFocused = true;
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          isSearchFocused = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
                child: ListView.builder(
                  // Might Implement Blinkers
                  itemCount: fetchAttendence.length,
                  itemBuilder: (context, index) {
                    final event = fetchAttendence[index] as Map<String, dynamic>;


                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Student Report',
                                                    style: TextStyle(
                                                      fontFamily: 'Bold',
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(0),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffF9B429),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.mode_edit_rounded),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Flex(
                                                        direction: Axis.vertical,
                                                        children: [
                                                          Expanded(
                                                            child: Dialog(
                                                              child: Padding(
                                                                padding: EdgeInsets.all(20.0),
                                                                child: SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text(
                                                                        'Edit Event',
                                                                        style: TextStyle(
                                                                          fontFamily: 'Bold',
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 20.0,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 20.0),
                                                                      TextField(
                                                                        controller: studentnameController,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'Name',
                                                                        ),

                                                                      ),

                                                                      SizedBox(height: 10.0),
                                                                      DropdownButtonFormField<String>(
                                                                        value: selectedGender,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'Gender',
                                                                        ),

                                                                        onChanged: (value) {
                                                                          setState(() {

                                                                            selectedGender = value;
                                                                          });
                                                                        },
                                                                        items:
                                                                        ['Male', 'Female', 'Other'].map((gender) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: gender,
                                                                            child: Text(gender),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                      TextField(
                                                                        controller: PhoneNumberController,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'Number',
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 10.0),
                                                                      TextField(
                                                                        controller: ClassController,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'Class',
                                                                        ),
                                                                      ),
                                                                      TextField(
                                                                        controller: SchoolNameController,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'School Name',
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 20.0),
                                                                      TypeAheadFormField<String>(
                                                                        textFieldConfiguration: TextFieldConfiguration(
                                                                          controller: selectedEventController,
                                                                          decoration: InputDecoration(
                                                                            labelText: 'Select Event',
                                                                          ),
                                                                        ),
                                                                        suggestionsCallback: (pattern) async {
                                                                          // Modify the filter logic based on your requirements
                                                                          return eventData
                                                                              .where((event) =>
                                                                          event['name'].toLowerCase().contains(
                                                                              pattern.toLowerCase()) ||
                                                                              event['date']
                                                                                  .toLowerCase()
                                                                                  .contains(pattern.toLowerCase()))
                                                                              .map((event) =>
                                                                          '${event['name']} - ${event['date']}')
                                                                              .toList();
                                                                        },
                                                                        itemBuilder: (context, String suggestion) {
                                                                          final eventName = suggestion.split(' - ')[0];
                                                                          final eventDate = suggestion.split(' - ')[1];
                                                                          return ListTile(
                                                                            title: Text('$eventName - $eventDate'),
                                                                          );
                                                                        },
                                                                        onSuggestionSelected: (String suggestion) {
                                                                          final selectedEvent = eventData.firstWhere(
                                                                                  (event) =>
                                                                              '${event['name']} - ${event['date']}' ==
                                                                                  suggestion);
                                                                          setState(() {
                                                                            selectedEventController.text = suggestion;
                                                                            final eventId = selectedEvent['id'];
                                                                            // Access the event ID using event['id']
                                                                            // Do whatever you need with the event ID
                                                                            selected_event_id = eventId;
                                                                            print('Selected event ID: $eventId');
                                                                          });
                                                                        },
                                                                        validator: (value) {
                                                                          if (value == null || value.isEmpty) {
                                                                            return 'Please select an event';
                                                                          }
                                                                          return null;
                                                                        },
                                                                      ),
                                                                      SizedBox(height: 20.0),
                                                                      ElevatedButton(
                                                                        onPressed: _saveForm,
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary: Color(0xffF9B429),
                                                                          onPrimary: Colors.black,
                                                                        ),
                                                                        child: Text('Submit'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                color: Colors.white,
                                                iconSize: 20,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffF9B429),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.delete_rounded),
                                                onPressed: () {},
                                                color: Colors.white,
                                                iconSize: 20,
                                              ),
                                            ),
                                          ]),
                                    ),
                                    // Adjust the top padding value as needed

                                    SizedBox(height: 20.0),
                                    /* Text(
                                      'Event Details',
                                      style: TextStyle(
                                        fontFamily: 'Bold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),*/
                                    /* SizedBox(height: 20.0),*/
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Text(
                                        'Student: ${event['name'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Text(
                                        'Class: ${event['class'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Text(
                                        'Gender: ${event['gender'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Text(
                                        'Phone: ${event['phone'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Text(
                                        'School: ${event['school'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Text(
                                        'Event: ${event['event_name'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Card(
                            elevation: 2.0,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 10),
                                ],
                              ),
                              title: Text(
                                'Name: ${event['name'] ?? ''}',
                                style: TextStyle(
                                  letterSpacing: 1,
                                  fontSize: 16,
                                  fontFamily: 'Bold',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Event: ${event['event_name'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Regular',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0), // Add spacing between cards
                        ],
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    final String name = studentnameController.text;
    final String gender = selectedGender ?? '';
    final String classess = ClassController.text;
    final String school = SchoolNameController.text;
    final String phone = PhoneNumberController.text;
    final String event_name = selectedEventController.text;
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (name.isEmpty ||
        gender.isEmpty ||
        classess.isEmpty ||
        school.isEmpty ||
        phone.isEmpty ||
        event_name.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill all fields'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final dio = Dio();
    final url = 'http://139.59.29.21:8080/panchayat/students/new';

    // Include the authentication token in the headers
    final headers = {
      'Authorization': token,
    };

    final data = {
      'name': name,
      'gender': gender,
      'className': classess,
      'phone': phone,
      'school': school,
      'event_id': selected_event_id,
    };

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final savedData = {
          'name': name,
          'gender': gender,
          'className': classess,
          'phone': phone,
          'school': school,
          'event_id': selected_event_id,
        };
        studentnameController.clear();
        ClassController.clear();
        PhoneNumberController.clear();
        SchoolNameController.clear();

        _showToast("Data submitted successfully");
        Navigator.of(context).pop(); // Close the dialog

        // Fetch the updated event data
        await Attendence();

        setState(() {
          fetchAttendence = attendence;
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to save data'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error, stacktrace) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while submitting data'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print(error);
      print(stacktrace);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StudentAt(),
  ));
}
