import 'dart:ui';

import 'package:flutter/material.dart';

import 'services/mood_prediction_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6750A4);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Detector POC',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1),
          displayMedium:
              TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
      ),
      home: const MoodDetectorHome(),
    );
  }
}

class MoodDetectorHome extends StatefulWidget {
  const MoodDetectorHome({super.key});

  @override
  State<MoodDetectorHome> createState() => _MoodDetectorHomeState();
}

class _MoodDetectorHomeState extends State<MoodDetectorHome> {
  final TextEditingController _textController = TextEditingController(
    text: 'I feel overwhelmed and cannot sleep.',
  );
  late final MoodPredictionService _predictionService;

  String _currentMood = 'Serene';
  double _moodScore = 0.82;
  String _moodDescription =
      'Your facial cues and tone suggest you are relaxed and present. Keep embracing the calm moments.';
  double? _rawScore;
  double? _scaledScore;
  String? _lastAnalyzedInput;
  bool _isLoading = false;
  String? _errorMessage;

  final List<_MoodSnapshot> _recentEntries = [
    const _MoodSnapshot(
      label: 'Inspired',
      score: 0.91,
      timeAgo: '10 min ago',
      color: Color(0xFFA1F0D1),
      icon: Icons.auto_awesome,
    ),
    const _MoodSnapshot(
      label: 'Curious',
      score: 0.76,
      timeAgo: '2 hrs ago',
      color: Color(0xFFB7C0FF),
      icon: Icons.lightbulb_outline,
    ),
    const _MoodSnapshot(
      label: 'Reflective',
      score: 0.64,
      timeAgo: 'Yesterday',
      color: Color(0xFFF9C1D4),
      icon: Icons.self_improvement,
    ),
  ];

  List<String> _recommendedActions = [
    'Capture a gratitude voice note',
    'Take a mindful breathing break',
    'Share a positive update with your team',
  ];

  @override
  void initState() {
    super.initState();
    _predictionService = MoodPredictionService();
  }

  @override
  void dispose() {
    _textController.dispose();
    _predictionService.dispose();
    super.dispose();
  }

