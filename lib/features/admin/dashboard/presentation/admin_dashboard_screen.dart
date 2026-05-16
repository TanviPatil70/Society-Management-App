import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../maintenance/presentation/admin_maintenance_screen.dart';
import '../../members/presentation/admin_members_list_screen.dart';
import '../../notices/presentation/admin_notices_screen.dart';
import '../../payments/presentation/admin_payment_records_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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

  void _openScreen(BuildContext context, String title) {
    if (title == 'Post Notices') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminNoticesScreen()),
      );
    } else if (title == 'Manage Maintenance') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminMaintenanceScreen()),
      );
    } else if (title == 'Members List') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminMembersListScreen()),
      );
    } else if (title == 'Manage Members') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPaymentRecordsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> adminOptions = [
      {
        'title': 'Post Notices',
        'subtitle': 'Create and publish notices',
        'icon': Icons.campaign,
        'color': Colors.blue,
      },
      {
        'title': 'Manage Maintenance',
        'subtitle': 'Create bills with due dates',
        'icon': Icons.account_balance_wallet,
        'color': Colors.green,
      },
      {
        'title': 'Members List',
        'subtitle': 'Check monthly payment status',
        'icon': Icons.group,
        'color': Colors.orange,
      },
      {
        'title': 'Manage Members',
        'subtitle': 'Create user and view history',
        'icon': Icons.manage_accounts,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.indigo,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Manage notices, bills, and members easily'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: adminOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = adminOptions[index];
                  final Color color = item['color'] as Color;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openScreen(context, item['title'] as String),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 18,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: color.withOpacity(0.14),
                              child: Icon(
                                item['icon'] as IconData,
                                color: color,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['subtitle'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
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