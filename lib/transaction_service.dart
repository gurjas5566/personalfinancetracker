import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import './transaction_model.dart';
import 'budget_model.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This getter provides the ID of the current logged-in user.
  String get currentUserId => _auth.currentUser!.uid;

  // This method provides a real-time stream of all transactions for the current user.
  // The data is automatically ordered by date, descending.

  // This method adds a new transaction to the Firestore database.
  Future<void> addTransaction(Transaction transaction) {
    // We don't need to pass the ID here, as Firestore will generate it.
    return _db.collection('transactions').add(transaction.toFirestore());
  }

  // This method updates an existing transaction using its document ID.
  Future<void> updateTransaction(Transaction transaction) {
    return _db
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  // This method deletes a transaction from the database.
  Future<void> deleteTransaction(String transactionId) {
    return _db.collection('transactions').doc(transactionId).delete();
  }

  Stream<List<Transaction>> getTransactions() {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Transaction.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Budget>> getBudget() {
    return _db
        .collection('budgets')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList(),
        );
  }

  // Add a new budget
  Future<void> addBudget(Budget budget) {
    return _db.collection('budgets').add(budget.toFirestore());
  }

  // Update an existing budget
  Future<void> updateBudget(Budget budget) {
    return _db
        .collection('budgets')
        .doc(budget.id)
        .update(budget.toFirestore());
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) {
    return _db.collection('budgets').doc(budgetId).delete();
  }
}
