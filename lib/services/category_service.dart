import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bongbieng_app/models/category_model.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<CategoryModel>> getCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // GÁN ID VÀO JSON
        return CategoryModel.fromJson(data);
      }).toList();
    });
  }
}