import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final holidayProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('holidays')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
      .orderBy('date')
      .limit(90)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
            'date': (doc['date'] as Timestamp).toDate(),
            'title': doc['title'] as String,
            'subtitle': doc['subtitle'] as String,
            'icon': doc['icon'] as String,
          }).toList());
});