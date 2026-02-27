import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../services/notification_service.dart';
import '../../providers/app_providers.dart';
import '../../utils/haptic_helper.dart';
import '../../widgets/animated_button.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final int amount;
  final String bookingId;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.bookingId,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _confettiController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();

    // Checkmark animation
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _checkmarkAnimation = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkmarkController.forward();
      HapticHelper.success();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _confettiController.forward();
    });

    _scheduleTripReminder();
  }

  Future<void> _scheduleTripReminder() async {
    try {
      final api = ref.read(apiServiceProvider);
      final booking = await api.getBookingDetails(widget.bookingId);

      final departureDateStr = booking['departure_date'] as String?;
      final departureTimeStr = booking['departure_time'] as String?;

      if (departureDateStr != null && departureTimeStr != null) {
        // Parse date and time
        // Example: 2024-05-20 and 08:30
        final dateParts = departureDateStr.split('-');
        final timeParts = departureTimeStr.split(':');

        final departureDateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        // Schedule 1 hour before
        final reminderTime =
            departureDateTime.subtract(const Duration(minutes: 60));

        if (reminderTime.isAfter(DateTime.now())) {
          await NotificationService.scheduleNotification(
            id: widget.bookingId.hashCode,
            title: 'Rappel de voyage 🚌',
            body:
                'Votre bus pour ${booking['to_city']} part dans 1 heure. N\'oubliez pas votre ticket !',
            scheduledDate: reminderTime,
          );
          debugPrint('Notification scheduled for $reminderTime');
        }
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti background
            AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    animation: _confettiAnimation.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated checkmark
                    ScaleTransition(
                      scale: _checkmarkAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Success title
                    const Text(
                      'Paiement réussi !',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Amount
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.amount} FCFA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Success message
                    Text(
                      'Ta réservation a été confirmée avec succès',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Booking ID card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Numéro de réservation',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            widget.bookingId,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 32),

                    // Info cards
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: 'E-mail de confirmation',
                      subtitle: 'Envoyé à ton adresse e-mail',
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.directions_bus,
                      title: 'Point de départ',
                      subtitle: 'Présente-toi 15 min avant le départ',
                      color: Colors.orange,
                    ),

                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.phone,
                      title: 'Besoin d\'aide ?',
                      subtitle: 'Contacte-nous au +226 XX XX XX XX',
                      color: Colors.green,
                    ),

                    const SizedBox(height: 40),

                    // Action buttons
                    AnimatedButton(
                      text: 'Voir mes réservations',
                      onPressed: () {
                        context.go('/my-bookings');
                      },
                      icon: Icons.receipt_long,
                    ),

                    const SizedBox(height: 12),

                    SecondaryButton(
                      text: 'Retour à l\'accueil',
                      onPressed: () {
                        context.go('/home');
                      },
                      icon: Icons.home_outlined,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Confetti painter for celebration effect
class ConfettiPainter extends CustomPainter {
  final double animation;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.animation})
      : particles = List.generate(50, (index) => ConfettiParticle());

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final progress = animation;
      final x = size.width * particle.x;
      final y = size.height * progress * particle.speed;

      if (y > size.height) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * particle.rotation);

      // Draw confetti shape
      if (particle.shape == 0) {
        // Circle
        canvas.drawCircle(Offset.zero, particle.size, paint);
      } else {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size * 2,
            height: particle.size,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      animation != oldDelegate.animation;
}

class ConfettiParticle {
  final double x;
  final double speed;
  final double rotation;
  final double size;
  final Color color;
  final int shape;

  ConfettiParticle()
      : x = math.Random().nextDouble(),
        speed = 0.5 + math.Random().nextDouble() * 1.5,
        rotation = math.Random().nextDouble() * math.pi * 4,
        size = 4 + math.Random().nextDouble() * 8,
        color = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.purple,
          Colors.pink,
        ][math.Random().nextInt(7)],
        shape = math.Random().nextInt(2);
}
