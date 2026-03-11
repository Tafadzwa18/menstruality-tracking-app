import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class ReportService {
  Future<File> generateHealthReport({
    required String userName,
    required List<DailyLog> logs,
    required int cycleLength,
    required int periodLength,
    required Set<String> categories,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(userName),
          pw.SizedBox(height: 20),
          _buildCycleSummary(cycleLength, periodLength),
          pw.SizedBox(height: 30),
          if (categories.contains('Cycle Dates') || categories.contains('Mood & Energy Logs'))
            _buildLogTable(logs, categories),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/health_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(String name) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Health & Menstruality Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated for: $name', style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.PdfLogo(),
      ],
    );
  }

  pw.Widget _buildCycleSummary(int cycle, int period) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Cycle Overview', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Avg Cycle Length: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('$cycle days'),
              pw.SizedBox(width: 40),
              pw.Text('Avg Period: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('$period days'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLogTable(List<DailyLog> logs, Set<String> categories) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.pink400),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
      },
      data: <List<String>>[
        <String>['Date', 'Mood', 'Energy', 'Symptoms'],
        ...logs.take(30).map((log) => [
              log.date.toString().substring(0, 10),
              categories.contains('Mood & Energy Logs') ? log.mood : '-',
              categories.contains('Mood & Energy Logs') ? log.energyLevel.toString() : '-',
              categories.contains('Symptom Trends') ? log.symptoms.join(', ') : '-',
            ]),
      ],
    );
  }
}
