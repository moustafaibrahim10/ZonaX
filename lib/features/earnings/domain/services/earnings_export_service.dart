import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/earnings_entity.dart';

class EarningsExportService {
  static Future<void> exportAsPdf(EarningsEntity data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSummary(data),
            pw.SizedBox(height: 20),
            _buildPerformanceStats(data.performanceStats),
            pw.SizedBox(height: 20),
            _buildRecentTrips(data.recentTrips),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${output.path}/earnings_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'My Earnings Report');
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Earnings Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.SizedBox(height: 5),
        pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSummary(EarningsEntity data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Total Earnings', '${data.headerSummary.totalEarnings} EGP'),
          _buildSummaryItem('Trips Completed', '${data.headerSummary.trips}'),
          _buildSummaryItem('Hours Online', '${data.headerSummary.hours}h'),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 5),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
      ],
    );
  }

  static pw.Widget _buildPerformanceStats(EarningsPerformanceStatsEntity stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Performance Stats', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Avg per Trip', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Earnings/Hour', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Trend', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${stats.avgPerTrip} EGP')),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${stats.earningsPerHour} EGP')),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(stats.trend)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildRecentTrips(List<dynamic> trips) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Recent Trips', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal100),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Route', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Fare', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            ...trips.take(15).map((tripData) {
              final fareValue = tripData['fare'] ?? tripData['earnings'] ?? tripData['amount'];
              final fare = fareValue != null ? "$fareValue EGP" : "0 EGP";
              final time = tripData['time']?.toString() ?? tripData['start_time']?.toString() ?? "00:00";
              final route = tripData['destination']?.toString() ?? "${tripData['from'] ?? ''} - ${tripData['to'] ?? ''}";

              return pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(route, style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(time, style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(fare, style: const pw.TextStyle(fontSize: 10))),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
