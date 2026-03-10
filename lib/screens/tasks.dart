import 'package:flutter/material.dart';
import 'package:herodydemo/controller/task_controller.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with TickerProviderStateMixin {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final TaskController taskController = TaskController();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  DateTime? selectedDate;
  int _priorityIndex = 1; // 0=Low, 1=Medium, 2=High
  String _selectedCategory = 'Personal';

  bool _titleFocused = false;
  bool _descFocused = false;
  bool _hasTitle = false;

  static const Color _accent = Color(0xFF7B61FF);
  static const Color _bgTop = Color(0xFF0F0C29);
  static const Color _bgBottom = Color(0xFF302B63);
  static const Color _cardBg = Color(0xFF1A1733);

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final _priorities = [
    {'label': 'Low', 'color': const Color(0xFF00D9C0), 'icon': Icons.arrow_downward_rounded},
    {'label': 'Medium', 'color': const Color(0xFF7B61FF), 'icon': Icons.remove_rounded},
    {'label': 'High', 'color': const Color(0xFFFF6B6B), 'icon': Icons.arrow_upward_rounded},
  ];

  final _categories = ['Personal', 'Work', 'Health', 'Finance', 'Other'];
  final _categoryIcons = [
    Icons.person_rounded,
    Icons.work_rounded,
    Icons.favorite_rounded,
    Icons.attach_money_rounded,
    Icons.more_horiz_rounded,
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController, curve: Curves.easeOutCubic));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entryController.forward();

    _titleFocus.addListener(() => setState(() => _titleFocused = _titleFocus.hasFocus));
    _descFocus.addListener(() => setState(() => _descFocused = _descFocus.hasFocus));
    titleController.addListener(() => setState(() => _hasTitle = titleController.text.trim().isNotEmpty));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent, surface: _cardBg),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent, surface: _cardBg),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}  •  $h:$m $ampm';
  }

  void _submit() {
    if (!_hasTitle) return;
    taskController.addTask(
      titleController.text.trim(),
      descController.text.trim(),
      selectedDate,
      priority: _priorityIndex,
      category: _selectedCategory,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: Stack(
          children: [
            // Orbs
            Positioned(
              top: -90,
              right: -70,
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withOpacity(0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B).withOpacity(0.04),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    // ── Top bar ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        children: [
                          // Back
                          GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              "New Task",
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _accent.withOpacity(0.3), width: 1),
                            ),
                            child: Text(
                              "Create",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Scrollable form ──────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Title field
                              _FieldLabel("TASK TITLE"),
                              const SizedBox(height: 10),
                              _InputBox(
                                controller: titleController,
                                focusNode: _titleFocus,
                                isFocused: _titleFocused,
                                hasValue: _hasTitle,
                                hint: "What needs to be done?",
                                accent: _accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                onClear: () => titleController.clear(),
                              ),

                              const SizedBox(height: 22),

                              // Description field
                              _FieldLabel("DESCRIPTION"),
                              const SizedBox(height: 10),
                              _InputBox(
                                controller: descController,
                                focusNode: _descFocus,
                                isFocused: _descFocused,
                                hasValue: descController.text.isNotEmpty,
                                hint: "Add details, notes or steps…",
                                accent: _accent,
                                maxLines: 4,
                                onClear: () => descController.clear(),
                              ),

                              const SizedBox(height: 26),

                              // Priority
                              _FieldLabel("PRIORITY"),
                              const SizedBox(height: 12),
                              Row(
                                children: List.generate(_priorities.length, (i) {
                                  final p = _priorities[i];
                                  final active = _priorityIndex == i;
                                  final color = p['color'] as Color;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _priorityIndex = i),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        margin: EdgeInsets.only(
                                            right: i < 2 ? 10 : 0),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? color.withOpacity(0.15)
                                              : Colors.white.withOpacity(0.04),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: active
                                                ? color.withOpacity(0.5)
                                                : Colors.white.withOpacity(0.08),
                                            width: active ? 1.5 : 1,
                                          ),
                                          boxShadow: active
                                              ? [
                                                  BoxShadow(
                                                      color: color
                                                          .withOpacity(0.2),
                                                      blurRadius: 12,
                                                      offset:
                                                          const Offset(0, 4))
                                                ]
                                              : [],
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              p['icon'] as IconData,
                                              color: active
                                                  ? color
                                                  : Colors.white
                                                      .withOpacity(0.25),
                                              size: 18,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              p['label'] as String,
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: active
                                                    ? color
                                                    : Colors.white
                                                        .withOpacity(0.3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 26),

                              // Category
                              _FieldLabel("CATEGORY"),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 46,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categories.length,
                                  itemBuilder: (context, i) {
                                    final active =
                                        _selectedCategory == _categories[i];
                                    return GestureDetector(
                                      onTap: () => setState(
                                          () => _selectedCategory =
                                              _categories[i]),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? _accent.withOpacity(0.15)
                                              : Colors.white.withOpacity(0.04),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: active
                                                ? _accent.withOpacity(0.5)
                                                : Colors.white.withOpacity(0.08),
                                            width: active ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _categoryIcons[i],
                                              size: 14,
                                              color: active
                                                  ? _accent
                                                  : Colors.white
                                                      .withOpacity(0.3),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _categories[i],
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: active
                                                    ? _accent
                                                    : Colors.white
                                                        .withOpacity(0.35),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 26),

                              // Due date
                              _FieldLabel("DUE DATE & TIME"),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: pickDateTime,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: selectedDate != null
                                        ? _accent.withOpacity(0.08)
                                        : Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedDate != null
                                          ? _accent.withOpacity(0.4)
                                          : Colors.white.withOpacity(0.1),
                                      width: selectedDate != null ? 1.5 : 1,
                                    ),
                                    boxShadow: selectedDate != null
                                        ? [
                                            BoxShadow(
                                                color:
                                                    _accent.withOpacity(0.1),
                                                blurRadius: 16)
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: selectedDate != null
                                              ? _accent.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today_rounded,
                                          size: 16,
                                          color: selectedDate != null
                                              ? _accent
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedDate == null
                                                  ? "Set due date & time"
                                                  : _formatDate(selectedDate!),
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: selectedDate == null
                                                    ? Colors.white
                                                        .withOpacity(0.3)
                                                    : Colors.white
                                                        .withOpacity(0.9),
                                              ),
                                            ),
                                            if (selectedDate == null)
                                              Text(
                                                "Optional — tap to pick",
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (selectedDate != null)
                                        GestureDetector(
                                          onTap: () =>
                                              setState(() => selectedDate = null),
                                          child: Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.06),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 13,
                                              color:
                                                  Colors.white.withOpacity(0.4),
                                            ),
                                          ),
                                        )
                                      else
                                        Icon(Icons.chevron_right_rounded,
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            size: 20),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Add Task button
                              GestureDetector(
                                onTap: _hasTitle ? _submit : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    color: _hasTitle
                                        ? _accent
                                        : _accent.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: _hasTitle
                                        ? [
                                            BoxShadow(
                                                color:
                                                    _accent.withOpacity(0.45),
                                                blurRadius: 28,
                                                offset: const Offset(0, 12))
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add Task",
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: _hasTitle
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.35),
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _hasTitle
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.06),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: _hasTitle
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.35),
        letterSpacing: 2.0,
      ),
    );
  }
}

// ── Input box ─────────────────────────────────────────────────────────────────

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool hasValue;
  final String hint;
  final Color accent;
  final int maxLines;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onClear;

  const _InputBox({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hasValue,
    required this.hint,
    required this.accent,
    required this.onClear,
    this.maxLines = 1,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? accent.withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                    color: accent.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: maxLines,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: Colors.white,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.2),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
            ),
          ),
          if (hasValue)
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      color: accent.withOpacity(0.7), size: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}