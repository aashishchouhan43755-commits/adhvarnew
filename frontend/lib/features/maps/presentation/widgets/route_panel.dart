import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/route_model.dart';
import '../providers/maps_provider.dart';
import 'room_picker_sheet.dart';

class RoutePanel extends ConsumerWidget {
  const RoutePanel({super.key});

  Future<void> _pickStart(BuildContext context, WidgetRef ref) async {
    final room = await showRoomPickerSheet(context, title: "From");
    if (room != null) {
      ref.read(routeSelectionProvider.notifier).setStart(room);
    }
  }

  Future<void> _pickDestination(BuildContext context, WidgetRef ref) async {
    final room = await showRoomPickerSheet(context, title: "To");
    if (room != null) {
      ref.read(routeSelectionProvider.notifier).setDestination(room);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(routeSelectionProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route inputs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _LocationRow(
                        icon: Icons.my_location_rounded,
                        iconGradient: const [Color(0xFF1d4ed8), Color(0xFF3b82f6)],
                        label: selection.start?.roomName ?? "Choose starting point",
                        filled: selection.start != null,
                        onTap: () => _pickStart(context, ref),
                        isFirst: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: Colors.grey.shade200),
                      ),
                      _LocationRow(
                        icon: Icons.location_on_rounded,
                        iconGradient: const [Color(0xFFef4444), Color(0xFFf97316)],
                        label: selection.destination?.roomName ?? "Choose destination",
                        filled: selection.destination != null,
                        onTap: () => _pickDestination(context, ref),
                        isFirst: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                selection.route.when(
                  data: (route) => route == null
                      ? const SizedBox.shrink()
                      : _RouteSummary(route: route),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.20)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade400, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Couldn't calculate a route between those rooms.",
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Location row ──────────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final bool isFirst;

  const _LocationRow({
    required this.icon,
    required this.iconGradient,
    required this.label,
    required this.filled,
    required this.onTap,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isFirst ? Radius.zero : const Radius.circular(16),
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: iconGradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight:
                      filled ? FontWeight.w600 : FontWeight.normal,
                  color: filled
                      ? const Color(0xFF1e293b)
                      : Colors.grey.shade500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Route summary ─────────────────────────────────────────────────────────────

class _RouteSummary extends StatelessWidget {
  final RouteModel route;

  const _RouteSummary({required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            _StatChip(
              icon: Icons.directions_walk_rounded,
              label: route.formattedDistance,
              gradient: const [Color(0xFF059669), Color(0xFF10b981)],
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.schedule_rounded,
              label: route.formattedTime,
              gradient: const [Color(0xFF7c3aed), Color(0xFF8b5cf6)],
            ),
            if (route.floorsTraversed.length > 1) ...[
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.layers_rounded,
                label: "${route.floorsTraversed.length} floors",
                gradient: const [Color(0xFFea580c), Color(0xFFf97316)],
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Steps with timeline styling
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 130),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: route.steps.length,
            itemBuilder: (context, index) {
              final isLast = index == route.steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1d4ed8), Color(0xFF7c3aed)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF1d4ed8)
                                          .withValues(alpha: 0.3),
                                      const Color(0xFF7c3aed)
                                          .withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: isLast ? 0 : 10,
                          top: 2,
                        ),
                        child: Text(
                          route.steps[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.12)).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: gradient)
                .createShader(bounds),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: gradient.first,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
