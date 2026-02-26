import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../utils/haptic_helper.dart';

enum PaymentMethod {
  orangeMoney,
  mtnMoney,
  card,
}

enum PaymentStatus {
  pending,
  success,
  failed,
  cancelled,
}

class PaymentData {
  final String orderId;
  final int amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? errorMessage;
  final DateTime createdAt;

  PaymentData({
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'amount': amount,
        'method': method.toString(),
        'status': status.toString(),
        'errorMessage': errorMessage,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      orderId: json['orderId'],
      amount: json['amount'],
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['method'],
        orElse: () => PaymentMethod.orangeMoney,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      errorMessage: json['errorMessage'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class PaymentService {
  static const String _paymentHistoryKey = 'payment_history';

  static Future<PaymentData> initiatePayment({
    required int amount,
    required String bookingId,
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    try {
      if (kDebugMode ||
          const bool.fromEnvironment('MOCK_PAYMENT', defaultValue: true)) {
        await Future.delayed(const Duration(seconds: 2));
        final mockPayment = PaymentData(
          orderId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          method: method,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
        );
        await _addToHistory(mockPayment);
        HapticHelper.lightImpact();
        return mockPayment;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      String methodStr;
      switch (method) {
        case PaymentMethod.orangeMoney:
          methodStr = 'orange_money_bf';
          break;
        case PaymentMethod.mtnMoney:
          methodStr = 'moov_money_bf';
          break;
        case PaymentMethod.card:
          methodStr = 'card';
          break;
      }

      Map<String, dynamic> body = {
        'amount': amount,
        'bookingId': bookingId,
        'paymentMethod': methodStr,
        'phoneNumber': phoneNumber,
      };

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final paymentResponse = data['payment'] ?? {};

        final payment = PaymentData(
          orderId: paymentResponse['id']?.toString() ?? '',
          amount: amount,
          method: method,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
        );

        // Sauvegarder dans l'historique
        await _addToHistory(payment);

        // Haptic feedback
        HapticHelper.lightImpact();

        return payment;
      } else {
        throw Exception('Payment initiation failed: ${response.body}');
      }
    } catch (e) {
      HapticHelper.error();
      debugPrint('Payment initiation error: $e');
      rethrow;
    }
  }

  static Future<PaymentStatus> checkPaymentStatus(String orderId) async {
    try {
      if (kDebugMode && orderId.startsWith('mock_')) {
        await Future.delayed(const Duration(seconds: 1));
        HapticHelper.success();
        return PaymentStatus.success;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/payments/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentMap = data['payment'] ?? {};
        final statusString =
            (paymentMap['status']?.toString() ?? 'pending').toLowerCase();

        PaymentStatus status;
        if (statusString.contains('success') || statusString.contains('paid')) {
          status = PaymentStatus.success;
          HapticHelper.success();
        } else if (statusString.contains('fail') ||
            statusString.contains('error')) {
          status = PaymentStatus.failed;
          HapticHelper.error();
        } else if (statusString.contains('cancel')) {
          status = PaymentStatus.cancelled;
        } else {
          status = PaymentStatus.pending;
        }

        return status;
      } else {
        throw Exception('Status check failed');
      }
    } catch (e) {
      debugPrint('Payment status check error: $e');
      return PaymentStatus.pending;
    }
  }

  // Polling pour Orange Money / MTN (USSD prompt)
  static Future<PaymentStatus> waitForPaymentConfirmation(
    String orderId, {
    Duration timeout = const Duration(minutes: 5),
    Duration pollInterval = const Duration(seconds: 3),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final status = await checkPaymentStatus(orderId);

      if (status != PaymentStatus.pending) {
        return status;
      }

      // Attendre avant le prochain check
      await Future.delayed(pollInterval);
    }

    // Timeout
    return PaymentStatus.failed;
  }

  // Obtenir l'historique des paiements
  static Future<List<PaymentData>> getPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_paymentHistoryKey);

      if (historyJson == null) return [];

      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList.map((json) => PaymentData.fromJson(json)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading payment history: $e');
      return [];
    }
  }

  // Sauvegarder paiement dans l'historique
  static Future<void> _addToHistory(PaymentData payment) async {
    try {
      final history = await getPaymentHistory();
      history.insert(0, payment);

      // Garder seulement les 50 derniers
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _paymentHistoryKey,
        jsonEncode(history.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving payment history: $e');
    }
  }

  // Mettre à jour le statut dans l'historique
  static Future<void> updatePaymentStatus(
    String orderId,
    PaymentStatus newStatus, {
    String? errorMessage,
  }) async {
    try {
      final history = await getPaymentHistory();
      final index = history.indexWhere((p) => p.orderId == orderId);

      if (index != -1) {
        history[index] = PaymentData(
          orderId: history[index].orderId,
          amount: history[index].amount,
          method: history[index].method,
          status: newStatus,
          errorMessage: errorMessage,
          createdAt: history[index].createdAt,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _paymentHistoryKey,
          jsonEncode(history.map((p) => p.toJson()).toList()),
        );
      }
    } catch (e) {
      debugPrint('Error updating payment status: $e');
    }
  }

  // Calculer les statistiques de paiement
  static Future<Map<String, dynamic>> getPaymentStats() async {
    final history = await getPaymentHistory();

    int totalTransactions = history.length;
    int successfulTransactions =
        history.where((p) => p.status == PaymentStatus.success).length;
    int totalSpent = history
        .where((p) => p.status == PaymentStatus.success)
        .fold(0, (sum, p) => sum + p.amount);

    Map<PaymentMethod, int> methodCount = {};
    for (var method in PaymentMethod.values) {
      methodCount[method] = history.where((p) => p.method == method).length;
    }

    return {
      'totalTransactions': totalTransactions,
      'successfulTransactions': successfulTransactions,
      'totalSpent': totalSpent,
      'successRate': totalTransactions > 0
          ? (successfulTransactions / totalTransactions * 100).round()
          : 0,
      'methodCount': methodCount,
      'averageAmount': successfulTransactions > 0
          ? (totalSpent / successfulTransactions).round()
          : 0,
    };
  }

  // Formater le montant
  static String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} FCFA';
  }

  // Obtenir l'abreviation de la methode
  static String getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return 'OM';
      case PaymentMethod.mtnMoney:
        return 'MM';
      case PaymentMethod.card:
        return 'CB';
    }
  }

