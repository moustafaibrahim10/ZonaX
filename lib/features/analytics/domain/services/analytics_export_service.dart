import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/analytics_entity.dart';

class AnalyticsExportService {
  static Future<void> exportAsPdf(AnalyticsEntity data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildWeeklySummary(data.weeklySummary),
            pw.SizedBox(height: 20),
            _buildWeeklyGoals(data.weeklyGoals),
            pw.SizedBox(height: 20),
            _buildTopRoutes(data.weeklySummary.topRoutes),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${output.path}/analytics_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'My Analytics Report');
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.SizedBox(height: 5),
        pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildWeeklySummary(WeeklySummaryEntity summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('This Week Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Earnings', '${summary.totalEarnings.toStringAsFixed(0)} EGP'),
              _buildSummaryItem('Trips', '${summary.completedTrips}'),
              _buildSummaryItem('Online', '${summary.onlineHours.toStringAsFixed(1)}h'),
              _buildSummaryItem('Avg/Hr', '${summary.avgPerHour.toStringAsFixed(0)} EGP'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 5),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
      ],
    );
  }

  static pw.Widget _buildWeeklyGoals(WeeklyGoalsEntity goals) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Weekly Goals', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Goal Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Current', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Target', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Earnings')),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${goals.earningsGoal.current.toStringAsFixed(0)} EGP')),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${goals.earningsGoal.target.toStringAsFixed(0)} EGP')),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Trips')),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${goals.tripsGoal.current.toStringAsFixed(0)}')),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${goals.tripsGoal.target.toStringAsFixed(0)}')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTopRoutes(List<dynamic> routes) {
    if (routes.isEmpty) {
      return pw.SizedBox();
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Top Earning Routes', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal100),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Route', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Trips', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Fare', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            ...routes.take(10).map((routeData) {
              String route = "Unknown Route";
              String trips = "0";
              String fare = "0 EGP";

              if (routeData is Map) {
                route = routeData['route_name']?.toString() ?? routeData['route']?.toString() ?? routeData['name']?.toString() ?? route;
                trips = routeData['trips_count']?.toString() ?? routeData['trips']?.toString() ?? routeData['count']?.toString() ?? trips;
                final fareValue = routeData['fare'] ?? routeData['earnings'] ?? routeData['amount'];
                fare = fareValue != null ? "$fareValue EGP" : fare;
              } else if (routeData is String) {
                route = routeData;
              }

              return pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(route, style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(trips, style: const pw.TextStyle(fontSize: 10))),
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
