import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kaili/core/theme/app_theme.dart';
import 'package:kaili/domain/entities/entities.dart';
import 'package:kaili/presentation/providers/providers.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final shiftsAsync = ref.watch(shiftsProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: KailiColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(user, shiftsAsync),
            shiftsAsync.when(
              loading: () => _buildLoadingState(),
              error: (err, _) => _buildErrorState(err),
              data: (shifts) => _buildShiftListByDay(shifts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(user, AsyncValue<List<Shift>> shiftsAsync) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mon planning',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: KailiColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user != null
                        ? '${user.firstName} ${user.lastName} • ${user.service}'
                        : 'Chargement...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: KailiColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatsCounter(shiftsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCounter(AsyncValue<List<Shift>> shiftsAsync) {
    return shiftsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (shifts) {
        final now = DateTime.now();
        
        // Calcul des heures réalisées
        double hoursCompleted = 0;

        for (final shift in shifts) {
          final isPast = shift.date.isBefore(DateTime(now.year, now.month, now.day));
          if (isPast && shift.startTime != null && shift.endTime != null) {
            // Parse time strings "HH:mm" format
            final start = _parseTime(shift.startTime!);
            final end = _parseTime(shift.endTime!);
            if (start != null && end != null) {
              final duration = end.difference(start).inMinutes / 60.0;
              hoursCompleted += duration;
            }
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: KailiColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: KailiColors.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatNumber(hoursCompleted.toStringAsFixed(1), 'h'),
              const SizedBox(height: 6),
              Text(
                'réalisées',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: KailiColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatNumber(String value, String unit) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KailiColors.primary,
            ),
          ),
          TextSpan(
            text: unit,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KailiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return DateTime(2024, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      }
    } catch (_) {}
    return null;
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircularProgressIndicator(color: KailiColors.primary),
              const SizedBox(height: 16),
              Text(
                'Chargement du planning...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KailiColors.errorSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Erreur',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: KailiColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: KailiColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftListByDay(List<Shift> shifts) {
    if (shifts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Column(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 48, color: KailiColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Aucun créneau à afficher',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KailiColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Grouper par jour
    final groupedByDay = <DateTime, List<Shift>>{};
    for (final shift in shifts) {
      final dayKey = DateTime(shift.date.year, shift.date.month, shift.date.day);
      groupedByDay.putIfAbsent(dayKey, () => []).add(shift);
    }

    final sortedDays = groupedByDay.keys.toList()..sort();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dayKey = sortedDays[index];
            final dayShifts = groupedByDay[dayKey]!;
            return _DaySection(date: dayKey, shifts: dayShifts);
          },
          childCount: sortedDays.length,
        ),
      ),
    );
  }
}

// ─── Day Section ───────────────────────────────────
class _DaySection extends StatelessWidget {
  final DateTime date;
  final List<Shift> shifts;

  const _DaySection({required this.date, required this.shifts});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête jour
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                DateFormat('EEEE d MMMM', 'fr_FR').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KailiColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: KailiColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Aujourd\'hui',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Les créneaux
        ...shifts.map((shift) => _ShiftDayCard(shift: shift)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Shift Day Card ────────────────────────────────
class _ShiftDayCard extends StatelessWidget {
  final Shift shift;

  const _ShiftDayCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: KailiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KailiColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Type de créneau
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: _getShiftColor(shift.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Infos créneau
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.type.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: KailiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (shift.startTime != null && shift.endTime != null) ...[
                      Icon(Icons.access_time, size: 14, color: KailiColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${shift.startTime} - ${shift.endTime}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: KailiColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.location_on_outlined, size: 14, color: KailiColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shift.service,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: KailiColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Color _getShiftColor(ShiftType type) {
    return switch (type) {
      ShiftType.garde24h => KailiColors.garde24h,
      ShiftType.gardeNuit => KailiColors.garde24h,
      ShiftType.gardeJour => KailiColors.garde24h,
      ShiftType.conge => KailiColors.conge,
      _ => KailiColors.primary,
    };
  }
}
