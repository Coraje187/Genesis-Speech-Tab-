import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GenesisSpeechApp());
}

class GenesisSpeechApp extends StatefulWidget {
  const GenesisSpeechApp({super.key});

  @override
  State<GenesisSpeechApp> createState() => _GenesisSpeechAppState();
}

class _GenesisSpeechAppState extends State<GenesisSpeechApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genesis Speech Tab',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: AACHomeScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      ),
    );
  }
}

// ==========================================
// DATA MODELS & FITZGERALD KEY
// ==========================================

enum WordType { pronoun, verb, social, adjective, noun, question, learning, slang }

class SymbolItem {
  final String label;
  final String spokenText;
  final String? assetName;
  final IconData? fallbackIcon;
  final WordType type;
  final String category;
  final Color? customColor;

  const SymbolItem({
    required this.label,
    required this.spokenText,
    this.assetName,
    this.fallbackIcon,
    required this.type,
    this.category = 'Core',
    this.customColor,
  });

  Color getColor(bool isDark) {
    if (customColor != null) {
      return customColor!;
    }
    if (isDark) {
      switch (type) {
        case WordType.pronoun: return const Color(0xFF854D0E);   // Dark Yellow
        case WordType.verb: return const Color(0xFF166534);      // Dark Green
        case WordType.social: return const Color(0xFF9D174D);    // Dark Pink
        case WordType.adjective: return const Color(0xFF075985); // Dark Blue
        case WordType.noun: return const Color(0xFF9A3412);      // Dark Orange
        case WordType.question: return const Color(0xFF6B21A8);  // Dark Purple
        case WordType.learning: return const Color(0xFF374151);  // Dark Slate
        case WordType.slang: return const Color(0xFF581C87);     // Deep Purple
      }
    } else {
      switch (type) {
        case WordType.pronoun: return const Color(0xFFFFF176);   // Yellow
        case WordType.verb: return const Color(0xFFA5D6A7);      // Green
        case WordType.social: return const Color(0xFFF48FB1);    // Pink
        case WordType.adjective: return const Color(0xFF90CAF9); // Blue
        case WordType.noun: return const Color(0xFFFFCC80);      // Orange
        case WordType.question: return const Color(0xFFCE93D8);  // Light Purple
        case WordType.learning: return const Color(0xFFE2E8F0);  // Soft Slate
        case WordType.slang: return const Color(0xFFE9D5FF);     // Lavender
      }
    }
  }

  Color getBorderColor(bool isDark) {
    if (isDark) return Colors.white24;
    switch (type) {
      case WordType.pronoun: return const Color(0xFFCA8A04);
      case WordType.verb: return const Color(0xFF16A34A);
      case WordType.social: return const Color(0xFFDB2777);
      case WordType.adjective: return const Color(0xFF0284C7);
      case WordType.noun: return const Color(0xFFEA580C);
      case WordType.question: return const Color(0xFF9333EA);
      case WordType.learning: return const Color(0xFF94A3B8);
      case WordType.slang: return const Color(0xFF7E22CE);
    }
  }
}

// ==========================================
// MAIN SCREEN IMPLEMENTATION
// ==========================================

class AACHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const AACHomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<AACHomeScreen> createState() => _AACHomeScreenState();
}

