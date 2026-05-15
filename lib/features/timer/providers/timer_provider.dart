import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'timer_state.dart';
import '../../avatar/providers/economy_provider.dart';
import 'mission_provider.dart';

part 'timer_provider.g.dart';

// const int focusDuration = 10;
// const int breakDuration = 10;
const int focusDuration = 25 * 60; // original
const int breakDuration = 5 * 60; // original

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return TimerState(
      remainingSeconds: focusDuration,
      phase: TimerPhase.focus,
      isRunning: false,
    );
  }

  void startTimer() {
    if (state.isRunning) return;
    
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        _handlePhaseComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void _handlePhaseComplete() {
    if (state.phase == TimerPhase.focus) {
      // Focus done, move to waiting
      // Reward diamonds and increment mission!
      ref.read(economyNotifierProvider.notifier).addDiamonds(2);
      ref.read(missionNotifierProvider.notifier).addCompletedCycle();
      
      state = state.copyWith(
        phase: TimerPhase.waiting,
        isRunning: false,
      );
    } else if (state.phase == TimerPhase.breakPhase) {
      // Break done, move to focus
      state = state.copyWith(
        phase: TimerPhase.focus,
        remainingSeconds: focusDuration,
        isRunning: false,
      );
    }
  }

  void continueToBreak() {
    if (state.phase == TimerPhase.waiting) {
      state = state.copyWith(
        phase: TimerPhase.breakPhase,
        remainingSeconds: breakDuration,
        isRunning: false,
      );
      startTimer();
    }
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(
      remainingSeconds: focusDuration,
      phase: TimerPhase.focus,
      isRunning: false,
    );
  }
}
