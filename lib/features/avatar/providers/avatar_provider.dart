import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import 'economy_provider.dart';

part 'avatar_provider.g.dart';

class AvatarData {
  final int id;
  final String name;
  final int price;
  final String description;

  const AvatarData(this.id, this.name, this.price, this.description);
}

const List<AvatarData> avatarCatalog = [
  AvatarData(1, 'The Beginner Focus', 10, 'A reliable companion for your first steps.'),
  AvatarData(2, 'The Pomodoro Knight', 20, 'Defends your focus from distractions.'),
  AvatarData(3, 'The Eternal Zen Master', 50, 'Achieve ultimate unbroken flow state.'),
];

class AvatarState {
  final int activeAvatarId;
  final List<int> unlockedAvatarIds;

  AvatarState({required this.activeAvatarId, required this.unlockedAvatarIds});

  AvatarState copyWith({int? activeAvatarId, List<int>? unlockedAvatarIds}) {
    return AvatarState(
      activeAvatarId: activeAvatarId ?? this.activeAvatarId,
      unlockedAvatarIds: unlockedAvatarIds ?? this.unlockedAvatarIds,
    );
  }
}

@Riverpod(keepAlive: true)
class AvatarNotifier extends _$AvatarNotifier {
  @override
  AvatarState build() {
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && previous?.value?.id != next.value?.id) {
        _initRemoteData();
      } else if (next.value == null) {
        state = AvatarState(activeAvatarId: 1, unlockedAvatarIds: [1]);
      }
    });

    Future.microtask(_initRemoteData);
    return AvatarState(
      activeAvatarId: 1,
      unlockedAvatarIds: [1], // Avatar 1 is unlocked by default
    );
  }

  Future<void> _initRemoteData() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('active_avatar_id, unlocked_avatar_ids')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          List<int> unlockedIds = [1];
          if (data['unlocked_avatar_ids'] != null) {
            unlockedIds = List<int>.from(data['unlocked_avatar_ids']);
          }

          state = state.copyWith(
            activeAvatarId: data['active_avatar_id'] as int? ?? 1,
            unlockedAvatarIds: unlockedIds,
          );
        }
      } catch (e) {
        // Ignore error
      }
    }
  }

  void setActiveAvatar(int id) {
    if (state.unlockedAvatarIds.contains(id)) {
      state = state.copyWith(activeAvatarId: id);
      _syncToSupabase();
    }
  }

  bool buyAvatar(int id) {
    if (state.unlockedAvatarIds.contains(id)) return false;
    
    final avatar = avatarCatalog.firstWhere((a) => a.id == id);
    final economy = ref.read(economyNotifierProvider.notifier);
    
    if (economy.spendDiamonds(avatar.price)) {
      state = state.copyWith(
        unlockedAvatarIds: [...state.unlockedAvatarIds, id],
      );
      _syncToSupabase();
      return true;
    }
    return false;
  }

  Future<void> _syncToSupabase() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({
              'active_avatar_id': state.activeAvatarId,
              'unlocked_avatar_ids': state.unlockedAvatarIds,
            })
            .eq('id', user.id);
      } catch (e) {
        // Handle error
      }
    }
  }
}
