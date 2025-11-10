import 'dart:ui';

import 'package:flutter/material.dart';

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
  String _currentMood = 'Serene';
  double _moodScore = 0.82;
  String _moodDescription =
      'Your facial cues and tone suggest you are relaxed and present. Keep embracing the calm moments.';

  final List<_MoodSnapshot> _recentEntries = const [
    _MoodSnapshot(
      label: 'Inspired',
      score: 0.91,
      timeAgo: '10 min ago',
      color: Color(0xFFA1F0D1),
      icon: Icons.auto_awesome,
    ),
    _MoodSnapshot(
      label: 'Curious',
      score: 0.76,
      timeAgo: '2 hrs ago',
      color: Color(0xFFB7C0FF),
      icon: Icons.lightbulb_outline,
    ),
    _MoodSnapshot(
      label: 'Reflective',
      score: 0.64,
      timeAgo: 'Yesterday',
      color: Color(0xFFF9C1D4),
      icon: Icons.self_improvement,
    ),
  ];

  final List<String> _recommendedActions = const [
    'Capture a gratitude voice note',
    'Take a mindful breathing break',
    'Share a positive update with your team',
  ];

  void _simulateMoodScan() {
    setState(() {
      final moods = [
        ('Joyful', 0.94,
            'You radiate excitement. Channel that energy toward your next big idea!'),
        ('Grounded', 0.78,
            'A balanced mood detected. Keep leaning on routines that anchor you.'),
        ('Reflective', 0.65,
            'You seem thoughtful. Consider journaling to capture what is on your mind.'),
        ('Empowered', 0.88,
            'Confidence shines through. Use it to spark meaningful connections today.'),
      ];

      moods.shuffle();
      final mood = moods.first;

      _currentMood = mood.$1;
      _moodScore = mood.$2;
      _moodDescription = mood.$3;
    });
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
                const SizedBox(height: 32),
                _buildMoodCard(context),
                const SizedBox(height: 28),
                _buildActionsCard(context),
                const SizedBox(height: 28),
                Text(
                  'Recent vibes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
              onPressed: _simulateMoodScan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.mic_rounded),
              label: const Text(
                'Start Mood Scan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _currentMood,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_moodScore * 100).round()}% confidence',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
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
