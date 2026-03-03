import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SeatSelectionWidget extends StatefulWidget {
  final List<String> selectedSeats;
  final Function(List<String>) onSeatsSelected;
  final int maxSeats;
  final int totalSeats; // New: configurable seat count from DB
  final List<String>? occupiedSeats; // New: actual occupied seats from DB

  const SeatSelectionWidget({
    Key? key,
    required this.selectedSeats,
    required this.onSeatsSelected,
    this.maxSeats = 4,
    this.totalSeats = 45, // Default from DB
    this.occupiedSeats,
  }) : super(key: key);

  @override
  State<SeatSelectionWidget> createState() => _SeatSelectionWidgetState();
}

class _SeatSelectionWidgetState extends State<SeatSelectionWidget> {
  late List<String> _selected;
  late int rows;
  late int cols;
  late List<String> _occupiedSeats;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedSeats);
    _occupiedSeats = widget.occupiedSeats ?? [];
    
    // Calculate grid dimensions based on total seats (45 = 5 rows x 9 cols)
    // Standard bus layout: 45 seats = 5 rows x 9 columns
    // 40 seats = 4 rows x 10 columns, 50 seats = 5 rows x 10, etc.
    cols = 9; // Standard column count
    rows = (widget.totalSeats / cols).ceil();
  }

  String _seatNumber(int row, int col) {
    final rowLetter = String.fromCharCode(65 + row); // A, B, C, etc.
    return '$rowLetter${col + 1}';
  }

  void _toggleSeat(String seat) {
    if (_occupiedSeats.contains(seat)) {
      // Can't select occupied seat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ce siège est déjà réservé'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      if (_selected.contains(seat)) {
        _selected.remove(seat);
      } else {
        if (_selected.length < widget.maxSeats) {
          _selected.add(seat);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Maximum ${widget.maxSeats} sièges autorisés',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
      widget.onSeatsSelected(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Sélectionner les sièges (${_selected.length}/${widget.maxSeats})',
            style: AppTextStyles.h4,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.8,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: widget.totalSeats,
            itemBuilder: (context, index) {
              final row = index ~/ cols;
              final col = index % cols;
              final seat = _seatNumber(row, col);
              final isOccupied = _occupiedSeats.contains(seat);
              final isSelected = _selected.contains(seat);

              return GestureDetector(
                onTap: isOccupied ? null : () => _toggleSeat(seat),
                child: Container(
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? AppColors.gray
                        : isSelected
                            ? AppColors.primary
                            : AppColors.white,
                    border: Border.all(
                      color: isOccupied
                          ? AppColors.gray.withValues(alpha: 0.5)
                          : AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Center(
                    child: Text(
                      seat,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOccupied
                            ? Colors.white
                            : isSelected
                                ? Colors.white
                                : AppColors.charcoal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend('Disponible', AppColors.white, AppColors.primary),
              _buildLegend('Occupé', AppColors.gray, null),
              _buildLegend('Sélectionné', AppColors.primary, null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color bgColor, Color? borderColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            border: borderColor != null ? Border.all(color: borderColor) : null,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
