import 'package:flutter/material.dart';
import '../data/admin_maintenance_service.dart';

class AdminMaintenanceScreen extends StatefulWidget {
  const AdminMaintenanceScreen({super.key});

  @override
  State<AdminMaintenanceScreen> createState() => _AdminMaintenanceScreenState();
}

class _AdminMaintenanceScreenState extends State<AdminMaintenanceScreen> {
  final _amountController = TextEditingController();
  final _service = AdminMaintenanceService();

  bool _isLoading = false;
  bool _isPageLoading = true;

  List<Map<String, dynamic>> _bills = [];
  List<String> _flatNumbers = [];

  String? _selectedFlat;
  String? _selectedMonth;
  int? _selectedYear;
  DateTime? _selectedDueDate;

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(6, (index) => currentYear - 1 + index);
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isPageLoading = true;
    });

    try {
      final bills = await _service.getBills();
      final flats = await _service.getAvailableFlatNumbers();

      if (!mounted) return;
      setState(() {
        _bills = bills;
        _flatNumbers = flats;
        _selectedMonth ??=
            AdminMaintenanceService.monthNames[DateTime.now().month - 1];
        _selectedYear ??= DateTime.now().year;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load maintenance data: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isPageLoading = false;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDueDate = picked;
    });
  }

  String get _formattedDueDate {
    if (_selectedDueDate == null) return 'Select due date';
    final date = _selectedDueDate!;
    return '${date.day.toString().padLeft(2, '0')} '
        '${AdminMaintenanceService.monthNames[date.month - 1]} '
        '${date.year}';
  }

  Future<void> _addBill() async {
    final amount = _amountController.text.trim();

    if (_selectedFlat == null ||
        _selectedMonth == null ||
        _selectedYear == null ||
        _selectedDueDate == null ||
        amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all fields properly')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.addBill(
        flatNo: _selectedFlat!,
        month: _selectedMonth!,
        year: _selectedYear!,
        amount: amount,
        dueDate: _formattedDueDate,
      );

      _amountController.clear();
      setState(() {
        _selectedDueDate = null;
      });

      await _loadInitialData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance bill added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value == 'paid') return Colors.green;
    if (value == 'unpaid') return Colors.red;
    return Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthItems = AdminMaintenanceService.monthNames;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Maintenance'),
        centerTitle: true,
      ),
      body: _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Maintenance Bill',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedFlat,
                            decoration: const InputDecoration(
                              labelText: 'Flat Number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.home_work_outlined),
                            ),
                            items: _flatNumbers
                                .map(
                                  (flat) => DropdownMenuItem<String>(
                                    value: flat,
                                    child: Text(flat),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFlat = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedMonth,
                            decoration: const InputDecoration(
                              labelText: 'Month',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                            ),
                            items: monthItems
                                .map(
                                  (month) => DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.date_range_outlined),
                            ),
                            items: _years
                                .map(
                                  (year) => DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickDueDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event_outlined),
                              ),
                              child: Text(
                                _formattedDueDate,
                                style: TextStyle(
                                  color: _selectedDueDate == null
                                      ? Colors.grey.shade700
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _addBill,
                              icon: const Icon(Icons.save_alt),
                              label: Text(
                                _isLoading ? 'Saving...' : 'Create Bill',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Recent Bills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_bills.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No maintenance bills available'),
                        ),
                      ),
                    )
                  else
                    ..._bills.map(
                      (bill) {
                        final status = '${bill['status'] ?? 'Unknown'}';
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
                              backgroundColor: Colors.indigo.shade50,
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Text(
                              '${bill['flat_no'] ?? ''} • ${bill['month'] ?? ''}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '₹${bill['amount'] ?? ''} • Due: ${bill['due_date'] ?? ''}',
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}