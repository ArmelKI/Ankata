import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<Uint8List> generateTicket(Map<String, dynamic> booking) async {
    final pdf = pw.Document();

    // Load assets if needed (e.g. logo)
    // final logo = pw.MemoryImage((await rootBundle.load('assets/logos/ankata_logo.jpeg')).buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('BILLET DE TRANSPORT ANKATA',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'Code: ${booking['bookingCode'] ?? booking['booking_code'] ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          'Compagnie: ${booking['companyName'] ?? booking['company_name'] ?? '—'}'),
                      pw.Text('Trajet: ${booking['from']} -> ${booking['to']}'),
                      pw.Text('Date: ${booking['departureDate'] ?? '—'}'),
                      pw.Text('Heure: ${booking['departureTime'] ?? '—'}'),
                    ],
                  ),
                  pw.Container(
                    width: 100,
                    height: 100,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: booking['bookingCode'] ??
                          booking['booking_code'] ??
                          'N/A',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('PASSAGERS',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Nom', 'Téléphone', 'Type'],
                  ...((booking['passengers'] as List? ?? []).map((p) => [
                        p['name']?.toString() ?? '—',
                        p['phone']?.toString() ?? '—',
                        p['type']?.toString() ?? 'Adult',
                      ])),
                  if (booking['passengerName'] != null) // Fallback for old data
                    [
                      '${booking['passengerName']}',
                      '${booking['passengerPhone'] ?? '—'}',
                      'Adult'
                    ]
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Siège(s): ${booking['seatNumbers']?.join(", ") ?? booking['seats'] ?? "N/A"}'),
                  pw.Text(
                      'Montant Total: ${booking['totalAmount'] ?? booking['price'] ?? 0} FCFA',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                  child: pw.Text('Merci d\'avoir voyagé avec Ankata !',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
              pw.Center(
                  child: pw.Text(
                      'Ce billet électronique est valable sur présentation d\'une pièce d\'identité.',
                      style: pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> saveAndShare(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Mon ticket Ankata');
  }

  static Future<void> printTicket(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }
}
