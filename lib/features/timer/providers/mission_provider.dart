import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'streak_provider.dart';

part 'mission_provider.g.dart';

class MissionState {
  final int targetCycles;
  final int completedCycles;

  MissionState({required this.targetCycles, required this.completedCycles});

  MissionState copyWith({int? targetCycles, int? completedCycles}) {
    return MissionState(
      targetCycles: targetCycles ?? this.targetCycles,
      completedCycles: completedCycles ?? this.completedCycles,
    );
  }
}

@Riverpod(keepAlive: true)
class MissionNotifier extends _$MissionNotifier {
  @override
  MissionState build() {
    return MissionState(targetCycles: 0, completedCycles: 0);
  }

  void setTargetCycles(int target) {
    state = state.copyWith(targetCycles: target);
  }

  void addCompletedCycle() {
    state = state.copyWith(completedCycles: state.completedCycles + 1);

    // Reward streak when mission is fully completed
    if (state.completedCycles == state.targetCycles && state.targetCycles > 0) {
      ref.read(streakNotifierProvider.notifier).incrementStreakIfEligible();
    }
  }

  void resetMission() {
    state = state.copyWith(targetCycles: 0, completedCycles: 0);
  }
}
