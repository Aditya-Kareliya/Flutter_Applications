import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../data/gita_data.dart';
import '../../data/models/gita_shloka_model.dart';
import '../../../preview_app/features/qr_module/presentation/widgets/adaptive_widgets.dart'; // To use showAdaptiveFeedback

class GitaShlokaPopup extends StatefulWidget {
  final int initialIndex;

  const GitaShlokaPopup({super.key, required this.initialIndex});

  @override
  State<GitaShlokaPopup> createState() => _GitaShlokaPopupState();
}

class _GitaShlokaPopupState extends State<GitaShlokaPopup>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool _isSpeaking = false;
  int _currentIndex = 0;
  bool _isMovingForward = true;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );
    _animController.forward();

    _initTts();
    _setNaturalVoice();
    _startAutoAdvanceTimer();
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 70), (timer) {
      if (mounted && !_isSpeaking) {
        if (_currentIndex < GitaData.shlokas.length - 1) {
          _moveToIndex(_currentIndex + 1);
        } else {
          _moveToIndex(0);
        }
      }
    });
  }

  void _initTts() {
    flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    flutterTts.setCompletionHandler(() {
      _stopBackgroundMusic();
      if (mounted) setState(() => _isSpeaking = false);
    });

    flutterTts.setErrorHandler((msg) {
      _stopBackgroundMusic();
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _setNaturalVoice() async {
    try {
      List<dynamic> voices = await flutterTts.getVoices;
      for (var voice in voices) {
        if (voice is Map &&
            voice['locale']?.toString().contains('hi-IN') == true) {
          if (voice['name']?.toString().toLowerCase().contains('natural') ==
                  true ||
              voice['name']?.toString().toLowerCase().contains('premium') ==
                  true) {
            await flutterTts.setVoice({
              "name": voice["name"],
              "locale": voice["locale"],
            });
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("Error setting natural voice: $e");
    }
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.15);
      await _audioPlayer.play(
        UrlSource(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  Future<void> _stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }

  Future<void> _speak(GitaShloka shloka) async {
    if (_isSpeaking) {
      await flutterTts.stop();
      await _stopBackgroundMusic();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      await _playBackgroundMusic();
      await flutterTts.setLanguage("hi-IN");
      await flutterTts.setPitch(0.70);
      await flutterTts.setSpeechRate(0.35);
      await flutterTts.setVolume(1.0);
      await flutterTts.speak(shloka.shloka);
    }
  }

  Future<void> _stopSpeaking() async {
    if (_isSpeaking) {
      await flutterTts.stop();
      await _stopBackgroundMusic();
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _moveToIndex(int newIndex) {
    if (newIndex == _currentIndex) return;

    _stopSpeaking();
    _startAutoAdvanceTimer();

    setState(() {
      _isMovingForward =
          newIndex > _currentIndex ||
          (newIndex == 0 && _currentIndex == GitaData.shlokas.length - 1);
      _currentIndex = newIndex;
    });
  }

  void _copyToClipboard(GitaShloka shloka) {
    final text =
        'Bhagavad Gita ${shloka.chapter}.${shloka.verse}\n\n${shloka.shloka}\n\n${shloka.meaning}';
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (!mounted) return;
      showAdaptiveFeedback(context, 'Shloka copied to clipboard!');
    });
  }

  void _shareShloka(GitaShloka shloka) {
    final text =
        'Bhagavad Gita ${shloka.chapter}.${shloka.verse}\n\n${shloka.shloka}\n\n${shloka.meaning}\n\n- Shared from Flutter Portfolio App';
    Share.share(text);
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    flutterTts.stop();
    _audioPlayer.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = themeProvider.seedColor;

    final currentShloka = GitaData.shlokas[_currentIndex];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 540),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade900.withOpacity(0.3)
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Stack(
                      children: [
                        // Subtle background gradient glows
                        Positioned(
                          top: -60,
                          left: -60,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.15),
                              backgroundBlendMode: BlendMode.screen,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80,
                          right: -40,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.1),
                              backgroundBlendMode: BlendMode.colorDodge,
                            ),
                          ),
                        ),

                        // Main Layout
                        Column(
                          children: [
                            // Top Indicators / Close Button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 20, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      key: ValueKey<int>(_currentIndex),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Ch ${currentShloka.chapter} • V ${currentShloka.verse}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.black87,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content Area with Beautiful Animation
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                switchInCurve: Curves.easeOutQuint,
                                switchOutCurve: Curves.easeInQuint,
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      // Determine direction based on state tracking and transition type
                                      final isEntering =
                                          child.key ==
                                          ValueKey<int>(_currentIndex);

                                      // Setup slide offsets based on whether we are moving forward or backward
                                      Offset beginOffset;
                                      if (isEntering) {
                                        beginOffset = _isMovingForward
                                            ? const Offset(0.3, 0.0)
                                            : const Offset(-0.3, 0.0);
                                      } else {
                                        beginOffset = _isMovingForward
                                            ? const Offset(-0.3, 0.0)
                                            : const Offset(0.3, 0.0);
                                      }

                                      final slideAnimation = Tween<Offset>(
                                        begin: beginOffset,
                                        end: Offset.zero,
                                      ).animate(animation);

                                      final scaleAnimation = Tween<double>(
                                        begin: 0.95,
                                        end: 1.0,
                                      ).animate(animation);

                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: scaleAnimation,
                                          child: SlideTransition(
                                            position: slideAnimation,
                                            child: child,
                                          ),
                                        ),
                                      );
                                    },
                                child: SingleChildScrollView(
                                  key: ValueKey<int>(_currentIndex),
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 28,
                                        color: primaryColor.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 20),

                                      // Sanskrit
                                      Text(
                                        currentShloka.shloka,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFFFFE082)
                                              : primaryColor, // Gold in dark mode
                                          height: 1.6,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Transliteration
                                      if (currentShloka
                                          .transliteration
                                          .isNotEmpty) ...[
                                        Text(
                                          currentShloka.transliteration,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.black.withOpacity(0.5),
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],

                                      // Minimal Separator
                                      Container(
                                        height: 2,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Meaning
                                      Text(
                                        currentShloka.meaning,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.85)
                                              : Colors.black87,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Compact Bottom Glass Action Bar
                            Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTinyBtn(
                                    Icons.arrow_back_ios_rounded,
                                    _currentIndex > 0
                                        ? () => _moveToIndex(_currentIndex - 1)
                                        : null,
                                    isDark,
                                  ),
                                  _buildTinyBtn(
                                    Icons.copy_rounded,
                                    () => _copyToClipboard(currentShloka),
                                    isDark,
                                  ),

                                  // Play / Stop Button
                                  GestureDetector(
                                    onTap: () => _speak(currentShloka),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _isSpeaking
                                            ? primaryColor
                                            : (isDark
                                                  ? Colors.white12
                                                  : Colors.black.withOpacity(
                                                      0.05,
                                                    )),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isSpeaking
                                            ? Icons.stop_rounded
                                            : Icons.record_voice_over_rounded,
                                        color: _isSpeaking
                                            ? Colors.white
                                            : (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                        size: 24,
                                      ),
                                    ),
                                  ),

                                  _buildTinyBtn(
                                    Icons.ios_share_rounded,
                                    () => _shareShloka(currentShloka),
                                    isDark,
                                  ),
                                  _buildTinyBtn(
                                    Icons.arrow_forward_ios_rounded,
                                    _currentIndex < GitaData.shlokas.length - 1
                                        ? () => _moveToIndex(_currentIndex + 1)
                                        : null,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTinyBtn(IconData icon, VoidCallback? onTap, bool isDark) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: onTap == null
            ? (isDark ? Colors.white24 : Colors.black26)
            : (isDark ? Colors.white70 : Colors.black54),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      splashRadius: 20,
    );
  }
}
