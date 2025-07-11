import 'dart:convert';
import 'package:attendance_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holiday Uploader',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: HolidayUploader(),
    );
  }
}

class HolidayUploader extends StatefulWidget {
  @override
  _HolidayUploaderState createState() => _HolidayUploaderState();
}

class _HolidayUploaderState extends State<HolidayUploader> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _uploadHolidays() async {
    setState(() => _isLoading = true);

    try {
      // Load JSON file from assets or local storage
       final jsonString = await rootBundle.loadString('assets/holidays.json');
    final List<dynamic> jsonData = json.decode(jsonString);

      // Upload each holiday to Firestore
      for (var holiday in jsonData) {
        await _firestore.collection('holidays').add({
          'date': Timestamp.fromDate(DateTime.parse(holiday['date'])),
          'title': holiday['title'],
          'subtitle': holiday['subtitle'],
          'icon': holiday['icon'],
        });
      }
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Holidays uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading holidays: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Holidays to Firestore'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _uploadHolidays,
                child: const Text('Upload Holidays'),
              ),
      ),
    );
  }
}