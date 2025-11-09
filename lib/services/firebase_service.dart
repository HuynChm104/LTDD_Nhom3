//cấu hình firebase

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  CollectionReference get users => db.collection('users');
  CollectionReference get products => db.collection('products');
  CollectionReference get branches => db.collection('branches');
  CollectionReference get categories => db.collection('categories');
  CollectionReference get orders => db.collection('orders');
}
