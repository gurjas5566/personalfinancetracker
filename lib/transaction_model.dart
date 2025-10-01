import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String category;
  final String userId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.userId,
  });

  // Factory constructor to create a Transaction object from a Firestore document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'General',
      userId: data['userId'] ?? '',
    );
  }

  // Convert a Transaction object into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
      'category': category,
      'userId': userId,
    };
  }
}
