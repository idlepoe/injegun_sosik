import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/soldier.dart';

/// Firestore soldiers 컬렉션 조회 (군장병 우대업소)
class SoldierRepository {
  SoldierRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// soldiers 컬렉션 전체 조회
  Future<List<Soldier>> getAll() async {
    final snapshot =
        await _firestore.collection('soldiers').get(const GetOptions());
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      final updatedAt = data['updatedAt'];
      if (updatedAt is Timestamp) {
        data['updatedAt'] = updatedAt.toDate().toIso8601String();
      }
      return Soldier.fromMap(data);
    }).toList();
  }
}
