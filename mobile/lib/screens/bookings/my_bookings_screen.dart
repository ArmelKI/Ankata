import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final resp = await api.getMyBookings();
      final list = resp['bookings'] as List<dynamic>? ?? [];
      setState(() {
        _allBookings = list.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _upcomingBookings => _allBookings
      .where((b) =>
          (b['status'] ?? '') == 'confirmed' ||
          (b['status'] ?? '') == 'pending')
      .toList();

  List<Map<String, dynamic>> get _pastBookings => _allBookings
      .where((b) =>
          (b['status'] ?? '') == 'completed' ||
          (b['status'] ?? '') == 'cancelled')
      .toList();

  List<Map<String, dynamic>> get _pendingBookings =>
      _allBookings.where((b) => (b['status'] ?? '') == 'pending').toList();

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final id = (booking['id'] ?? booking['bookingId'])?.toString() ?? '';
    if (id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler la réservation'),
        content: const Text(
            'Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final api = ref.read(apiServiceProvider);
      await api.cancelBooking(id, 'Annulé par l\'utilisateur');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Mes Réservations', style: AppTextStyles.h3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'En attente'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_upcomingBookings),
                    _buildBookingList(_pendingBookings),
                    _buildBookingList(_pastBookings, showCancel: false),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64, color: AppColors.gray.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Impossible de charger les réservations',
                style: AppTextStyles.h4, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_error ?? '',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<Map<String, dynamic>> bookings,
      {bool showCancel = true}) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: bookings.length,
        itemBuilder: (context, i) =>
            _buildBookingCard(bookings[i], showCancel: showCancel),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 72, color: AppColors.gray.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('Aucune réservation', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'Vos réservations apparaîtront ici dès que vous en aurez effectué une.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search),
              label: const Text('Rechercher un trajet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking,
      {bool showCancel = true}) {
    final status = booking['status'] ?? 'pending';
    final from = booking['originCity'] ??
        booking['origin_city'] ??
        booking['from'] ??
        '—';
    final to = booking['destinationCity'] ??
        booking['destination_city'] ??
        booking['to'] ??
        '—';
    final company = booking['companyName'] ?? booking['company_name'] ?? '—';
    final date = booking['departureDate'] ?? booking['departure_date'] ?? '—';
    final time = booking['departureTime'] ?? booking['departure_time'] ?? '';
    final code = booking['bookingCode'] ?? booking['booking_code'] ?? '';
    final price = booking['totalAmount'] ?? booking['total_amount'] ?? 0;
    final passengers =
        booking['passengerCount'] ?? booking['passenger_count'] ?? 1;

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;
    switch (status) {
      case 'confirmed':
        statusColor = AppColors.success;
        statusLabel = 'Confirmée';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        statusIcon = Icons.hourglass_top;
        break;
      case 'completed':
        statusColor = AppColors.gray;
        statusLabel = 'Terminée';
        statusIcon = Icons.flag;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusLabel = 'Annulée';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.gray;
        statusLabel = status;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shadowColor: AppColors.charcoal.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBookingDetail(booking),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: route + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$from → $to',
                          style: AppTextStyles.h4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          company,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.gray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              // Info row
              Row(
                children: [
                  _infoChip(Icons.calendar_today_outlined, date),
                  if (time.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _infoChip(Icons.access_time, time),
                  ],
                  const SizedBox(width: 12),
                  _infoChip(Icons.people_outline, '$passengers passager(s)'),
                ],
              ),
              if (code.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(
                        Icons.confirmation_number_outlined, 'Code: $code'),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              // Footer: price + actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price > 0 ? '$price FCFA' : '—',
                    style: AppTextStyles.price,
                  ),
                  Row(
                    children: [
                      if (showCancel &&
                          (status == 'confirmed' || status == 'pending'))
                        TextButton.icon(
                          onPressed: () => _cancelBooking(booking),
                          icon: const Icon(Icons.close,
                              size: 16, color: AppColors.error),
                          label: const Text('Annuler',
                              style: TextStyle(color: AppColors.error)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => _showBookingDetail(booking),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Détails'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gray),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showBookingDetail(Map<String, dynamic> booking) {
    final from = booking['originCity'] ?? booking['from'] ?? '—';
    final to = booking['destinationCity'] ?? booking['to'] ?? '—';
    final code = booking['bookingCode'] ?? booking['booking_code'] ?? 'N/A';
    final status = booking['status'] ?? 'N/A';
    final date = booking['departureDate'] ?? booking['departure_date'] ?? '—';
    final time = booking['departureTime'] ?? booking['departure_time'] ?? '—';
    final company = booking['companyName'] ?? booking['company_name'] ?? '—';
    final price = booking['totalAmount'] ?? 0;
    final passengers = booking['passengerCount'] ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle + title
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Détails de la réservation', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              _detailRow('Trajet', '$from → $to'),
              _detailRow('Compagnie', company),
              _detailRow('Date', date),
              _detailRow('Heure', time),
              _detailRow('Passagers', '$passengers'),
              _detailRow('Montant', price > 0 ? '$price FCFA' : '—'),
              _detailRow('Code de réservation', code),
              _detailRow('Statut', status),
              const SizedBox(height: AppSpacing.lg),
              if (status == 'confirmed' || status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _cancelBooking(booking);
                    },
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppColors.error),
                    label: const Text('Annuler la réservation',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
