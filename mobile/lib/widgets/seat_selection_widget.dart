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
  static const int rows = 4;
  static const int cols = 10;
  static const List<String> occupiedSeats = [
    'A5',
    'B2',
    'C7',
    'D3'
  ]; // Mock données

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedSeats);
  }

  String _seatNumber(int row, int col) {
    final rowLetter = String.fromCharCode(65 + row); // A, B, C, D
    return '$rowLetter${col + 1}';
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.8,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: rows * cols,
            itemBuilder: (context, index) {
              final row = index ~/ cols;
              final col = index % cols;
              final seat = _seatNumber(row, col);
              final isOccupied = occupiedSeats.contains(seat);
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
                          ? AppColors.gray.withOpacity(0.5)
                          : AppColors.primary.withOpacity(0.3),
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
