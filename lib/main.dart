import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('is_dark_mode')) {
        setState(() {
          _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleDarkMode() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (_) {}
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
        colorSchemeSeed: const Color(0xFF4F46E5),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: AACHomeScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      ),
    );
  }
}

// ==========================================
// DATA MODELS & CLINICAL FITZGERALD KEY
// ==========================================

enum WordType {
  pronoun,
  verb,
  social,
  adjective,
  noun,
  question,
  learning,
  slang,
  sign,
  restaurant,
  sensory,
}

class SymbolItem {
  String id;
  String label;
  String spokenText;
  String? assetName;
  String? localImagePath;
  String? networkImageUrl;
  String? customEmoji;
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
    this.localImagePath,
    this.networkImageUrl,
    this.customEmoji,
    this.fallbackIcon,
    required this.type,
    this.category = 'Core',
    this.customColor,
    this.signGestureHint,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'spokenText': spokenText,
        'assetName': assetName,
        'localImagePath': localImagePath,
        'networkImageUrl': networkImageUrl,
        'customEmoji': customEmoji,
        'type': type.name,
        'category': category,
        'signGestureHint': signGestureHint,
      };

  factory SymbolItem.fromJson(Map<String, dynamic> json) {
    WordType parsedType = WordType.noun;
    try {
      parsedType = WordType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'noun'),
        orElse: () => WordType.noun,
      );
    } catch (_) {}

    return SymbolItem(
      id: json['id']?.toString() ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      label: json['label']?.toString() ?? 'Word',
      spokenText: json['spokenText']?.toString() ?? 'Word',
      assetName: json['assetName']?.toString(),
      localImagePath: json['localImagePath']?.toString(),
      networkImageUrl: json['networkImageUrl']?.toString(),
      customEmoji: json['customEmoji']?.toString(),
      fallbackIcon: Icons.star_rounded,
      type: parsedType,
      category: json['category']?.toString() ?? 'Core',
      signGestureHint: json['signGestureHint']?.toString(),
    );
  }

  // Card background color (Soft, elegant pastel in Light Mode; Rich muted surface in Sensory Dark Mode)
  Color getColor(bool isDark) {
    if (customColor != null && !isDark) {
      return customColor!;
    }
    if (isDark) {
      switch (type) {
        case WordType.pronoun:
          return const Color(0xFF422006); // Warm Amber Dark
        case WordType.verb:
          return const Color(0xFF052E16); // Deep Emerald Dark
        case WordType.social:
          return const Color(0xFF500724); // Deep Rose Dark
        case WordType.adjective:
          return const Color(0xFF082F49); // Deep Sky Dark
        case WordType.noun:
          return const Color(0xFF431407); // Warm Orange Dark
        case WordType.question:
          return const Color(0xFF3B0764); // Deep Violet Dark
        case WordType.learning:
          return const Color(0xFF1E293B); // Slate Dark
        case WordType.slang:
          return const Color(0xFF311042); // Plum Dark
        case WordType.sign:
          return const Color(0xFF172554); // Royal Navy Dark
        case WordType.restaurant:
          return const Color(0xFF450A0A); // Crimson Dark
        case WordType.sensory:
          return const Color(0xFF134E4A); // Calm Teal Dark
      }
    } else {
      switch (type) {
        case WordType.pronoun:
          return const Color(0xFFFEF9C3); // Soft FitzGerald Yellow
        case WordType.verb:
          return const Color(0xFFDCFCE7); // Soft FitzGerald Green
        case WordType.social:
          return const Color(0xFFFCE7F3); // Soft FitzGerald Pink
        case WordType.adjective:
          return const Color(0xFFE0F2FE); // Soft FitzGerald Blue
        case WordType.noun:
          return const Color(0xFFFFEDD5); // Soft FitzGerald Orange
        case WordType.question:
          return const Color(0xFFF3E8FF); // Soft Purple
        case WordType.learning:
          return const Color(0xFFF1F5F9); // Crisp Slate
        case WordType.slang:
          return const Color(0xFFFAE8FF); // Soft Fuchsia
        case WordType.sign:
          return const Color(0xFFDBEAFE); // Soft Indigo Sky
        case WordType.restaurant:
          return const Color(0xFFFEE2E2); // Warm Restaurant Coral/Red
        case WordType.sensory:
          return const Color(0xFFCCFBF1); // Calming Sensory Mint/Teal
      }
    }
  }

  // Accent border & top stripe color
  Color getBorderColor(bool isDark) {
    if (isDark) {
      switch (type) {
        case WordType.pronoun:
          return const Color(0xFFEAB308);
        case WordType.verb:
          return const Color(0xFF22C55E);
        case WordType.social:
          return const Color(0xFFEC4899);
        case WordType.adjective:
          return const Color(0xFF38BDF8);
        case WordType.noun:
          return const Color(0xFFF97316);
        case WordType.question:
          return const Color(0xFFA855F7);
        case WordType.learning:
          return const Color(0xFF64748B);
        case WordType.slang:
          return const Color(0xFFD946EF);
        case WordType.sign:
          return const Color(0xFF60A5FA);
        case WordType.restaurant:
          return const Color(0xFFEF4444);
        case WordType.sensory:
          return const Color(0xFF2DD4BF);
      }
    }
    switch (type) {
      case WordType.pronoun:
        return const Color(0xFFEAB308);
      case WordType.verb:
        return const Color(0xFF22C55E);
      case WordType.social:
        return const Color(0xFFEC4899);
      case WordType.adjective:
        return const Color(0xFF0EA5E9);
      case WordType.noun:
        return const Color(0xFFF97316);
      case WordType.question:
        return const Color(0xFF9333EA);
      case WordType.learning:
        return const Color(0xFF94A3B8);
      case WordType.slang:
        return const Color(0xFFC026D3);
      case WordType.sign:
        return const Color(0xFF3B82F6);
      case WordType.restaurant:
        return const Color(0xFFEF4444);
      case WordType.sensory:
        return const Color(0xFF0D9488);
    }
  }
}

