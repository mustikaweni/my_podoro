import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  int diamondBalance = 0;
  int currentStreakDays = 0;
  
  // 1 = Beginner, 2 = Knight, 3 = Zen Master
  int activeAvatarId = 1;
  
  List<int> unlockedAvatarIds = [1];
}
