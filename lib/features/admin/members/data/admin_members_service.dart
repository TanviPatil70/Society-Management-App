import '../../../../core/services/supabase_service.dart';

class AdminMembersService {
  static const Map<String, int> _monthMap = {
    'january': 1,
    'february': 2,
    'march': 3,
    'april': 4,
    'may': 5,
    'june': 6,
    'july': 7,
    'august': 8,
    'september': 9,
    'october': 10,
    'november': 11,
    'december': 12,
  };

  Future<List<Map<String, dynamic>>> getMembersWithStatus({
    required int selectedMonth,
    required int selectedYear,
  }) async {
    final membersData = await SupabaseService.client
        .from('members')
        .select()
        .order('flat_no');

    final billsData = await SupabaseService.client
        .from('maintenance_bills')
        .select();

    final members = List<Map<String, dynamic>>.from(membersData);
    final bills = List<Map<String, dynamic>>.from(billsData);

    return members.map((member) {
      final flatNo = '${member['flat_no'] ?? ''}'.trim();

      final matchedBill = bills.cast<Map<String, dynamic>?>().firstWhere(
            (bill) =>
                bill != null &&
                '${bill['flat_no'] ?? ''}'.trim() == flatNo &&
                _matchesMonthYear(
                  '${bill['month'] ?? ''}',
                  selectedMonth,
                  selectedYear,
                ),
            orElse: () => null,
          );

      final status =
          matchedBill == null ? 'Unpaid' : '${matchedBill['status'] ?? 'Unpaid'}';

      return {
        ...member,
        'billing_month': _displayMonthYear(selectedMonth, selectedYear),
        'status': status.toLowerCase() == 'paid' ? 'Paid' : 'Unpaid',
      };
    }).toList();
  }

  bool _matchesMonthYear(String rawMonth, int selectedMonth, int selectedYear) {
    final cleaned = rawMonth.trim().toLowerCase();
    if (cleaned.isEmpty) return false;

    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.isEmpty) return false;

    final monthNumber = _monthMap[parts.first];
    if (monthNumber == null || monthNumber != selectedMonth) return false;

    if (parts.length >= 2) {
      final year = int.tryParse(parts.last);
      if (year != null) {
        return year == selectedYear;
      }
    }

    return true;
  }

  String _displayMonthYear(int month, int year) {
    const names = [
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

    return '${names[month - 1]} $year';
  }
}