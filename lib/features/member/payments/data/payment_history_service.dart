import '../../../../core/services/supabase_service.dart';

class PaymentHistoryService {
  Future<List<Map<String, dynamic>>> getPaymentHistory(String flatNo) async {
    final data = await SupabaseService.client
        .from('payments')
        .select()
        .eq('flat_no', flatNo)
        .order('paid_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}