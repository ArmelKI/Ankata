import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/payment_service.dart';
import '../../widgets/animated_button.dart';
import '../../utils/haptic_helper.dart';
import '../../widgets/progress_stepper.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int amount;
  final String bookingId;
  final String tripDetails;
  final int? basePrice;
  final int? serviceFee;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.bookingId,
    required this.tripDetails,
    this.basePrice,
    this.serviceFee,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selectedMethod = PaymentMethod.orangeMoney;
  bool _isProcessing = false;
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _discountAmount = 0;
  bool _isApplyingPromo = false;
  String? _appliedPromoCode;
  String? _promoError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Paiement'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress stepper
          const ProgressStepper(
            currentStep: 3,
            steps: [
              'Recherche',
              'Choix',
              'Passagers',
              'Paiement',
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Trip summary card
                    _buildTripSummaryCard(),

                    const SizedBox(height: 24),

                    // Amount to pay
                    _buildAmountCard(),

                    const SizedBox(height: 24),

                    // Promo Code Section
                    _buildPromoCodeSection(),

                    const SizedBox(height: 24),

                    // Payment method title
                    const Text(
                      'Choisir le mode de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment methods
                    _buildPaymentMethodCard(
                      method: PaymentMethod.orangeMoney,
                      icon: 'OM',
                      title: 'Orange Money',
                      subtitle: 'Paiement instantane et securise',
                      badge: '70% marche',
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentMethodCard(
                      method: PaymentMethod.mtnMoney,
                      icon: 'MM',
                      title: 'MTN Mobile Money',
                      subtitle: 'Paiement instantane et securise',
                      badge: '20% marche',
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentMethodCard(
                      method: PaymentMethod.card,
                      icon: 'CB',
                      title: 'Carte bancaire',
                      subtitle: 'Visa, Mastercard acceptees',
                      badge: 'International',
                    ),

                    // Phone number field (for mobile money)
                    if (_selectedMethod != PaymentMethod.card) ...[
                      const SizedBox(height: 24),
                      _buildPhoneField(),
                    ],

                    const SizedBox(height: 24),

                    // Security badge
                    _buildSecurityBadge(),

                    const SizedBox(height: 80), // Space for button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating payment button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedButton(
          text: _isProcessing
              ? 'Traitement en cours...'
              : 'Payer ${PaymentService.formatAmount(widget.amount - _discountAmount)}',
          isLoading: _isProcessing,
          onPressed: _processPayment,
          icon: _isProcessing ? null : Icons.lock_outline,
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_bus,
              color: Colors.blue.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Récapitulatif',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tripDetails,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Montant à payer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PaymentService.formatAmount(widget.amount - _discountAmount),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Paiement sécurisé',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (widget.basePrice != null && widget.serviceFee != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Billet',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  PaymentService.formatAmount(widget.basePrice!),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Frais Ankata',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  PaymentService.formatAmount(widget.serviceFee!),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (_discountAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Réduction Code Promo (${_appliedPromoCode})',
                    style:
                        TextStyle(color: Colors.green.shade200, fontSize: 13),
                  ),
                  Text(
                    '- ${PaymentService.formatAmount(_discountAmount)}',
                    style: TextStyle(
                        color: Colors.green.shade200,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code Promo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  decoration: InputDecoration(
                    hintText: 'Ex: WELCOME10',
                    errorText: _promoError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  enabled: !_isApplyingPromo && _appliedPromoCode == null,
                ),
              ),
              const SizedBox(width: 12),
              if (_appliedPromoCode == null)
                ElevatedButton(
                  onPressed: _isApplyingPromo ? null : _handleApplyPromo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _isApplyingPromo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Appliquer'),
                )
              else
                IconButton(
                  onPressed: () {
                    setState(() {
                      _appliedPromoCode = null;
                      _discountAmount = 0;
                      _promoController.clear();
                    });
                  },
                  icon: const Icon(Icons.cancel, color: AppColors.error),
                ),
            ],
          ),
          if (_appliedPromoCode != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Code $_appliedPromoCode appliqué avec succès !',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleApplyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplyingPromo = true;
      _promoError = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.validatePromoCode(code, widget.amount);

      if (mounted) {
        setState(() {
          _isApplyingPromo = false;
          _appliedPromoCode = code;
          _discountAmount = (result['discountAmount'] as num).toInt();
        });

        HapticHelper.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code promo appliqué !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApplyingPromo = false;
          _promoError = e.toString().contains('400')
              ? 'Code promo invalide ou expiré'
              : 'Erreur lors de la validation';
        });
        HapticHelper.error();
      }
    }
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() => _selectedMethod = method);

        // Auto-detect phone number method
        if (_phoneController.text.isNotEmpty) {
          final recommended = PaymentService.detectRecommendedMethod(
            _phoneController.text,
          );
          if (recommended != null) {
            setState(() => _selectedMethod = recommended);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Radio
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  HapticHelper.lightImpact();
                  setState(() => _selectedMethod = value);
                }
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro de téléphone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+226 XX XX XX XX',
            prefixIcon: const Icon(Icons.phone),
            suffixIcon: _phoneController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _phoneController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro';
            }
            if (!PaymentService.isValidPhoneNumber(value)) {
              return 'Numéro invalide (8 chiffres)';
            }
            return null;
          },
          onChanged: (value) {
            // Auto-detect payment method
            if (value.length >= 8) {
              final recommended = PaymentService.detectRecommendedMethod(value);
              if (recommended != null && recommended != _selectedMethod) {
                setState(() => _selectedMethod = recommended);
                HapticHelper.lightImpact();

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Méthode recommandée: ${PaymentService.getMethodName(recommended)}',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Tu recevras un prompt USSD pour confirmer le paiement',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Colors.green.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Paiement 100% sécurisé et confidentiel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    // Validate form
    if (_selectedMethod != PaymentMethod.card) {
      if (!_formKey.currentState!.validate()) {
        HapticHelper.error();
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final phoneNumber = _selectedMethod != PaymentMethod.card
          ? PaymentService.normalizePhoneNumber(_phoneController.text)
          : '';

      // Initiate payment
      final payment = await PaymentService.initiatePayment(
        amount: widget.amount,
        bookingId: widget.bookingId,
        method: _selectedMethod,
        phoneNumber: phoneNumber,
      );

      if (!mounted) return;

      // Show dialog
      if (_selectedMethod == PaymentMethod.card) {
        // For card, show Stripe sheet (TODO)
        _showCardPaymentSheet();
      } else {
        // For mobile money, show waiting dialog
        _showMobileMoneyWaitingDialog(payment);
      }
    } catch (e) {
      if (!mounted) return;

      HapticHelper.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isProcessing = false);
    }
  }

  void _showMobileMoneyWaitingDialog(PaymentData payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    PaymentService.getMethodIcon(_selectedMethod),
                    style: const TextStyle(fontSize: 40),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'En attente de confirmation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Compose *144# sur ton téléphone\net confirme le paiement avec ton code PIN',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isProcessing = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );

    // Start polling for payment status
    PaymentService.waitForPaymentConfirmation(payment.orderId).then((status) {
      if (!mounted) return;

      Navigator.pop(context); // Close waiting dialog

      if (status == PaymentStatus.success) {
        HapticHelper.success();
        _navigateToSuccessScreen();
      } else {
        HapticHelper.error();
        _showPaymentFailedDialog();
      }

      setState(() => _isProcessing = false);
    });
  }

  void _showCardPaymentSheet() {
    // TODO: Implement Stripe payment sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paiement par carte bientôt disponible'),
      ),
    );
    setState(() => _isProcessing = false);
  }

  void _navigateToSuccessScreen() {
    context.go(
      '/payment-success',
      extra: {
        'amount': widget.amount,
        'bookingId': widget.bookingId,
      },
    );
  }

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Paiement échoué'),
          ],
        ),
        content: const Text(
          'Le paiement n\'a pas pu être complété. Vérifie ton solde et réessaye.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
