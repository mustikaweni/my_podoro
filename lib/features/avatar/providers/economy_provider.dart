import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

part 'economy_provider.g.dart';

@Riverpod(keepAlive: true)
class EconomyNotifier extends _$EconomyNotifier {
  @override
  int build() {
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && previous?.value?.id != next.value?.id) {
        _initRemoteData();
      } else if (next.value == null) {
        state = 0;
      }
    });
    
    Future.microtask(_initRemoteData);
    return 0; // Default diamond balance
  }

  Future<void> _initRemoteData() async {
    final user = ref.read(authProvider).value;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('diamond_balance')
            .eq('id', user.id)
            .maybeSingle();
        
        if (data != null && data['diamond_balance'] != null) {
          state = data['diamond_balance'] as int;
        }
      } catch (e) {
        // Ignore error
      }
    }
  }

  void addDiamonds(int amount) {
    state += amount;
    _syncToSupabase();
  }

  bool spendDiamonds(int amount) {
    if (state >= amount) {
      state -= amount;
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
            .update({'diamond_balance': state})
            .eq('id', user.id);
      } catch (e) {
        // Handle error
      }
    }
  }
}