// All 111 bundled offline PNG symbols in assets/symbols/
const List<String> availableSymbolAssets = [
  'mcdonalds.png',
  'happy_meal.png',
  'chickfila.png',
  'wendys.png',
  'burgerking.png',
  'tacobell.png',
  'pizzahut.png',
  'subway.png',
  'starbucks.png',
  'dunkin.png',
  'dairyqueen.png',
  'ihop.png',
  'pandaexpress.png',
  'nuggets.png',
  'fries.png',
  'burger.png',
  'pizza.png',
  'taco.png',
  'hotdog.png',
  'pancakes.png',
  'pasta.png',
  'sandwich.png',
  'ice_cream.png',
  'milkshake.png',
  'donut.png',
  'soda.png',
  'ketchup.png',
  'cheese.png',
  'chicken.png',
  'apple.png',
  'banana.png',
  'strawberry.png',
  'blueberry.png',
  'lemon.png',
  'orange_fruit.png',
  'cracker.png',
  'snack.png',
  'cookie.png',
  'cupcake.png',
  'cake.png',
  'eat.png',
  'drink.png',
  'water.png',
  'juice.png',
  'milk.png',
  'dog.png',
  'cat.png',
  'rabbit.png',
  'horse.png',
  'bird.png',
  'fish.png',
  'dolphin.png',
  'duck.png',
  'cow.png',
  'pig.png',
  'sheep.png',
  'chicken_animal.png',
  'frog.png',
  'monkey.png',
  'lion.png',
  'tiger.png',
  'elephant.png',
  'bear.png',
  'giraffe.png',
  'dinosaur.png',
  'butterfly.png',
  'turtle.png',
  'dishes.png',
  'loud.png',
  'quiet.png',
  'headphones.png',
  'bright.png',
  'blanket.png',
  'swing.png',
  'happy.png',
  'sad.png',
  'tired.png',
  'angry.png',
  'scared.png',
  'sick.png',
  'hurt.png',
  'good.png',
  'bad.png',
  'hug.png',
  'help.png',
  'please.png',
  'thank_you.png',
  'stop.png',
  'go.png',
  'play.png',
  'like.png',
  'see.png',
  'want.png',
  'yes.png',
  'no.png',
  'more.png',
  'i.png',
  'you.png',
  'mom.png',
  'dad.png',
  'toilet.png',
  'tablet.png',
  'tv.png',
  'book.png',
  'pencil.png',
  'draw.png',
  'music.png',
  'home.png',
  'school.png',
  'car.png',
  'bed.png',
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
  final ImagePicker _imagePicker = ImagePicker();

  // Sentence Bar stores full SymbolItems so the bar displays pictures + text!
  final List<SymbolItem> _sentenceItems = [];
  String _typingBuffer = "";
  String _selectedCategory = 'Core';
  bool _useQwerty = false;
  bool _phonicsMode = false;
  bool _isEditMode = false;

  // Voice & Language Settings
  String _selectedLanguage = 'en-US';
  String _voiceGender = 'female';
  double _speechRate = 0.48;
  double _pitch = 1.25;
  List<dynamic> _availableVoices = [];

  // User-created custom category tabs
  List<Map<String, String>> _customCategories = [];

  // Default Built-In Vocabulary across all rich categories
  List<SymbolItem> _buildDefaultVocabulary() {
    return [
      // -------------------------------------------------------------
      // 1. CORE BOARD (High-frequency motor-planning words)
      // -------------------------------------------------------------
      SymbolItem(id: 'i', label: 'I', spokenText: 'I', assetName: 'i.png', fallbackIcon: Icons.person, type: WordType.pronoun, category: 'Core'),
      SymbolItem(id: 'want', label: 'Want', spokenText: 'want', assetName: 'want.png', fallbackIcon: Icons.pan_tool, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'you', label: 'You', spokenText: 'you', assetName: 'you.png', fallbackIcon: Icons.people, type: WordType.pronoun, category: 'Core'),
      SymbolItem(id: 'please', label: 'Please', spokenText: 'please', assetName: 'please.png', fallbackIcon: Icons.volunteer_activism, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'help', label: 'Help', spokenText: 'Help me please', assetName: 'help.png', fallbackIcon: Icons.help_outline, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'more', label: 'More', spokenText: 'more', assetName: 'more.png', fallbackIcon: Icons.add_circle, type: WordType.adjective, category: 'Core'),
      SymbolItem(id: 'eat', label: 'Eat', spokenText: 'eat', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'drink', label: 'Drink', spokenText: 'drink', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'go', label: 'Go', spokenText: 'go', assetName: 'go.png', fallbackIcon: Icons.directions_run, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'stop', label: 'Stop', spokenText: 'Stop please', assetName: 'stop.png', fallbackIcon: Icons.front_hand, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'yes', label: 'Yes', spokenText: 'Yes', assetName: 'yes.png', fallbackIcon: Icons.check_circle, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'no', label: 'No', spokenText: 'No', assetName: 'no.png', fallbackIcon: Icons.cancel, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'like', label: 'Like', spokenText: 'like', assetName: 'like.png', fallbackIcon: Icons.thumb_up, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'see', label: 'See', spokenText: 'see', assetName: 'see.png', fallbackIcon: Icons.visibility, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'play', label: 'Play', spokenText: 'play', assetName: 'play.png', fallbackIcon: Icons.sports_esports, type: WordType.verb, category: 'Core'),
      SymbolItem(id: 'toilet', label: 'Bathroom', spokenText: 'I need the bathroom', assetName: 'toilet.png', fallbackIcon: Icons.wc, type: WordType.noun, category: 'Core'),
      SymbolItem(id: 'mom', label: 'Mom', spokenText: 'Mom', assetName: 'mom.png', fallbackIcon: Icons.face_3, type: WordType.pronoun, category: 'Core'),
      SymbolItem(id: 'dad', label: 'Dad', spokenText: 'Dad', assetName: 'dad.png', fallbackIcon: Icons.face, type: WordType.pronoun, category: 'Core'),
      SymbolItem(id: 'hug_core', label: 'Hug', spokenText: 'I want a hug', assetName: 'hug.png', fallbackIcon: Icons.favorite, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'thank_you', label: 'Thank You', spokenText: 'Thank you', assetName: 'thank_you.png', fallbackIcon: Icons.handshake, type: WordType.social, category: 'Core'),
      SymbolItem(id: 'home_core', label: 'Home', spokenText: 'I want to go home', assetName: 'home.png', fallbackIcon: Icons.home, type: WordType.noun, category: 'Core'),
      SymbolItem(id: 'car_core', label: 'Car Ride', spokenText: 'Go for a car ride', assetName: 'car.png', fallbackIcon: Icons.directions_car, type: WordType.noun, category: 'Core'),
      SymbolItem(id: 'tablet', label: 'Tablet', spokenText: 'My tablet please', assetName: 'tablet.png', fallbackIcon: Icons.tablet_mac, type: WordType.noun, category: 'Core'),
      SymbolItem(id: 'sleep_core', label: 'Sleep / Bed', spokenText: 'I am ready for bed', assetName: 'bed.png', fallbackIcon: Icons.bed, type: WordType.noun, category: 'Core'),

      // -------------------------------------------------------------
      // 2. RESTAURANTS & FAST FOOD (McDonald's, Favorites & Orders!)
      // -------------------------------------------------------------
      SymbolItem(id: 'rest_mcd', label: "McDonald's", spokenText: "I want McDonald's please", assetName: 'mcdonalds.png', fallbackIcon: Icons.fastfood, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_happymeal', label: 'Happy Meal', spokenText: "I want a McDonald's Happy Meal", assetName: 'happy_meal.png', fallbackIcon: Icons.card_giftcard, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_cfa', label: 'Chick-fil-A', spokenText: 'I want Chick-fil-A please', assetName: 'chickfila.png', fallbackIcon: Icons.fastfood, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_wendys', label: "Wendy's", spokenText: "I want Wendy's please", assetName: 'wendys.png', fallbackIcon: Icons.fastfood, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_bk', label: 'Burger King', spokenText: 'I want Burger King please', assetName: 'burgerking.png', fallbackIcon: Icons.lunch_dining, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_tacobell', label: 'Taco Bell', spokenText: 'I want Taco Bell please', assetName: 'tacobell.png', fallbackIcon: Icons.tapas, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_pizzahut', label: 'Pizza Hut', spokenText: 'I want Pizza Hut please', assetName: 'pizzahut.png', fallbackIcon: Icons.local_pizza, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_subway', label: 'Subway', spokenText: 'I want Subway please', assetName: 'subway.png', fallbackIcon: Icons.bakery_dining, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_starbucks', label: 'Starbucks', spokenText: 'I want Starbucks please', assetName: 'starbucks.png', fallbackIcon: Icons.local_cafe, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_dunkin', label: "Dunkin'", spokenText: "I want Dunkin' Donuts please", assetName: 'dunkin.png', fallbackIcon: Icons.donut_large, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_dq', label: 'Dairy Queen', spokenText: 'I want Dairy Queen ice cream please', assetName: 'dairyqueen.png', fallbackIcon: Icons.icecream, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_ihop', label: 'IHOP', spokenText: 'I want IHOP pancakes please', assetName: 'ihop.png', fallbackIcon: Icons.breakfast_dining, type: WordType.restaurant, category: 'Restaurants'),
      SymbolItem(id: 'rest_panda', label: 'Panda Express', spokenText: 'I want Panda Express please', assetName: 'pandaexpress.png', fallbackIcon: Icons.ramen_dining, type: WordType.restaurant, category: 'Restaurants'),
      // Favorite Restaurant Meals & Sides
      SymbolItem(id: 'ord_nuggets', label: 'Chicken Nuggets', spokenText: 'Chicken nuggets please', assetName: 'nuggets.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_fries', label: 'French Fries', spokenText: 'French fries please', assetName: 'fries.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_burger', label: 'Cheeseburger', spokenText: 'Cheeseburger please', assetName: 'burger.png', fallbackIcon: Icons.lunch_dining, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_pizza', label: 'Pizza', spokenText: 'Pizza slice please', assetName: 'pizza.png', fallbackIcon: Icons.local_pizza, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_taco', label: 'Taco', spokenText: 'Taco please', assetName: 'taco.png', fallbackIcon: Icons.tapas, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_hotdog', label: 'Hot Dog', spokenText: 'Hot dog please', assetName: 'hotdog.png', fallbackIcon: Icons.bakery_dining, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_pancakes', label: 'Pancakes', spokenText: 'Pancakes please', assetName: 'pancakes.png', fallbackIcon: Icons.breakfast_dining, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_mac', label: 'Mac & Cheese', spokenText: 'Macaroni and cheese please', assetName: 'pasta.png', fallbackIcon: Icons.dinner_dining, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_sandwich', label: 'Sandwich', spokenText: 'Sandwich please', assetName: 'sandwich.png', fallbackIcon: Icons.lunch_dining, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_icecream', label: 'Ice Cream', spokenText: 'Ice cream cone please', assetName: 'ice_cream.png', fallbackIcon: Icons.icecream, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_milkshake', label: 'Milkshake', spokenText: 'Milkshake please', assetName: 'milkshake.png', fallbackIcon: Icons.local_drink, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_donut', label: 'Donut', spokenText: 'Donut please', assetName: 'donut.png', fallbackIcon: Icons.donut_small, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_soda', label: 'Soda / Drink', spokenText: 'Soda please', assetName: 'soda.png', fallbackIcon: Icons.local_drink, type: WordType.noun, category: 'Restaurants'),
      SymbolItem(id: 'ord_ketchup', label: 'Ketchup', spokenText: 'Ketchup for dipping please', assetName: 'ketchup.png', fallbackIcon: Icons.water_drop, type: WordType.noun, category: 'Restaurants'),

      // -------------------------------------------------------------
      // 3. FOOD & DRINKS (Home Meals, Fruits, Snacks & Drinks)
      // -------------------------------------------------------------
      SymbolItem(id: 'apple', label: 'Apple', spokenText: 'Apple', assetName: 'apple.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'banana', label: 'Banana', spokenText: 'Banana', assetName: 'banana.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'strawberry_f', label: 'Strawberries', spokenText: 'Strawberries', assetName: 'strawberry.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'blueberry_f', label: 'Blueberries', spokenText: 'Blueberries', assetName: 'blueberry.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'orange_f', label: 'Orange', spokenText: 'Orange', assetName: 'orange_fruit.png', fallbackIcon: Icons.restaurant, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'pizza', label: 'Pizza', spokenText: 'Pizza', assetName: 'pizza.png', fallbackIcon: Icons.local_pizza, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'nuggets_f', label: 'Nuggets', spokenText: 'Chicken nuggets', assetName: 'nuggets.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'fries_f', label: 'Fries', spokenText: 'French fries', assetName: 'fries.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'pasta_f', label: 'Pasta / Noodles', spokenText: 'Pasta noodles', assetName: 'pasta.png', fallbackIcon: Icons.dinner_dining, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'pancakes_f', label: 'Pancakes', spokenText: 'Pancakes', assetName: 'pancakes.png', fallbackIcon: Icons.breakfast_dining, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'sandwich_f', label: 'Sandwich', spokenText: 'Sandwich', assetName: 'sandwich.png', fallbackIcon: Icons.lunch_dining, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'cheese_f', label: 'Cheese', spokenText: 'Cheese', assetName: 'cheese.png', fallbackIcon: Icons.lunch_dining, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'cracker', label: 'Crackers', spokenText: 'Crackers', assetName: 'cracker.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'snack', label: 'Snack', spokenText: 'I want a snack', assetName: 'snack.png', fallbackIcon: Icons.fastfood, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'cookie', label: 'Cookie', spokenText: 'Cookie', assetName: 'cookie.png', fallbackIcon: Icons.cookie, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'cupcake_f', label: 'Cupcake', spokenText: 'Cupcake', assetName: 'cupcake.png', fallbackIcon: Icons.cake, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'icecream_f', label: 'Ice Cream', spokenText: 'Ice cream', assetName: 'ice_cream.png', fallbackIcon: Icons.icecream, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'water', label: 'Water', spokenText: 'Water please', assetName: 'water.png', fallbackIcon: Icons.water_drop, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'juice', label: 'Juice', spokenText: 'Juice please', assetName: 'juice.png', fallbackIcon: Icons.local_cafe, type: WordType.noun, category: 'Food'),
      SymbolItem(id: 'milk', label: 'Milk', spokenText: 'Milk please', assetName: 'milk.png', fallbackIcon: Icons.local_drink, type: WordType.noun, category: 'Food'),

      // -------------------------------------------------------------
      // 4. ANIMALS & PETS (22 Illustrated Animals!)
      // -------------------------------------------------------------
      SymbolItem(id: 'an_dog', label: 'Dog / Puppy', spokenText: 'Dog', assetName: 'dog.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_cat', label: 'Cat / Kitty', spokenText: 'Cat', assetName: 'cat.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_rabbit', label: 'Bunny Rabbit', spokenText: 'Bunny rabbit', assetName: 'rabbit.png', fallbackIcon: Icons.cruelty_free, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_horse', label: 'Horse / Pony', spokenText: 'Horse', assetName: 'horse.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_dolphin', label: 'Dolphin', spokenText: 'Dolphin', assetName: 'dolphin.png', fallbackIcon: Icons.water, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_bird', label: 'Bird', spokenText: 'Bird', assetName: 'bird.png', fallbackIcon: Icons.flutter_dash, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_fish', label: 'Fish', spokenText: 'Fish', assetName: 'fish.png', fallbackIcon: Icons.set_meal, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_duck', label: 'Duck', spokenText: 'Duck, quack quack', assetName: 'duck.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_cow', label: 'Cow', spokenText: 'Cow, moo', assetName: 'cow.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_pig', label: 'Pig', spokenText: 'Pig, oink oink', assetName: 'pig.png', fallbackIcon: Icons.savings, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_sheep', label: 'Sheep', spokenText: 'Sheep, baa', assetName: 'sheep.png', fallbackIcon: Icons.cloud, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_chicken', label: 'Chicken', spokenText: 'Chicken', assetName: 'chicken_animal.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_frog', label: 'Frog', spokenText: 'Frog, ribbit', assetName: 'frog.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_monkey', label: 'Monkey', spokenText: 'Monkey', assetName: 'monkey.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_lion', label: 'Lion', spokenText: 'Lion, roar!', assetName: 'lion.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_tiger', label: 'Tiger', spokenText: 'Tiger', assetName: 'tiger.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_elephant', label: 'Elephant', spokenText: 'Elephant', assetName: 'elephant.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_bear', label: 'Teddy Bear', spokenText: 'Bear', assetName: 'bear.png', fallbackIcon: Icons.toys, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_giraffe', label: 'Giraffe', spokenText: 'Giraffe', assetName: 'giraffe.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_dinosaur', label: 'Dinosaur', spokenText: 'Dinosaur, stomp and roar!', assetName: 'dinosaur.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_butterfly', label: 'Butterfly', spokenText: 'Pretty butterfly', assetName: 'butterfly.png', fallbackIcon: Icons.auto_awesome, type: WordType.noun, category: 'Animals'),
      SymbolItem(id: 'an_turtle', label: 'Turtle', spokenText: 'Turtle', assetName: 'turtle.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Animals'),

      // -------------------------------------------------------------
      // 5. STRAWBERRY SHORTCAKE & CARTOONS
      // -------------------------------------------------------------
      SymbolItem(id: 'ss_main', label: 'Strawberry Shortcake', spokenText: 'I want Strawberry Shortcake cartoon!', assetName: 'strawberry.png', fallbackIcon: Icons.tv, type: WordType.social, category: 'Cartoons'),
      SymbolItem(id: 'ss_watch', label: 'Watch Cartoon', spokenText: 'Put on Strawberry Shortcake show please', assetName: 'tv.png', fallbackIcon: Icons.live_tv, type: WordType.verb, category: 'Cartoons'),
      SymbolItem(id: 'ss_custard', label: 'Custard Kitty', spokenText: 'Custard the pink cat', assetName: 'cat.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Cartoons'),
      SymbolItem(id: 'ss_pupcake', label: 'Pupcake Dog', spokenText: 'Pupcake the puppy dog', assetName: 'dog.png', fallbackIcon: Icons.pets, type: WordType.noun, category: 'Cartoons'),
      SymbolItem(id: 'ss_blueberry', label: 'Blueberry Muffin', spokenText: 'Blueberry Muffin', assetName: 'blueberry.png', fallbackIcon: Icons.person, type: WordType.adjective, category: 'Cartoons'),
      SymbolItem(id: 'ss_lemon', label: 'Lemon Meringue', spokenText: 'Lemon Meringue', assetName: 'lemon.png', fallbackIcon: Icons.person, type: WordType.pronoun, category: 'Cartoons'),
      SymbolItem(id: 'ss_orange', label: 'Orange Blossom', spokenText: 'Orange Blossom', assetName: 'orange_fruit.png', fallbackIcon: Icons.person, type: WordType.noun, category: 'Cartoons'),
      SymbolItem(id: 'ss_raspberry', label: 'Raspberry Torte', spokenText: 'Raspberry Torte', assetName: 'cupcake.png', fallbackIcon: Icons.person, type: WordType.social, category: 'Cartoons'),
      SymbolItem(id: 'ss_song', label: 'Berry Song', spokenText: 'Play the Strawberry Shortcake song please', assetName: 'music.png', fallbackIcon: Icons.music_note, type: WordType.verb, category: 'Cartoons'),
      SymbolItem(id: 'ss_cake', label: 'Berry Cake', spokenText: 'Strawberry Shortcake berry cake', assetName: 'cake.png', fallbackIcon: Icons.cake, type: WordType.noun, category: 'Cartoons'),
      SymbolItem(id: 'ss_next', label: 'Next Episode', spokenText: 'Next episode please', assetName: 'go.png', fallbackIcon: Icons.skip_next, type: WordType.verb, category: 'Cartoons'),
      SymbolItem(id: 'ss_rewind', label: 'Rewind / Again', spokenText: 'Rewind that part please', assetName: 'more.png', fallbackIcon: Icons.replay, type: WordType.verb, category: 'Cartoons'),

      // -------------------------------------------------------------
      // 6. SENSORY, NOISE & FEELINGS (Domestic Triggers + Regulation)
      // -------------------------------------------------------------
      SymbolItem(id: 'sn_dishes', label: 'Dishes Hurt Ears', spokenText: 'The dishes clanging hurt my ears! Please stop.', assetName: 'dishes.png', fallbackIcon: Icons.hearing_disabled, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'sn_kitchen', label: 'Too Loud!', spokenText: 'It is too loud in here, my ears hurt', assetName: 'loud.png', fallbackIcon: Icons.volume_off, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'sn_quiet_room', label: 'Quiet Bedroom', spokenText: 'I need to go to my quiet room right now', assetName: 'quiet.png', fallbackIcon: Icons.meeting_room, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'sn_headphones', label: 'Headphones', spokenText: 'I need my noise cancelling headphones please', assetName: 'headphones.png', fallbackIcon: Icons.headphones, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'sn_bright', label: 'Too Bright', spokenText: 'The lights are too bright, please turn them down', assetName: 'bright.png', fallbackIcon: Icons.light_mode, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'sn_hug', label: 'Squeeze / Hug', spokenText: 'I need a tight hug and deep pressure please', assetName: 'hug.png', fallbackIcon: Icons.favorite, type: WordType.social, category: 'Sensory'),
      SymbolItem(id: 'sn_blanket', label: 'Heavy Blanket', spokenText: 'I want my cozy blanket please', assetName: 'blanket.png', fallbackIcon: Icons.bed, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'sn_swing', label: 'Swing / Rock', spokenText: 'I want to swing or rock to feel calm', assetName: 'swing.png', fallbackIcon: Icons.airline_seat_recline_normal, type: WordType.sensory, category: 'Sensory'),
      SymbolItem(id: 'happy_f', label: 'Happy', spokenText: 'I am happy', assetName: 'happy.png', fallbackIcon: Icons.mood, type: WordType.adjective, category: 'Sensory'),
      SymbolItem(id: 'sad', label: 'Sad', spokenText: 'I am sad', assetName: 'sad.png', fallbackIcon: Icons.sentiment_dissatisfied, type: WordType.adjective, category: 'Sensory'),
      SymbolItem(id: 'angry', label: 'Angry / Mad', spokenText: 'I feel frustrated and mad', assetName: 'angry.png', fallbackIcon: Icons.mood_bad, type: WordType.adjective, category: 'Sensory'),
      SymbolItem(id: 'scared', label: 'Scared', spokenText: 'I am scared, please comfort me', assetName: 'scared.png', fallbackIcon: Icons.warning_amber, type: WordType.adjective, category: 'Sensory'),
      SymbolItem(id: 'tired_f', label: 'Tired', spokenText: 'I am tired and need rest', assetName: 'tired.png', fallbackIcon: Icons.bedtime, type: WordType.adjective, category: 'Sensory'),
      SymbolItem(id: 'sick', label: 'Tummy Sick', spokenText: 'My tummy feels sick', assetName: 'sick.png', fallbackIcon: Icons.sick, type: WordType.social, category: 'Sensory'),
      SymbolItem(id: 'hurt', label: 'Something Hurts', spokenText: 'Ouch, something hurts me', assetName: 'hurt.png', fallbackIcon: Icons.healing, type: WordType.social, category: 'Sensory'),

      // -------------------------------------------------------------
      // 7. LEARNING AREA (Colors, Shapes, School & Concepts)
      // -------------------------------------------------------------
      SymbolItem(id: 'c_red', label: 'Red', spokenText: 'Red', fallbackIcon: Icons.circle, customColor: const Color(0xFFFECACA), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'c_blue', label: 'Blue', spokenText: 'Blue', fallbackIcon: Icons.circle, customColor: const Color(0xFFBFDBFE), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'c_green', label: 'Green', spokenText: 'Green', fallbackIcon: Icons.circle, customColor: const Color(0xFFBBF7D0), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'c_yellow', label: 'Yellow', spokenText: 'Yellow', fallbackIcon: Icons.circle, customColor: const Color(0xFFFEF08A), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'c_orange', label: 'Orange', spokenText: 'Orange', fallbackIcon: Icons.circle, customColor: const Color(0xFFFED7AA), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'c_purple', label: 'Purple', spokenText: 'Purple', fallbackIcon: Icons.circle, customColor: const Color(0xFFE9D5FF), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'c_pink', label: 'Pink', spokenText: 'Pink', fallbackIcon: Icons.circle, customColor: const Color(0xFFFBCFE8), type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'sh_circle', label: 'Circle', spokenText: 'Circle', fallbackIcon: Icons.circle_outlined, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'sh_square', label: 'Square', spokenText: 'Square', fallbackIcon: Icons.crop_square, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'sh_triangle', label: 'Triangle', spokenText: 'Triangle', fallbackIcon: Icons.change_history, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'sh_star', label: 'Star', spokenText: 'Star', fallbackIcon: Icons.star_rounded, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'sh_heart', label: 'Heart', spokenText: 'Heart', fallbackIcon: Icons.favorite_rounded, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'bk_read', label: 'Read Book', spokenText: 'Read a book', assetName: 'book.png', fallbackIcon: Icons.menu_book, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'pn_write', label: 'Write / Pencil', spokenText: 'Write with pencil', assetName: 'pencil.png', fallbackIcon: Icons.edit, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'dr_art', label: 'Draw & Color', spokenText: 'Draw and color', assetName: 'draw.png', fallbackIcon: Icons.palette, type: WordType.learning, category: 'Learning'),
      SymbolItem(id: 'sc_school', label: 'School', spokenText: 'School', assetName: 'school.png', fallbackIcon: Icons.school, type: WordType.noun, category: 'Learning'),
      SymbolItem(id: 'mu_music', label: 'Music', spokenText: 'Listen to music', assetName: 'music.png', fallbackIcon: Icons.music_note, type: WordType.noun, category: 'Learning'),

      // -------------------------------------------------------------
      // 8. SIGN LANGUAGE (Total Communication: Sign + Speech + Symbol)
      // -------------------------------------------------------------
      SymbolItem(id: 'asl_ily', label: 'I Love You 🤟', spokenText: 'I love you', customEmoji: '🤟', fallbackIcon: Icons.favorite, type: WordType.sign, category: 'Signs', signGestureHint: '🤟 Thumb, index & pinky up'),
      SymbolItem(id: 'asl_more', label: 'More 🤲', spokenText: 'More please', assetName: 'more.png', fallbackIcon: Icons.add_circle, type: WordType.sign, category: 'Signs', signGestureHint: '🤲 Tap fingertips together'),
      SymbolItem(id: 'asl_please', label: 'Please 🙏', spokenText: 'Please', assetName: 'please.png', fallbackIcon: Icons.volunteer_activism, type: WordType.sign, category: 'Signs', signGestureHint: '🙏 Rub flat hand on chest'),
      SymbolItem(id: 'asl_thanks', label: 'Thank You 🤝', spokenText: 'Thank you', assetName: 'thank_you.png', fallbackIcon: Icons.handshake, type: WordType.sign, category: 'Signs', signGestureHint: '🤝 Touch chin & move out'),
      SymbolItem(id: 'asl_help', label: 'Help 🆘', spokenText: 'Help me please', assetName: 'help.png', fallbackIcon: Icons.help_outline, type: WordType.sign, category: 'Signs', signGestureHint: '🆘 Thumbs-up on flat palm'),
      SymbolItem(id: 'asl_stop', label: 'Stop 🛑', spokenText: 'Stop', assetName: 'stop.png', fallbackIcon: Icons.front_hand, type: WordType.sign, category: 'Signs', signGestureHint: '🛑 Chop hand onto palm'),
      SymbolItem(id: 'asl_eat', label: 'Eat 🍽️', spokenText: 'Eat', assetName: 'eat.png', fallbackIcon: Icons.restaurant, type: WordType.sign, category: 'Signs', signGestureHint: '🍽️ Fingertips to mouth'),
      SymbolItem(id: 'asl_drink', label: 'Drink 🥤', spokenText: 'Drink', assetName: 'drink.png', fallbackIcon: Icons.local_drink, type: WordType.sign, category: 'Signs', signGestureHint: '🥤 Tip C-hand to mouth'),
      SymbolItem(id: 'asl_water', label: 'Water 💧', spokenText: 'Water', assetName: 'water.png', fallbackIcon: Icons.water_drop, type: WordType.sign, category: 'Signs', signGestureHint: '💧 Tap W-fingers to chin'),
      SymbolItem(id: 'asl_toilet', label: 'Bathroom 🚻', spokenText: 'Bathroom', assetName: 'toilet.png', fallbackIcon: Icons.wc, type: WordType.sign, category: 'Signs', signGestureHint: '🚻 Shake T-hand side to side'),
      SymbolItem(id: 'asl_yes', label: 'Yes ✅', spokenText: 'Yes', assetName: 'yes.png', fallbackIcon: Icons.check_circle, type: WordType.sign, category: 'Signs', signGestureHint: '✅ Nod fist up and down'),
      SymbolItem(id: 'asl_no', label: 'No ❌', spokenText: 'No', assetName: 'no.png', fallbackIcon: Icons.cancel, type: WordType.sign, category: 'Signs', signGestureHint: '❌ Tap 2 fingers to thumb'),
      SymbolItem(id: 'asl_done', label: 'All Done ✨', spokenText: 'All done', customEmoji: '👐', fallbackIcon: Icons.done_all, type: WordType.sign, category: 'Signs', signGestureHint: '✨ Twist open hands outward'),
      SymbolItem(id: 'asl_hug', label: 'Hug 🫂', spokenText: 'Hug', assetName: 'hug.png', fallbackIcon: Icons.favorite, type: WordType.sign, category: 'Signs', signGestureHint: '🫂 Cross arms over chest'),

      // -------------------------------------------------------------
      // 9. VIBES & PEER SLANG
      // -------------------------------------------------------------
      SymbolItem(id: 'sl_lets_go', label: "Let's Go!", spokenText: "Let's gooo!", customEmoji: '🚀', fallbackIcon: Icons.rocket_launch, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_awesome', label: 'Awesome!', spokenText: 'That is so awesome!', customEmoji: '🌟', fallbackIcon: Icons.auto_awesome, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_bruh', label: 'Bruh', spokenText: 'Bruh...', customEmoji: '😐', fallbackIcon: Icons.sentiment_neutral, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_fire', label: 'Fire', spokenText: 'That is fire!', customEmoji: '🔥', fallbackIcon: Icons.local_fire_department, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_chill', label: 'Chill', spokenText: 'Just chilling.', customEmoji: '😎', fallbackIcon: Icons.ac_unit, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_no_way', label: 'No Way!', spokenText: 'No way! For real?', customEmoji: '😲', fallbackIcon: Icons.bolt, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_my_bad', label: 'My Bad', spokenText: 'My bad, sorry about that.', customEmoji: '🙋‍♀️', fallbackIcon: Icons.pan_tool, type: WordType.slang, category: 'Slang'),
      SymbolItem(id: 'sl_bestie', label: 'Bestie', spokenText: 'You are my bestie!', customEmoji: '💖', fallbackIcon: Icons.favorite, type: WordType.slang, category: 'Slang'),
    ];
  }

  late List<SymbolItem> _vocabulary = _buildDefaultVocabulary();

  final List<String> _dictionary = const [
    "I", "want", "need", "help", "please", "McDonald's", "Happy Meal", "nuggets",
    "fries", "pizza", "water", "juice", "milk", "banana", "apple", "strawberry",
    "bathroom", "hurt", "mom", "dad", "home", "dog", "cat", "bunny", "dolphin",
    "quiet", "headphones", "hug", "play", "tablet", "stop"
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _initTts();
  }

  // ==========================================
  // PERSISTENT STORAGE (SharedPreferences)
  // ==========================================
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load voice settings
      _selectedLanguage = prefs.getString('selected_language') ?? 'en-US';
      _voiceGender = prefs.getString('voice_gender') ?? 'female';
      _speechRate = prefs.getDouble('speech_rate') ?? 0.48;
      _pitch = prefs.getDouble('pitch') ?? 1.25;

      // Load custom categories
      final customCatsJson = prefs.getString('custom_categories_v2');
      if (customCatsJson != null) {
        final List<dynamic> decoded = jsonDecode(customCatsJson);
        _customCategories = decoded
            .map((e) => {
                  'name': e['name']?.toString() ?? 'Custom',
                  'label': e['label']?.toString() ?? '⭐ Custom',
                })
            .toList();
      }

      // Start with default vocabulary, apply edits, deletions, and custom additions
      List<SymbolItem> base = _buildDefaultVocabulary();

      final deletedIds = prefs.getStringList('deleted_ids_v2') ?? [];
      base.removeWhere((item) => deletedIds.contains(item.id));

      final editedJson = prefs.getString('edited_items_v2');
      if (editedJson != null) {
        final Map<String, dynamic> editedMap = jsonDecode(editedJson);
        for (int i = 0; i < base.length; i++) {
          final id = base[i].id;
          if (editedMap.containsKey(id)) {
            base[i] = SymbolItem.fromJson(editedMap[id]);
          }
        }
      }

      final customItemsJson = prefs.getString('custom_items_v2');
      if (customItemsJson != null) {
        final List<dynamic> customList = jsonDecode(customItemsJson);
        for (final raw in customList) {
          base.add(SymbolItem.fromJson(raw));
        }
      }

      if (mounted) {
        setState(() {
          _vocabulary = base;
        });
      }
    } catch (e) {
      debugPrint("Error loading saved data: $e");
    }
  }

  Future<void> _saveCustomItem(SymbolItem newItem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customItemsJson = prefs.getString('custom_items_v2');
      List<dynamic> list = customItemsJson != null ? jsonDecode(customItemsJson) : [];
      list.removeWhere((e) => e['id'] == newItem.id);
      list.add(newItem.toJson());
      await prefs.setString('custom_items_v2', jsonEncode(list));
    } catch (e) {
      debugPrint("Error saving custom item: $e");
    }
  }

  Future<void> _saveEditedItem(SymbolItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (item.id.startsWith('custom_')) {
        await _saveCustomItem(item);
      } else {
        final editedJson = prefs.getString('edited_items_v2');
        Map<String, dynamic> editedMap = editedJson != null ? jsonDecode(editedJson) : {};
        editedMap[item.id] = item.toJson();
        await prefs.setString('edited_items_v2', jsonEncode(editedMap));
      }
    } catch (e) {
      debugPrint("Error saving edited item: $e");
    }
  }

  Future<void> _deleteItemPersistently(SymbolItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (item.id.startsWith('custom_')) {
        final customItemsJson = prefs.getString('custom_items_v2');
        if (customItemsJson != null) {
          List<dynamic> list = jsonDecode(customItemsJson);
          list.removeWhere((e) => e['id'] == item.id);
          await prefs.setString('custom_items_v2', jsonEncode(list));
        }
      } else {
        final deletedIds = prefs.getStringList('deleted_ids_v2') ?? [];
        if (!deletedIds.contains(item.id)) {
          deletedIds.add(item.id);
          await prefs.setStringList('deleted_ids_v2', deletedIds);
        }
      }
    } catch (e) {
      debugPrint("Error deleting item: $e");
    }
  }

  Future<void> _saveVoicePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', _selectedLanguage);
      await prefs.setString('voice_gender', _voiceGender);
      await prefs.setDouble('speech_rate', _speechRate);
      await prefs.setDouble('pitch', _pitch);
    } catch (_) {}
  }

  // ==========================================
  // TEXT TO SPEECH (TTS) ENGINE
  // ==========================================
  Future<void> _initTts() async {
    try {
      await _flutterTts.awaitSynthCompletion(true);
      final dynamic engines = await _flutterTts.getEngines;
      if (engines is List && engines.isNotEmpty) {
        if (engines.contains("com.google.android.tts")) {
          await _flutterTts.setEngine("com.google.android.tts");
        } else if (engines.contains("com.ivona.tts.oem")) {
          await _flutterTts.setEngine("com.ivona.tts.oem");
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
                  (name.contains('female') ||
                      name.contains('salli') ||
                      name.contains('kendra') ||
                      name.contains('zira') ||
                      name.contains('samantha') ||
                      name.contains('network') ||
                      name.contains('iob') ||
                      name.contains('tpf'))) {
                await _flutterTts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              } else if (_voiceGender == 'male' &&
                  (name.contains('male') ||
                      name.contains('joey') ||
                      name.contains('david') ||
                      name.contains('guy') ||
                      name.contains('iom'))) {
                await _flutterTts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              }
            }
          }
        }
      }
      await _saveVoicePreferences();
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

  void _onTapSymbol(SymbolItem item) {
    setState(() {
      _sentenceItems.add(item);
    });
    _speakText(item.spokenText);
  }

  void _speakFullSentence() {
    final fullText = [
      ..._sentenceItems.map((e) => e.spokenText),
      if (_typingBuffer.isNotEmpty) _typingBuffer,
    ].join(" ");
    _speakText(fullText);
  }

  // ==========================================
  // RENDER SYMBOL IMAGE (Asset / Local Photo / Online / Emoji)
  // ==========================================
  Widget _buildSymbolVisual(SymbolItem item, bool isDark, {double size = 56}) {
    if (item.localImagePath != null && item.localImagePath!.isNotEmpty) {
      final file = File(item.localImagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) => _buildFallbackVisual(item, isDark, size),
          ),
        );
      }
    }
    if (item.networkImageUrl != null && item.networkImageUrl!.isNotEmpty) {
      return Image.network(
        item.networkImageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackVisual(item, isDark, size),
      );
    }
    if (item.assetName != null && item.assetName!.isNotEmpty) {
      return Image.asset(
        'assets/symbols/${item.assetName}',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackVisual(item, isDark, size),
      );
    }
    if (item.customEmoji != null && item.customEmoji!.isNotEmpty) {
      return Center(
        child: Text(
          item.customEmoji!,
          style: TextStyle(fontSize: size * 0.78),
        ),
      );
    }
    return _buildFallbackVisual(item, isDark, size);
  }

  Widget _buildFallbackVisual(SymbolItem item, bool isDark, double size) {
    return Icon(
      item.fallbackIcon ?? Icons.record_voice_over_rounded,
      size: size * 0.75,
      color: isDark ? Colors.white : Colors.black87,
    );
  }

  // ==========================================
  // 🆘 EMERGENCY SENSORY OVERLOAD FULL-SCREEN CARD
  // ==========================================
  void _showSensoryOverloadModal() {
    _speakText(
      "I am having sensory overload. Please give me quiet space and do not ask me questions right now.",
    );
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0xFFEF4444), width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🛑 🎧 🫂", style: TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                const Text(
                  "SENSORY OVERLOAD",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFCA5A5),
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "I am overwhelmed right now.\n• Please lower voices & stop loud noises (like dishes)\n• Please give me quiet space & my headphones\n• Please wait before asking me questions",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _speakText(
                        "I am having sensory overload. Please give me quiet space and do not ask me questions right now.",
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text(
                        "Speak Alert Again",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        "I Feel Better (Close)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 🔍 FULL-SCREEN "SHOW MY ORDER / CARD" DISPLAY
  // ==========================================
  void _showLargeDisplayModal() {
    if (_sentenceItems.isEmpty && _typingBuffer.isEmpty) return;
    _speakFullSentence();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.visibility_rounded, color: Color(0xFF4F46E5), size: 28),
                        SizedBox(width: 8),
                        Text(
                          "Show What I Want",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _sentenceItems.map((item) {
                    return Container(
                      width: 150,
                      height: 165,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.getColor(widget.isDarkMode),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: item.getBorderColor(widget.isDarkMode), width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: _buildSymbolVisual(item, false, size: 80),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  [
                    ..._sentenceItems.map((e) => e.spokenText),
                    if (_typingBuffer.isNotEmpty) _typingBuffer,
                  ].join(" "),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _speakFullSentence,
                  icon: const Icon(Icons.volume_up_rounded, size: 28),
                  label: const Text("Speak Aloud", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // ➕ ADD CUSTOM CATEGORY TAB DIALOG
  // ==========================================
  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '⭐');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.create_new_folder_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text('Create New Tab / Board', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tab Name (e.g., Toys, Family, Places)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emojiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tab Icon Emoji (e.g., 🧸, 👨‍👩‍👧, 🏞️)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final rawName = nameCtrl.text.trim();
                if (rawName.isEmpty) return;
                final emoji = emojiCtrl.text.trim().isEmpty ? '⭐' : emojiCtrl.text.trim();
                final newCat = {
                  'name': rawName,
                  'label': '$emoji $rawName',
                };
                setState(() {
                  _customCategories.add(newCat);
                  _selectedCategory = rawName;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('custom_categories_v2', jsonEncode(_customCategories));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Tab'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // EASY WORD & IMAGE STUDIO (Add or Customize Any Button!)
  // Supports:
  // 1. 📸 Tablet Camera / Photo Gallery
  // 2. 🌐 Live Search of 35,000+ Online ARASAAC Symbols
  // 3. 🎨 Instant Search of 111 Built-in Offline Symbols
  // 4. 😊 Custom Emoji Sticker
  // ==========================================
  void _showWordStudioDialog({SymbolItem? existingItem, String? targetCategory}) {
    final isEditing = existingItem != null;
    final category = existingItem?.category ?? targetCategory ?? (_selectedCategory == 'ABC' ? 'Core' : _selectedCategory);

    final labelCtrl = TextEditingController(text: existingItem?.label ?? '');
    final speechCtrl = TextEditingController(text: existingItem?.spokenText ?? '');
    final emojiCtrl = TextEditingController(text: existingItem?.customEmoji ?? '');
    final symbolSearchCtrl = TextEditingController();
    final onlineSearchCtrl = TextEditingController();

    String? selectedAsset = existingItem?.assetName;
    String? selectedLocalPath = existingItem?.localImagePath;
    String? selectedNetworkUrl = existingItem?.networkImageUrl;
    WordType selectedType = existingItem?.type ??
        (category == 'Restaurants'
            ? WordType.restaurant
            : category == 'Sensory'
                ? WordType.sensory
                : WordType.noun);

    String filterQuery = '';
    List<String> onlineUrls = [];
    bool isSearchingOnline = false;

    Future<void> searchArasaacOnline(String query, StateSetter setDialogState) async {
      final clean = query.trim();
      if (clean.isEmpty) return;
      setDialogState(() {
        isSearchingOnline = true;
      });
      try {
        final client = HttpClient();
        final uri = Uri.parse(
          'https://api.arasaac.org/api/pictograms/en/search/${Uri.encodeComponent(clean)}',
        );
        final req = await client.getUrl(uri);
        final res = await req.close();
        if (res.statusCode == 200) {
          final body = await res.transform(utf8.decoder).join();
          final List<dynamic> data = jsonDecode(body);
          final urls = data
              .take(24)
              .map((item) => 'https://static.arasaac.org/pictograms/${item['_id']}/${item['_id']}_500.png')
              .toList();
          setDialogState(() {
            onlineUrls = urls;
            isSearchingOnline = false;
          });
        } else {
          setDialogState(() {
            onlineUrls = [];
            isSearchingOnline = false;
          });
        }
      } catch (e) {
        setDialogState(() {
          isSearchingOnline = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredAssets = availableSymbolAssets
                .where((a) => a.toLowerCase().replaceAll('.png', '').contains(filterQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
              contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.add_photo_alternate_rounded,
                      color: const Color(0xFF4F46E5),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Customize "${existingItem.label}"' : 'Add New Word to $category',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 580,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Word Label & Speech Inputs
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: labelCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Button Label (Shown on Card)',
                                hintText: 'e.g. McDonald\'s, Dolphin, Grandma',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                if (!isEditing) {
                                  speechCtrl.text = val;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: speechCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Spoken Phrase (What it Says)',
                                hintText: 'e.g. I want McDonald\'s please',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 2. Easy Photo Picker Row (Camera + Gallery + Preview)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Live Preview Box
                            Container(
                              width: 72,
                              height: 72,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF4F46E5), width: 2),
                              ),
                              child: _buildSymbolVisual(
                                SymbolItem(
                                  id: 'preview',
                                  label: labelCtrl.text,
                                  spokenText: speechCtrl.text,
                                  assetName: selectedAsset,
                                  localImagePath: selectedLocalPath,
                                  networkImageUrl: selectedNetworkUrl,
                                  customEmoji: emojiCtrl.text.trim(),
                                  type: selectedType,
                                ),
                                false,
                                size: 56,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final XFile? photo = await _imagePicker.pickImage(
                                          source: ImageSource.camera,
                                          maxWidth: 500,
                                          maxHeight: 500,
                                          imageQuality: 85,
                                        );
                                        if (photo != null) {
                                          setDialogState(() {
                                            selectedLocalPath = photo.path;
                                            selectedAsset = null;
                                            selectedNetworkUrl = null;
                                          });
                                        }
                                      } catch (e) {
                                        debugPrint("Camera error: $e");
                                      }
                                    },
                                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                    label: const Text('Take Photo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final XFile? image = await _imagePicker.pickImage(
                                          source: ImageSource.gallery,
                                          maxWidth: 500,
                                          maxHeight: 500,
                                          imageQuality: 85,
                                        );
                                        if (image != null) {
                                          setDialogState(() {
                                            selectedLocalPath = image.path;
                                            selectedAsset = null;
                                            selectedNetworkUrl = null;
                                          });
                                        }
                                      } catch (e) {
                                        debugPrint("Gallery error: $e");
                                      }
                                    },
                                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                                    label: const Text('Pick from Gallery'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0284C7),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: emojiCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Or Emoji 🦄',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) {
                                        if (v.trim().isNotEmpty) {
                                          setDialogState(() {
                                            selectedAsset = null;
                                            selectedLocalPath = null;
                                            selectedNetworkUrl = null;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Online 35,000+ ARASAAC Symbol Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: onlineSearchCtrl,
                              decoration: const InputDecoration(
                                labelText: '🌐 Search 35,000+ Online Symbols (Type any word)',
                                hintText: 'e.g. trampoline, grandma, waffles, paw patrol...',
                                prefixIcon: Icon(Icons.public_rounded),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onSubmitted: (v) => searchArasaacOnline(v, setDialogState),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => searchArasaacOnline(onlineSearchCtrl.text, setDialogState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            child: isSearchingOnline
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Search Web'),
                          ),
                        ],
                      ),

                      if (onlineUrls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Tap an Online Symbol to Use:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D9488)),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 92,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: onlineUrls.length,
                            itemBuilder: (context, idx) {
                              final url = onlineUrls[idx];
                              final isSelected = selectedNetworkUrl == url;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedNetworkUrl = url;
                                      selectedAsset = null;
                                      selectedLocalPath = null;
                                    });
                                  },
                                  child: Container(
                                    width: 86,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF0D9488) : Colors.black26,
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                    child: Image.network(url, fit: BoxFit.contain),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // 4. Built-in 111 Offline Symbols (With Quick Filter)
                      Row(
                        children: [
                          const Text(
                            '🎨 Built-In Symbols & Restaurant Logos (111 Offline):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 190,
                            height: 36,
                            child: TextField(
                              controller: symbolSearchCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Filter built-in...',
                                prefixIcon: Icon(Icons.search, size: 18),
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => setDialogState(() => filterQuery = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 165,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredAssets.length,
                          itemBuilder: (context, idx) {
                            final asset = filteredAssets[idx];
                            final isSelected = selectedAsset == asset;
                            final cleanName = asset.replaceAll('.png', '').replaceAll('_', ' ');

                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedAsset = asset;
                                  selectedLocalPath = null;
                                  selectedNetworkUrl = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE0E7FF) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF4F46E5) : Colors.black12,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.asset('assets/symbols/$asset', fit: BoxFit.contain),
                                    ),
                                    Text(
                                      cleanName,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 5. Color Category Selector
                      const Text('Card Color Style:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Noun (Orange)'),
                            selected: selectedType == WordType.noun,
                            selectedColor: const Color(0xFFFED7AA),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.noun),
                          ),
                          ChoiceChip(
                            label: const Text('Restaurant (Red)'),
                            selected: selectedType == WordType.restaurant,
                            selectedColor: const Color(0xFFFECACA),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.restaurant),
                          ),
                          ChoiceChip(
                            label: const Text('Action / Verb (Green)'),
                            selected: selectedType == WordType.verb,
                            selectedColor: const Color(0xFFBBF7D0),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.verb),
                          ),
                          ChoiceChip(
                            label: const Text('Social (Pink)'),
                            selected: selectedType == WordType.social,
                            selectedColor: const Color(0xFFFBCFE8),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.social),
                          ),
                          ChoiceChip(
                            label: const Text('Sensory (Teal)'),
                            selected: selectedType == WordType.sensory,
                            selectedColor: const Color(0xFF99F6E4),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.sensory),
                          ),
                          ChoiceChip(
                            label: const Text('Feeling / Describe (Blue)'),
                            selected: selectedType == WordType.adjective,
                            selectedColor: const Color(0xFFBAE6FD),
                            onSelected: (_) => setDialogState(() => selectedType = WordType.adjective),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (isEditing)
                  TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        _vocabulary.remove(existingItem);
                      });
                      await _deleteItemPersistently(existingItem);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Delete Button', style: TextStyle(color: Colors.redAccent)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final label = labelCtrl.text.trim();
                    if (label.isEmpty) return;
                    final spoken = speechCtrl.text.trim().isNotEmpty ? speechCtrl.text.trim() : label;
                    final emoji = emojiCtrl.text.trim().isNotEmpty ? emojiCtrl.text.trim() : null;

                    if (isEditing) {
                      setState(() {
                        existingItem.label = label;
                        existingItem.spokenText = spoken;
                        existingItem.assetName = selectedAsset;
                        existingItem.localImagePath = selectedLocalPath;
                        existingItem.networkImageUrl = selectedNetworkUrl;
                        existingItem.customEmoji = emoji;
                        existingItem.type = selectedType;
                      });
                      await _saveEditedItem(existingItem);
                    } else {
                      final newItem = SymbolItem(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        label: label,
                        spokenText: spoken,
                        assetName: selectedAsset,
                        localImagePath: selectedLocalPath,
                        networkImageUrl: selectedNetworkUrl,
                        customEmoji: emoji,
                        fallbackIcon: Icons.star_rounded,
                        type: selectedType,
                        category: category,
                      );
                      setState(() {
                        _vocabulary.add(newItem);
                      });
                      await _saveCustomItem(newItem);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(isEditing ? 'Save Changes' : 'Save Word'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: Color(0xFF4F46E5)),
                  SizedBox(width: 8),
                  Text('Voice, Language & App Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Voice Tone & Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.female, size: 18),
                          label: const Text('Sweet Female Voice'),
                          selected: _voiceGender == 'female',
                          selectedColor: const Color(0xFFFBCFE8),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                _voiceGender = 'female';
                                _pitch = 1.25;
                              });
                              setState(() {});
                              _applyVoiceSettings();
                            }
                          },
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.male, size: 18),
                          label: const Text('Warm Male Voice'),
                          selected: _voiceGender == 'male',
                          selectedColor: const Color(0xFFBAE6FD),
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
                        DropdownMenuItem(value: 'es-US', child: Text('🇲🇽 Spanish (Español - Latinoamérica)')),
                        DropdownMenuItem(value: 'es-ES', child: Text('🇪🇸 Spanish (Español - España)')),
                        DropdownMenuItem(value: 'fr-FR', child: Text('🇫🇷 French (Français)')),
                        DropdownMenuItem(value: 'de-DE', child: Text('🇩🇪 German (Deutsch)')),
                        DropdownMenuItem(value: 'pt-BR', child: Text('🇧🇷 Portuguese (Português)')),
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
                    Text('Voice Pitch: ${_pitch.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _pitch,
                      min: 0.6,
                      max: 1.8,
                      divisions: 12,
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
                      min: 0.25,
                      max: 0.85,
                      divisions: 12,
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
                  onPressed: () => _speakText("Hi! I am Genesis Speech Tab. Let's talk together!"),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Test Voice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                  ),
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
  // MAIN SCAFFOLD BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(isDark),
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

  // 1. ELEGANT CLINICAL HEADER BAR
  Widget _buildTopAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Brand Logo & Title
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Genesis Speech Tab',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const Spacer(),

          // 🆘 1-Tap Sensory Overload Alert Button
          FilledButton.tonalIcon(
            onPressed: _showSensoryOverloadModal,
            icon: const Icon(Icons.sos_rounded, size: 18, color: Color(0xFFEF4444)),
            label: const Text(
              'Overload Card',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
              foregroundColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),

          // ➕ Prominent Add Word & Image Button
          FilledButton.icon(
            onPressed: () => _showWordStudioDialog(
              targetCategory: _selectedCategory == 'ABC' ? 'Core' : _selectedCategory,
            ),
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
            label: const Text(
              'Add Word / Photo',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 6),

          // ✏️ Edit Mode Toggle
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.check_circle_rounded : Icons.tune_rounded,
              size: 24,
              color: _isEditMode
                  ? const Color(0xFF16A34A)
                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
            tooltip: _isEditMode ? "Finish Editing" : "Customize Any Button",
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),

          // 🔊 Voice & Language Settings
          IconButton(
            icon: Icon(
              Icons.settings_voice_rounded,
              size: 24,
              color: isDark ? Colors.indigo.shade300 : const Color(0xFF4F46E5),
            ),
            tooltip: "Voice & Language Settings",
            visualDensity: VisualDensity.compact,
            onPressed: _showVoiceSettingsDialog,
          ),

          // 🌙 Sensory Dark Mode Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 24,
              color: isDark ? Colors.amber : const Color(0xFF475569),
            ),
            tooltip: isDark ? "Switch to Light Mode" : "Sensory Dark Mode",
            visualDensity: VisualDensity.compact,
            onPressed: widget.onToggleDarkMode,
          ),
        ],
      ),
    );
  }

  // 2. VISUAL SENTENCE STRIP BAR (Shows Pictures + Words & Speaks Full Sentence!)
  Widget _buildSentenceBar(bool isDark) {
    final hasContent = _sentenceItems.isNotEmpty || _typingBuffer.isNotEmpty;

    return Container(
      height: 88,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEditMode
              ? const Color(0xFF3B82F6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tapping the sentence strip speaks the full sentence!
          Expanded(
            child: InkWell(
              onTap: hasContent ? _speakFullSentence : null,
              borderRadius: BorderRadius.circular(14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (!hasContent)
                      Row(
                        children: [
                          Icon(
                            _isEditMode ? Icons.edit_note_rounded : Icons.touch_app_rounded,
                            color: _isEditMode
                                ? Colors.blueAccent
                                : (isDark ? Colors.white38 : Colors.grey.shade400),
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditMode
                                ? "Edit Mode ON: Tap any card below to change its picture, photo, or voice!"
                                : "Tap cards to speak & build a sentence here...",
                            style: TextStyle(
                              fontSize: 16,
                              color: _isEditMode
                                  ? Colors.blueAccent
                                  : (isDark ? Colors.white38 : Colors.grey.shade500),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    // Visual Symbol Cards inside the Sentence Strip!
                    ..._sentenceItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _speakText(item.spokenText),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 68,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.getColor(isDark),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: item.getBorderColor(isDark), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _buildSymbolVisual(item, false, size: 36),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_typingBuffer.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Text(
                          "$_typingBuffer|",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.amber.shade200 : Colors.brown.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 🔍 Show Large Order / Sentence Card (Great for Restaurants!)
          if (hasContent)
            IconButton(
              icon: const Icon(Icons.fullscreen_rounded, size: 30, color: Color(0xFF4F46E5)),
              tooltip: "Show Big Card (Great for Restaurants!)",
              onPressed: _showLargeDisplayModal,
            ),

          // 🔊 Speak Full Sentence Button
          ElevatedButton.icon(
            icon: const Icon(Icons.volume_up_rounded, size: 26),
            label: const Text('Speak', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            onPressed: hasContent ? _speakFullSentence : null,
          ),
          const SizedBox(width: 4),

          // ⌫ Backspace
          IconButton(
            icon: const Icon(Icons.backspace_outlined, size: 24, color: Colors.orange),
            tooltip: "Remove Last Word",
            onPressed: () {
              setState(() {
                if (_typingBuffer.isNotEmpty) {
                  _typingBuffer = _typingBuffer.substring(0, _typingBuffer.length - 1);
                } else if (_sentenceItems.isNotEmpty) {
                  _sentenceItems.removeLast();
                }
              });
            },
          ),

          // 🗑️ Clear All
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 26, color: Colors.redAccent),
            tooltip: "Clear Sentence Bar",
            onPressed: () {
              setState(() {
                _sentenceItems.clear();
                _typingBuffer = "";
              });
            },
          ),
        ],
      ),
    );
  }

  // 3. CATEGORY NAVIGATION TABS (With Restaurants, Animals, Cartoons, Sensory & + New Tab)
  Widget _buildCategoryTabs(bool isDark) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Core', 'label': '🗣️ Core Words', 'color': const Color(0xFF4F46E5)},
      {'name': 'Restaurants', 'label': '🍔 Restaurants', 'color': const Color(0xFFDC2626)},
      {'name': 'Food', 'label': '🍎 Food & Drinks', 'color': const Color(0xFFEA580C)},
      {'name': 'Animals', 'label': '🐾 Animals', 'color': const Color(0xFF16A34A)},
      {'name': 'Cartoons', 'label': '🍓 Cartoons', 'color': const Color(0xFFDB2777)},
      {'name': 'Sensory', 'label': '🧠 Sensory & Feelings', 'color': const Color(0xFF0D9488)},
      {'name': 'Learning', 'label': '🎓 Learning', 'color': const Color(0xFF2563EB)},
      {'name': 'Signs', 'label': '🤟 ASL Signs', 'color': const Color(0xFF7C3AED)},
      {'name': 'ABC', 'label': '🔤 ABC & 123', 'color': const Color(0xFF0284C7)},
      {'name': 'Slang', 'label': '⚡ Vibes', 'color': const Color(0xFF9333EA)},
      ..._customCategories.map((c) => {
            'name': c['name']!,
            'label': c['label']!,
            'color': const Color(0xFF4F46E5),
          }),
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          // Last chip: ➕ New Category Tab
          if (index == categories.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF4F46E5)),
                label: const Text(
                  'New Tab',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onPressed: _showAddCategoryDialog,
              ),
            );
          }

          final cat = categories[index];
          final isSelected = _selectedCategory == cat['name'];
          final Color activeColor = cat['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(
                cat['label'] as String,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
              ),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              side: BorderSide(
                color: isSelected
                    ? activeColor
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (_) => setState(() => _selectedCategory = cat['name'] as String),
            ),
          );
        },
      ),
    );
  }

  // 4. CLINICAL-GRADE SYMBOL GRID
  Widget _buildSymbolGrid(bool isDark) {
    final items = _vocabulary.where((item) => item.category == _selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 152,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemCount: items.length + 1, // +1 for the Add Word tile
      itemBuilder: (context, index) {
        // Last Tile: ➕ Add Word & Photo to Section
        if (index == items.length) {
          return InkWell(
            onTap: () => _showWordStudioDialog(targetCategory: _selectedCategory),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4F46E5),
                  width: 2.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, size: 34, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ADD WORD\nOR PHOTO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.indigo.shade200 : const Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final item = items[index];
        final borderColor = _isEditMode ? const Color(0xFF3B82F6) : item.getBorderColor(isDark);

        return InkWell(
          onTap: () {
            if (_isEditMode) {
              _showWordStudioDialog(existingItem: item);
            } else {
              _onTapSymbol(item);
            }
          },
          onLongPress: () => _showWordStudioDialog(existingItem: item),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: item.getColor(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: _isEditMode ? 3 : 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Crisp inner white symbol well so illustrations & logos pop clearly
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.94) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _buildSymbolVisual(item, false, size: 68),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.signGestureHint != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.signGestureHint!,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
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
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. ALPHABET, PHONICS & NUMBERS BOARD
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
        ? ["I", "want", "McDonald's", "nuggets", "please", "dolphin"]
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
                            pred,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.indigo.shade900,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _sentenceItems.add(
                                SymbolItem(
                                  id: 'typed_${DateTime.now().millisecondsSinceEpoch}',
                                  label: pred,
                                  spokenText: pred,
                                  customEmoji: '💬',
                                  type: WordType.learning,
                                ),
                              );
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
                activeColor: const Color(0xFF4F46E5),
                onChanged: (val) => setState(() => _phonicsMode = val),
              ),
              Text(
                _phonicsMode ? "Phonics" : "Letters",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _useQwerty = !_useQwerty),
                child: Text(_useQwerty ? "ABC" : "QWERTY"),
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
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      onTap: () {
                        setState(() => _typingBuffer += char);
                        _speakText(_phonicsMode ? (phonicsMap[char] ?? char) : char.toLowerCase());
                      },
                    )),
                ...numbers.split('').map((num) => _buildKeyButton(
                      num,
                      color: isDark ? const Color(0xFF422006) : const Color(0xFFFEF9C3),
                      textColor: isDark ? Colors.amber.shade200 : const Color(0xFF713F12),
                      borderColor: isDark ? const Color(0xFFEAB308) : const Color(0xFFFACC15),
                      onTap: () {
                        setState(() => _typingBuffer += num);
                        _speakText(num);
                      },
                    )),
                _buildKeyButton(
                  "SPACE",
                  color: isDark ? const Color(0xFF052E16) : const Color(0xFFDCFCE7),
                  textColor: isDark ? Colors.green.shade200 : const Color(0xFF166534),
                  borderColor: const Color(0xFF22C55E),
                  onTap: () {
                    if (_typingBuffer.isNotEmpty) {
                      final completedWord = _typingBuffer;
                      setState(() {
                        _sentenceItems.add(
                          SymbolItem(
                            id: 'typed_${DateTime.now().millisecondsSinceEpoch}',
                            label: completedWord,
                            spokenText: completedWord,
                            customEmoji: '💬',
                            type: WordType.learning,
                          ),
                        );
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
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
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
