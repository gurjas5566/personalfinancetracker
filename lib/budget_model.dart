import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String category;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.userId,
  });

  // Factory constructor to create a Budget object from a Firestore document
  factory Budget.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      category: data['category'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  // Convert a Budget object into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }
}
