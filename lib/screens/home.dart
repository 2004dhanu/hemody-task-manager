import 'package:flutter/material.dart';
import 'package:herodydemo/controller/task_controller.dart';
import 'package:herodydemo/model/task_model.dart';
import 'package:herodydemo/screens/profile.dart';
import 'package:herodydemo/screens/tasks.dart';
import 'package:herodydemo/widgets/task.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TaskController controller = TaskController();

  static const Color _accent = Color(0xFF7B61FF);
  static const Color _bgTop = Color(0xFF0F0C29);
  static const Color _bgBottom = Color(0xFF302B63);
  static const Color _cardBg = Color(0xFF1A1733);

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  int _filterIndex = 0; // 0=All, 1=Active, 2=Done
  final List<String> _filters = ['All', 'Active', 'Done'];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Task> _filtered(List<Task> tasks) {
    if (_filterIndex == 1) return tasks.where((t) => !t.completed).toList();
    if (_filterIndex == 2) return tasks.where((t) => t.completed).toList();
    return tasks;
  }

  // ── Edit Dialog ────────────────────────────────────────────────────────────
  void showEditDialog(BuildContext context, Task task) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description);
    DateTime? selectedDate = task.dueDate;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => StatefulBuilder(
        builder: (ctx, setS) {
          Future<void> pickDateTime() async {
            final date = await showDatePicker(
              context: ctx,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2023),
              lastDate: DateTime(2100),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: _accent, surface: _cardBg),
                ),
                child: child!,
              ),
            );
            if (date == null) return;
            final time = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay.now(),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: _accent, surface: _cardBg),
                ),
                child: child!,
              ),
            );
            if (time == null) return;
            setS(() {
              selectedDate = DateTime(date.year, date.month, date.day,
                  time.hour, time.minute);
            });
          }

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: _accent.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: _accent.withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 2)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: _accent, size: 17),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Edit Task",
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.close_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _DialogField(
                        controller: titleCtrl, label: "TITLE", hint: "Task title"),
                    const SizedBox(height: 16),
                    _DialogField(
                        controller: descCtrl,
                        label: "DESCRIPTION",
                        hint: "Add details…",
                        maxLines: 3),
                    const SizedBox(height: 16),

                    // Date row
                    GestureDetector(
                      onTap: pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: _accent.withOpacity(0.7), size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? "Set due date & time"
                                    : _formatDate(selectedDate!),
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  color: selectedDate == null
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.white.withOpacity(0.25),
                                size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              controller.editTask(task.id, titleCtrl.text,
                                  descCtrl.text, selectedDate);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _accent,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: _accent.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6))
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Complete Dialog ─────────────────────────────────────────────────────────
  void showCompleteDialog(BuildContext context, Task task) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: const Color(0xFF00D9C0).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF00D9C0).withOpacity(0.12),
                    blurRadius: 40)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9C0).withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF00D9C0).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF00D9C0), size: 26),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mark Complete?",
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\"${task.title}\" will be moved\nto your completed tasks.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.45),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: Text("Cancel",
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white.withOpacity(0.5))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.toggleTask(task);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D9C0),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF00D9C0)
                                      .withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6))
                            ],
                          ),
                          child: const Center(
                            child: Text("Confirm",
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
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
              top: -80,
              right: -60,
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
              bottom: 80,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D9C0).withOpacity(0.04),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting(),
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.4),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: const TextSpan(children: [
                                    TextSpan(
                                      text: "My ",
                                      style: TextStyle(
                                        fontFamily: 'Playfair Display',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Tasks",
                                      style: TextStyle(
                                        fontFamily: 'Playfair Display',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: _accent,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          // Profile button
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProfileScreen()),
                            ),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: _accent.withOpacity(0.3)),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: _accent,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Filter chips ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: List.generate(_filters.length, (i) {
                          final active = _filterIndex == i;
                          return GestureDetector(
                            onTap: () => setState(() => _filterIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? _accent
                                    : Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? _accent
                                      : Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                            color: _accent.withOpacity(0.35),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4))
                                      ]
                                    : [],
                              ),
                              child: Text(
                                _filters[i],
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Task list ────────────────────────────────
                    Expanded(
                      child: StreamBuilder<List<Task>>(
                        stream: controller.fetchTasks(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      _accent.withOpacity(0.7)),
                                ),
                              ),
                            );
                          }

                          final all = snapshot.data!;
                          final tasks = _filtered(all);

                          // Stats bar
                          final done =
                              all.where((t) => t.completed).length;
                          final total = all.length;

                          if (tasks.isEmpty) {
                            return _EmptyState(
                                filterIndex: _filterIndex,
                                accent: _accent);
                          }

                          return Column(
                            children: [
                              // Stats
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    24, 0, 24, 16),
                                child: _StatsBar(
                                    done: done,
                                    total: total,
                                    accent: _accent),
                              ),

                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 0, 20, 100),
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                                    return _AnimatedTaskTile(
                                      index: index,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: _StyledTaskCard(
                                          task: task,
                                          accent: _accent,
                                          onToggle: () => showCompleteDialog(
                                              context, task),
                                          onDelete: () =>
                                              controller.deleteTask(task.id),
                                          onEdit: () =>
                                              showEditDialog(context, task),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── FAB ──────────────────────────────────────────────
            Positioned(
              bottom: 32,
              right: 24,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTaskScreen()),
                ),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: _accent.withOpacity(0.5),
                          blurRadius: 28,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌙';
  }
}

