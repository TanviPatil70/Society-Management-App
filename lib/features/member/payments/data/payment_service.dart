import '../../../../core/services/supabase_service.dart';

class PaymentService {
  Future<void> payBill(Map<String, dynamic> bill) async {
    await SupabaseService.client
        .from('maintenance_bills')
        .update({'status': 'Paid'})
        .eq('id', bill['id']);

    await SupabaseService.client.from('payments').insert({
      'bill_id': bill['id'],
      'member_id': bill['member_id'],
      'flat_no': bill['flat_no'],
      'month': bill['month'],
      'amount': bill['amount'],
      'status': 'Paid',
      'paid_at': DateTime.now().toIso8601String(),
    });
  }
}