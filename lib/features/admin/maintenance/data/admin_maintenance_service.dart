import '../../../../core/services/supabase_service.dart';

class AdminMaintenanceService {
  static const List<String> monthNames = [
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

  Future<List<Map<String, dynamic>>> getBills() async {
    final data = await SupabaseService.client
        .from('maintenance_bills')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<String>> getAvailableFlatNumbers() async {
    final data = await SupabaseService.client
        .from('members')
        .select('flat_no')
        .order('flat_no');

    final flats = data
        .map((item) => (item['flat_no'] ?? '').toString().trim())
        .where((flat) => flat.isNotEmpty)
        .toSet()
        .toList();

    flats.sort();
    return flats;
  }

  Future<void> addBill({
    required String flatNo,
    required String month,
    required int year,
    required String amount,
    required String dueDate,
  }) async {
    final member = await SupabaseService.client
        .from('members')
        .select()
        .eq('flat_no', flatNo)
        .maybeSingle();

    if (member == null) {
      throw Exception('No member found for flat $flatNo');
    }

    final normalizedMonth = '$month $year';

    final existing = await SupabaseService.client
        .from('maintenance_bills')
        .select('id')
        .eq('flat_no', flatNo)
        .eq('month', normalizedMonth)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Bill already exists for $flatNo for $normalizedMonth');
    }

    await SupabaseService.client.from('maintenance_bills').insert({
      'member_id': member['id'],
      'flat_no': flatNo,
      'month': normalizedMonth,
      'amount': double.parse(amount),
      'status': 'Unpaid',
      'due_date': dueDate,
    });
  }

  Future<void> updateBillStatus({
    required String id,
    required String status,
  }) async {
    await SupabaseService.client
        .from('maintenance_bills')
        .update({'status': status})
        .eq('id', id);
  }
}