// ── Stats bar ────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final int done;
  final int total;
  final Color accent;

  const _StatsBar(
      {required this.done, required this.total, required this.accent});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$done of $total completed",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                "${(pct * 100).round()}%",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Styled task card ─────────────────────────────────────────────────────────

class _StyledTaskCard extends StatelessWidget {
  final Task task;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _StyledTaskCard({
    required this.task,
    required this.accent,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  // ── Priority config ──────────────────────────────────────────────
  static const _priorityColors = [
    Color(0xFF00D9C0), // Low
    Color(0xFF7B61FF), // Medium
    Color(0xFFFF6B6B), // High
  ];
  static const _priorityLabels = ['Low', 'Medium', 'High'];
  static const _priorityIcons = [
    Icons.arrow_downward_rounded,
    Icons.remove_rounded,
    Icons.arrow_upward_rounded,
  ];

  // ── Category config ──────────────────────────────────────────────
  static const _categoryIcons = {
    'Personal': Icons.person_rounded,
    'Work':     Icons.work_rounded,
    'Health':   Icons.favorite_rounded,
    'Finance':  Icons.attach_money_rounded,
    'Other':    Icons.more_horiz_rounded,
  };

  Color get _priorityColor =>
      _priorityColors[task.priority.clamp(0, 2)];
  String get _priorityLabel =>
      _priorityLabels[task.priority.clamp(0, 2)];
  IconData get _priorityIcon =>
      _priorityIcons[task.priority.clamp(0, 2)];
  IconData get _categoryIcon =>
      _categoryIcons[task.category] ?? Icons.label_rounded;

  bool get _isOverdue =>
      task.dueDate != null &&
      task.dueDate!.isBefore(DateTime.now()) &&
      !task.completed;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m  = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}  •  $h:$m $ap';
  }

  @override
  Widget build(BuildContext context) {
    final bool done = task.completed;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: done ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1733),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: done
                ? const Color(0xFF00D9C0).withOpacity(0.2)
                : _priorityColor.withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: done
                  ? Colors.black.withOpacity(0.1)
                  : _priorityColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Priority accent bar ──────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _priorityColor.withOpacity(done ? 0.25 : 0.85),
                      _priorityColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Checkbox ─────────────────────────────────
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xFF00D9C0).withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: done
                              ? const Color(0xFF00D9C0)
                              : Colors.white.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded,
                              color: Color(0xFF00D9C0), size: 15)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ── Main content ──────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Title
                        Text(
                          task.title,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: done
                                ? Colors.white.withOpacity(0.35)
                                : Colors.white,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor:
                                Colors.white.withOpacity(0.3),
                            height: 1.3,
                          ),
                        ),

                        // Description
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.38),
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // ── Meta chips ────────────────────────
                        Wrap(
                          spacing: 7,
                          runSpacing: 6,
                          children: [

                            // Priority
                            _Chip(
                              icon: _priorityIcon,
                              label: _priorityLabel,
                              color: _priorityColor,
                            ),

                            // Category
                            _Chip(
                              icon: _categoryIcon,
                              label: task.category,
                              color: accent.withOpacity(0.85),
                            ),

                            // Due date
                            if (task.dueDate != null)
                              _Chip(
                                icon: _isOverdue
                                    ? Icons.warning_amber_rounded
                                    : Icons.access_time_rounded,
                                label: _formatDate(task.dueDate!),
                                color: _isOverdue
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.white.withOpacity(0.5),
                              ),

                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Action buttons ────────────────────────────
                  Column(
                    children: [
                      _IconBtn(
                        icon: Icons.edit_rounded,
                        color: done
                            ? Colors.white.withOpacity(0.15)
                            : accent.withOpacity(0.75),
                        onTap: done ? null : onEdit,
                      ),
                      const SizedBox(height: 8),
                      _IconBtn(
                        icon: Icons.delete_outline_rounded,
                        color: done
                            ? Colors.white.withOpacity(0.15)
                            : const Color(0xFFFF6B6B).withOpacity(0.75),
                        onTap: done ? null : onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(onTap != null ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ── Animated list tile ────────────────────────────────────────────────────────

class _AnimatedTaskTile extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedTaskTile({required this.index, required this.child});

  @override
  State<_AnimatedTaskTile> createState() => _AnimatedTaskTileState();
}

class _AnimatedTaskTileState extends State<_AnimatedTaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final int filterIndex;
  final Color accent;

  const _EmptyState({required this.filterIndex, required this.accent});

  @override
  Widget build(BuildContext context) {
    final msgs = [
      ['No tasks yet', 'Tap + to add your first task'],
      ['All caught up!', 'No active tasks remain'],
      ['Nothing completed', 'Finish a task to see it here'],
    ];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Icon(Icons.checklist_rounded,
                color: accent.withOpacity(0.6), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            msgs[filterIndex][0],
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            msgs[filterIndex][1],
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialog text field ─────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                color: Colors.white.withOpacity(0.25)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF7B61FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}