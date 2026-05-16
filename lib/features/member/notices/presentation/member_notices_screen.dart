import 'package:flutter/material.dart';
import '../data/member_notice_service.dart';

class MemberNoticesScreen extends StatelessWidget {
  const MemberNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeService = MemberNoticeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Notices'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: noticeService.getNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notices = snapshot.data ?? [];

          if (notices.isEmpty) {
            return const Center(child: Text('No notices available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(notice['title'] ?? ''),
                  subtitle: Text(notice['message'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}