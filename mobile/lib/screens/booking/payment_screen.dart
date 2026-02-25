import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import 'dart:math';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentScreen({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _wavePhoneController = TextEditingController();
  String _selectedPaymentMethod = 'wave';
  bool _isProcessing = false;

  @override
  void dispose() {
    _wavePhoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_wavePhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulation du paiement USSD (attente de 4 secondes)
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    // Utilisation du code de réservation généré par l'API
    final bookingCode = widget.bookingData['bookingCode'] ?? 'UNKNOWN';

    // (TODO: Appeler une API backend pour marquer le paiement comme effectif)

    // Naviguer vers l'écran de confirmation
    context.go('/confirmation', extra: {
      ...widget.bookingData,
      'bookingCode': bookingCode,
      'paymentMethod': _selectedPaymentMethod,
      'paymentPhone': _wavePhoneController.text,
    });
  }

  void _safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripRaw = widget.bookingData['trip'];
    if (tripRaw is! Map<String, dynamic>) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _safePop(context),
          ),
          title: Text('Paiement', style: AppTextStyles.h4),
        ),
        body: Center(
          child: Text(
            'Aucun trajet selectionne',
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    final trip = tripRaw;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => _safePop(context),
        ),
        title: Text('Paiement', style: AppTextStyles.h4),
      ),
      body: _isProcessing
          ? _buildProcessingScreen(trip)
          : Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummary(trip),
                        const SizedBox(height: AppSpacing.lg),
                        _buildPaymentMethods(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSecurityInfo(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(trip),
              ],
            ),
    );
  }

  Widget _buildProcessingScreen(Map<String, dynamic> trip) {
    Color methodColor = _selectedPaymentMethod == 'wave'
        ? const Color(0xFF00D8C6)
        : _selectedPaymentMethod == 'orange'
            ? const Color(0xFFFF7900)
            : const Color(0xFF009FE3);

    String methodName = _selectedPaymentMethod == 'wave'
        ? 'Wave'
        : _selectedPaymentMethod == 'orange'
            ? 'Orange Money'
            : 'Moov Money';

    final totalAmount = trip['price'] + 500;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.1 * sin(value * 2 * pi)),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(methodColor),
                          strokeWidth: 6,
                        ),
                      );
                    },
                    onEnd: () {},
                  ),
                ),
                Icon(
                  Icons.phone_android_rounded,
                  size: 60,
                  color: methodColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'En attente de validation',
              style: AppTextStyles.h3.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: methodColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Veuillez consulter votre téléphone',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: methodColor.withOpacity(
                          0.8), // Using withOpacity to ensure dark enough text
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Un popup $methodName a été envoyé au ${_wavePhoneController.text}. Saisissez votre code secret pour valider le paiement de $totalAmount FCFA.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Theme.of(context).colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Ne fermez pas cette application',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          _buildProgressStep(1, 'Recherche', true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'Sélection', true),
          _buildProgressLine(true),
          _buildProgressStep(3, 'Passager', true),
          _buildProgressLine(true),
          _buildProgressStep(4, 'Paiement', true),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: completed ? AppColors.primary : Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.surface, size: 18)
                : Text(
                    step.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: completed ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool completed) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: completed ? AppColors.primary : Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> trip) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif de la commande', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryRow(
              'Trajet', '${trip['departure']} → ${trip['arrival']}'),
          _buildSummaryRow('Compagnie', trip['company']),
          _buildSummaryRow('Date', trip['date']),
          _buildSummaryRow('Siège', widget.bookingData['seat']),
          const Divider(height: AppSpacing.lg),
          _buildSummaryRow('Prix du billet', '${trip['price']} FCFA',
              isBold: true),
          _buildSummaryRow('Frais de service', '500 FCFA'),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total à payer',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              Text('${trip['price'] + 500} FCFA', style: AppTextStyles.price),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Méthode de paiement', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),

          // Wave Payment
          _buildPaymentOption(
            'wave',
            'Wave',
            'Paiement mobile sécurisé',
            Icons.account_balance_wallet,
            const Color(0xFF00D8C6),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Orange Money
          _buildPaymentOption(
            'orange',
            'Orange Money',
            'Paiement via Orange Money',
            Icons.phone_android,
            const Color(0xFFFF7900),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Moov Money
          _buildPaymentOption(
            'moov',
            'Moov Africa Money',
            'Paiement via Moov Money',
            Icons.account_balance_wallet,
            const Color(0xFF009FE3),
          ),

          // Phone number input for selected method
          ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _wavePhoneController,
              decoration: InputDecoration(
                labelText:
                    'Numéro ${_selectedPaymentMethod == "wave" ? "Wave" : _selectedPaymentMethod == "orange" ? "Orange Money" : "Moov Money"}',
                hintText: 'Ex: 70 12 34 56',
                prefixIcon: const Icon(Icons.phone_android),
                prefixText: '+226 ',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (_selectedPaymentMethod == 'wave'
                        ? const Color(0xFF00D8C6)
                        : _selectedPaymentMethod == 'orange'
                            ? const Color(0xFFFF7900)
                            : const Color(0xFF009FE3))
                    .withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 20,
                    color: _selectedPaymentMethod == 'wave'
                        ? const Color(0xFF00D8C6)
                        : _selectedPaymentMethod == 'orange'
                            ? const Color(0xFFFF7900)
                            : const Color(0xFF009FE3),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Vous recevrez une notification pour valider le paiement',
                      style: AppTextStyles.caption.copyWith(
                        color: _selectedPaymentMethod == 'wave'
                            ? const Color(0xFF00D8C6)
                            : _selectedPaymentMethod == 'orange'
                                ? const Color(0xFFFF7900)
                                : const Color(0xFF009FE3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = value);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Theme.of(context).scaffoldBackgroundColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppRadius.radiusSm,
          color: isSelected ? color.withValues(alpha: 0.05) : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (newValue) {
                setState(() => _selectedPaymentMethod = newValue!);
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: AppColors.success, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement 100% sécurisé',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toutes vos transactions sont cryptées et sécurisées',
                  style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> trip) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à payer',
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                Text('${trip['price'] + 500} FCFA', style: AppTextStyles.price),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedPaymentMethod == 'wave'
                          ? Icons.account_balance_wallet
                          : Icons.phone_android,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _selectedPaymentMethod == 'wave'
                          ? 'Payer avec Wave'
                          : _selectedPaymentMethod == 'orange'
                              ? 'Payer avec Orange Money'
                              : 'Payer avec Moov Money',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
