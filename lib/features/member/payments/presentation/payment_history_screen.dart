import 'package:flutter/material.dart';
import '../data/payment_history_service.dart';
import '../data/receipt_service.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String memberFlat;

  const PaymentHistoryScreen({
    super.key,
    required this.memberFlat,
  });

  void _showReceipt(BuildContext context, Map<String, dynamic> payment) {
    final receiptService = ReceiptService();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flat: ${payment['flat_no'] ?? ''}'),
            Text('Month: ${payment['month'] ?? ''}'),
            Text('Amount: ₹${payment['amount'] ?? ''}'),
            Text('Status: ${payment['status'] ?? ''}'),
            Text('Paid At: ${payment['paid_at'] ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await receiptService.shareReceipt(payment);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt ready to share')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to generate receipt: $e')),
                );
              }
            },
            child: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = PaymentHistoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getPaymentHistory(memberFlat),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No payment history found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final payment = history[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('${payment['month']} • ${payment['flat_no']}'),
                  subtitle: Text(
                    '₹${payment['amount']} • ${payment['status']} • ${payment['paid_at']}',
                  ),
                  trailing: TextButton(
                    onPressed: () => _showReceipt(context, payment),
                    child: const Text('Receipt'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}