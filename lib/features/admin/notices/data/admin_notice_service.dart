import '../../../../core/services/supabase_service.dart';

class AdminNoticeService {
  Future<List<Map<String, dynamic>>> getNotices() async {
    final data = await SupabaseService.client
        .from('notices')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addNotice({
    required String title,
    required String message,
    required String createdBy,
  }) async {
    await SupabaseService.client.from('notices').insert({
      'title': title,
      'message': message,
      'created_by': createdBy,
    });
  }
}