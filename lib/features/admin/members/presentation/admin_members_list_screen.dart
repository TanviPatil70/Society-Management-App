import 'package:flutter/material.dart';
import '../data/admin_members_service.dart';

class AdminMembersListScreen extends StatefulWidget {
  const AdminMembersListScreen({super.key});

  @override
  State<AdminMembersListScreen> createState() => _AdminMembersListScreenState();
}

class _AdminMembersListScreenState extends State<AdminMembersListScreen> {
  final _service = AdminMembersService();

  bool _isLoading = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  List<Map<String, dynamic>> _members = [];

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(6, (index) => currentYear - 1 + index);
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _service.getMembersWithStatus(
        selectedMonth: _selectedMonth,
        selectedYear: _selectedYear,
      );

      if (!mounted) return;
      setState(() {
        _members = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load members: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    return status == 'Paid' ? Colors.green : Colors.red;
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members List'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMembers,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_monthNames[index]),
                        ),
                      ),
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() {
                          _selectedMonth = value;
                        });
                        await _loadMembers();
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      items: _years
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() {
                          _selectedYear = value;
                        });
                        await _loadMembers();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Maintenance Status • ${_monthNames[_selectedMonth - 1]} $_selectedYear',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_members.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No members found')),
                ),
              )
            else
              ..._members.map((member) {
                final status = '${member['status'] ?? 'Unpaid'}';
                final statusColor = _statusColor(status);

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
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.person, color: Colors.orange),
                    ),
                    title: Text(
                      '${member['name'] ?? 'Member'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Flat: ${member['flat_no'] ?? ''} • Phone: ${member['phone'] ?? member['mobile'] ?? 'N/A'}',
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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