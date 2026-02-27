import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  Map<String, dynamic>? _walletData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getWalletData();

      if (mounted) {
        setState(() {
          _walletData = data;
          _transactions = data['transactions'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Historique du Portefeuille'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    _buildWalletHeader(),
                    Expanded(
                      child: _transactions.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                return _buildTransactionItem(
                                    _transactions[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildWalletHeader() {
    final balance = _walletData?['balance'] ?? 0;
    final xp = _walletData?['xp'] ?? 0;
    final level = _walletData?['level'] ?? 'Bronze';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solde disponible',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
                ),
                Text(
                  '${balance.toString()} FCFA',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Column(
              children: [
                Text(
                  level.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$xp XP',
                  style: AppTextStyles.overline.copyWith(color: AppColors.gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.gray.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction pour le moment',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final type = tx['type'] as String? ?? 'unknown';
    final amount = tx['amount'] as num? ?? 0;
    final status = tx['status'] as String? ?? 'completed';
    final date = tx['created_at'] as String? ?? '';
    final description = tx['description'] as String? ?? '';

    IconData icon;
    Color color;
    String prefix = '-';

    switch (type) {
      case 'payment':
        icon = Icons.shopping_bag_outlined;
        color = AppColors.charcoal;
        prefix = '-';
        break;
      case 'referral_bonus':
        icon = Icons.card_giftcard;
        color = Colors.green;
        prefix = '+';
        break;
      case 'refund':
        icon = Icons.replay;
        color = Colors.blue;
        prefix = '+';
        break;
      default:
        icon = Icons.payment;
        color = AppColors.gray;
        prefix = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(date),
          style: AppTextStyles.caption.copyWith(color: AppColors.gray),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$prefix${amount.toInt().toString()} F',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: prefix == '+' ? Colors.green : AppColors.charcoal,
              ),
            ),
            Text(
              status.toUpperCase(),
              style: AppTextStyles.overline.copyWith(
                color: status == 'completed' ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
