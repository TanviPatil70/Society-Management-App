import '../../../../core/services/supabase_service.dart';

class AdminMemberManagementService {
  Future<List<Map<String, dynamic>>> getAllMembers() async {
    final data = await SupabaseService.client
        .from('members')
        .select()
        .order('flat_no');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createMember({
    required String name,
    required String flatNo,
    required String email,
    required String phone,
  }) async {
    final existingMember = await SupabaseService.client
        .from('members')
        .select('id')
        .eq('flat_no', flatNo)
        .maybeSingle();

    if (existingMember != null) {
      throw Exception('A member with flat $flatNo already exists');
    }

    await SupabaseService.client.from('members').insert({
      'name': name.trim(),
      'flat_no': flatNo.trim().toUpperCase(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'role': 'member',
    });
  }

  Future<List<Map<String, dynamic>>> getPaymentHistoryForMember(
    String flatNo,
  ) async {
    final data = await SupabaseService.client
        .from('payments')
        .select()
        .eq('flat_no', flatNo)
        .order('paid_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}