  Future<void> _analyzeMood() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please describe how you are feeling before analyzing.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prediction = await _predictionService.predictMood(text);
      if (!mounted) {
        return;
      }
      final insights = _interpretScore(prediction.rawScore);
      setState(() {
        _currentMood = insights.label;
        _moodScore = insights.progress;
        _moodDescription = insights.description;
        _recommendedActions = List<String>.from(insights.recommendations);
        _rawScore = prediction.rawScore;
        _scaledScore = prediction.scaledScore;
        _lastAnalyzedInput = prediction.input;
        _recentEntries.insert(
          0,
          _MoodSnapshot(
            label: insights.label,
            score: insights.progress,
            timeAgo: 'Just now',
            color: insights.color,
            icon: insights.icon,
          ),
        );
        if (_recentEntries.length > 6) {
          _recentEntries.removeRange(6, _recentEntries.length);
        }
      });
    } on MoodPredictionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Unable to analyze your mood right now. Please try again shortly.';
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  _MoodInsights _interpretScore(double rawScore) {
    final normalized = rawScore.clamp(1, 10).toDouble();
    final progress = (1 - ((normalized - 1) / 9)).clamp(0.0, 1.0).toDouble();

    if (normalized <= 3.0) {
      return _MoodInsights(
        label: 'Joyful',
        description:
            'Your language signals steadiness and calm. Keep reinforcing the routines that help you feel balanced.',
        recommendations: const [
          'Share a quick gratitude note with a friend',
          'Schedule a short walk to maintain your rhythm',
          'Capture how you are feeling in a journal entry',
        ],
        progress: progress,
        color:  Color(0xFFFFFFFF),
        icon: Icons.auto_awesome,
      );
    }

    if (normalized <= 4.5) {
      return _MoodInsights(
        label: 'At ease',
        description:
            'It seems like you feel peaceful and satisfied with what you have, without constantly seeking more.',
        recommendations: const [
          'Keep nurturing gratitude every day',
          'Stay curious and open to growth',
          'Protect your peace by setting healthy boundaries',
        ],
        progress: progress,
        color: const Color(0xFFFFFFFF),
        icon: Icons.lightbulb_outline,
      );
    }

    if (normalized <= 6.5) {
      return _MoodInsights(
        label: 'Tense',
        description:
            'The text suggests you are feeling stretched. Consider lighter commitments and compassionate self-talk today.',
        recommendations: const [
          'Prioritize rest and hydration breaks',
          'List one practical step that could reduce stress',
          'Message a colleague or friend for support',
        ],
        progress: progress,
        color: const Color(0xFFFFFFFFF),
        icon: Icons.self_improvement,
      );
    }


    if (normalized <= 7.5) {
      return _MoodInsights(
        label: 'Drained',
        description:
        'A drained person feels mentally and physically exhausted, with little motivation or energy left to handle daily tasks.',
        recommendations: const [
          'Rest without guilt — your body and mind need it',
          'Simplify your schedule and say no when needed',
          'Reconnect with small joys that recharge you',
        ],
        progress: progress,
        color: const Color(0xFFFFFFFFF),
        icon: Icons.self_improvement,
      );
    }

    if (normalized <= 8.5) {
      return _MoodInsights(
        label: 'At Risk',
        description:
            'Your tone indicates elevated distress. Please check in with a trusted contact and consider professional resources.',
        recommendations: const [
          'Reach out to a support hotline or counselor',
          'Let someone nearby know how you are feeling',
          'Focus on slow breathing while you seek help',
        ],
        progress: progress,
        color: const Color(0xFFFF0000),
        icon: Icons.warning_rounded,
      );
    }

    return _MoodInsights(
      label: 'Crisis',
      description:
          'The message signals severe emotional distress. Please contact emergency services or a crisis hotline immediately.',
      recommendations: const [
        'Call your local emergency number or crisis hotline',
        'Stay with someone you trust until you feel safe',
        'Remove access to anything that could harm you',
      ],
      progress: progress,
      color: const Color(0xFFFFFFFF),
      icon: Icons.report_gmailerrorred,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF22172A),
            Color(0xFF1C213C),
            Color(0xFF172936),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Mood Detector'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
              tooltip: 'Preferences',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Ava',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s tune into your mood.',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Describe how you are feeling',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  minLines: 2,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share a sentence about your current mood...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: theme.colorScheme.secondary.withOpacity(0.6),
                        width: 1.4,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFFFB4AB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildMoodCard(context),
                const SizedBox(height: 28),
                _buildActionsCard(context),
                const SizedBox(height: 28),
                Text(
                  'Recent vibes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentMoodList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _analyzeMood,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )
                  : const Icon(Icons.analytics_outlined),
              label: Text(
                _isLoading ? 'Analyzing…' : 'Analyze Mood',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    final theme = Theme.of(context);

    return _FrostedCard(
      gradientColors: const [Color(0xFF6750A4), Color(0xFF8D6FE2)],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.waves,
                  color: theme.colorScheme.onPrimary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  'Current Mood',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _currentMood,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Stability index: ${(_moodScore * 100).round()}%',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.8),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _moodDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ScoreMetricChip(
                  label: 'Raw score',
                  value:
                      _rawScore != null ? _rawScore!.toStringAsFixed(2) : '–',
                  helper: '1 = calm · 10 = crisis',
                ),
                _ScoreMetricChip(
                  label: 'Scaled score',
                  value: _scaledScore != null
                      ? _scaledScore!.toStringAsFixed(0)
                      : '–',
                  helper: '0 – 100 scale',
                ),
              ],
            ),
            if (_lastAnalyzedInput != null) ...[
              const SizedBox(height: 18),
              Text(
                'Last analyzed text',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _lastAnalyzedInput!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    final theme = Theme.of(context);

    return _FrostedCard(
      gradientColors: const [Color(0xFF2D2A48), Color(0xFF353B59)],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended actions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._recommendedActions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.secondaryContainer
                            .withOpacity(0.25),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: const [
                _MoodChip(label: 'Mindfulness'),
                _MoodChip(label: 'Empathy'),
                _MoodChip(label: 'Focus'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMoodList() {
    return Column(
      children: _recentEntries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _MoodTimelineTile(entry: entry),
            ),
          )
          .toList(),
    );
  }
}

class _MoodTimelineTile extends StatelessWidget {
  const _MoodTimelineTile({required this.entry});

  final _MoodSnapshot entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: entry.color.withOpacity(0.18),
          ),
          child: Icon(entry.icon, color: entry.color, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: entry.score,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(entry.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrostedCard extends StatelessWidget {
  const _FrostedCard({required this.child, required this.gradientColors});

  final Widget child;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white.withOpacity(0.12),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class _ScoreMetricChip extends StatelessWidget {
  const _ScoreMetricChip({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white70,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodInsights {
  const _MoodInsights({
    required this.label,
    required this.description,
    required this.recommendations,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final String label;
  final String description;
  final List<String> recommendations;
  final double progress;
  final Color color;
  final IconData icon;
}

class _MoodSnapshot {
  const _MoodSnapshot({
    required this.label,
    required this.score,
    required this.timeAgo,
    required this.color,
    required this.icon,
  });

  final String label;
  final double score;
  final String timeAgo;
  final Color color;
  final IconData icon;
}
