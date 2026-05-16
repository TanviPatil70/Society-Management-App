import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../maintenance/presentation/member_maintenance_screen.dart';
import '../../notices/presentation/member_notices_screen.dart';
import '../../payments/presentation/payment_history_screen.dart';

class MemberDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> profile;

  const MemberDashboardScreen({
    super.key,
    required this.profile,
  });

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> memberOptions = [
      {
        'title': 'View Notices',
        'icon': Icons.notifications,
        'color': Colors.blue,
      },
      {
        'title': 'Maintenance Due',
        'icon': Icons.account_balance_wallet,
        'color': Colors.red,
      },
      {
        'title': 'Payment History',
        'icon': Icons.history,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.indigo.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Hello, ${profile['name'] ?? 'Member'}'),
                subtitle: Text('Flat ${profile['flat_no'] ?? ''}'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: memberOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = memberOptions[index];

                  return Card(
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (item['title'] == 'View Notices') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MemberNoticesScreen(),
                            ),
                          );
                        } else if (item['title'] == 'Maintenance Due') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberMaintenanceScreen(
                                memberFlat: profile['flat_no'],
                              ),
                            ),
                          );
                        } else if (item['title'] == 'Payment History') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentHistoryScreen(
                                memberFlat: profile['flat_no'],
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                (item['color'] as Color).withOpacity(0.15),
                            child: Icon(
                              item['icon'],
                              color: item['color'],
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}