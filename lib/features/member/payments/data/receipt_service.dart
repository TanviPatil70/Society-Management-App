import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReceiptService {
  Future<File> generateReceiptPdf(Map<String, dynamic> payment) async {
    final pdf = pw.Document();

    final flatNo = '${payment['flat_no'] ?? ''}';
    final month = '${payment['month'] ?? ''}';
    final amount = '${payment['amount'] ?? ''}';
    final status = '${payment['status'] ?? ''}';
    final paidAt = '${payment['paid_at'] ?? ''}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Society Maintenance Receipt',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Society Member App'),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text('Flat Number: $flatNo', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text('Month: $month', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text('Amount Paid: ₹$amount', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text('Status: $status', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text('Paid At: $paidAt', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text(
                  'This is a system-generated receipt for maintenance payment.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final safeMonth = month.replaceAll(' ', '_').replaceAll('/', '-');
    final file = File('${directory.path}/receipt_${flatNo}_$safeMonth.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> shareReceipt(Map<String, dynamic> payment) async {
    final file = await generateReceiptPdf(payment);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Maintenance payment receipt',
      subject: 'Society Maintenance Receipt',
    );
  }
}