class _AACHomeScreenState extends State<AACHomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _sentenceBuffer = [];
  String _typingBuffer = "";
  String _selectedCategory = 'Core';
  bool _useQwerty = false;
  bool _phonicsMode = false; // False = Letter Name ("Bee"), True = Phonic ("Buh")

  // Master Vocabulary with Real 22+ ARASAAC Symbols and Clinical AAC Expansion
  late final List<SymbolItem> _vocabulary = [
    // -------------------------------------------------------------
    // 1. CORE BOARD (Always accessible high-frequency motor words)
    // -------------------------------------------------------------
    const SymbolItem(label: 'I', spokenText: 'I', assetName: 'i.png', fallbackIcon: Icons.person, type: WordType.pronoun, category: 'Core'),
    const SymbolItem(label: 'You', spokenText: 'You', assetName: 'you.png', fallbackIcon: Icons.people, type: WordType.pronoun, category: 'Core'),
    const SymbolItem(label: 'Want', spokenText: 'Want', assetName: 'want.png', fallbackIcon: Icons.pan_tool, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'Like', spokenText: 'Like', assetName: 'like.png', fallbackIcon: Icons.thumb_up, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'See', spokenText: 'See', assetName: 'see.png', fallbackIcon: Icons.visibility, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'Go', spokenText: 'Go', assetName: 'go.png', fallbackIcon: Icons.directions_run, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'Play', spokenText: 'Play', assetName: 'play.png', fallbackIcon: Icons.sports_esports, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'Eat', spokenText: 'Eat', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'Drink', spokenText: 'Drink', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.verb, category: 'Core'),
    const SymbolItem(label: 'More', spokenText: 'More', assetName: 'more.png', fallbackIcon: Icons.add_circle, type: WordType.adjective, category: 'Core'),
    const SymbolItem(label: 'Stop', spokenText: 'Stop', assetName: 'stop.png', fallbackIcon: Icons.front_hand, type: WordType.social, category: 'Core'),
    const SymbolItem(label: 'Help', spokenText: 'Help me please', assetName: 'help.png', fallbackIcon: Icons.help_outline, type: WordType.social, category: 'Core'),
    const SymbolItem(label: 'Yes', spokenText: 'Yes', assetName: 'yes.png', fallbackIcon: Icons.check_circle, type: WordType.social, category: 'Core'),
    const SymbolItem(label: 'No', spokenText: 'No', assetName: 'no.png', fallbackIcon: Icons.cancel, type: WordType.social, category: 'Core'),
    const SymbolItem(label: 'Please', spokenText: 'Please', assetName: 'please.png', fallbackIcon: Icons.volunteer_activism, type: WordType.social, category: 'Core'),
    const SymbolItem(label: 'Thank You', spokenText: 'Thank you', assetName: 'thank_you.png', fallbackIcon: Icons.handshake, type: WordType.social, category: 'Core'),
    const SymbolItem(label: 'Good', spokenText: 'Good', assetName: 'good.png', fallbackIcon: Icons.sentiment_very_satisfied, type: WordType.adjective, category: 'Core'),
    const SymbolItem(label: 'Bad', spokenText: 'Bad', assetName: 'bad.png', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.adjective, category: 'Core'),
    const SymbolItem(label: 'Happy', spokenText: 'Happy', assetName: 'happy.png', fallbackIcon: Icons.mood, type: WordType.adjective, category: 'Core'),
    const SymbolItem(label: 'Tired', spokenText: 'Tired', assetName: 'tired.png', fallbackIcon: Icons.bedtime, type: WordType.adjective, category: 'Core'),
    const SymbolItem(label: 'Toilet', spokenText: 'I need the bathroom', assetName: 'toilet.png', fallbackIcon: Icons.wc, type: WordType.noun, category: 'Core'),
    const SymbolItem(label: 'Tablet', spokenText: 'Tablet', assetName: 'tablet.png', fallbackIcon: Icons.tablet, type: WordType.noun, category: 'Core'),

    // -------------------------------------------------------------
    // 2. FOOD & DRINK CATEGORY
    // -------------------------------------------------------------
    const SymbolItem(label: 'Water', spokenText: 'Water', assetName: 'water.png', fallbackIcon: Icons.water_drop, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Juice', spokenText: 'Juice', assetName: 'juice.png', fallbackIcon: Icons.local_cafe, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Apple', spokenText: 'Apple', assetName: 'apple.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Cracker', spokenText: 'Cracker', assetName: 'cracker.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Eat', spokenText: 'Eat food', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.verb, category: 'Food'),
    const SymbolItem(label: 'Drink', spokenText: 'Drink', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.verb, category: 'Food'),
    const SymbolItem(label: 'Banana', spokenText: 'Banana', fallbackIcon: Icons.lunch_dining, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Pizza', spokenText: 'Pizza', fallbackIcon: Icons.local_pizza, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Snack', spokenText: 'Snack', fallbackIcon: Icons.cookie, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Milk', spokenText: 'Milk', fallbackIcon: Icons.local_drink, type: WordType.noun, category: 'Food'),
    const SymbolItem(label: 'Hot', spokenText: 'It is hot', fallbackIcon: Icons.whatshot, type: WordType.adjective, category: 'Food'),
    const SymbolItem(label: 'Cold', spokenText: 'It is cold', fallbackIcon: Icons.ac_unit, type: WordType.adjective, category: 'Food'),
    const SymbolItem(label: 'All Done', spokenText: 'All done eating', fallbackIcon: Icons.done_all, type: WordType.social, category: 'Food'),

    // -------------------------------------------------------------
    // 3. FEELINGS & SENSORY
    // -------------------------------------------------------------
    const SymbolItem(label: 'Happy', spokenText: 'I am happy', assetName: 'happy.png', fallbackIcon: Icons.mood, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Tired', spokenText: 'I am tired', assetName: 'tired.png', fallbackIcon: Icons.bedtime, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Good', spokenText: 'I feel good', assetName: 'good.png', fallbackIcon: Icons.thumb_up, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Bad', spokenText: 'I feel bad', assetName: 'bad.png', fallbackIcon: Icons.thumb_down, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Mad / Angry', spokenText: 'I am mad right now', fallbackIcon: Icons.mood_bad, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Sad', spokenText: 'I am sad', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Scared', spokenText: 'I am scared', fallbackIcon: Icons.warning_amber, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Sick', spokenText: 'I feel sick', fallbackIcon: Icons.sick, type: WordType.adjective, category: 'Feelings'),
    const SymbolItem(label: 'Hurt', spokenText: 'Ouch, that hurts!', fallbackIcon: Icons.healing, type: WordType.social, category: 'Feelings'),
    const SymbolItem(label: 'Too Loud', spokenText: 'It is too loud in here!', fallbackIcon: Icons.volume_off, type: WordType.social, category: 'Feelings'),
    const SymbolItem(label: 'Leave Me', spokenText: 'Leave me alone please', fallbackIcon: Icons.do_not_disturb_on, type: WordType.social, category: 'Feelings'),
    const SymbolItem(label: 'Too Much', spokenText: 'This is too much for me right now', fallbackIcon: Icons.psychology, type: WordType.social, category: 'Feelings'),
    const SymbolItem(label: 'Hug', spokenText: 'I want a hug please', fallbackIcon: Icons.favorite, type: WordType.social, category: 'Feelings'),

    // -------------------------------------------------------------
    // 4. LEARNING AREA (Colors, Shapes, School & Concepts)
    // -------------------------------------------------------------
    const SymbolItem(label: 'Red', spokenText: 'Red', fallbackIcon: Icons.circle, customColor: Color(0xFFEF4444), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Blue', spokenText: 'Blue', fallbackIcon: Icons.circle, customColor: Color(0xFF3B82F6), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Green', spokenText: 'Green', fallbackIcon: Icons.circle, customColor: Color(0xFF22C55E), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Yellow', spokenText: 'Yellow', fallbackIcon: Icons.circle, customColor: Color(0xFFEAB308), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Orange', spokenText: 'Orange', fallbackIcon: Icons.circle, customColor: Color(0xFFF97316), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Purple', spokenText: 'Purple', fallbackIcon: Icons.circle, customColor: Color(0xFFA855F7), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Pink', spokenText: 'Pink', fallbackIcon: Icons.circle, customColor: Color(0xFFEC4899), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Black', spokenText: 'Black', fallbackIcon: Icons.circle, customColor: Color(0xFF1E293B), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'White', spokenText: 'White', fallbackIcon: Icons.circle_outlined, customColor: Color(0xFFF8FAFC), type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Circle', spokenText: 'Circle', fallbackIcon: Icons.circle_outlined, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Square', spokenText: 'Square', fallbackIcon: Icons.crop_square, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Triangle', spokenText: 'Triangle', fallbackIcon: Icons.change_history, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Star', spokenText: 'Star', fallbackIcon: Icons.star, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Heart', spokenText: 'Heart', fallbackIcon: Icons.favorite, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Big', spokenText: 'Big', fallbackIcon: Icons.aspect_ratio, type: WordType.adjective, category: 'Learning'),
    const SymbolItem(label: 'Small', spokenText: 'Small', fallbackIcon: Icons.zoom_in_map, type: WordType.adjective, category: 'Learning'),
    const SymbolItem(label: 'Book / Read', spokenText: 'Read a book', fallbackIcon: Icons.menu_book, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Pencil / Write', spokenText: 'Write with pencil', fallbackIcon: Icons.edit, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Draw', spokenText: 'Draw and color', fallbackIcon: Icons.palette, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Teacher', spokenText: 'My teacher', fallbackIcon: Icons.person, type: WordType.noun, category: 'Learning'),
    const SymbolItem(label: 'School', spokenText: 'At school', fallbackIcon: Icons.school, type: WordType.noun, category: 'Learning'),
    const SymbolItem(label: 'Listen', spokenText: 'Listen carefully', fallbackIcon: Icons.hearing, type: WordType.learning, category: 'Learning'),
    const SymbolItem(label: 'Good Job!', spokenText: 'Great job! You did it!', fallbackIcon: Icons.thumb_up, type: WordType.social, category: 'Learning'),

    // -------------------------------------------------------------
    // 5. VIBES & PEER SLANG
    // -------------------------------------------------------------
    const SymbolItem(label: "Let's Go!", spokenText: "Let's gooo!", fallbackIcon: Icons.rocket_launch, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'Bruh', spokenText: 'Bruh...', fallbackIcon: Icons.sentiment_neutral, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'Cap', spokenText: "That's cap, you are lying!", fallbackIcon: Icons.sports_baseball, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'Sus', spokenText: 'That is so sus.', fallbackIcon: Icons.warning_amber, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'Fire', spokenText: 'That is fire!', fallbackIcon: Icons.local_fire_department, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'Chill', spokenText: 'Chill out please.', fallbackIcon: Icons.ac_unit, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'My Bad', spokenText: 'My bad, sorry about that.', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.slang, category: 'Slang'),
    const SymbolItem(label: 'Whatever', spokenText: 'Whatever...', fallbackIcon: Icons.undo, type: WordType.slang, category: 'Slang'),
  ];

  // Common predictive words for fast spelling
  final List<String> _dictionary = const [
    "I", "want", "need", "help", "please", "water", "food", "bathroom", "hurt",
    "mom", "dad", "home", "outside", "sleep", "tired", "happy", "sad", "loud",
    "quiet", "medicine", "hug", "play", "tablet", "music", "stop", "more", "yes", "no"
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    try {
      await _flutterTts.awaitSynthCompletion(true);
      // Look for system TTS engine (like com.ivona.tts.oem on Fire OS)
      final dynamic engines = await _flutterTts.getEngines;
      if (engines is List && engines.isNotEmpty) {
        if (engines.contains("com.ivona.tts.oem")) {
          await _flutterTts.setEngine("com.ivona.tts.oem");
        } else if (engines.contains("com.google.android.tts")) {
          await _flutterTts.setEngine("com.google.android.tts");
        } else {
          await _flutterTts.setEngine(engines.first.toString());
        }
      }
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.05);
    } catch (e) {
      debugPrint("TTS init error: $e");
    }
  }

  void _speakText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS speak error: $e");
    }
  }

  void _addWord(String spokenText) {
    setState(() {
      _sentenceBuffer.add(spokenText);
    });
    _speakText(spokenText);
  }

  void _speakFullSentence() {
    final fullText = [
      ..._sentenceBuffer,
      if (_typingBuffer.isNotEmpty) _typingBuffer
    ].join(" ");
    _speakText(fullText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildSentenceBar(isDark),
            _buildCategoryTabs(isDark),
            Expanded(
              child: _selectedCategory == 'ABC'
                  ? _buildAlphabetBoard(isDark)
                  : _buildSymbolGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // 1. TOP SENTENCE BAR (Always visible across tabs)
  Widget _buildSentenceBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_sentenceBuffer.isEmpty && _typingBuffer.isEmpty)
                    Text(
                      "Tap symbols or letters to speak...",
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ..._sentenceBuffer.map((w) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text(
                            w,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                          side: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFC7D2FE)),
                        ),
                      )),
                  if (_typingBuffer.isNotEmpty)
                    Chip(
                      label: Text(
                        "$_typingBuffer|",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      backgroundColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Speak Full Sentence Button
          ElevatedButton.icon(
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            label: const Text('Speak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: (_sentenceBuffer.isEmpty && _typingBuffer.isEmpty) ? null : _speakFullSentence,
          ),
          const SizedBox(width: 4),
          // Backspace
          IconButton(
            icon: const Icon(Icons.backspace_outlined, size: 26, color: Colors.orange),
            tooltip: "Backspace",
            onPressed: () {
              setState(() {
                if (_typingBuffer.isNotEmpty) {
                  _typingBuffer = _typingBuffer.substring(0, _typingBuffer.length - 1);
                } else if (_sentenceBuffer.isNotEmpty) {
                  _sentenceBuffer.removeLast();
                }
              });
            },
          ),
          // Clear All
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, size: 28, color: Colors.redAccent),
            tooltip: "Clear All",
            onPressed: () {
              setState(() {
                _sentenceBuffer.clear();
                _typingBuffer = "";
              });
            },
          ),
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 26,
              color: widget.isDarkMode ? Colors.amber : const Color(0xFF475569),
            ),
            tooltip: widget.isDarkMode ? "Light Mode" : "Dark Mode",
            onPressed: widget.onToggleDarkMode,
          ),
        ],
      ),
    );
  }

  // 2. CATEGORY NAVIGATION TABS
  Widget _buildCategoryTabs(bool isDark) {
    final categories = [
      {'name': 'Core', 'label': 'Core AAC', 'icon': Icons.grid_view_rounded},
      {'name': 'Food', 'label': 'Food & Drinks', 'icon': Icons.restaurant_rounded},
      {'name': 'Feelings', 'label': 'Feelings & Body', 'icon': Icons.emoji_emotions_rounded},
      {'name': 'Learning', 'label': '🎓 Learning', 'icon': Icons.school_rounded},
      {'name': 'ABC', 'label': '🔤 ABC & 123', 'icon': Icons.keyboard_alt_rounded},
      {'name': 'Slang', 'label': '⚡ Vibes & Slang', 'icon': Icons.rocket_launch_rounded},
    ];

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                cat['icon'] as IconData,
                color: isSelected ? Colors.white : (isDark ? Colors.indigo.shade200 : Colors.indigo),
                size: 20,
              ),
              label: Text(
                cat['label'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF4F46E5),
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              onSelected: (_) => setState(() => _selectedCategory = cat['name'] as String),
            ),
          );
        },
      ),
    );
  }

  // 3. SYMBOL GRID (Real ARASAAC PNGs with Fallback Icons)
  Widget _buildSymbolGrid(bool isDark) {
    final items = _vocabulary.where((item) => item.category == _selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          onTap: () => _addWord(item.spokenText),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: item.getColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.getBorderColor(isDark), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    child: item.assetName != null
                        ? Image.asset(
                            'assets/symbols/${item.assetName}',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              item.fallbackIcon ?? Icons.record_voice_over,
                              size: 44,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          )
                        : Icon(
                            item.fallbackIcon ?? Icons.record_voice_over,
                            size: 44,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                  child: Text(
                    item.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. ALPHABET, PHONICS & NUMBERS BOARD
  Widget _buildAlphabetBoard(bool isDark) {
    const abcOrder = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const qwertyOrder = "QWERTYUIOPASDFGHJKLZXCVBNM";
    const numbers = "1234567890";
    final letters = (_useQwerty ? qwertyOrder : abcOrder).split('');

    // Phonics sound map for early literacy / speech practice
    const Map<String, String> phonicsMap = {
      'A': 'ah', 'B': 'buh', 'C': 'kuh', 'D': 'duh', 'E': 'eh', 'F': 'fff',
      'G': 'guh', 'H': 'huh', 'I': 'ih', 'J': 'juh', 'K': 'kuh', 'L': 'lll',
      'M': 'mmm', 'N': 'nnn', 'O': 'aw', 'P': 'puh', 'Q': 'kwuh', 'R': 'rrr',
      'S': 'sss', 'T': 'tuh', 'U': 'uh', 'V': 'vvv', 'W': 'wuh', 'X': 'ks',
      'Y': 'yuh', 'Z': 'zzz'
    };

    // Predictive words based on typing buffer
    final predictions = _typingBuffer.isEmpty
        ? ["I", "want", "need", "help", "please", "water"]
        : _dictionary
            .where((w) => w.toLowerCase().startsWith(_typingBuffer.toLowerCase()))
            .take(6)
            .toList();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Word Prediction & Mode Toggles
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: predictions.map((pred) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          backgroundColor: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                          side: BorderSide(color: isDark ? const Color(0xFF4F46E5) : const Color(0xFFC7D2FE)),
                          label: Text(
                            pred.toUpperCase(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.indigo.shade900,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _sentenceBuffer.add(pred);
                              _typingBuffer = "";
                            });
                            _speakText(pred);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Switch(
                value: _phonicsMode,
                activeColor: Colors.indigo,
                onChanged: (val) => setState(() => _phonicsMode = val),
              ),
              Text(
                _phonicsMode ? "Phonics" : "Letter Names",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _useQwerty = !_useQwerty),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.indigo.shade200 : Colors.indigo,
                ),
                child: Text(_useQwerty ? "ABC Order" : "QWERTY"),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Letters + Numbers Keyboard Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 9,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                ...letters.map((char) => _buildKeyButton(
                      char,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
                      textColor: isDark ? Colors.white : const Color(0xFF0C4A6E),
                      borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
                      onTap: () {
                        setState(() => _typingBuffer += char);
                        _speakText(_phonicsMode ? (phonicsMap[char] ?? char) : char.toLowerCase());
                      },
                    )),
                ...numbers.split('').map((num) => _buildKeyButton(
                      num,
                      color: isDark ? const Color(0xFF3B2D0A) : const Color(0xFFFEF08A),
                      textColor: isDark ? Colors.amber.shade200 : const Color(0xFF713F12),
                      borderColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE047),
                      onTap: () {
                        setState(() => _typingBuffer += num);
                        _speakText(num);
                      },
                    )),
                _buildKeyButton(
                  "SPACE",
                  color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                  textColor: isDark ? Colors.green.shade200 : const Color(0xFF166534),
                  borderColor: isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC),
                  onTap: () {
                    if (_typingBuffer.isNotEmpty) {
                      final completedWord = _typingBuffer;
                      setState(() {
                        _sentenceBuffer.add(completedWord);
                        _typingBuffer = "";
                      });
                      _speakText(completedWord);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(
    String label, {
    required Color color,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: label == "SPACE" ? 13 : 22,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
