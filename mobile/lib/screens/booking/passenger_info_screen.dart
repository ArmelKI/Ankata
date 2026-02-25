import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/seat_selection_widget.dart';

class PassengerInfoScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> tripData;

  const PassengerInfoScreen({
    Key? key,
    required this.tripData,
  }) : super(key: key);

  @override
  ConsumerState<PassengerInfoScreen> createState() =>
      _PassengerInfoScreenState();
}

class _PassengerInfoScreenState extends ConsumerState<PassengerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  List<String> _selectedSeats = [];

  bool _acceptTerms = false;
  String? _idType = 'CNI';
  int _adultCount = 1;
  int _childCount = 0;

  @override
  void initState() {
    super.initState();
    final passengers = widget.tripData['passengers'];
    if (passengers is int && passengers > 0) {
      _adultCount = passengers;
    }

    // Pre-fill user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final firstName = user['firstName'] ?? user['first_name'] ?? '';
        final lastName = user['lastName'] ?? user['last_name'] ?? '';
        setState(() {
          _nameController.text = '$firstName $lastName'.trim();
          final phone = user['phoneNumber'] ?? user['phone_number'] ?? '';
          _phoneController.text =
              phone.startsWith('+226') ? phone.substring(4).trim() : phone;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _validateAndContinue() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez accepter les conditions générales'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      final trip = widget.tripData['trip'] as Map<String, dynamic>;
      final seatSurcharge = _selectedSeats.length * 500; // 500 FCFA par siège

      try {
        final response = await ref.read(apiServiceProvider).createBooking({
          'scheduleId': trip['scheduleId'],
          'lineId': trip['lineId'],
          'companyId': trip['companyId'],
          'passengers': [
            {
              'name': _nameController.text,
              'phone': _phoneController.text,
            }
          ],
          'seatNumbers': _selectedSeats,
          'departureDate': trip['date'],
          'luggageWeightKg': 0,
        });

        final booking = response['booking'];
        final totalWithSeats = (booking['totalAmount'] ?? 0) + seatSurcharge;

        if (mounted) {
          context.push('/payment', extra: {
            'amount': totalWithSeats,
            'basePrice': booking['basePrice'],
            'serviceFee': booking['serviceFee'],
            'seatSurcharge': seatSurcharge,
            'bookingId': booking['id']?.toString() ?? '',
            'tripDetails': '${trip['from']} → ${trip['to']}',
            'bookingCode': booking['bookingCode'],
            'trip': trip,
            'passenger': {
              'name': _nameController.text,
              'phone': _phoneController.text,
            },
            'seats': _selectedSeats.join(', '),
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de réservation: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => _safePop(context),
        ),
        title: Text('Informations passager', style: AppTextStyles.h4),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTripSummary(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPassengerCounts(),
                    const SizedBox(height: AppSpacing.lg),
                    SeatSelectionWidget(
                      selectedSeats: _selectedSeats,
                      onSeatsSelected: (seats) {
                        setState(() => _selectedSeats = seats);
                      },
                      maxSeats: 4,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPersonalInfo(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildIdentityInfo(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTermsCheckbox(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(),
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
          _buildProgressLine(false),
          _buildProgressStep(4, 'Paiement', false),
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

  Widget _buildTripSummary() {
    final tripRaw = widget.tripData['trip'];
    if (tripRaw is! Map<String, dynamic>) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusMd,
          boxShadow: AppShadows.shadow1,
        ),
        child: Text(
          'Aucun trajet selectionne',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
        ),
      );
    }
    final trip = tripRaw;
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
          Text('Récapitulatif', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Compagnie',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
              Text(trip['company'],
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Horaire',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
              Text('${trip['departure']} → ${trip['arrival']}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Siège',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
              Text(widget.tripData['seat'] ?? 'Non assigné',
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Text('${trip['price']} FCFA', style: AppTextStyles.price),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCounts() {
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
          Text('Nombre de passagers', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          _buildCounterRow('Adultes', _adultCount, (delta) {
            final next = _adultCount + delta;
            if (next < 1 || next > 9) return;
            setState(() => _adultCount = next);
          }),
          const SizedBox(height: AppSpacing.sm),
          _buildCounterRow('Enfants', _childCount, (delta) {
            final next = _childCount + delta;
            if (next < 0 || next > 9) return;
            setState(() => _childCount = next);
          }),
        ],
      ),
    );
  }

  Widget _buildCounterRow(
      String label, int value, void Function(int) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Row(
          children: [
            IconButton(
              onPressed: () => onChange(-1),
              icon: const Icon(Icons.remove, size: 18),
            ),
            Text('$value', style: AppTextStyles.bodyMedium),
            IconButton(
              onPressed: () => onChange(1),
              icon: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
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
          Text('Informations personnelles', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              hintText: 'Ex: Votre nom complet',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom complet';
              }
              if (value.length < 3) {
                return 'Le nom doit contenir au moins 3 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              hintText: 'Ex: 70 12 34 56',
              prefixIcon: Icon(Icons.phone),
              prefixText: '+226 ',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              if (value.replaceAll(' ', '').length != 8) {
                return 'Le numéro doit contenir 8 chiffres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityInfo() {
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
          Text('Pièce d\'identité', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _idType,
            decoration: const InputDecoration(
              labelText: 'Type de pièce',
              prefixIcon: Icon(Icons.badge),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'CNI', child: Text('Carte Nationale d\'Identité')),
              DropdownMenuItem(value: 'Passeport', child: Text('Passeport')),
              DropdownMenuItem(
                  value: 'Permis', child: Text('Permis de conduire')),
            ],
            onChanged: (value) {
              setState(() => _idType = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _idNumberController,
            decoration: const InputDecoration(
              labelText: 'Numéro de pièce',
              hintText: 'Ex: B123456789',
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le numéro de votre pièce';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Row(
              children: [
                const Icon(Icons.info, size: 20, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Votre pièce d\'identité sera vérifiée lors de l\'embarquement',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() => _acceptTerms = value ?? false);
            },
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() => _acceptTerms = !_acceptTerms);
                },
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.charcoal),
                    children: [
                      const TextSpan(text: 'J\'accepte les '),
                      TextSpan(
                        text: 'conditions générales',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _validateAndContinue,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: AppColors.white))
                : const Text('Continuer vers le paiement'),
          ),
        ),
      ),
    );
  }
}
