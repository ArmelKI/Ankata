import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Intégration auto-login : on tente de récupérer l'utilisateur courant
      final userResponse = await ref.read(apiServiceProvider).getCurrentUser();
      if (userResponse['user'] != null) {
        ref.read(currentUserProvider.notifier).state = userResponse['user'];
        if (mounted) {
          context.go('/home');
        }
        return;
      }
    } catch (e) {
      // Échec silencieux, ira vers onboarding/login
    }

    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ankata_logo.jpeg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Application de réservation de transport',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
