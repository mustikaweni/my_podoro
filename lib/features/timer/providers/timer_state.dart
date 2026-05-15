enum TimerPhase { focus, waiting, breakPhase }

class TimerState {
  final int remainingSeconds;
  final TimerPhase phase;
  final bool isRunning;

  TimerState({
    required this.remainingSeconds,
    required this.phase,
    required this.isRunning,
  });

  TimerState copyWith({
    int? remainingSeconds,
    TimerPhase? phase,
    bool? isRunning,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      phase: phase ?? this.phase,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
