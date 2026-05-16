import '../../../../core/services/supabase_service.dart';

class MemberMaintenanceService {
  Future<List<Map<String, dynamic>>> getBills(String flatNo) async {
    final data = await SupabaseService.client
        .from('maintenance_bills')
        .select()
        .eq('flat_no', flatNo)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}