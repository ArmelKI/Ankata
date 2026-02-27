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
import '../../config/app_constants.dart';
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
    final companyName = widget.ticket['company'] as String? ?? 'Compagnie';
    final companyColor = CompanyColors.getCompanyColor(companyName);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Votre Billet',
            style: AppTextStyles.h3.copyWith(color: AppColors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            color: AppColors.primary,
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
            children: [
              // Billet Ticket Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.radiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // En-tête Compagnie
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: companyColor.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: companyColor.withValues(alpha: 0.2),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Center(
                              child: Text(
                                companyName[0],
                                style: AppTextStyles.h2
                                    .copyWith(color: companyColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(companyName, style: AppTextStyles.h3),
                                Text('Transport et logistique',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.gray)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.success.withValues(alpha: 0.1),
                              borderRadius: AppRadius.radiusFull,
                            ),
                            child: Text(
                              isCancelled ? 'ANNULÉ' : 'CONFIRMÉ',
                              style: AppTextStyles.caption.copyWith(
                                color: isCancelled
                                    ? AppColors.error
                                    : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Détails du trajet
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DÉPART',
                                        style: AppTextStyles.caption
                                            .copyWith(color: AppColors.gray)),
                                    const SizedBox(height: 4),
                                    Text(widget.ticket['from'] as String? ?? '',
                                        style: AppTextStyles.h3),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.ticket['date']} • ${widget.ticket['departure']}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm),
                                child: Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.gray, size: 28),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ARRIVÉE',
                                        style: AppTextStyles.caption
                                            .copyWith(color: AppColors.gray)),
                                    const SizedBox(height: 4),
                                    Text(widget.ticket['to'] as String? ?? '',
                                        style: AppTextStyles.h3),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.ticket['arrival']}',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.gray),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Ligne de séparation style ticket
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(10)),
                            ),
                          ),
                        ),
                        Expanded(child:
                            LayoutBuilder(builder: (context, constraints) {
                          return Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              (constraints.constrainWidth() / 15).floor(),
                              (index) => const SizedBox(
                                width: 8,
                                height: 1.5,
                                child: DecoratedBox(
                                    decoration:
                                        BoxDecoration(color: AppColors.border)),
                              ),
                            ),
                          );
                        })),
                        SizedBox(
                          height: 20,
                          width: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Informations passager et QR Code
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoItem(
                                    'PASSAGER',
                                    widget.ticket['passengerName'] as String? ??
                                        'N/A'),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildInfoItem(
                                            'SIÈGE',
                                            widget.ticket['seatNumber']
                                                    as String? ??
                                                'N/A')),
                                    Expanded(
                                        child: _buildInfoItem('PRIX',
                                            '${widget.ticket['totalPrice'] ?? 0} FCFA')),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _buildInfoItem(
                                    'CODE DE RÉSERVATION', bookingCode,
                                    isHighlight: true),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: QrImageView(
                                    data: bookingCode,
                                    version: QrVersions.auto,
                                    size: 100,
                                    backgroundColor: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scannez-moi',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.gray),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Boutons d'action
              if (!isCancelled) ...[
                ElevatedButton.icon(
                  onPressed: () => _generatePdfTicket(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger le billet PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed:
                      _isCancelling ? null : () => _showCancelDialog(context),
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cancel_outlined),
                  label: const Text('Annuler ma réservation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.gray, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: isHighlight
              ? AppTextStyles.h4
                  .copyWith(color: AppColors.primary, letterSpacing: 1.5)
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
