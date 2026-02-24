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
    if (_selectedPaymentMethod == 'wave') {
      if (_wavePhoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer votre numéro Wave'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    // Simulation du paiement
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    // Générer un code de réservation
    final bookingCode = _generateBookingCode();

    // Naviguer vers l'écran de confirmation
    context.go('/confirmation', extra: {
      ...widget.bookingData,
      'bookingCode': bookingCode,
      'paymentMethod': _selectedPaymentMethod,
    });
  }

  void _safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  String _generateBookingCode() {
    final random = Random();
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // Sans I, O pour éviter confusion
    const numbers = '0123456789';
    
    String code = '';
    // 3 lettres
    for (int i = 0; i < 3; i++) {
      code += letters[random.nextInt(letters.length)];
    }
    // 6 chiffres
    for (int i = 0; i < 6; i++) {
      code += numbers[random.nextInt(numbers.length)];
    }
    
    return code;
  }

  @override
  Widget build(BuildContext context) {
    final tripRaw = widget.bookingData['trip'];
    if (tripRaw is! Map<String, dynamic>) {
      return Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => _safePop(context),
          ),
          title: Text('Paiement', style: AppTextStyles.h4),
        ),
        body: Center(
          child: Text(
            'Aucun trajet selectionne',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
          ),
        ),
      );
    }
    final trip = tripRaw;
    
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => _safePop(context),
        ),
        title: Text('Paiement', style: AppTextStyles.h4),
      ),
      body: _isProcessing
          ? _buildProcessingScreen()
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

  Widget _buildProcessingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Paiement en cours...',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _selectedPaymentMethod == 'wave'
                ? 'Veuillez valider le paiement sur votre téléphone'
                : 'Traitement de votre paiement',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.white,
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
            color: completed ? AppColors.primary : AppColors.lightGray,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check, color: AppColors.white, size: 18)
                : Text(
                    step.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: completed ? AppColors.primary : AppColors.gray,
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
        color: completed ? AppColors.primary : AppColors.lightGray,
      ),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> trip) {
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
          Text('Récapitulatif de la commande', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryRow('Trajet', '${trip['departure']} → ${trip['arrival']}'),
          _buildSummaryRow('Compagnie', trip['company']),
          _buildSummaryRow('Date', trip['date']),
          _buildSummaryRow('Siège', widget.bookingData['seat']),
          const Divider(height: AppSpacing.lg),
          _buildSummaryRow('Prix du billet', '${trip['price']} FCFA', isBold: true),
          _buildSummaryRow('Frais de service', '500 FCFA'),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total à payer', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
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
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
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
        color: AppColors.white,
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
              labelText: 'Numéro ${_selectedPaymentMethod == "wave" ? "Wave" : _selectedPaymentMethod == "orange" ? "Orange Money" : "Moov Money"}',
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
                      : const Color(0xFF009FE3)).withValues(alpha: 0.1),
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
            color: isSelected ? color : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppRadius.radiusSm,
          color: isSelected ? color.withValues(alpha: 0.05) : AppColors.white,
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
                    style: AppTextStyles.caption.copyWith(color: AppColors.gray),
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
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray),
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
        color: AppColors.white,
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
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
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
