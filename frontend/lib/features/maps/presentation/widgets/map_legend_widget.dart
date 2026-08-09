import 'package:flutter/material.dart';

/// Collapsible floating legend showing node type colors.
class MapLegendWidget extends StatefulWidget {
  const MapLegendWidget({super.key});

  @override
  State<MapLegendWidget> createState() => _MapLegendWidgetState();
}

class _MapLegendWidgetState extends State<MapLegendWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  static const _items = [
    _LegendItem(color: Color(0xFF1A73E8), icon: Icons.my_location_rounded, label: 'Start'),
    _LegendItem(color: Color(0xFFEA4335), icon: Icons.location_on_rounded, label: 'Destination'),
    _LegendItem(color: Color(0xFF00B2B2), icon: Icons.route_rounded, label: 'Route'),
    _LegendItem(color: Color(0xFF3E7CB1), icon: Icons.elevator_outlined, label: 'Lift'),
    _LegendItem(color: Color(0xFFB5563A), icon: Icons.stairs_outlined, label: 'Staircase'),
    _LegendItem(color: Color(0xFF4E8B5C), icon: Icons.wc_outlined, label: 'Washroom'),
    _LegendItem(color: Color(0xFFB23A3A), icon: Icons.emergency_outlined, label: 'Emergency Exit'),
    _LegendItem(color: Color(0xFFD48806), icon: Icons.desk_outlined, label: 'Reception'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1d4ed8), Color(0xFF7c3aed)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.map_outlined,
                        size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Legend',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.expand_more_rounded,
                        size: 18, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // Items
            FadeTransition(
              opacity: _fadeAnim,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 1,
                          color: Colors.grey.shade100,
                          indent: 12,
                          endIndent: 12,
                        ),
                        const SizedBox(height: 6),
                        for (final item in _items)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(item.icon,
                                      size: 13, color: item.color),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final IconData icon;
  final String label;

  const _LegendItem({
    required this.color,
    required this.icon,
    required this.label,
  });
}
