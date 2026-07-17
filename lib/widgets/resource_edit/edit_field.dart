// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final bool showEditIcon;
  final VoidCallback onEditChanged;
  final bool isDark;
  final int minLines;
  final int maxLines;
  final FocusNode? focusNode;
   EditField({super.key, required this.label, required this.controller, required this.isEditing, this.showEditIcon = true, required this.onEditChanged, required this.isDark, this.minLines = 1, this.maxLines = 1, this.focusNode});

   final Color primaryColor = Color(0xFF1B3A6B);


  @override
  Widget build(BuildContext context) {
    return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF161D2B) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isEditing
            ? primaryColor.withOpacity(isDark ? 0.7 : 0.5)
            : (isDark ? Colors.grey[850]! : Colors.grey[200]!),
        width: isEditing ? 1.4 : 1,
      ),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  minLines: minLines,
                  focusNode: focusNode,
                  readOnly: !isEditing,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (showEditIcon)
            IconButton(
              onPressed: onEditChanged,
              icon: Icon(
                isEditing ? Icons.check_circle : Icons.edit_outlined,
                color: isEditing
                    ? primaryColor
                    : (isDark ? Colors.grey[400] : Colors.grey[500]),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    ),
  );
  }
}
