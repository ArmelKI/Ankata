import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../services/api_service.dart';
import '../../utils/company_logo_helper.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({Key? key}) : super(key: key);

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingTickets = [];
  List<Map<String, dynamic>> _pastTickets = [];
  List<Map<String, dynamic>> _cancelledTickets = [];

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
      final apiService = ApiService();
      final response = await apiService.getMyBookings();

      final List<dynamic> allBookings = response['bookings'] ?? [];

      final now = DateTime.now();
      final List<Map<String, dynamic>> upcoming = [];
      final List<Map<String, dynamic>> past = [];
      final List<Map<String, dynamic>> cancelled = [];

      for (var b in allBookings) {
        final booking = b as Map<String, dynamic>;

        // Convert API format to UI format
        final schedule = booking['schedule'] ?? {};
        final line = schedule['line'] ?? {};
        final company = line['company'] ?? {};
        final companyName = company['name'] ?? 'Inconnu';

        final departureTimeRaw = schedule['departureTime'] ?? '';
        final arrivalTimeRaw = schedule['arrivalTime'] ?? '';

        final mappedBooking = {
          'id': booking['id']?.toString() ?? '',
          'bookingCode': booking['bookingCode'] ?? '',
          'company': companyName,
          'from': line['originCity'] ?? '',
          'to': line['destinationCity'] ?? '',
          'date': booking['travelDate'] ?? '',
          'departure': departureTimeRaw,
          'arrival': arrivalTimeRaw,
          'seat': booking['seatNumber']?.toString() ?? 'N/A',
          'price': booking['totalPrice'] ?? 0,
          'rating': company['rating_average'] ?? 0.0,
          'status': booking['status'] ?? 'pending',
          ...booking,
        };

        if (mappedBooking['status'] == 'cancelled') {
          cancelled.add(mappedBooking);
          continue;
        }

        try {
          // Check if date is in the past
          final dateStr = mappedBooking['date'];
          final dateObj = DateTime.parse(dateStr);
          if (dateObj.isBefore(DateTime(now.year, now.month, now.day))) {
            past.add(mappedBooking);
          } else {
            upcoming.add(mappedBooking);
          }
        } catch (_) {
          upcoming.add(mappedBooking);
        }
      }

      setState(() {
        _upcomingTickets = upcoming;
        _pastTickets = past;
        _cancelledTickets = cancelled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tickets: $e');
      setState(() {
        _upcomingTickets = [];
        _pastTickets = [];
        _cancelledTickets = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement de vos billets'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshTickets() async {
    await _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Text('Mes Billets', style: AppTextStyles.h3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surface,
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
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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

  Widget _buildTicketCard(Map<String, dynamic> ticket, String type) {
    final canCancel = type == 'upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                CompanyLogoHelper.buildLogo(
                  ticket['company'] as String? ?? '',
                  size: 60,
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
                        color: Theme.of(context).colorScheme.surface,
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
                                .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                              .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                                .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number,
                                size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                ticket['bookingCode'],
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_seat,
                                size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Siège ${ticket['seat']}',
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${ticket['price']} FCFA',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
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

              bool success = false;
              try {
                final apiService = ApiService();
                await apiService.cancelBooking(
                  bookingId,
                  'Annulé par l\'utilisateur',
                );
                success = true;
              } catch (e) {
                print('Erreur lors de l\'annulation de la réservation: $e');
              }

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
