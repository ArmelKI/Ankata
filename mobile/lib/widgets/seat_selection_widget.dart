import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SeatSelectionWidget extends StatefulWidget {
  final List<String> selectedSeats;
  final Function(List<String>) onSeatsSelected;
  final int maxSeats;

  const SeatSelectionWidget({
    Key? key,
    required this.selectedSeats,
    required this.onSeatsSelected,
    this.maxSeats = 4,
  }) : super(key: key);

  @override
  State<SeatSelectionWidget> createState() => _SeatSelectionWidgetState();
}

class _SeatSelectionWidgetState extends State<SeatSelectionWidget> {
  late List<String> _selected;

  // Bus configuration
  static const int rows = 12;

  // Mock occupied seats
  static const List<String> occupiedSeats = [
    '1A',
    '3B',
    '5C',
    '8D',
    '10A',
    '11C'
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedSeats);
  }

  String _seatLabel(int row, int col) {
    final colLetter = String.fromCharCode(65 + col); // A, B, C, D
    return '${row + 1}$colLetter';
  }

  void _toggleSeat(String seat) {
    setState(() {
      if (_selected.contains(seat)) {
        _selected.remove(seat);
      } else {
        if (_selected.length < widget.maxSeats) {
          _selected.add(seat);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${widget.maxSeats} sièges autorisés'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      widget.onSeatsSelected(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Choisir vos sièges', style: AppTextStyles.h4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selected.length}/${widget.maxSeats}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bus Layout
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.gray.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                // Front / Driver area
                _buildBusFront(),
                const SizedBox(height: 20),

                // Seats grid
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows,
                  itemBuilder: (context, rowIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left side seats (A, B)
                          _buildSeat(rowIndex, 0),
                          const SizedBox(width: 8),
                          _buildSeat(rowIndex, 1),

                          // Aisle
                          const SizedBox(width: 32),

                          // Right side seats (C, D)
                          _buildSeat(rowIndex, 2),
                          const SizedBox(width: 8),
                          _buildSeat(rowIndex, 3),
                        ],
                      ),
                    );
                  },
                ),

                // Back of bus
                const SizedBox(height: 10),
                const Icon(Icons.door_back_door_outlined,
                    color: AppColors.gray, size: 24),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildBusFront() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.circle_outlined, color: AppColors.charcoal, size: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.charcoal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('AVANT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Icon(Icons.door_front_door_outlined,
            color: AppColors.charcoal, size: 24),
      ],
    );
  }

  Widget _buildSeat(int row, int col) {
    final label = _seatLabel(row, col);
    final isOccupied = occupiedSeats.contains(label);
    final isSelected = _selected.contains(label);

    return GestureDetector(
      onTap: isOccupied ? null : () => _toggleSeat(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isOccupied
              ? AppColors.gray.withOpacity(0.2)
              : isSelected
                  ? AppColors.primary
                  : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOccupied
                ? Colors.transparent
                : isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Seat Icon / Design
            if (!isOccupied)
              Positioned(
                top: 4,
                child: Container(
                  width: 30,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // Decorative element
                  ),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isOccupied
                    ? AppColors.gray
                    : isSelected
                        ? Colors.white
                        : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(
            'Disponible', AppColors.white, AppColors.primary.withOpacity(0.3)),
        _legendItem(
            'Occupé', AppColors.gray.withOpacity(0.2), Colors.transparent),
        _legendItem('Sélectionné', AppColors.primary, AppColors.primary),
      ],
    );
  }

  Widget _legendItem(String label, Color color, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
