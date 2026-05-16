import '../../../../core/services/supabase_service.dart';

class MemberNoticeService {
  Future<List<Map<String, dynamic>>> getNotices() async {
    final data = await SupabaseService.client
        .from('notices')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}