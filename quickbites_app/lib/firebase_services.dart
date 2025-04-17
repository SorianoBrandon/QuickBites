import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Stream<List<Map<String, dynamic>>> getOrdersStream() {
  return db.collection('orders').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  });
}
