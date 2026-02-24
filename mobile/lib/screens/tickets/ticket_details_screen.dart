import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_theme.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  Future<void> _generatePdfTicket(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Générer QR code en image
      final qrImage = await QrPainter(
        data: ticket['bookingCode'] as String? ?? '',
        version: QrVersions.auto,
        gapless: false,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImageData(200);

      final qrBytes = qrImage!.buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ANKATA TRANSPORT',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Burkina Faso',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        'BILLET DE TRANSPORT',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue700,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 32),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 24),

                // Informations du voyage
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Colonne gauche - Infos voyage
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfInfo('Compagnie',
                              ticket['company'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 16),
                          _buildPdfInfo('Code de réservation',
                              ticket['bookingCode'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 16),
                          _buildPdfInfo('Date d\'achat',
                              ticket['purchaseDate'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 24),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'TRAJET',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'DÉPART',
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                              color: PdfColors.grey600,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Text(
                                            ticket['from'] as String? ?? 'N/A',
                                            style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Text(
                                            '${ticket['date'] ?? 'N/A'} • ${ticket['departure'] ?? 'N/A'}',
                                            style: const pw.TextStyle(
                                              fontSize: 10,
                                              color: PdfColors.grey700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: pw.Icon(
                                        const pw.IconData(
                                            0xe5d8), // arrow_forward
                                        size: 24,
                                        color: PdfColors.blue700,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'ARRIVÉE',
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                              color: PdfColors.grey600,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Text(
                                            ticket['to'] as String? ?? 'N/A',
                                            style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Text(
                                            '${ticket['date'] ?? 'N/A'} • ${ticket['arrival'] ?? 'N/A'}',
                                            style: const pw.TextStyle(
                                              fontSize: 10,
                                              color: PdfColors.grey700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          _buildPdfInfo('Passager',
                              ticket['passengerName'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 12),
                          _buildPdfInfo('Téléphone',
                              ticket['passengerPhone'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 12),
                          _buildPdfInfo('Siège',
                              ticket['seatNumber'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 12),
                          _buildPdfInfo(
                              'Prix', '${ticket['totalPrice'] ?? 0} FCFA'),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 24),

                    // Colonne droite - QR Code
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        border:
                            pw.Border.all(color: PdfColors.grey300, width: 2),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'SCANNEZ CE CODE',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 12),
                          pw.Image(
                            pw.MemoryImage(qrBytes),
                            width: 150,
                            height: 150,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            ticket['bookingCode'] as String? ?? '',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                pw.Divider(),
                pw.SizedBox(height: 16),

                // Pied de page
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Conditions:',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '• Annulation gratuite jusqu\'à 36h avant le départ',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          '• Frais de 500 FCFA si annulation < 36h',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          '• Présentez ce billet à l\'embarquement',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Support client:',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '+226 XX XX XX XX',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          'support@ankata.bf',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Sauvegarder et partager le PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/billet_${ticket['bookingCode']}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Votre billet Ankata - ${ticket['from']} → ${ticket['to']}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du PDF: $e')),
        );
      }
    }
  }

  pw.Widget _buildPdfInfo(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingCode = ticket['bookingCode'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Votre billet', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.radiusMd,
              boxShadow: AppShadows.shadow1,
            ),
            child: Column(
              children: [
                Text('Code billet',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.gray)),
                const SizedBox(height: AppSpacing.sm),
                Text(bookingCode, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.md),
                QrImageView(
                  data: bookingCode,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: AppColors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.radiusMd,
              boxShadow: AppShadows.shadow1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trajet', style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${ticket['from']} → ${ticket['to']}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${ticket['date']} • ${ticket['departure']} - ${ticket['arrival']}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _generatePdfTicket(context),
              icon: const Icon(Icons.download),
              label: const Text('Télécharger le billet PDF'),
            ),
          ),
        ],
      ),
    );
  }
}
