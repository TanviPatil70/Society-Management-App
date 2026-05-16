class AppData {
  static String currentMemberFlat = 'A-302';

  static List<Map<String, String>> notices = [
    {
      'title': 'Water supply maintenance',
      'message': 'Water supply will be unavailable tomorrow from 10 AM to 1 PM.',
    },
    {
      'title': 'Society meeting',
      'message': 'General society meeting on Sunday at 6 PM in the hall.',
    },
  ];

  static List<Map<String, String>> maintenanceBills = [
    {
      'month': 'May 2026',
      'flat': 'A-302',
      'amount': '2500',
      'status': 'Unpaid',
      'date': 'Due on 20 May 2026',
    },
    {
      'month': 'April 2026',
      'flat': 'A-302',
      'amount': '2500',
      'status': 'Paid',
      'date': 'Paid on 10 Apr 2026',
    },
    {
      'month': 'May 2026',
      'flat': 'B-101',
      'amount': '3000',
      'status': 'Unpaid',
      'date': 'Due on 18 May 2026',
    },
  ];

  static List<Map<String, String>> paymentHistory = [
    {
      'month': 'April 2026',
      'flat': 'A-302',
      'amount': '2500',
      'status': 'Paid',
      'date': 'Paid on 10 Apr 2026',
    },
  ];
}