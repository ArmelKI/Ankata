import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/pdf_service.dart';
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
      final bytes = await PdfService.generateTicket(widget.ticket);
      if (context.mounted) {
        await PdfService.saveAndShare(
            bytes, 'billet_${widget.ticket['bookingCode'] ?? 'ankata'}.pdf');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du PDF: $e')),
        );
      }
    }
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
                  onPressed: () {
                    context.push('/tickets/track', extra: widget.ticket);
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Suivre mon bus en direct'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _generatePdfTicket(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger le billet PDF'),
                  style: OutlinedButton.styleFrom(
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