  // Obtenir le nom de la méthode
  static String getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.mtnMoney:
        return 'MTN Mobile Money';
      case PaymentMethod.card:
        return 'Carte bancaire';
    }
  }

  // Valider le numéro de téléphone
  static bool isValidPhoneNumber(String phone) {
    // Burkina Faso: +226XXXXXXXX ou 226XXXXXXXX ou XXXXXXXX
    final regex = RegExp(r'^(\+?226)?[0-9]{8}$');
    return regex.hasMatch(phone.replaceAll(' ', ''));
  }

  // Normaliser le numéro (ajouter +226)
  static String normalizePhoneNumber(String phone) {
    phone = phone.replaceAll(' ', '').replaceAll('-', '');

    if (phone.startsWith('+226')) {
      return phone;
    } else if (phone.startsWith('226')) {
      return '+$phone';
    } else if (phone.length == 8) {
      return '+226$phone';
    }

    return phone;
  }

  // Vérifier si Orange Money est disponible (basé sur le préfixe)
  static bool isOrangeNumber(String phone) {
    phone = normalizePhoneNumber(phone);
    // Orange BF commence par +226 05, 06, 07, 45, 46, 47
    final orangePrefixes = ['05', '06', '07', '45', '46', '47'];
    return orangePrefixes.any((prefix) => phone.contains('+226$prefix'));
  }

  // Vérifier si MTN est disponible
  static bool isMTNNumber(String phone) {
    phone = normalizePhoneNumber(phone);
    // MTN BF commence par +226 50, 51, 52, 53, 54, 55, 56, 57, 60, 61, 62, 63, 64, 65, 66, 67, 70, 71, 72, 73, 74, 75, 76, 77
    final mtnPrefixes = [
      '50',
      '51',
      '52',
      '53',
      '54',
      '55',
      '56',
      '57',
      '60',
      '61',
      '62',
      '63',
      '64',
      '65',
      '66',
      '67',
      '70',
      '71',
      '72',
      '73',
      '74',
      '75',
      '76',
      '77'
    ];
    return mtnPrefixes.any((prefix) => phone.contains('+226$prefix'));
  }

  // Détecter automatiquement la méthode recommandée
  static PaymentMethod? detectRecommendedMethod(String phone) {
    if (isOrangeNumber(phone)) {
      return PaymentMethod.orangeMoney;
    } else if (isMTNNumber(phone)) {
      return PaymentMethod.mtnMoney;
    }
    return null; // Carte par défaut
  }
}
