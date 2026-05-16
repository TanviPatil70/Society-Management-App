import 'package:flutter/material.dart';
import '../data/member_maintenance_service.dart';
import '../../payments/data/payment_service.dart';
import '../../payments/presentation/payment_history_screen.dart';

class MemberMaintenanceScreen extends StatefulWidget {
  final String memberFlat;

  const MemberMaintenanceScreen({
    super.key,
    required this.memberFlat,
  });

  @override
  State<MemberMaintenanceScreen> createState() =>
      _MemberMaintenanceScreenState();
}

class _MemberMaintenanceScreenState extends State<MemberMaintenanceScreen> {
  final MemberMaintenanceService _maintenanceService =
      MemberMaintenanceService();
  final PaymentService _paymentService = PaymentService();

  late Future<List<Map<String, dynamic>>> _billsFuture;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() {
    _billsFuture = _maintenanceService.getBills(widget.memberFlat);
  }

  Future<void> _refreshBills() async {
    setState(() {
      _loadBills();
    });
  }

  Future<void> _payBill(Map<String, dynamic> bill) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Confirm Payment'),
            content: Text('Pay ₹${bill['amount']} for ${bill['month']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Pay Now'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _isPaying = true;
    });

    try {
      await _paymentService.payBill(bill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful')),
      );

      await _refreshBills();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isPaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Due'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _billsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bills = snapshot.data ?? [];
          final unpaidBills =
              bills.where((bill) => bill['status'] == 'Unpaid').toList();

          final currentDue = unpaidBills.fold<double>(
            0,
            (sum, bill) => sum + ((bill['amount'] ?? 0) as num).toDouble(),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  color: unpaidBills.isEmpty
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(
                      unpaidBills.isEmpty ? Icons.check_circle : Icons.warning,
                      color: unpaidBills.isEmpty ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      unpaidBills.isEmpty ? 'No Pending Due' : 'Current Due',
                    ),
                    subtitle: Text(
                      unpaidBills.isEmpty
                          ? 'All maintenance bills are paid for ${widget.memberFlat}'
                          : '₹${currentDue.toStringAsFixed(0)} pending for ${widget.memberFlat}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pending Bills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: unpaidBills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 72,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No pending maintenance dues',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'You are all caught up. Your paid bills are available in Payment History.',
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentHistoryScreen(
                                        memberFlat: widget.memberFlat,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.history),
                                label: const Text('View Payment History'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: unpaidBills.length,
                          itemBuilder: (context, index) {
                            final bill = unpaidBills[index];

                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.schedule,
                                  color: Colors.orange,
                                ),
                                title: Text(
                                  '${bill['month']} • ${bill['flat_no']}',
                                ),
                                subtitle: Text(
                                  '₹${bill['amount']} • ${bill['due_date']}',
                                ),
                                trailing: ElevatedButton(
                                  onPressed: _isPaying
                                      ? null
                                      : () => _payBill(bill),
                                  child: Text(
                                    _isPaying ? 'Processing...' : 'Pay',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}