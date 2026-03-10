import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:herodydemo/model/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  static const Color _accent = Color(0xFF7B61FF);
  static const Color _cardBg = Color(0xFF1A1733);

  // Priority config
  static const _priorityColors = [
    Color(0xFF00D9C0), // Low  — teal
    Color(0xFF7B61FF), // Medium — violet
    Color(0xFFFF6B6B), // High — coral
  ];
  static const _priorityLabels = ['Low', 'Medium', 'High'];
  static const _priorityIcons = [
    Icons.arrow_downward_rounded,
    Icons.remove_rounded,
    Icons.arrow_upward_rounded,
  ];

  // Category config
  static const _categoryIcons = {
    'Personal': Icons.person_rounded,
    'Work': Icons.work_rounded,
    'Health': Icons.favorite_rounded,
    'Finance': Icons.attach_money_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  Color get _priorityColor =>
      _priorityColors[task.priority.clamp(0, 2)];

  String get _priorityLabel =>
      _priorityLabels[task.priority.clamp(0, 2)];

  IconData get _priorityIcon =>
      _priorityIcons[task.priority.clamp(0, 2)];

  IconData get _categoryIcon =>
      _categoryIcons[task.category] ?? Icons.label_rounded;

  String get _formattedDate => task.dueDate != null
      ? DateFormat("MMM d  •  h:mm a").format(task.dueDate!)
      : "No due date";

  bool get _isOverdue =>
      task.dueDate != null &&
      task.dueDate!.isBefore(DateTime.now()) &&
      !task.completed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: task.completed ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.completed
                ? const Color(0xFF00D9C0).withOpacity(0.2)
                : _priorityColor.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: task.completed
                  ? Colors.black.withOpacity(0.1)
                  : _priorityColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Priority accent bar at top ──────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _priorityColor.withOpacity(task.completed ? 0.3 : 0.8),
                      _priorityColor.withOpacity(0.1),
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
                  // ── Checkbox ──────────────────────────────────
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: task.completed
                            ? const Color(0xFF00D9C0).withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: task.completed
                              ? const Color(0xFF00D9C0)
                              : Colors.white.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: task.completed
                          ? const Icon(Icons.check_rounded,
                              color: Color(0xFF00D9C0), size: 15)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ── Content ───────────────────────────────────
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
                            color: task.completed
                                ? Colors.white.withOpacity(0.35)
                                : Colors.white,
                            decoration: task.completed
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
                              color: Colors.white.withOpacity(0.4),
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // ── Meta chips row ─────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            // Priority chip
                            _MetaChip(
                              icon: _priorityIcon,
                              label: _priorityLabel,
                              color: _priorityColor,
                            ),

                            // Category chip
                            _MetaChip(
                              icon: _categoryIcon,
                              label: task.category,
                              color: _accent.withOpacity(0.8),
                            ),

                            // Due date chip
                            _MetaChip(
                              icon: _isOverdue
                                  ? Icons.warning_amber_rounded
                                  : task.dueDate != null
                                      ? Icons.access_time_rounded
                                      : Icons.calendar_today_rounded,
                              label: _formattedDate,
                              color: _isOverdue
                                  ? const Color(0xFFFF6B6B)
                                  : task.dueDate != null
                                      ? Colors.white.withOpacity(0.55)
                                      : Colors.white.withOpacity(0.25),
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
                      _ActionBtn(
                        icon: Icons.edit_rounded,
                        color: task.completed
                            ? Colors.white.withOpacity(0.15)
                            : _accent.withOpacity(0.8),
                        onTap: task.completed ? null : onEdit,
                      ),
                      const SizedBox(height: 8),
                      _ActionBtn(
                        icon: Icons.delete_outline_rounded,
                        color: task.completed
                            ? Colors.white.withOpacity(0.15)
                            : const Color(0xFFFF6B6B).withOpacity(0.8),
                        onTap: task.completed ? null : onDelete,
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

// ── Meta chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
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

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({
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