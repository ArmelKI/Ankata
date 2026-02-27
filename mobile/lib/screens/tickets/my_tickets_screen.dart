import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../services/booking_service.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingTickets = [];
  List<Map<String, dynamic>> _pastTickets = [];
  List<Map<String, dynamic>> _cancelledTickets = [];

  BookingService get _bookingService =>
      BookingService(ref.read(apiServiceProvider));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final upcoming = await _bookingService.getUserBookings(status: 'upcoming');
      final past = await _bookingService.getUserBookings(status: 'past');
      final cancelled = await _bookingService.getCancelledBookings();

      if (!mounted) return;

      setState(() {
        _upcomingTickets = upcoming.map(_mapBookingToTicket).toList();
        _pastTickets = past.map(_mapBookingToTicket).toList();
        _cancelledTickets = cancelled.map(_mapBookingToTicket).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _upcomingTickets = [];
        _pastTickets = [];
        _cancelledTickets = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Impossible de charger les billets'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _refreshTickets() async {
    await _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Mes Billets', style: AppTextStyles.h3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primary,
          labelStyle:
              AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
            Tab(text: 'Annulés'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTicketsList(_upcomingTickets, 'upcoming'),
                _buildTicketsList(_pastTickets, 'past'),
                _buildTicketsList(_cancelledTickets, 'cancelled'),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildShimmer(60, 60),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmer(120, 16),
                    const SizedBox(height: 8),
                    _buildShimmer(80, 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildShimmer(double.infinity, 40),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppGradients.shimmer,
        borderRadius: AppRadius.radiusSm,
      ),
    );
  }

  Widget _buildTicketsList(List<Map<String, dynamic>> tickets, String type) {
    if (tickets.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _refreshTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _buildTicketCard(ticket, type);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String message;

    switch (type) {
      case 'upcoming':
        title = 'Aucun billet à venir';
        message = 'Vous n\'avez pas encore réservé de trajet';
        break;
      case 'past':
        title = 'Aucun voyage effectué';
        message = 'Vos voyages terminés apparaîtront ici';
        break;
      case 'cancelled':
        title = 'Aucun billet annulé';
        message = 'Vos billets annulés apparaîtront ici';
        break;
      default:
        title = 'Aucun billet';
        message = '';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 60,
                color: AppColors.gray,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            if (type == 'upcoming') ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.search),
                label: const Text('Rechercher un trajet'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _mapBookingToTicket(Map<String, dynamic> booking) {
    final bookingCode = booking['booking_code'] ?? booking['bookingCode'] ?? '';
    final company = booking['company_name'] ??
        booking['companyName'] ??
        booking['company'] ??
        'Compagnie';
    final from = booking['origin_city'] ?? booking['from'] ?? '';
    final to = booking['destination_city'] ?? booking['to'] ?? '';
    final date =
        _formatDate(booking['departure_date'] ?? booking['departureDate']);
    final departure =
        _formatTime(booking['departure_time'] ?? booking['departureTime']);
    final arrival =
        _formatTime(booking['arrival_time'] ?? booking['arrivalTime']);
    final seat = _formatSeats(
        booking['seat_numbers'] ?? booking['seatNumbers'] ?? booking['seat']);
    final price = booking['total_price'] ?? booking['totalPrice'] ?? 0;

    return {
      'id': booking['id']?.toString() ?? bookingCode,
      'bookingCode': bookingCode,
      'company': company,
      'from': from,
      'to': to,
      'date': date,
      'departure': departure,
      'arrival': arrival,
      'seat': seat,
      'price': price,
      'rating': booking['rating'] ?? 0.0,
    };
  }

  String _formatDate(dynamic raw) {
    if (raw == null) {
      return '--';
    }
    DateTime? date;
    if (raw is DateTime) {
      date = raw;
    } else if (raw is String) {
      date = DateTime.tryParse(raw);
    }
    if (date == null) {
      return '--';
    }
    return DateFormat('d MMM yyyy', 'en').format(date);
  }

  String _formatTime(dynamic raw) {
    if (raw == null) {
      return '--:--';
    }
    if (raw is DateTime) {
      return DateFormat('HH:mm').format(raw);
    }
    if (raw is String) {
      if (raw.contains('T')) {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) {
          return DateFormat('HH:mm').format(parsed);
        }
      }
      if (raw.length >= 5) {
        return raw.substring(0, 5);
      }
    }
    return '--:--';
  }

  String _formatSeats(dynamic raw) {
    if (raw == null) {
      return '-';
    }
    if (raw is List) {
      return raw.map((s) => s.toString()).join(', ');
    }
    return raw.toString();
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, String type) {
    final canCancel = type == 'upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          // Header with company
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: CompanyColors.getCompanyColor(ticket['company'])
                  .withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CompanyColors.getCompanyColor(ticket['company']),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Center(
                    child: Text(
                      ticket['company'][0],
                      style: AppTextStyles.h2.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['company'],
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            ticket['rating'].toString(),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (type == 'upcoming')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text(
                      'Confirmé',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Trip details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['departure'],
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            ticket['from'],
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_forward,
                            color: AppColors.primary, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          ticket['date'],
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.gray),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ticket['arrival'],
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            ticket['to'],
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gray),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number,
                              size: 16, color: AppColors.gray),
                          const SizedBox(width: 4),
                          Text(
                            ticket['bookingCode'],
                            style: AppTextStyles.bodySmall
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.event_seat,
                              size: 16, color: AppColors.gray),
                          const SizedBox(width: 4),
                          Text(
                            'Siège ${ticket['seat']}',
                            style: AppTextStyles.bodySmall
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '${ticket['price']} FCFA',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showTicketDetails(context, ticket);
                        },
                        icon: const Icon(Icons.qr_code, size: 20),
                        label: const Text('Voir le billet'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (canCancel)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showCancelDialog(context, ticket);
                          },
                          icon: const Icon(Icons.cancel, size: 20),
                          label: const Text('Annuler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDetails(BuildContext context, Map<String, dynamic> ticket) {
    context.push('/ticket-details', extra: ticket);
  }

  void _showCancelDialog(BuildContext context, Map<String, dynamic> ticket) {
    final fee = _calculateCancellationFee(ticket);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir annuler cette réservation ?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 20, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      fee == 0
                          ? 'Annulation gratuite (plus de 36h avant le depart)'
                          : 'Frais d\'annulation: 500 FCFA (moins de 36h)',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non, garder'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Appeler le service pour annuler
              final bookingId = (ticket['id'] as String?) ??
                  (ticket['bookingCode'] as String?);

              if (bookingId == null || bookingId.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Annulation indisponible pour ce billet'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                return;
              }

              final bookingService = _bookingService;
              final success = await bookingService.cancelBooking(
                bookingId,
                'Annulée par l\'utilisateur',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (fee == 0
                              ? 'Reservation annulee gratuitement'
                              : 'Reservation annulee. Frais: 500 FCFA')
                          : 'Erreur: Impossible d\'annuler',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }

              if (success) {
                _refreshTickets();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  int _calculateCancellationFee(Map<String, dynamic> ticket) {
    final dateRaw = ticket['date'] as String?;
    final departureRaw = ticket['departure'] as String?;
    if (dateRaw == null || departureRaw == null) {
      return 0;
    }

    try {
      final date = DateFormat('d MMM yyyy', 'en').parse(dateRaw);
      final timeParts = departureRaw.split(':');
      final departureDate = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      final diff = departureDate.difference(DateTime.now());
      if (diff.inHours >= 36) {
        return 0;
      }
      return 500;
    } catch (_) {
      return 0;
    }
  }
}
