import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

part 'streak_provider.g.dart';

class StreakState {
  final int currentStreakDays;
  final List<String> streakDates;
  final bool showCelebration;

  StreakState({
    required this.currentStreakDays,
    required this.streakDates,
    this.showCelebration = false,
  });

  StreakState copyWith({
    int? currentStreakDays,
    List<String>? streakDates,
    bool? showCelebration,
  }) {
    return StreakState(
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      streakDates: streakDates ?? this.streakDates,
      showCelebration: showCelebration ?? this.showCelebration,
    );
  }
}

@Riverpod(keepAlive: true)
class StreakNotifier extends _$StreakNotifier {
  @override
  StreakState build() {
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && previous?.value?.id != next.value?.id) {
        _initRemoteData();
      } else if (next.value == null) {
        state = StreakState(currentStreakDays: 0, streakDates: [], showCelebration: false);
      }
    });

    Future.microtask(_initRemoteData);
    return StreakState(currentStreakDays: 0, streakDates: [], showCelebration: false);
  }

  Future<void> _initRemoteData() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('current_streak_days, streak_dates')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          int streakDays = data['current_streak_days'] as int? ?? 0;
          List<String> dates = [];
          if (data['streak_dates'] != null) {
            dates = List<String>.from(data['streak_dates']);
          }
          state = StreakState(
            currentStreakDays: streakDays,
            streakDates: dates,
            showCelebration: false,
          );
        }
      } catch (e) {
        // Ignore error
      }
    }
  }

  Future<void> incrementStreakIfEligible() async {
    final today = DateTime.now().toIso8601String().substring(0, 10); // "YYYY-MM-DD"

    if (!state.streakDates.contains(today)) {
      final newDates = [...state.streakDates, today];
      state = state.copyWith(
        currentStreakDays: state.currentStreakDays + 1,
        streakDates: newDates,
        showCelebration: true, // Trigger celebration UI
      );
      _syncToSupabase();
    }
  }

  void dismissCelebration() {
    state = state.copyWith(showCelebration: false);
  }

  Future<void> _syncToSupabase() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({
              'current_streak_days': state.currentStreakDays,
              'streak_dates': state.streakDates,
            })
            .eq('id', user.id);
      } catch (e) {
        // Handle error
      }
    }
  }
}
