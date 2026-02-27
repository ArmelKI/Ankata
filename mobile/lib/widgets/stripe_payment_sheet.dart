import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/haptic_helper.dart';

class StripePaymentSheet extends StatefulWidget {
  final int amount;
  final VoidCallback onPaymentSuccess;

  const StripePaymentSheet({
    Key? key,
    required this.amount,
    required this.onPaymentSuccess,
  }) : super(key: key);

  static void show(BuildContext context,
      {required int amount, required VoidCallback onPaymentSuccess}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StripePaymentSheet(
        amount: amount,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<StripePaymentSheet> createState() => _StripePaymentSheetState();
}

class _StripePaymentSheetState extends State<StripePaymentSheet> {
  bool _isProcessing = false;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    HapticHelper.lightImpact();

    // Simulate Stripe processing
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      widget.onPaymentSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Détails du paiement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Montant à payer',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.gray),
                    ),
                    Text(
                      '${widget.amount} FCFA',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Card Number
                _buildFieldLabel('Numéro de carte'),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '4242 4242 4242 4242',
                    prefixIcon: const Icon(Icons.credit_card),
                    border:
                        OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    // Expiry
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Expiration'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _expiryController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusMd),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // CVC
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('CVC'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cvcController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '123',
                              border: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusMd),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Payer ${widget.amount} FCFA',
                            style: AppTextStyles.button
                                .copyWith(color: AppColors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 14, color: AppColors.gray),
                      const SizedBox(width: 4),
                      Text(
                        'Paiement sécurisé par Stripe',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.gray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
      ),
    );
  }
}
