import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late Dio _dio;
  bool _isLoading = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    handlePerm();
    _dio = Dio();
    FlutterDownloader.initialize(debug: true);
    initializeNotifications();
  }
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Replace with your app icon name
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          // Handle notification tap here
        });

    // Request notification permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'channel_id', // Change this channel ID as needed
      'Channel Name', // Change this channel name as needed
      'Channel Description', // Change this channel description as needed
      importance: Importance.high,
    ));
  }
  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id', // Change this channel ID as needed
      'Channel Name', // Change this channel name as needed
      'Channel Description', // Change this channel description as needed
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Change this notification ID as needed
      'CSV Downloaded', // Change this notification title as needed
      'The CSV file has been downloaded successfully.', // Change this notification message as needed
      platformChannelSpecifics,
      payload: 'notification_payload', // Change this payload as needed
    );
  }


  Future<void> handlePerm() async {
    await Permission.storage.isDenied.then((value) {
      print(value);
      if (value) {
        Permission.storage.request();
      }
    });
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await _dio.get(
        'http://139.59.29.21:8080/panchayat/events/csv',
        options: Options(
            headers: {'Authorization': token},
            responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        //final directory = await path_provider.getApplicationDocumentsDirectory();
        final directory = '/storage/emulated/0/Download/report.csv';
        print(directory.toString());
        final filePath = '$directory';

        //await DefaultCacheManager().putFile(filePath, response.data);
        final file = File(directory);
        await file.create(recursive: true);
        await file.writeAsBytes(response.data);
        showNotification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV downloaded successfully')),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to download',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      // Open the downloaded file
      // await FlutterDownloader.open(taskId: taskId);
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download CSV')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    FlutterDownloader.cancelAll();
    super.dispose();
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
        body: Padding(
            padding: EdgeInsets.all(20),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Report",
                  style: TextStyle(
                    fontFamily: 'Bold',
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    wordSpacing: 7,
                  ),
                ),
              ),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _downloadFile,
                  child: const Text(
                    'Download CSV',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xffF9B429) // Change the color here
                  ),
                ),
              ),
            ])));
  }

}
