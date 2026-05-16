import 'package:flutter/material.dart';
import '../../../member/payments/data/receipt_service.dart';
import '../data/admin_member_management_service.dart';

class AdminMemberDetailScreen extends StatefulWidget {
  final Map<String, dynamic> member;

  const AdminMemberDetailScreen({
    super.key,
    required this.member,
  });

  @override
  State<AdminMemberDetailScreen> createState() => _AdminMemberDetailScreenState();
}

class _AdminMemberDetailScreenState extends State<AdminMemberDetailScreen> {
  final _service = AdminMemberManagementService();
  final _receiptService = ReceiptService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _service.getPaymentHistoryForMember(
        '${widget.member['flat_no'] ?? ''}',
      );

      if (!mounted) return;
      setState(() {
        _payments = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load payment history: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadReceipt(Map<String, dynamic> payment) async {
    try {
      await _receiptService.shareReceipt(payment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt ready to share')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate receipt: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    return Scaffold(
      appBar: AppBar(
        title: Text('Member • ${member['flat_no'] ?? ''}'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple.shade100,
                  child: const Icon(Icons.person, color: Colors.purple),
                ),
                title: Text(
                  '${member['name'] ?? 'Member'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Flat: ${member['flat_no'] ?? ''}\nEmail: ${member['email'] ?? 'N/A'}\nPhone: ${member['phone'] ?? 'N/A'}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Payment History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_payments.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No payment history found')),
                ),
              )
            else
              ..._payments.map((payment) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.check_circle, color: Colors.green),
                    ),
                    title: Text(
                      '${payment['month'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '₹${payment['amount'] ?? ''} • ${payment['status'] ?? ''}\nPaid at: ${payment['paid_at'] ?? ''}',
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => _downloadReceipt(payment),
                      child: const Text('Receipt'),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}