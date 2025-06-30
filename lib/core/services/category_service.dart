import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/category.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<Category>> streamCategories() {
    return _firestore
        .collection('categories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toMap());
  }

  static Future<void> updateCategory(
      String id, Map<String, dynamic> data) async {
    await _firestore.collection('categories').doc(id).update(data);
  }

  static Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }
}
