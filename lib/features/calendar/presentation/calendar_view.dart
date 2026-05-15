import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../timer/providers/streak_provider.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF14142B);
    final subTextColor = isDark ? const Color(0xFF9096A5) : const Color(0xFF5A5A6D);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'My Streaks',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDA3B21),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${streak.currentStreakDays}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Keep the momentum going! You're on a roll.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: subTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildCalendarCard(streak.streakDates, isDark, textColor),
            const SizedBox(height: 24),
            _buildStatsCard(streak.currentStreakDays, isDark, textColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(List<String> streakDates, bool isDark, Color textColor) {
    Set<DateTime> streakSet = streakDates.map((dateStr) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime.utc(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return DateTime.now();
    }).toSet();

    final cardBg = isDark ? const Color(0xFF20263F) : Colors.white;
    final shadowColor = isDark ? Colors.transparent : const Color(0xFF6153FF).withOpacity(0.05);
    final labelColor = isDark ? const Color(0xFFC1C6D9) : const Color(0xFF5E4940);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
          weekendStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(
              day,
              textColor,
              isDark,
              isStreak: _isStreakDay(day, streakSet),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(
              day,
              textColor,
              isDark,
              isToday: true,
              isStreak: _isStreakDay(day, streakSet),
            );
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, textColor, isDark, isOutside: true);
          },
        ),
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  bool _isStreakDay(DateTime day, Set<DateTime> streakSet) {
    return streakSet.any(
      (streakDay) =>
          streakDay.year == day.year &&
          streakDay.month == day.month &&
          streakDay.day == day.day,
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    Color defaultTextColor,
    bool isDark, {
    bool isToday = false,
    bool isStreak = false,
    bool isOutside = false,
  }) {
    Color textColor = isOutside
        ? (isDark ? const Color(0xFF4A5065) : const Color(0xFFD0D4E0))
        : defaultTextColor;
    
    if (isToday) textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? const Color(0xFFDA3B21) : Colors.transparent,
        border: isStreak && !isToday
            ? Border.all(color: const Color(0xFFF9A18D), width: 1.5)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday || isStreak
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: textColor,
                height: 1.0,
              ),
            ),
            if (isStreak || isToday) ...[
              const SizedBox(height: 2),
              Icon(
                Icons.local_fire_department,
                size: 10,
                color: isToday
                    ? (isDark ? Colors.white : Colors.black)
                    : const Color(0xFFDA3B21),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int currentStreak, bool isDark, Color textColor) {
    final cardBg = isDark ? const Color(0xFF282E45) : const Color(0xFFEFF0FA);
    final labelColor = isDark ? const Color(0xFFC1C6D9) : const Color(0xFF5E4940);
    final fireIconBg = isDark ? const Color(0xFF3D282A) : const Color(0xFFFFD6C9);
    final badgeIconBg = isDark ? const Color(0xFF2B2F4C) : const Color(0xFFD6D6FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: fireIconBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFDA3B21),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currentStreak Days',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: badgeIconBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Color(0xFF6153FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Longest Streak',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currentStreak} Days',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
