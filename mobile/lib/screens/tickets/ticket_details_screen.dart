import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';

class TicketDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  ConsumerState<TicketDetailsScreen> createState() =>
      _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends ConsumerState<TicketDetailsScreen> {
  bool _isCancelling = false;

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le billet'),
        content: const Text(
            'Êtes-vous sûr de vouloir annuler ce billet ? Des frais d\'annulation peuvent s\'appliquer selon les conditions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non, garder'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelTicket();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTicket() async {
    setState(() => _isCancelling = true);
    try {
      final bookingId = widget.ticket['id']?.toString() ??
          widget.ticket['bookingId']?.toString();
      if (bookingId == null || bookingId.isEmpty) {
        throw Exception('ID de réservation manquant');
      }

      await ref
          .read(apiServiceProvider)
          .cancelBooking(bookingId, 'Annulation par le passager');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Billet annulé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Impossible d\'annuler ce billet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  Future<void> _generatePdfTicket(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Générer QR code en image
      final qrImage = await QrPainter(
        data: widget.ticket['bookingCode'] as String? ?? '',
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
                              widget.ticket['company'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 16),
                          _buildPdfInfo('Code de réservation',
                              widget.ticket['bookingCode'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 16),
                          _buildPdfInfo(
                              'Date d\'achat',
                              widget.ticket['purchaseDate'] as String? ??
                                  'N/A'),
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
                                            widget.ticket['from'] as String? ??
                                                'N/A',
                                            style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Text(
                                            '${widget.ticket['date'] ?? 'N/A'} • ${widget.ticket['departure'] ?? 'N/A'}',
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
                                            widget.ticket['to'] as String? ??
                                                'N/A',
                                            style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Text(
                                            '${widget.ticket['date'] ?? 'N/A'} • ${widget.ticket['arrival'] ?? 'N/A'}',
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
                          _buildPdfInfo(
                              'Passager',
                              widget.ticket['passengerName'] as String? ??
                                  'N/A'),
                          pw.SizedBox(height: 12),
                          _buildPdfInfo(
                              'Téléphone',
                              widget.ticket['passengerPhone'] as String? ??
                                  'N/A'),
                          pw.SizedBox(height: 12),
                          _buildPdfInfo('Siège',
                              widget.ticket['seatNumber'] as String? ?? 'N/A'),
                          pw.SizedBox(height: 12),
                          _buildPdfInfo('Prix',
                              '${widget.ticket['totalPrice'] ?? 0} FCFA'),
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
                            widget.ticket['bookingCode'] as String? ?? '',
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
      final file =
          File('${output.path}/billet_${widget.ticket['bookingCode']}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Votre billet Ankata - ${widget.ticket['from']} → ${widget.ticket['to']}',
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
    final bookingCode = widget.ticket['bookingCode'] as String? ?? '';
    final status = widget.ticket['status'] as String? ?? '';
    final isCancelled = status.toLowerCase() == 'cancelled';

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
                  '${widget.ticket['from']} → ${widget.ticket['to']}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${widget.ticket['date']} • ${widget.ticket['departure']} - ${widget.ticket['arrival']}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Center(
                child: Text(
                  'BILLET ANNULÉ',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generatePdfTicket(context),
                icon: const Icon(Icons.download),
                label: const Text('Télécharger le billet PDF'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    _isCancelling ? null : () => _showCancelDialog(context),
                icon: _isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined),
                label: const Text('Annuler le billet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
