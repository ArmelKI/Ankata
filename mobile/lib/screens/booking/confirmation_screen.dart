import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const ConfirmationScreen({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  void _copyBookingCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: bookingData['bookingCode']));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code de réservation copié'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _generateAndDownloadPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final tripRaw = bookingData['trip'] as Map<String, dynamic>;
      final passengerRaw = bookingData['passenger'] as Map<String, dynamic>;
      final bookingCode = bookingData['bookingCode'] as String? ?? '';

      // Générer QR code
      final qrImage = await QrPainter(
        data: bookingCode,
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
                          'Billet de Transport',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      width: 100,
                      height: 100,
                      child: pw.Image(pw.MemoryImage(qrBytes)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Code de réservation: $bookingCode',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Informations du trajet',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Départ:',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(tripRaw['from'] ?? '',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(tripRaw['departure'] ?? '',
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Arrivée:',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(tripRaw['to'] ?? '',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(tripRaw['arrival'] ?? '',
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Compagnie:',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(tripRaw['company'] ?? '',
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Siège:',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(bookingData['seat'] ?? '',
                              style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Informations du passager',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Nom:',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(passengerRaw['name'] ?? '',
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Téléphone:',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(passengerRaw['phone'] ?? '',
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.SizedBox(height: 16),
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
                          '• Présentez ce billet à l\'embarquement',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          '• Arrivez 30 min avant le départ',
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Support:',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
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

      final outputDir = await getTemporaryDirectory();
      final outputFile = File('${outputDir.path}/billet_$bookingCode.pdf');
      await outputFile.writeAsBytes(await pdf.save());

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Billet téléchargé: ${outputFile.path}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final tripRaw = bookingData['trip'] as Map<String, dynamic>;
      final passengerRaw = bookingData['passenger'] as Map<String, dynamic>;
      final bookingCode = bookingData['bookingCode'] as String? ?? '';

      final qrImage = await QrPainter(
        data: bookingCode,
        version: QrVersions.auto,
        gapless: false,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImageData(200);

      final qrBytes = qrImage!.buffer.asUint8List();

      // Same PDF generation as download
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ANKATA TRANSPORT',
                            style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue700)),
                        pw.SizedBox(height: 4),
                        pw.Text('Billet de Transport',
                            style: const pw.TextStyle(
                                fontSize: 12, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Container(
                        width: 100,
                        height: 100,
                        child: pw.Image(pw.MemoryImage(qrBytes))),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text('Code: $bookingCode',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 24),
                pw.Text('Trajet: ${tripRaw['from']} → ${tripRaw['to']}',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    'Départ: ${tripRaw['departure']} - Arrivée: ${tripRaw['arrival']}',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),
                pw.Text('Passager: ${passengerRaw['name']}',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Siège: ${bookingData['seat']}',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ],
            );
          },
        ),
      );

      final outputDir = await getTemporaryDirectory();
      final outputFile = File('${outputDir.path}/billet_$bookingCode.pdf');
      await outputFile.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(outputFile.path)],
        text: 'Mon billet Ankata - Code: $bookingCode',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de partage: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripRaw = bookingData['trip'];
    final passengerRaw = bookingData['passenger'];
    final bookingCode = bookingData['bookingCode'] as String? ?? '';

    if (tripRaw is! Map<String, dynamic> ||
        passengerRaw is! Map<String, dynamic>) {
      return Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          title: Text('Confirmation', style: AppTextStyles.h4),
        ),
        body: Center(
          child: Text(
            'Donnees de reservation manquantes',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
          ),
        ),
      );
    }

    final trip = tripRaw;
    final passenger = passengerRaw;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildSuccessIcon(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Réservation confirmée !',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Votre billet a été envoyé par SMS',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.gray),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildBookingCode(context, bookingCode),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQRCode(bookingCode),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTripDetails(trip, passenger),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInstructions(),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle,
        size: 80,
        color: AppColors.success,
      ),
    );
  }

  Widget _buildBookingCode(BuildContext context, String code) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow2,
      ),
      child: Column(
        children: [
          Text(
            'Code de réservation',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: AppTextStyles.h1.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.primary),
                onPressed: () => _copyBookingCode(context),
                tooltip: 'Copier',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Présentez ce code à l\'embarquement',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(String code) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.lightGray, width: 2),
              borderRadius: AppRadius.radiusSm,
            ),
            child: QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Scannez ce code lors de l\'embarquement',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails(
      Map<String, dynamic> trip, Map<String, dynamic> passenger) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détails du voyage', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),

          // Company logo and name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CompanyColors.getCompanyColor(trip['company']),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Center(
                  child: Text(
                    trip['company'][0],
                    style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['company'],
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        Text(
                          '${trip['rating']} (${trip['reviews']} avis)',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg),

          // Route
          _buildDetailRow(
              Icons.route, 'Trajet', '${trip['from']} → ${trip['to']}'),
          _buildDetailRow(Icons.calendar_today, 'Date', trip['date']),
          _buildDetailRow(Icons.access_time, 'Horaire',
              '${trip['departure']} - ${trip['arrival']}'),
          _buildDetailRow(Icons.event_seat, 'Siège', bookingData['seat']),

          const Divider(height: AppSpacing.lg),

          // Passenger
          Text('Passager',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(Icons.person, 'Nom', passenger['name']),
          _buildDetailRow(
              Icons.phone, 'Téléphone', '+226 ${passenger['phone']}'),

          const Divider(height: AppSpacing.lg),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total payé',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              Text('${trip['price'] + 500} FCFA', style: AppTextStyles.price),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: AppColors.info, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Que faire ensuite ?',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInstructionItem('Présentez-vous 30 minutes avant le départ'),
          _buildInstructionItem('Apportez votre pièce d\'identité'),
          _buildInstructionItem(
              'Présentez votre code de réservation ou QR code'),
          _buildInstructionItem(
              'Annulation gratuite jusqu\'à 24h avant le départ'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.check_circle, size: 16, color: AppColors.info),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _generateAndDownloadPdf(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sharePdf(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Retour à l\'accueil'),
            ),
          ),
        ],
      ),
    );
  }
}
