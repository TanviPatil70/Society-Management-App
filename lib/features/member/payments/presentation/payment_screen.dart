import 'package:flutter/material.dart';
import '../data/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bill;

  const PaymentScreen({super.key, required this.bill});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _markAsPaid() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _paymentService.payBill(widget.bill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Maintenance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Flat Number'),
                    subtitle: Text('${bill['flat_no'] ?? ''}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Month'),
                    subtitle: Text('${bill['month'] ?? ''}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Amount'),
                    subtitle: Text('₹${bill['amount'] ?? ''}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text('${bill['due_date'] ?? ''}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.green.shade50,
              child: const ListTile(
                leading: Icon(Icons.info, color: Colors.green),
                title: Text('Payment Mode'),
                subtitle: Text('UPI / Card / Net Banking (demo)'),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: Text(
                  _isLoading
                      ? 'Processing...'
                      : 'Pay ₹${bill['amount'] ?? ''}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _markAsPaid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}