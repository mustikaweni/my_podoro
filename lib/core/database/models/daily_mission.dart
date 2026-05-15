import 'package:isar/isar.dart';

part 'daily_mission.g.dart';

@collection
class DailyMission {
  Id id = Isar.autoIncrement;

  DateTime? date; // Disimpan pada jam 00:00:00 untuk hari tersebut
  
  int targetCycles = 4;
  int completedCycles = 0;
}
