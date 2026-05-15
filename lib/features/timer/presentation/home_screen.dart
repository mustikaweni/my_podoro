import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/timer_provider.dart';
import '../providers/timer_state.dart';
import '../providers/mission_provider.dart';
import '../../avatar/providers/economy_provider.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../calendar/presentation/calendar_view.dart';
import '../../settings/presentation/settings_view.dart';
import '../../avatar/presentation/catalog_view.dart';
import '../providers/streak_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCycle = 4;
  int _bottomNavIndex = 0;

  late final AudioPlayer _audioPlayer;
  bool _isMusicPlaying = false;
  bool _isMusicLoading = false;
  final String _lofiUrl = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Sync local play flag with player event listener
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isMusicPlaying = state == PlayerState.playing;
        });
      }
    });

    // If starting directly in Rest mode, auto-start audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerState = ref.read(timerNotifierProvider);
      if (timerState.phase == TimerPhase.breakPhase) {
        _startMusic();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startMusic() async {
    if (_isMusicPlaying || _isMusicLoading) return;
    setState(() => _isMusicLoading = true);
    try {
      await _audioPlayer.play(UrlSource(_lofiUrl));
    } catch (e) {
      debugPrint("Failed to play audio: $e");
    } finally {
      if (mounted) setState(() => _isMusicLoading = false);
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Failed to stop audio: $e");
    }
  }

  Future<void> _toggleMusic() async {
    if (_isMusicLoading) return;
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    } else {
      await _startMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final missionState = ref.watch(missionNotifierProvider);
    final economy = ref.watch(economyNotifierProvider);
    final avatarState = ref.watch(avatarNotifierProvider);
    final streak = ref.watch(streakNotifierProvider);

    // React to phase changes to trigger music automated behavior
    ref.listen(timerNotifierProvider, (previous, next) {
      if (next.phase == TimerPhase.breakPhase && previous?.phase != TimerPhase.breakPhase) {
        _startMusic();
      } else if (next.phase != TimerPhase.breakPhase && previous?.phase == TimerPhase.breakPhase) {
        _stopMusic();
      }
    });

    // React to streak updates to show the Gorgeous Celebration ONCE
    ref.listen(streakNotifierProvider, (previous, next) {
      if (next.showCelebration && !(previous?.showCelebration ?? false)) {
        _showStreakCelebrationDialog(next);
        ref.read(streakNotifierProvider.notifier).dismissCelebration();
      }
    });
    
    // Check if we are in the initial setup phase
    final isSetupPhase = missionState.targetCycles == 0 && !timerState.isRunning && timerState.phase == TimerPhase.focus;
    final isMissionComplete = missionState.targetCycles > 0 && missionState.completedCycles >= missionState.targetCycles;

    final Widget activeView;
    if (isSetupPhase) {
      activeView = KeyedSubtree(
        key: const ValueKey('setup_phase'),
        child: _buildSetupPhase(economy, missionState, streak, avatarState),
      );
    } else if (isMissionComplete) {
      activeView = KeyedSubtree(
        key: const ValueKey('mission_complete'),
        child: _buildMissionCompleteView(missionState),
      );
    } else if (timerState.phase == TimerPhase.focus) {
      activeView = KeyedSubtree(
        key: const ValueKey('focus_mode'),
        child: _buildFocusMode(economy, missionState, timerState, streak, avatarState),
      );
    } else {
      activeView = KeyedSubtree(
        key: const ValueKey('rest_mode'),
        child: _buildRestMode(economy, missionState, timerState, streak, avatarState),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          ),
        );
      },
      child: activeView,
    );
  }

  // ==========================================
  // 1. SETUP PHASE UI
  // ==========================================
  Widget _buildSetupPhase(int economy, MissionState missionState, StreakState streak, AvatarState avatarState) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBarSetup(economy, missionState, streak),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.03),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
                child: _bottomNavIndex == 1 
                    ? const CalendarView(key: ValueKey('calendar_view')) 
                    : _bottomNavIndex == 2 
                        ? const CatalogView(key: ValueKey('catalog_view')) 
                        : _bottomNavIndex == 3
                            ? const SettingsView(key: ValueKey('settings_view'))
                            : _buildHomeView(avatarState, key: const ValueKey('home_view')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeView(AvatarState avatarState, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildAvatarSectionSetup(avatarState),
          const SizedBox(height: 30),
          _buildSelectTargetCard(),
          const SizedBox(height: 30),
          _buildStartButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTopBarSetup(int economy, MissionState missionState, StreakState streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              Text(
                'Podoro',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF14142B),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF20263F) : const Color(0xFFEAEBFA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '$economy',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF14142B), 
                        fontWeight: FontWeight.w800, 
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.diamond, color: Color(0xFF55A6F6), size: 18),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6786A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '${streak.currentStreakDays}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getAvatarIcon(int id) {
    switch (id) {
      case 1:
        return Icons.smart_toy_rounded;
      case 2:
        return Icons.shield;
      case 3:
        return Icons.self_improvement;
      default:
        return Icons.smart_toy_rounded;
    }
  }

  Color _getAvatarBg(int id, {bool isDark = false}) {
    switch (id) {
      case 1:
        return isDark ? const Color(0xFF2A3430) : const Color(0xFFF3F4F8);
      case 2:
        return isDark ? const Color(0xFF3F3A34) : const Color(0xFFE5E0DA);
      case 3:
        return isDark ? const Color(0xFF303255) : const Color(0xFFEAEBFA);
      default:
        return isDark ? const Color(0xFF282E45) : Colors.white;
    }
  }

  Widget _buildAvatarSectionSetup(AvatarState avatarState) {
    final activeAvatar = avatarCatalog.firstWhere(
      (a) => a.id == avatarState.activeAvatarId,
      orElse: () => avatarCatalog[0],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF20263F) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.transparent : const Color(0xFF6153FF).withOpacity(0.08),
                blurRadius: 40,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAvatarBg(avatarState.activeAvatarId, isDark: isDark),
                  border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                ),
              ),
              Icon(
                _getAvatarIcon(avatarState.activeAvatarId), 
                size: 100, 
                color: avatarState.activeAvatarId == 1 
                    ? const Color(0xFF8AA19B) 
                    : (avatarState.activeAvatarId == 3 ? const Color(0xFF6153FF) : (isDark ? const Color(0xFFC1C6D9) : Colors.grey[700])),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          activeAvatar.name.replaceAll('The ', ''), // Cleans up 'The Beginner Focus' to 'Beginner Focus'
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFB82315),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          activeAvatar.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9096A5) : const Color(0xFF5A5A6D),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectTargetCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF20263F) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Target',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF14142B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCycleButton(2),
              _buildCycleButton(4),
              _buildCycleButton(8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleButton(int cycles) {
    final isSelected = _selectedCycle == cycles;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _selectedCycle = cycles),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6153FF) : (isDark ? const Color(0xFF282E45) : const Color(0xFFEFF0FA)),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$cycles',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : (isDark ? const Color(0xFFC1C6D9) : const Color(0xFF4A4A5F)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cycles',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white70 : (isDark ? const Color(0xFF9096A5) : const Color(0xFF7A7A9A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDA3B21),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFDA3B21).withOpacity(0.4),
        ),
        onPressed: () {
          ref.read(missionNotifierProvider.notifier).setTargetCycles(_selectedCycle);
          ref.read(timerNotifierProvider.notifier).startTimer();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_fire_department_outlined, size: 28),
            SizedBox(width: 12),
            Text(
              'Start Focus',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF20263F) : const Color(0xFFEFF0FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled, 'Home'),
              _buildNavItem(1, Icons.calendar_today_rounded, 'Calendar'),
              _buildNavItem(2, Icons.menu_book_rounded, 'Catalog'),
              _buildNavItem(3, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _bottomNavIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6153FF) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9096A5) : const Color(0xFF5A5A6D)),
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF6153FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9096A5) : const Color(0xFF5A5A6D)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. FOCUS MODE UI
  // ==========================================
  Widget _buildFocusMode(int economy, MissionState missionState, TimerState timerState, StreakState streak, AvatarState avatarState) {
    if (missionState.completedCycles >= missionState.targetCycles) {
      return _buildMissionCompleteView(missionState);
    }
    final themeBg = const Color(0xFF161B2E); 

    return Scaffold(
      backgroundColor: themeBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showGiveUpDialog,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF282E45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF9096A5)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282E45),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFFDA3B21), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${streak.currentStreakDays}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDA3B21).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFDA3B21), width: 3),
                                    color: _getAvatarBg(avatarState.activeAvatarId, isDark: true),
                                  ),
                                  child: Icon(
                                    _getAvatarIcon(avatarState.activeAvatarId), 
                                    size: 70, 
                                    color: avatarState.activeAvatarId == 1 
                                        ? const Color(0xFF8AA19B) 
                                        : (avatarState.activeAvatarId == 3 ? const Color(0xFF6153FF) : const Color(0xFFC1C6D9)),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -5,
                                right: -5,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF282E45),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: themeBg, width: 4),
                                  ),
                                  child: const Icon(Icons.headphones, color: Color(0xFFDA3B21), size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          const Text(
                            'DEEP WORK SESSION',
                            style: TextStyle(
                              color: Color(0xFFD0D4E0),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),

                          SizedBox(
                            width: 280,
                            height: 280,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 280,
                                  height: 280,
                                  child: CustomPaint(
                                    painter: _SolidProgressPainter(
                                      progress: timerState.remainingSeconds / focusDuration,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTime(timerState.remainingSeconds),
                                  style: const TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF0FA),
                        foregroundColor: const Color(0xFF14142B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      onPressed: () {
                        final timer = ref.read(timerNotifierProvider.notifier);
                        if (timerState.isRunning) {
                          timer.pauseTimer();
                        } else {
                          timer.startTimer();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            timerState.isRunning ? "Pause" : "Resume",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _showGiveUpDialog,
                    child: const Text(
                      'Give Up',
                      style: TextStyle(
                        color: Color(0xFFD0D4E0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. REST MODE UI
  // ==========================================
  Widget _buildRestMode(int economy, MissionState missionState, TimerState timerState, StreakState streak, AvatarState avatarState) {
    // Determine the text to show: if waiting, show full break duration (e.g. 5 mins)
    String displayTime = timerState.phase == TimerPhase.waiting 
        ? _formatTime(breakDuration)
        : _formatTime(timerState.remainingSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFFC4E8C2), // Light green background
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showGiveUpDialog,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF0F3A21)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${streak.currentStreakDays}',
                          style: const TextStyle(color: Color(0xFF0F3A21), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.local_fire_department, color: Color(0xFFF96213), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glowing Avatar
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  blurRadius: 50,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.7), // Fake checkered bg
                                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 4),
                                ),
                                child: Icon(
                                  _getAvatarIcon(avatarState.activeAvatarId), 
                                  size: 120, 
                                  color: avatarState.activeAvatarId == 1 
                                      ? const Color(0xFF8AA19B) 
                                      : (avatarState.activeAvatarId == 3 ? const Color(0xFF6153FF) : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          const Text(
                            'Rest Mode',
                            style: TextStyle(
                              color: Color(0xFF2C5638),
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayTime,
                            style: const TextStyle(
                              fontSize: 88,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0B2615),
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Take a deep breath and recharge.',
                            style: TextStyle(
                              color: Color(0xFF2C5638),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Player Card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 28),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E1724),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.nightlight_round, color: Colors.orangeAccent),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Lo-fi Focus Beats',
                                        style: TextStyle(
                                          color: Color(0xFF0B2615),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Podoro Chill Radio',
                                        style: TextStyle(
                                          color: Color(0xFF5E4940),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleMusic,
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4A7659),
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isMusicLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            _isMusicPlaying ? Icons.pause : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3290D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFC3290D).withOpacity(0.4),
                  ),
                  onPressed: () {
                    if (timerState.phase == TimerPhase.waiting) {
                       ref.read(timerNotifierProvider.notifier).continueToBreak();
                    } else {
                       ref.read(timerNotifierProvider.notifier).reset(); 
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timerState.phase == TimerPhase.waiting ? 'Start Rest Mode' : 'Continue to Next Cycle',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. MISSION COMPLETE UI
  // ==========================================
  Widget _buildMissionCompleteView(MissionState missionState) {
    return Scaffold(
      backgroundColor: const Color(0xFF6153FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFD700),
                  size: 120,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Mission Accomplished!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You have completed ${missionState.completedCycles} of ${missionState.targetCycles} cycles.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD6D6FF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Rewards Earned: ',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '+${missionState.completedCycles * 2}',
                        style: const TextStyle(color: Color(0xFF55A6F6), fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.diamond, color: Color(0xFF55A6F6), size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6153FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ref.read(missionNotifierProvider.notifier).resetMission();
                      ref.read(timerNotifierProvider.notifier).reset();
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  void _showGiveUpDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEBFA),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.warning_amber_rounded, size: 64, color: Color(0xFFDA3B21)),
              const SizedBox(height: 16),
              const Text(
                'Give Up Session?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF14142B)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to end this session? All your current cycle progress will be lost.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF5A5A6D), fontWeight: FontWeight.w500, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F8),
                        foregroundColor: const Color(0xFF14142B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDA3B21),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(missionNotifierProvider.notifier).resetMission();
                        ref.read(timerNotifierProvider.notifier).reset();
                      },
                      child: const Text('Yes, Give Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showStreakCelebrationDialog(StreakState streak) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF161B2E),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFF7A00).withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7A00).withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFED),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4D00).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFFF4D00),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'STREAK IGNITED!',
                  style: TextStyle(
                    color: Color(0xFFFF9E57),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${streak.currentStreakDays} Day Streak!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Congratulations! You successfully checked-in today and kept your daily focus habit burning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC1C6D9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFFF4D00).withOpacity(0.4),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'AWESOME!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _SolidProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _SolidProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 16.0;
    final radius = (size.width / 2) - (strokeWidth / 2);

    final bgPaint = Paint()
      ..color = const Color(0xFF282E45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..color = const Color(0xFF6153FF) // Signature Violet Accent Color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(rect, -1.5708, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _SolidProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
