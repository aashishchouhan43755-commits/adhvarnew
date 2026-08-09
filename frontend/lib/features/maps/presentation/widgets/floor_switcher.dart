import 'package:flutter/material.dart';

import '../../../../core/models/floor_model.dart';

class FloorSwitcher extends StatelessWidget {
  final List<FloorModel> floors;
  final int? selectedFloorId;
  final void Function(FloorModel floor) onSelected;

  const FloorSwitcher({
    super.key,
    required this.floors,
    required this.selectedFloorId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: floors.map((floor) {
            final selected = floor.id == selectedFloorId;
            return GestureDetector(
              onTap: () => onSelected(floor),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF1d4ed8), Color(0xFF7c3aed)],
                        )
                      : null,
                  color: selected ? null : Colors.transparent,
                ),
                child: Text(
                  floor.name,
                  style: TextStyle(
                    color:
                        selected ? Colors.white : Colors.grey.shade600,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
