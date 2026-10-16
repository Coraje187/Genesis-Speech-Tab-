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

enum WordType { pronoun, verb, social, adjective, noun, question, learning, slang, sign }

class SymbolItem {
  String id;
  String label;
  String spokenText;
  String? assetName;
  IconData? fallbackIcon;
  WordType type;
  String category;
  Color? customColor;
  String? signGestureHint;

  SymbolItem({
    required this.id,
    required this.label,
    required this.spokenText,
    this.assetName,
    this.fallbackIcon,
    required this.type,
    this.category = 'Core',
    this.customColor,
    this.signGestureHint,
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
        case WordType.sign: return const Color(0xFF1E3A8A);      // Royal Indigo
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
        case WordType.sign: return const Color(0xFFDBEAFE);      // Soft Sky
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
      case WordType.sign: return const Color(0xFF2563EB);
    }
  }
}

// All locally cached ARASAAC PNGs
const List<String> availableSymbolAssets = [
  'apple.png', 'banana.png', 'pizza.png', 'cracker.png', 'snack.png',
  'cookie.png', 'eat.png', 'drink.png', 'water.png', 'juice.png',
  'milk.png', 'toilet.png', 'tablet.png', 'happy.png', 'sad.png',
  'tired.png', 'angry.png', 'scared.png', 'sick.png', 'hurt.png',
  'good.png', 'bad.png', 'hug.png', 'help.png', 'please.png',
  'thank_you.png', 'stop.png', 'go.png', 'play.png', 'like.png',
  'see.png', 'want.png', 'yes.png', 'no.png', 'more.png',
  'i.png', 'you.png', 'mom.png', 'dad.png', 'cat.png',
  'dog.png', 'book.png', 'pencil.png', 'draw.png', 'music.png',
  'home.png', 'school.png', 'car.png', 'bed.png'
];

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
  bool _phonicsMode = false;
  bool _isEditMode = false;

  // Voice & Language Settings
  String _selectedLanguage = 'en-US';
  String _voiceGender = 'female';
  double _speechRate = 0.48;
  double _pitch = 1.30;
  List<dynamic> _availableVoices = [];

  // Master Vocabulary
  late List<SymbolItem> _vocabulary = [
    // -------------------------------------------------------------
    // 1. CORE BOARD (Always accessible high-frequency motor words)
    // -------------------------------------------------------------
    SymbolItem(id: 'i', label: 'I', spokenText: 'I', assetName: 'i.png', fallbackIcon: Icons.person, type: WordType.pronoun, category: 'Core'),
    SymbolItem(id: 'you', label: 'You', spokenText: 'You', assetName: 'you.png', fallbackIcon: Icons.people, type: WordType.pronoun, category: 'Core'),
    SymbolItem(id: 'want', label: 'Want', spokenText: 'Want', assetName: 'want.png', fallbackIcon: Icons.pan_tool, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'like', label: 'Like', spokenText: 'Like', assetName: 'like.png', fallbackIcon: Icons.thumb_up, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'see', label: 'See', spokenText: 'See', assetName: 'see.png', fallbackIcon: Icons.visibility, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'go', label: 'Go', spokenText: 'Go', assetName: 'go.png', fallbackIcon: Icons.directions_run, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'play', label: 'Play', spokenText: 'Play', assetName: 'play.png', fallbackIcon: Icons.sports_esports, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'eat', label: 'Eat', spokenText: 'Eat', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'drink', label: 'Drink', spokenText: 'Drink', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.verb, category: 'Core'),
    SymbolItem(id: 'more', label: 'More', spokenText: 'More', assetName: 'more.png', fallbackIcon: Icons.add_circle, type: WordType.adjective, category: 'Core'),
    SymbolItem(id: 'stop', label: 'Stop', spokenText: 'Stop', assetName: 'stop.png', fallbackIcon: Icons.front_hand, type: WordType.social, category: 'Core'),
    SymbolItem(id: 'help', label: 'Help', spokenText: 'Help me please', assetName: 'help.png', fallbackIcon: Icons.help_outline, type: WordType.social, category: 'Core'),
    SymbolItem(id: 'yes', label: 'Yes', spokenText: 'Yes', assetName: 'yes.png', fallbackIcon: Icons.check_circle, type: WordType.social, category: 'Core'),
    SymbolItem(id: 'no', label: 'No', spokenText: 'No', assetName: 'no.png', fallbackIcon: Icons.cancel, type: WordType.social, category: 'Core'),
    SymbolItem(id: 'please', label: 'Please', spokenText: 'Please', assetName: 'please.png', fallbackIcon: Icons.volunteer_activism, type: WordType.social, category: 'Core'),
    SymbolItem(id: 'thank_you', label: 'Thank You', spokenText: 'Thank you', assetName: 'thank_you.png', fallbackIcon: Icons.handshake, type: WordType.social, category: 'Core'),
    SymbolItem(id: 'good', label: 'Good', spokenText: 'Good', assetName: 'good.png', fallbackIcon: Icons.sentiment_very_satisfied, type: WordType.adjective, category: 'Core'),
    SymbolItem(id: 'bad', label: 'Bad', spokenText: 'Bad', assetName: 'bad.png', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.adjective, category: 'Core'),
    SymbolItem(id: 'happy', label: 'Happy', spokenText: 'Happy', assetName: 'happy.png', fallbackIcon: Icons.mood, type: WordType.adjective, category: 'Core'),
    SymbolItem(id: 'tired', label: 'Tired', spokenText: 'Tired', assetName: 'tired.png', fallbackIcon: Icons.bedtime, type: WordType.adjective, category: 'Core'),
    SymbolItem(id: 'toilet', label: 'Toilet', spokenText: 'I need the bathroom', assetName: 'toilet.png', fallbackIcon: Icons.wc, type: WordType.noun, category: 'Core'),
    SymbolItem(id: 'tablet', label: 'Tablet', spokenText: 'Tablet', assetName: 'tablet.png', fallbackIcon: Icons.tablet, type: WordType.noun, category: 'Core'),

    // -------------------------------------------------------------
    // 2. FOOD & DRINK CATEGORY (With Real Banana & Food Symbols!)
    // -------------------------------------------------------------
    SymbolItem(id: 'banana', label: 'Banana', spokenText: 'Banana', assetName: 'banana.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'apple', label: 'Apple', spokenText: 'Apple', assetName: 'apple.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'pizza', label: 'Pizza', spokenText: 'Pizza', assetName: 'pizza.png', fallbackIcon: Icons.local_pizza, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'cracker', label: 'Cracker', spokenText: 'Cracker', assetName: 'cracker.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'snack', label: 'Snack', spokenText: 'Snack', assetName: 'snack.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'cookie', label: 'Cookie', spokenText: 'Cookie', assetName: 'cookie.png', fallbackIcon: Icons.cookie, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'water', label: 'Water', spokenText: 'Water', assetName: 'water.png', fallbackIcon: Icons.water_drop, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'juice', label: 'Juice', spokenText: 'Juice', assetName: 'juice.png', fallbackIcon: Icons.local_cafe, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'milk', label: 'Milk', spokenText: 'Milk', assetName: 'milk.png', fallbackIcon: Icons.local_drink, type: WordType.noun, category: 'Food'),
    SymbolItem(id: 'eat_f', label: 'Eat', spokenText: 'Eat food', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.verb, category: 'Food'),
    SymbolItem(id: 'drink_f', label: 'Drink', spokenText: 'Drink', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.verb, category: 'Food'),
    SymbolItem(id: 'hot', label: 'Hot', spokenText: 'It is hot', fallbackIcon: Icons.whatshot, type: WordType.adjective, category: 'Food'),
    SymbolItem(id: 'cold', label: 'Cold', spokenText: 'It is cold', fallbackIcon: Icons.ac_unit, type: WordType.adjective, category: 'Food'),
    SymbolItem(id: 'all_done', label: 'All Done', spokenText: 'All done eating', fallbackIcon: Icons.done_all, type: WordType.social, category: 'Food'),

    // -------------------------------------------------------------
    // 3. FEELINGS & SENSORY
    // -------------------------------------------------------------
    SymbolItem(id: 'happy_f', label: 'Happy', spokenText: 'I am happy', assetName: 'happy.png', fallbackIcon: Icons.mood, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'sad', label: 'Sad', spokenText: 'I am sad', assetName: 'sad.png', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'angry', label: 'Angry', spokenText: 'I am angry', assetName: 'angry.png', fallbackIcon: Icons.mood_bad, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'tired_f', label: 'Tired', spokenText: 'I am tired', assetName: 'tired.png', fallbackIcon: Icons.bedtime, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'scared', label: 'Scared', spokenText: 'I am scared', assetName: 'scared.png', fallbackIcon: Icons.warning_amber, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'sick', label: 'Sick', spokenText: 'I feel sick', assetName: 'sick.png', fallbackIcon: Icons.sick, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'hurt', label: 'Hurt', spokenText: 'Ouch, that hurts!', assetName: 'hurt.png', fallbackIcon: Icons.healing, type: WordType.social, category: 'Feelings'),
    SymbolItem(id: 'good_f', label: 'Good', spokenText: 'I feel good', assetName: 'good.png', fallbackIcon: Icons.thumb_up, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'bad_f', label: 'Bad', spokenText: 'I feel bad', assetName: 'bad.png', fallbackIcon: Icons.thumb_down, type: WordType.adjective, category: 'Feelings'),
    SymbolItem(id: 'hug', label: 'Hug', spokenText: 'I want a hug please', assetName: 'hug.png', fallbackIcon: Icons.favorite, type: WordType.social, category: 'Feelings'),
    SymbolItem(id: 'too_loud', label: 'Too Loud', spokenText: 'It is too loud in here!', fallbackIcon: Icons.volume_off, type: WordType.social, category: 'Feelings'),
    SymbolItem(id: 'leave_me', label: 'Leave Me', spokenText: 'Leave me alone please', fallbackIcon: Icons.do_not_disturb_on, type: WordType.social, category: 'Feelings'),
    SymbolItem(id: 'too_much', label: 'Too Much', spokenText: 'This is too much for me right now', fallbackIcon: Icons.psychology, type: WordType.social, category: 'Feelings'),

    // -------------------------------------------------------------
    // 4. LEARNING AREA (Colors, Shapes, School & Concepts)
    // -------------------------------------------------------------
    SymbolItem(id: 'c_red', label: 'Red', spokenText: 'Red', fallbackIcon: Icons.circle, customColor: const Color(0xFFEF4444), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_blue', label: 'Blue', spokenText: 'Blue', fallbackIcon: Icons.circle, customColor: const Color(0xFF3B82F6), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_green', label: 'Green', spokenText: 'Green', fallbackIcon: Icons.circle, customColor: const Color(0xFF22C55E), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_yellow', label: 'Yellow', spokenText: 'Yellow', fallbackIcon: Icons.circle, customColor: const Color(0xFFEAB308), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_orange', label: 'Orange', spokenText: 'Orange', fallbackIcon: Icons.circle, customColor: const Color(0xFFF97316), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_purple', label: 'Purple', spokenText: 'Purple', fallbackIcon: Icons.circle, customColor: const Color(0xFFA855F7), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_pink', label: 'Pink', spokenText: 'Pink', fallbackIcon: Icons.circle, customColor: const Color(0xFFEC4899), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_black', label: 'Black', spokenText: 'Black', fallbackIcon: Icons.circle, customColor: const Color(0xFF1E293B), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'c_white', label: 'White', spokenText: 'White', fallbackIcon: Icons.circle_outlined, customColor: const Color(0xFFF8FAFC), type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'sh_circle', label: 'Circle', spokenText: 'Circle', fallbackIcon: Icons.circle_outlined, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'sh_square', label: 'Square', spokenText: 'Square', fallbackIcon: Icons.crop_square, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'sh_triangle', label: 'Triangle', spokenText: 'Triangle', fallbackIcon: Icons.change_history, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'sh_star', label: 'Star', spokenText: 'Star', fallbackIcon: Icons.star, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'sh_heart', label: 'Heart', spokenText: 'Heart', fallbackIcon: Icons.favorite, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'cn_big', label: 'Big', spokenText: 'Big', fallbackIcon: Icons.aspect_ratio, type: WordType.adjective, category: 'Learning'),
    SymbolItem(id: 'cn_small', label: 'Small', spokenText: 'Small', fallbackIcon: Icons.zoom_in_map, type: WordType.adjective, category: 'Learning'),
    SymbolItem(id: 'bk_read', label: 'Book / Read', spokenText: 'Read a book', assetName: 'book.png', fallbackIcon: Icons.menu_book, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'pn_write', label: 'Pencil / Write', spokenText: 'Write with pencil', assetName: 'pencil.png', fallbackIcon: Icons.edit, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'dr_art', label: 'Draw', spokenText: 'Draw and color', assetName: 'draw.png', fallbackIcon: Icons.palette, type: WordType.learning, category: 'Learning'),
    SymbolItem(id: 'sc_school', label: 'School', spokenText: 'At school', assetName: 'school.png', fallbackIcon: Icons.school, type: WordType.noun, category: 'Learning'),
    SymbolItem(id: 'mu_music', label: 'Music', spokenText: 'Listen to music', assetName: 'music.png', fallbackIcon: Icons.music_note, type: WordType.noun, category: 'Learning'),
    SymbolItem(id: 'gd_job', label: 'Good Job!', spokenText: 'Great job! You did it!', fallbackIcon: Icons.thumb_up, type: WordType.social, category: 'Learning'),

    // -------------------------------------------------------------
    // 5. SIGN LANGUAGE (Total Communication: Sign + Speech + Symbol)
    // -------------------------------------------------------------
    SymbolItem(id: 'asl_ily', label: 'I Love You 🤟', spokenText: 'I love you. To sign, raise thumb, index, and pinky finger.', fallbackIcon: Icons.favorite, type: WordType.sign, category: 'Signs', signGestureHint: '🤟 Raise thumb, index, and pinky'),
    SymbolItem(id: 'asl_more', label: 'More 🤲', spokenText: 'More. In sign language, bring your fingertips together repeatedly.', assetName: 'more.png', fallbackIcon: Icons.add_circle, type: WordType.sign, category: 'Signs', signGestureHint: '🤲 Tap fingertips together'),
    SymbolItem(id: 'asl_please', label: 'Please 🙏', spokenText: 'Please. In sign language, rub flat palm in a circle on your chest.', assetName: 'please.png', fallbackIcon: Icons.volunteer_activism, type: WordType.sign, category: 'Signs', signGestureHint: '🙏 Rub flat hand over chest'),
    SymbolItem(id: 'asl_thanks', label: 'Thank You 🤝', spokenText: 'Thank you. Touch fingers to chin and bring hand forward.', assetName: 'thank_you.png', fallbackIcon: Icons.handshake, type: WordType.sign, category: 'Signs', signGestureHint: '🤝 Touch chin, move forward'),
    SymbolItem(id: 'asl_help', label: 'Help 🆘', spokenText: 'Help. Place thumbs-up fist on flat palm and lift both up.', assetName: 'help.png', fallbackIcon: Icons.help_outline, type: WordType.sign, category: 'Signs', signGestureHint: '🆘 Thumbs up on flat palm'),
    SymbolItem(id: 'asl_stop', label: 'Stop 🛑', spokenText: 'Stop. Bring the edge of one hand down onto your other palm.', assetName: 'stop.png', fallbackIcon: Icons.front_hand, type: WordType.sign, category: 'Signs', signGestureHint: '🛑 Chop edge of hand to palm'),
    SymbolItem(id: 'asl_eat', label: 'Eat 🍽️', spokenText: 'Eat. Bring grouped fingertips to your mouth repeatedly.', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.sign, category: 'Signs', signGestureHint: '🍽️ Fingertips to mouth'),
    SymbolItem(id: 'asl_drink', label: 'Drink 🥤', spokenText: 'Drink. Hold a C-hand to your mouth like a cup.', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.sign, category: 'Signs', signGestureHint: '🥤 Tip C-hand to mouth'),
    SymbolItem(id: 'asl_water', label: 'Water 💧', spokenText: 'Water. Make a W with three fingers and tap index to your chin.', assetName: 'water.png', fallbackIcon: Icons.water_drop, type: WordType.sign, category: 'Signs', signGestureHint: '💧 Tap W to chin'),
    SymbolItem(id: 'asl_toilet', label: 'Bathroom 🚻', spokenText: 'Bathroom. Make a T hand shape and shake side to side.', assetName: 'toilet.png', fallbackIcon: Icons.wc, type: WordType.sign, category: 'Signs', signGestureHint: '🚻 Shake T handshape'),
    SymbolItem(id: 'asl_yes', label: 'Yes ✅', spokenText: 'Yes. Make a fist and nod it up and down like a head.', assetName: 'yes.png', fallbackIcon: Icons.check_circle, type: WordType.sign, category: 'Signs', signGestureHint: '✅ Nod fist up and down'),
    SymbolItem(id: 'asl_no', label: 'No ❌', spokenText: 'No. Snap index and middle finger down to touch thumb.', assetName: 'no.png', fallbackIcon: Icons.cancel, type: WordType.sign, category: 'Signs', signGestureHint: '❌ Snap 2 fingers to thumb'),
    SymbolItem(id: 'asl_done', label: 'All Done ✨', spokenText: 'All done. Start palms in, twist both open hands outward.', fallbackIcon: Icons.done_all, type: WordType.sign, category: 'Signs', signGestureHint: '✨ Flash palms outward'),
    SymbolItem(id: 'asl_hug', label: 'Hug 🫂', spokenText: 'Hug. Cross both arms over your chest.', assetName: 'hug.png', fallbackIcon: Icons.favorite, type: WordType.sign, category: 'Signs', signGestureHint: '🫂 Cross arms over chest'),
    SymbolItem(id: 'asl_bed', label: 'Sleep 🛌', spokenText: 'Sleep. Draw hand down over face, closing fingers to thumb.', assetName: 'bed.png', fallbackIcon: Icons.bedtime, type: WordType.sign, category: 'Signs', signGestureHint: '🛌 Hand draws down face'),

    // -------------------------------------------------------------
    // 6. VIBES & PEER SLANG
    // -------------------------------------------------------------
    SymbolItem(id: 'sl_lets_go', label: "Let's Go!", spokenText: "Let's gooo!", fallbackIcon: Icons.rocket_launch, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_bruh', label: 'Bruh', spokenText: 'Bruh...', fallbackIcon: Icons.sentiment_neutral, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_cap', label: 'Cap', spokenText: "That's cap, you are lying!", fallbackIcon: Icons.sports_baseball, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_sus', label: 'Sus', spokenText: 'That is so sus.', fallbackIcon: Icons.warning_amber, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_fire', label: 'Fire', spokenText: 'That is fire!', fallbackIcon: Icons.local_fire_department, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_chill', label: 'Chill', spokenText: 'Chill out please.', fallbackIcon: Icons.ac_unit, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_my_bad', label: 'My Bad', spokenText: 'My bad, sorry about that.', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.slang, category: 'Slang'),
    SymbolItem(id: 'sl_whatever', label: 'Whatever', spokenText: 'Whatever...', fallbackIcon: Icons.undo, type: WordType.slang, category: 'Slang'),
  ];

  final List<String> _dictionary = const [
    "I", "want", "need", "help", "please", "water", "food", "banana", "apple",
    "bathroom", "hurt", "mom", "dad", "home", "outside", "sleep", "tired",
    "happy", "sad", "loud", "quiet", "medicine", "hug", "play", "tablet", "stop"
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.awaitSynthCompletion(true);
      final dynamic engines = await _flutterTts.getEngines;
      if (engines is List && engines.isNotEmpty) {
        if (engines.contains("com.ivona.tts.oem")) {
          await _flutterTts.setEngine("com.ivona.tts.oem");
        } else if (engines.contains("com.google.android.tts")) {
          await _flutterTts.setEngine("com.google.android.tts");
        }
      }

      final dynamic voices = await _flutterTts.getVoices;
      if (voices is List) {
        _availableVoices = voices;
      }

      await _applyVoiceSettings();
    } catch (e) {
      debugPrint("TTS init error: $e");
    }
  }

  Future<void> _applyVoiceSettings() async {
    try {
      await _flutterTts.setLanguage(_selectedLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(_pitch);

      if (_availableVoices.isNotEmpty) {
        for (var v in _availableVoices) {
          if (v is Map) {
            final name = v['name']?.toString().toLowerCase() ?? '';
            final locale = v['locale']?.toString().toLowerCase() ?? '';
            final prefix = _selectedLanguage.toLowerCase().substring(0, 2);

            if (locale.contains(prefix)) {
              if (_voiceGender == 'female' &&
                  (name.contains('female') || name.contains('salli') || name.contains('kendra') || name.contains('zira') || name.contains('samantha'))) {
                await _flutterTts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              } else if (_voiceGender == 'male' &&
                  (name.contains('male') || name.contains('joey') || name.contains('david') || name.contains('guy'))) {
                await _flutterTts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error applying voice settings: $e");
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

  // ==========================================
  // VOICE & LANGUAGE SETTINGS DIALOG
  // ==========================================
  void _showVoiceSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: Color(0xFF4F46E5)),
                  SizedBox(width: 8),
                  Text('Voice & Language Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Voice Gender & Tone:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.female, size: 18),
                          label: const Text('Female Voice (Natural)'),
                          selected: _voiceGender == 'female',
                          selectedColor: const Color(0xFFF48FB1),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                _voiceGender = 'female';
                                _pitch = 1.30;
                              });
                              setState(() {});
                              _applyVoiceSettings();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: const Icon(Icons.male, size: 18),
                          label: const Text('Male Voice'),
                          selected: _voiceGender == 'male',
                          selectedColor: const Color(0xFF90CAF9),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                _voiceGender = 'male';
                                _pitch = 0.95;
                              });
                              setState(() {});
                              _applyVoiceSettings();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Spoken Language:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'en-US', child: Text('🇺🇸 English (United States)')),
                        DropdownMenuItem(value: 'en-GB', child: Text('🇬🇧 English (United Kingdom)')),
                        DropdownMenuItem(value: 'es-ES', child: Text('🇪🇸 Spanish (Español)')),
                        DropdownMenuItem(value: 'es-US', child: Text('🇲🇽 Spanish (Latin America)')),
                        DropdownMenuItem(value: 'fr-FR', child: Text('🇫🇷 French (Français)')),
                        DropdownMenuItem(value: 'de-DE', child: Text('🇩🇪 German (Deutsch)')),
                        DropdownMenuItem(value: 'it-IT', child: Text('🇮🇹 Italian (Italiano)')),
                        DropdownMenuItem(value: 'pt-BR', child: Text('🇧🇷 Portuguese (Brasil)')),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          setDialogState(() => _selectedLanguage = lang);
                          setState(() {});
                          _applyVoiceSettings();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Pitch Tone: ${_pitch.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _pitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (v) {
                        setDialogState(() => _pitch = v);
                        setState(() {});
                        _applyVoiceSettings();
                      },
                    ),
                    Text('Speech Speed: ${_speechRate.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _speechRate,
                      min: 0.2,
                      max: 1.0,
                      divisions: 8,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (v) {
                        setDialogState(() => _speechRate = v);
                        setState(() {});
                        _applyVoiceSettings();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _speakText("Hello! This is how my voice sounds on Genesis Speech Tab."),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Test Voice'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ADD NEW WORD TO SECTION DIALOG
  // ==========================================
  void _showAddWordDialog(String category) {
    final labelCtrl = TextEditingController();
    final speechCtrl = TextEditingController();
    String? selectedAsset;
    WordType selectedType = WordType.noun;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.add_box_rounded, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text('Add Word to $category', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: labelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Display Label',
                          hintText: 'e.g. Pancakes, Grandma, Park',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          if (speechCtrl.text.isEmpty) {
                            speechCtrl.text = val;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: speechCtrl,
                        decoration: const InputDecoration(
                          labelText: 'What it Speaks',
                          hintText: 'e.g. I want delicious pancakes please',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Choose Image / Symbol:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade50,
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(6),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: availableSymbolAssets.length,
                          itemBuilder: (context, idx) {
                            final asset = availableSymbolAssets[idx];
                            final isSelected = selectedAsset == asset;

                            return InkWell(
                              onTap: () {
                                setDialogState(() => selectedAsset = asset);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFC7D2FE) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF4F46E5) : Colors.black12,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: Image.asset('assets/symbols/$asset', fit: BoxFit.contain),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Category Color Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Noun (Orange)'),
                            selected: selectedType == WordType.noun,
                            selectedColor: const Color(0xFFFFCC80),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.noun),
                          ),
                          ChoiceChip(
                            label: const Text('Verb (Green)'),
                            selected: selectedType == WordType.verb,
                            selectedColor: const Color(0xFFA5D6A7),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.verb),
                          ),
                          ChoiceChip(
                            label: const Text('Social (Pink)'),
                            selected: selectedType == WordType.social,
                            selectedColor: const Color(0xFFF48FB1),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.social),
                          ),
                          ChoiceChip(
                            label: const Text('Adjective (Blue)'),
                            selected: selectedType == WordType.adjective,
                            selectedColor: const Color(0xFF90CAF9),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.adjective),
                          ),
                          ChoiceChip(
                            label: const Text('Slang (Purple)'),
                            selected: selectedType == WordType.slang,
                            selectedColor: const Color(0xFFE9D5FF),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.slang),
                          ),
                          ChoiceChip(
                            label: const Text('Sign (Sky Blue)'),
                            selected: selectedType == WordType.sign,
                            selectedColor: const Color(0xFFDBEAFE),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.sign),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final label = labelCtrl.text.trim();
                    if (label.isEmpty) return;

                    final newItem = SymbolItem(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      label: label,
                      spokenText: speechCtrl.text.trim().isNotEmpty ? speechCtrl.text.trim() : label,
                      assetName: selectedAsset,
                      fallbackIcon: Icons.star_rounded,
                      type: selectedType,
                      category: category,
                    );

                    setState(() {
                      _vocabulary.add(newItem);
                    });

                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                  child: const Text('Add Word'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // IN-APP BUTTON & IMAGE CUSTOMIZER / EDITOR
  // ==========================================
  void _showEditButtonDialog(SymbolItem item) {
    final labelCtrl = TextEditingController(text: item.label);
    final speechCtrl = TextEditingController(text: item.spokenText);
    String? currentAsset = item.assetName;
    WordType currentType = item.type;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Text('Customize: ${item.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: labelCtrl,
                        decoration: const InputDecoration(labelText: 'Display Label', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: speechCtrl,
                        decoration: const InputDecoration(labelText: 'What it Speaks', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      const Text('Choose Symbol Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade50,
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(6),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: availableSymbolAssets.length,
                          itemBuilder: (context, idx) {
                            final asset = availableSymbolAssets[idx];
                            final isSelected = currentAsset == asset;

                            return InkWell(
                              onTap: () {
                                setDialogState(() => currentAsset = asset);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFC7D2FE) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF4F46E5) : Colors.black12,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: Image.asset('assets/symbols/$asset', fit: BoxFit.contain),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Fitzgerald Color Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Noun (Orange)'),
                            selected: currentType == WordType.noun,
                            selectedColor: const Color(0xFFFFCC80),
                            onSelected: (_) => setDialogState(() => currentType = WordType.noun),
                          ),
                          ChoiceChip(
                            label: const Text('Verb (Green)'),
                            selected: currentType == WordType.verb,
                            selectedColor: const Color(0xFFA5D6A7),
                            onSelected: (_) => setDialogState(() => currentType = WordType.verb),
                          ),
                          ChoiceChip(
                            label: const Text('Social (Pink)'),
                            selected: currentType == WordType.social,
                            selectedColor: const Color(0xFFF48FB1),
                            onSelected: (_) => setDialogState(() => currentType = WordType.social),
                          ),
                          ChoiceChip(
                            label: const Text('Adjective (Blue)'),
                            selected: currentType == WordType.adjective,
                            selectedColor: const Color(0xFF90CAF9),
                            onSelected: (_) => setDialogState(() => currentType = WordType.adjective),
                          ),
                          ChoiceChip(
                            label: const Text('Slang (Purple)'),
                            selected: currentType == WordType.slang,
                            selectedColor: const Color(0xFFE9D5FF),
                            onSelected: (_) => setDialogState(() => currentType = WordType.slang),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _vocabulary.remove(item));
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      item.label = labelCtrl.text.trim();
                      item.spokenText = speechCtrl.text.trim();
                      item.assetName = currentAsset;
                      item.type = currentType;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
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

  // 1. TOP SENTENCE BAR
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
                      _isEditMode
                          ? "🔧 Edit Mode ON: Tap any button to edit its image or label!"
                          : "Tap symbols, letters, or sign gestures to speak...",
                      style: TextStyle(
                        fontSize: 18,
                        color: _isEditMode
                            ? Colors.blueAccent
                            : (isDark ? Colors.white38 : Colors.grey.shade500),
                        fontWeight: FontWeight.w700,
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
          // Speak Full Sentence
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
          // Voice & Language Settings
          IconButton(
            icon: const Icon(Icons.record_voice_over_rounded, size: 26, color: Color(0xFF4F46E5)),
            tooltip: "Voice & Language Settings",
            onPressed: _showVoiceSettingsDialog,
          ),
          // Edit Mode Toggle
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.check_circle_rounded : Icons.edit_note_rounded,
              size: 28,
              color: _isEditMode ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
            ),
            tooltip: _isEditMode ? "Done Editing" : "Edit Images & Words",
            onPressed: () {
              setState(() => _isEditMode = !_isEditMode);
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
      {'name': 'Signs', 'label': '🤟 ASL Signs', 'icon': Icons.front_hand_rounded},
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

  // 3. SYMBOL GRID (With Real Symbols + ➕ Add Word Tile + Edit Mode)
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
      itemCount: items.length + 1, // +1 for the Add Word card
      itemBuilder: (context, index) {
        // Last Tile: ➕ Add Word to Section Button
        if (index == items.length) {
          return InkWell(
            onTap: () => _showAddWordDialog(_selectedCategory),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF3B82F6),
                  width: 2,
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, size: 40, color: Color(0xFF3B82F6)),
                  const SizedBox(height: 6),
                  Text(
                    'ADD WORD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.blue.shade200 : const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final item = items[index];

        return InkWell(
          onTap: () {
            if (_isEditMode) {
              _showEditButtonDialog(item);
            } else {
              _addWord(item.spokenText);
            }
          },
          onLongPress: () => _showEditButtonDialog(item),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: item.getColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isEditMode ? const Color(0xFF0284C7) : item.getBorderColor(isDark),
                width: _isEditMode ? 3 : 2,
              ),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
            ),
            child: Stack(
              children: [
                Center(
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
                        padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
                        child: Text(
                          item.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.signGestureHint != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                          child: Text(
                            item.signGestureHint!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.blue.shade200 : const Color(0xFF1E3A8A),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isEditMode)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 14, color: Color(0xFF0284C7)),
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

    const Map<String, String> phonicsMap = {
      'A': 'ah', 'B': 'buh', 'C': 'kuh', 'D': 'duh', 'E': 'eh', 'F': 'fff',
      'G': 'guh', 'H': 'huh', 'I': 'ih', 'J': 'juh', 'K': 'kuh', 'L': 'lll',
      'M': 'mmm', 'N': 'nnn', 'O': 'aw', 'P': 'puh', 'Q': 'kwuh', 'R': 'rrr',
      'S': 'sss', 'T': 'tuh', 'U': 'uh', 'V': 'vvv', 'W': 'wuh', 'X': 'ks',
      'Y': 'yuh', 'Z': 'zzz'
    };

    final predictions = _typingBuffer.isEmpty
        ? ["I", "want", "need", "help", "please", "banana"]
        : _dictionary
            .where((w) => w.toLowerCase().startsWith(_typingBuffer.toLowerCase()))
            .take(6)
            .toList();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
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
