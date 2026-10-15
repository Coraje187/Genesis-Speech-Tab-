import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenAacApp());
}

class OpenAacApp extends StatelessWidget {
  const OpenAacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAAC Motor Planning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        fontFamily: 'Roboto',
      ),
      home: const AacBoardScreen(),
    );
  }
}

// ==========================================
// DATA MODELS & FITZGERALD KEY
// ==========================================

enum PartOfSpeech {
  pronoun,     // Yellow: I, You, He, She
  verb,        // Green: Want, Go, Eat, Stop
  noun,        // Orange: Apple, Water, Toy
  adjective,   // Blue: Big, More, Finished
  social,      // Pink: Please, Yes, No
  slang,       // Vibrant Purple: Bruh, Let's go, Chill
  preposition, // Grey: In, On, Under
}

Color getButtonColor(PartOfSpeech pos) {
  switch (pos) {
    case PartOfSpeech.pronoun:
      return const Color(0xFFFEF08A);
    case PartOfSpeech.verb:
      return const Color(0xFFBBF7D0);
    case PartOfSpeech.noun:
      return const Color(0xFFFED7AA);
    case PartOfSpeech.adjective:
      return const Color(0xFFBAE6FD);
    case PartOfSpeech.social:
      return const Color(0xFFFBCFE8);
    case PartOfSpeech.slang:
      return const Color(0xFFE9D5FF);
    case PartOfSpeech.preposition:
      return const Color(0xFFE2E8F0);
  }
}

Color getButtonBorderColor(PartOfSpeech pos) {
  switch (pos) {
    case PartOfSpeech.pronoun:
      return const Color(0xFFCA8A04);
    case PartOfSpeech.verb:
      return const Color(0xFF16A34A);
    case PartOfSpeech.noun:
      return const Color(0xFFEA580C);
    case PartOfSpeech.adjective:
      return const Color(0xFF0284C7);
    case PartOfSpeech.social:
      return const Color(0xFFDB2777);
    case PartOfSpeech.slang:
      return const Color(0xFF9333EA);
    case PartOfSpeech.preposition:
      return const Color(0xFF94A3B8);
  }
}

class AacButtonData {
  String id;
  int row;
  int col;
  String label;
  String spokenText;
  IconData icon;
  PartOfSpeech partOfSpeech;
  String? targetBoardId;
  double pitch;
  double speechRate;
  bool isMasked;

  AacButtonData({
    required this.id,
    required this.row,
    required this.col,
    required this.label,
    required this.spokenText,
    required this.icon,
    required this.partOfSpeech,
    this.targetBoardId,
    this.pitch = 1.1,
    this.speechRate = 0.45,
    this.isMasked = false,
  });
}

// ==========================================
// MAIN SCREEN IMPLEMENTATION
// ==========================================

class AacBoardScreen extends StatefulWidget {
  const AacBoardScreen({super.key});

  @override
  State<AacBoardScreen> createState() => _AacBoardScreenState();
}

