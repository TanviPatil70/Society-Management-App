import 'package:flutter/material.dart';
import '../data/admin_notice_service.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _noticeService = AdminNoticeService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _notices = [];

  Future<void> _loadNotices() async {
    final data = await _noticeService.getNotices();
    if (!mounted) return;
    setState(() {
      _notices = data;
    });
  }

  Future<void> _addNotice() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _noticeService.addNotice(
        title: title,
        message: message,
        createdBy: 'Admin User',
      );

      _titleController.clear();
      _messageController.clear();

      await _loadNotices();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notices'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Notice Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notice Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addNotice,
                        icon: const Icon(Icons.send),
                        label: Text(_isLoading ? 'Posting...' : 'Post Notice'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Posted Notices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _notices.isEmpty
                  ? const Center(child: Text('No notices available'))
                  : ListView.builder(
                      itemCount: _notices.length,
                      itemBuilder: (context, index) {
                        final notice = _notices[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.campaign,
                              color: Colors.indigo,
                            ),
                            title: Text(notice['title'] ?? ''),
                            subtitle: Text(notice['message'] ?? ''),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}