import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String _mockLatestVersion = '1.1.0';
  static const String _mockStoreUrl =
      'https://play.google.com/store/apps/details?id=bf.ankata';

  static Future<void> checkUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isVersionLower(currentVersion, _mockLatestVersion)) {
        if (!context.mounted) return;
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  static bool _isVersionLower(String current, String latest) {
    final v1 = current.split('.').map(int.parse).toList();
    final v2 = latest.split('.').map(int.parse).toList();

    for (var i = 0; i < v1.length && i < v2.length; i++) {
      if (v2[i] > v1[i]) return true;
      if (v2[i] < v1[i]) return false;
    }
    return v2.length > v1.length;
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Mise à jour disponible'),
        content: const Text(
          'Une nouvelle version d\'Ankata est disponible. Veuillez mettre à jour pour profiter des dernières fonctionnalités et corrections.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = Uri.parse(_mockStoreUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }
}