class _AacBoardScreenState extends State<AacBoardScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<AacButtonData> _sentenceStrip = [];

  bool _isEditMode = false; // Toggle to Add/Edit words and tabs
  String _currentBoardId = 'home';

  static const int totalRows = 5;
  static const int totalCols = 7;

  // Board Registry: tabId -> Display Name
  final Map<String, String> _boardNames = {
    'home': '🏠 Home',
    'slang': '⚡ Vibes & Slang',
    'food': '🍎 Food & Drinks',
    'family': '👨‍👩‍👧 Family & Friends',
  };

  late Map<String, List<AacButtonData>> _boards;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initDefaultVocab();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.15);
  }

  void _speak(String text, {double pitch = 1.15, double rate = 0.45}) async {
    await _flutterTts.stop();
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.speak(text);
  }

  void _speakFullSentence() async {
    if (_sentenceStrip.isEmpty) return;
    final text = _sentenceStrip.map((b) => b.spokenText).join(' ');
    _speak(text);
  }

  void _initDefaultVocab() {
    // HOME BOARD
    final List<AacButtonData> homeButtons = [
      AacButtonData(id: 'i', row: 0, col: 0, label: 'I', spokenText: 'I', icon: Icons.person, partOfSpeech: PartOfSpeech.pronoun),
      AacButtonData(id: 'you', row: 0, col: 1, label: 'You', spokenText: 'You', icon: Icons.people, partOfSpeech: PartOfSpeech.pronoun),
      AacButtonData(id: 'yes', row: 0, col: 4, label: 'Yes', spokenText: 'Yes', icon: Icons.thumb_up, partOfSpeech: PartOfSpeech.social),
      AacButtonData(id: 'no', row: 0, col: 5, label: 'No way', spokenText: 'No way!', icon: Icons.thumb_down, partOfSpeech: PartOfSpeech.social, pitch: 1.25),
      AacButtonData(id: 'vibes_nav', row: 0, col: 6, label: '⚡ Slang', spokenText: '', icon: Icons.bolt, partOfSpeech: PartOfSpeech.slang, targetBoardId: 'slang'),

      AacButtonData(id: 'want', row: 1, col: 0, label: 'Want', spokenText: 'Want', icon: Icons.pan_tool, partOfSpeech: PartOfSpeech.verb),
      AacButtonData(id: 'like', row: 1, col: 1, label: 'Like', spokenText: 'Like', icon: Icons.favorite, partOfSpeech: PartOfSpeech.verb),
      AacButtonData(id: 'go', row: 1, col: 2, label: 'Go', spokenText: 'Go', icon: Icons.directions_run, partOfSpeech: PartOfSpeech.verb),
      AacButtonData(id: 'stop', row: 1, col: 3, label: 'Stop', spokenText: 'Stop!', icon: Icons.front_hand, partOfSpeech: PartOfSpeech.verb, pitch: 1.2),
      AacButtonData(id: 'help', row: 1, col: 4, label: 'Help', spokenText: 'Help me please', icon: Icons.sos, partOfSpeech: PartOfSpeech.social),
      AacButtonData(id: 'eat', row: 1, col: 5, label: 'Eat', spokenText: 'Eat', icon: Icons.restaurant, partOfSpeech: PartOfSpeech.verb, targetBoardId: 'food'),
      AacButtonData(id: 'drink', row: 1, col: 6, label: 'Drink', spokenText: 'Drink', icon: Icons.local_drink, partOfSpeech: PartOfSpeech.verb),

      AacButtonData(id: 'see', row: 2, col: 0, label: 'See', spokenText: 'See', icon: Icons.visibility, partOfSpeech: PartOfSpeech.verb),
      AacButtonData(id: 'play', row: 2, col: 1, label: 'Play', spokenText: 'Play', icon: Icons.sports_esports, partOfSpeech: PartOfSpeech.verb),
      AacButtonData(id: 'more', row: 2, col: 2, label: 'More', spokenText: 'More', icon: Icons.add_circle, partOfSpeech: PartOfSpeech.adjective),
      AacButtonData(id: 'finished', row: 2, col: 3, label: 'All Done', spokenText: 'I am all done', icon: Icons.check_circle, partOfSpeech: PartOfSpeech.adjective),
      AacButtonData(id: 'awesome', row: 2, col: 4, label: 'Awesome', spokenText: 'That is awesome!', icon: Icons.star, partOfSpeech: PartOfSpeech.slang, pitch: 1.3),
      AacButtonData(id: 'chill', row: 2, col: 5, label: 'Chill', spokenText: 'Chill out', icon: Icons.ac_unit, partOfSpeech: PartOfSpeech.slang),
      AacButtonData(id: 'bruh_quick', row: 2, col: 6, label: 'Bruh', spokenText: 'Bruh...', icon: Icons.sentiment_neutral, partOfSpeech: PartOfSpeech.slang, pitch: 0.85, speechRate: 0.35),

      AacButtonData(id: 'happy', row: 3, col: 0, label: 'Happy', spokenText: 'Happy', icon: Icons.mood, partOfSpeech: PartOfSpeech.adjective),
      AacButtonData(id: 'mad', row: 3, col: 1, label: 'Mad', spokenText: 'I am mad', icon: Icons.mood_bad, partOfSpeech: PartOfSpeech.adjective),
      AacButtonData(id: 'tired', row: 3, col: 2, label: 'Tired', spokenText: 'I am tired', icon: Icons.bedtime, partOfSpeech: PartOfSpeech.adjective, speechRate: 0.38),
      AacButtonData(id: 'loud', row: 3, col: 3, label: 'Too Loud', spokenText: 'It is too loud!', icon: Icons.volume_off, partOfSpeech: PartOfSpeech.social, pitch: 1.2),
      AacButtonData(id: 'space', row: 3, col: 4, label: 'My Space', spokenText: 'Please give me space', icon: Icons.accessibility_new, partOfSpeech: PartOfSpeech.social),
      AacButtonData(id: 'funny', row: 3, col: 5, label: 'Funny', spokenText: 'That is hilarious!', icon: Icons.sentiment_very_satisfied, partOfSpeech: PartOfSpeech.slang, pitch: 1.3),
      AacButtonData(id: 'gross', row: 3, col: 6, label: 'Gross', spokenText: 'Eww, that is so gross!', icon: Icons.sick, partOfSpeech: PartOfSpeech.slang, pitch: 1.25),

      AacButtonData(id: 'tablet', row: 4, col: 0, label: 'Tablet', spokenText: 'Tablet', icon: Icons.tablet, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'music', row: 4, col: 1, label: 'Music', spokenText: 'Music', icon: Icons.music_note, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'toy', row: 4, col: 2, label: 'Toy', spokenText: 'Toy', icon: Icons.smart_toy, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'outside', row: 4, col: 3, label: 'Outside', spokenText: 'Outside', icon: Icons.park, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'please', row: 4, col: 4, label: 'Please', spokenText: 'Please', icon: Icons.volunteer_activism, partOfSpeech: PartOfSpeech.social),
      AacButtonData(id: 'thanks', row: 4, col: 5, label: 'Thanks', spokenText: 'Thank you', icon: Icons.handshake, partOfSpeech: PartOfSpeech.social),
      AacButtonData(id: 'family_nav', row: 4, col: 6, label: 'Family', spokenText: '', icon: Icons.family_restroom, partOfSpeech: PartOfSpeech.noun, targetBoardId: 'family'),
    ];

    // SLANG BOARD
    final List<AacButtonData> slangButtons = [
      AacButtonData(id: 'back_s', row: 0, col: 0, label: '← Home', spokenText: '', icon: Icons.arrow_back, partOfSpeech: PartOfSpeech.preposition, targetBoardId: 'home'),
      AacButtonData(id: 'lets_go', row: 0, col: 1, label: "Let's Go!", spokenText: "Let's gooo!", icon: Icons.rocket_launch, partOfSpeech: PartOfSpeech.slang, pitch: 1.35, speechRate: 0.55),
      AacButtonData(id: 'bruh', row: 0, col: 2, label: 'Bruh', spokenText: 'Bruh...', icon: Icons.sentiment_neutral, partOfSpeech: PartOfSpeech.slang, pitch: 0.85, speechRate: 0.35),
      AacButtonData(id: 'for_real', row: 0, col: 3, label: 'For Real?', spokenText: 'Are you for real?', icon: Icons.help_outline, partOfSpeech: PartOfSpeech.slang, pitch: 1.2),
      AacButtonData(id: 'no_way_s', row: 0, col: 4, label: 'No Way!', spokenText: 'No way! You are kidding!', icon: Icons.report_problem, partOfSpeech: PartOfSpeech.slang, pitch: 1.3),
      AacButtonData(id: 'my_bad', row: 0, col: 5, label: 'My Bad', spokenText: 'My bad, sorry about that.', icon: Icons.sentiment_dissatisfied, partOfSpeech: PartOfSpeech.slang),
      AacButtonData(id: 'whatever', row: 0, col: 6, label: 'Whatever', spokenText: 'Whatever...', icon: Icons.undo, partOfSpeech: PartOfSpeech.slang, pitch: 0.9, speechRate: 0.38),
      AacButtonData(id: 'fire', row: 1, col: 1, label: 'Lit / Fire', spokenText: 'That is fire!', icon: Icons.local_fire_department, partOfSpeech: PartOfSpeech.slang, pitch: 1.3),
      AacButtonData(id: 'cap', row: 1, col: 2, label: 'Cap', spokenText: "That's cap, you are lying!", icon: Icons.sports_baseball, partOfSpeech: PartOfSpeech.slang),
      AacButtonData(id: 'sus', row: 1, col: 3, label: 'Sus', spokenText: 'That is so sus.', icon: Icons.warning_amber, partOfSpeech: PartOfSpeech.slang, pitch: 1.1),
      AacButtonData(id: 'slay', row: 1, col: 4, label: 'Nailed It', spokenText: 'You totally nailed it!', icon: Icons.auto_awesome, partOfSpeech: PartOfSpeech.slang, pitch: 1.3),
      AacButtonData(id: 'leave_alone', row: 2, col: 1, label: 'Leave Me', spokenText: 'Leave me alone please.', icon: Icons.do_not_disturb_on, partOfSpeech: PartOfSpeech.social),
      AacButtonData(id: 'overwhelmed', row: 2, col: 2, label: 'Too Much', spokenText: 'This is too much for me.', icon: Icons.psychology, partOfSpeech: PartOfSpeech.social),
    ];

    // FOOD BOARD
    final List<AacButtonData> foodButtons = [
      AacButtonData(id: 'back_f', row: 0, col: 0, label: '← Home', spokenText: '', icon: Icons.arrow_back, partOfSpeech: PartOfSpeech.preposition, targetBoardId: 'home'),
      AacButtonData(id: 'apple', row: 1, col: 0, label: 'Apple', spokenText: 'Apple', icon: Icons.nutrition, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'banana', row: 1, col: 1, label: 'Banana', spokenText: 'Banana', icon: Icons.lunch_dining, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'pizza', row: 1, col: 2, label: 'Pizza', spokenText: 'Pizza', icon: Icons.local_pizza, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'water', row: 1, col: 3, label: 'Water', spokenText: 'Water', icon: Icons.water_drop, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'juice', row: 1, col: 4, label: 'Juice', spokenText: 'Juice', icon: Icons.local_cafe, partOfSpeech: PartOfSpeech.noun),
      AacButtonData(id: 'snack', row: 1, col: 5, label: 'Snack', spokenText: 'Snack', icon: Icons.fastfood, partOfSpeech: PartOfSpeech.noun),
    ];

    // FAMILY BOARD (Custom words example)
    final List<AacButtonData> familyButtons = [
      AacButtonData(id: 'back_fam', row: 0, col: 0, label: '← Home', spokenText: '', icon: Icons.arrow_back, partOfSpeech: PartOfSpeech.preposition, targetBoardId: 'home'),
      AacButtonData(id: 'mom', row: 1, col: 1, label: 'Mom', spokenText: 'Mama', icon: Icons.face_3, partOfSpeech: PartOfSpeech.pronoun),
      AacButtonData(id: 'dad', row: 1, col: 2, label: 'Dad', spokenText: 'Dad', icon: Icons.face, partOfSpeech: PartOfSpeech.pronoun),
      AacButtonData(id: 'sister', row: 1, col: 3, label: 'Sister', spokenText: 'Sister', icon: Icons.girl, partOfSpeech: PartOfSpeech.pronoun),
      AacButtonData(id: 'brother', row: 1, col: 4, label: 'Brother', spokenText: 'Brother', icon: Icons.boy, partOfSpeech: PartOfSpeech.pronoun),
      AacButtonData(id: 'pet', row: 1, col: 5, label: 'Dog / Pet', spokenText: 'My puppy', icon: Icons.pets, partOfSpeech: PartOfSpeech.noun),
    ];

    _boards = {
      'home': homeButtons,
      'slang': slangButtons,
      'food': foodButtons,
      'family': familyButtons,
    };
  }

  // ==========================================
  // EDIT & ADD BUTTON DIALOG
  // ==========================================
  void _showAddOrEditDialog({required int row, required int col, AacButtonData? existing}) {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final speechCtrl = TextEditingController(text: existing?.spokenText ?? '');
    PartOfSpeech selectedPos = existing?.partOfSpeech ?? PartOfSpeech.noun;
    IconData selectedIcon = existing?.icon ?? Icons.star;
    double pitch = existing?.pitch ?? 1.15;
    double rate = existing?.speechRate ?? 0.45;

    final List<IconData> iconPickerOptions = [
      Icons.star, Icons.person, Icons.face, Icons.pets, Icons.favorite,
      Icons.fastfood, Icons.local_pizza, Icons.icecream, Icons.sports_esports,
      Icons.smart_toy, Icons.home, Icons.school, Icons.park, Icons.music_note,
      Icons.tv, Icons.directions_bus, Icons.car_repair, Icons.health_and_safety,
      Icons.rocket_launch, Icons.bolt, Icons.sick, Icons.sentiment_very_satisfied
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(existing == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  Text(existing == null ? 'Add New Word Button' : 'Edit Word Button'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Grid Position: Row ${row + 1}, Col ${col + 1} (Locked Coordinate)',
                          style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      TextField(
                        controller: labelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Button Label (Short text on screen)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g. Max',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: speechCtrl,
                        decoration: const InputDecoration(
                          labelText: 'What the tablet says aloud',
                          border: OutlineInputBorder(),
                          hintText: 'e.g. My dog Max is so cute!',
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Color / Word Type (Fitzgerald Key):', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: PartOfSpeech.values.map((pos) {
                          final isSelected = selectedPos == pos;
                          return ChoiceChip(
                            label: Text(pos.name.toUpperCase()),
                            selected: isSelected,
                            selectedColor: getButtonColor(pos),
                            onSelected: (val) {
                              if (val) setDialogState(() => selectedPos = pos);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      const Text('Select an Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: iconPickerOptions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final ic = iconPickerOptions[i];
                            final isPicked = selectedIcon == ic;
                            return InkWell(
                              onTap: () => setDialogState(() => selectedIcon = ic),
                              child: Container(
                                width: 46,
                                decoration: BoxDecoration(
                                  color: isPicked ? const Color(0xFF0284C7) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(ic, color: isPicked ? Colors.white : Colors.black87),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Pitch & Speed Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Voice Tone / Energy:'),
                          TextButton.icon(
                            onPressed: () {
                              final textToTest = speechCtrl.text.isEmpty ? labelCtrl.text : speechCtrl.text;
                              if (textToTest.isNotEmpty) {
                                _speak(textToTest, pitch: pitch, rate: rate);
                              }
                            },
                            icon: const Icon(Icons.volume_up, size: 18),
                            label: const Text('Test Voice'),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Excited Pitch:', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: pitch,
                              min: 0.8,
                              max: 1.5,
                              divisions: 7,
                              label: pitch.toStringAsFixed(2),
                              onChanged: (v) => setDialogState(() => pitch = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (existing != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _boards[_currentBoardId]?.removeWhere((b) => b.id == existing.id);
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Delete Button', style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final label = labelCtrl.text.trim();
                    final speech = speechCtrl.text.trim().isEmpty ? label : speechCtrl.text.trim();
                    if (label.isEmpty) return;

                    setState(() {
                      if (existing != null) {
                        existing.label = label;
                        existing.spokenText = speech;
                        existing.partOfSpeech = selectedPos;
                        existing.icon = selectedIcon;
                        existing.pitch = pitch;
                        existing.speechRate = rate;
                      } else {
                        final newBtn = AacButtonData(
                          id: 'btn_${DateTime.now().millisecondsSinceEpoch}',
                          row: row,
                          col: col,
                          label: label,
                          spokenText: speech,
                          icon: selectedIcon,
                          partOfSpeech: selectedPos,
                          pitch: pitch,
                          speechRate: rate,
                        );
                        _boards[_currentBoardId] ??= [];
                        _boards[_currentBoardId]!.add(newBtn);
                      }
                    });

                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Button'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ADD NEW TAB / BOARD DIALOG
  // ==========================================
  void _showAddTabDialog() {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.dashboard_customize, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text('Create New Tab / Category'),
            ],
          ),
          content: TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. School, Roblox, Park, Sensory',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final newId = 'tab_${DateTime.now().millisecondsSinceEpoch}';
                setState(() {
                  _boardNames[newId] = '📁 $name';
                  // Initialize board with fixed "Home" return button at (0,0)
                  _boards[newId] = [
                    AacButtonData(
                      id: 'back_$newId',
                      row: 0,
                      col: 0,
                      label: '← Home',
                      spokenText: '',
                      icon: Icons.arrow_back,
                      partOfSpeech: PartOfSpeech.preposition,
                      targetBoardId: 'home',
                    ),
                  ];
                  _currentBoardId = newId;
                });

                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Tab'),
            ),
          ],
        );
      },
    );
  }

  void _onButtonTap(AacButtonData btn) {
    if (_isEditMode) {
      // In Edit Mode, tapping an existing button edits its text, speech, icon, and pitch!
      _showAddOrEditDialog(row: btn.row, col: btn.col, existing: btn);
      return;
    }

    if (btn.isMasked) return;

    if (btn.spokenText.isNotEmpty) {
      _speak(btn.spokenText, pitch: btn.pitch, rate: btn.speechRate);
      setState(() {
        _sentenceStrip.add(btn);
      });
    }

    if (btn.targetBoardId != null) {
      setState(() {
        _currentBoardId = btn.targetBoardId!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentButtons = _boards[_currentBoardId] ?? [];
    final Map<String, AacButtonData> buttonMap = {
      for (var b in currentButtons) '${b.row}_${b.col}': b
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            // Dropdown to switch tabs / boards directly
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _boardNames.containsKey(_currentBoardId) ? _currentBoardId : 'home',
                  items: _boardNames.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (newBoardId) {
                    if (newBoardId != null) {
                      setState(() => _currentBoardId = newBoardId);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Button to Add a Brand New Tab/Category
            IconButton(
              onPressed: _showAddTabDialog,
              icon: const Icon(Icons.add_to_photos, color: Color(0xFF0284C7)),
              tooltip: 'Add New Tab / Category',
            ),
          ],
        ),
        actions: [
          // Edit Mode Switch (Parents/Therapists toggle to customize)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilterChip(
              avatar: Icon(_isEditMode ? Icons.edit : Icons.lock, size: 18),
              label: Text(_isEditMode ? 'Edit Mode ON (Tap to Edit)' : 'Child Mode'),
              selected: _isEditMode,
              selectedColor: const Color(0xFFFDE68A),
              onSelected: (val) {
                setState(() => _isEditMode = val);
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // -----------------------------------------------------------------
          // 1. TOP SENTENCE STRIP
          // -----------------------------------------------------------------
          Container(
            height: 90,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _sentenceStrip.isEmpty
                        ? Center(
                            child: Text(
                              _isEditMode
                                  ? '🔧 Edit Mode is ON: Tap any empty tile to ADD a word, or tap existing to EDIT.'
                                  : 'Tap buttons to formulate speech...',
                              style: TextStyle(
                                color: _isEditMode ? const Color(0xFF0284C7) : Colors.grey,
                                fontSize: 15,
                                fontWeight: _isEditMode ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _sentenceStrip.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final item = _sentenceStrip[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getButtonColor(item.partOfSpeech),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: getButtonBorderColor(item.partOfSpeech), width: 1.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(item.icon, size: 24, color: Colors.black87),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.label,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: _sentenceStrip.isEmpty ? null : _speakFullSentence,
                  icon: const Icon(Icons.volume_up, size: 28),
                  label: const Text('Speak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),

                IconButton(
                  onPressed: _sentenceStrip.isEmpty ? null : () => setState(() => _sentenceStrip.removeLast()),
                  icon: const Icon(Icons.backspace, color: Colors.redAccent, size: 28),
                  tooltip: 'Delete last word',
                ),
                IconButton(
                  onPressed: _sentenceStrip.isEmpty ? null : () => setState(() => _sentenceStrip.clear()),
                  icon: const Icon(Icons.delete_forever, color: Colors.grey, size: 28),
                  tooltip: 'Clear bar',
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFCBD5E1)),

          // -----------------------------------------------------------------
          // 2. MOTOR PLANNING GRID (FIXED 5x7)
          // -----------------------------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth = (constraints.maxWidth - (totalCols - 1) * 8) / totalCols;
                  final cellHeight = (constraints.maxHeight - (totalRows - 1) * 8) / totalRows;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: totalCols,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: cellWidth / cellHeight,
                    ),
                    itemCount: totalRows * totalCols,
                    itemBuilder: (context, index) {
                      final row = index ~/ totalCols;
                      final col = index % totalCols;
                      final key = '${row}_$col';
                      final buttonData = buttonMap[key];

                      // 1. EMPTY SLOT
                      if (buttonData == null) {
                        return InkWell(
                          onTap: _isEditMode
                              ? () => _showAddOrEditDialog(row: row, col: col)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isEditMode ? Colors.blue.withOpacity(0.08) : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isEditMode ? const Color(0xFF93C5FD) : Colors.black12,
                                width: _isEditMode ? 1.5 : 0.5,
                              ),
                            ),
                            child: _isEditMode
                                ? const Center(
                                    child: Icon(Icons.add, color: Color(0xFF3B82F6), size: 24),
                                  )
                                : null,
                          ),
                        );
                      }

                      // 2. ACTIVE BUTTON (OR IN EDIT MODE)
                      return Material(
                        color: getButtonColor(buttonData.partOfSpeech),
                        borderRadius: BorderRadius.circular(12),
                        elevation: _isEditMode ? 4 : 2,
                        child: InkWell(
                          onTap: () => _onButtonTap(buttonData),
                          borderRadius: BorderRadius.circular(12),
                          splashColor: Colors.black12,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isEditMode
                                    ? Colors.blueAccent
                                    : getButtonBorderColor(buttonData.partOfSpeech),
                                width: _isEditMode ? 2.5 : 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        buttonData.icon,
                                        size: cellHeight * 0.38,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        buttonData.label,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isEditMode)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.edit, size: 12, color: Colors.blueAccent),
                                    ),
                                  ),
                                if (buttonData.targetBoardId != null && !_isEditMode)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black45),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
