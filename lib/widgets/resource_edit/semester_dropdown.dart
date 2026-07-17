// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SemesterDropdown extends StatelessWidget {
  const SemesterDropdown({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.semesters,
    required this.selectedSemester,
    required this.onChanged,
    this.primaryColor = const Color(0xFF1B3A6B),
  });

  final bool isDark;
  final bool isLoading;
  final List<Map<String, dynamic>> semesters;
  final int? selectedSemester;
  final ValueChanged<int?> onChanged;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final validIds = semesters.map((s) => s['id']).toSet();

    final safeValue = validIds.contains(selectedSemester)
        ? selectedSemester
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D2B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                value: safeValue,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                dropdownColor:
                    isDark ? const Color(0xFF161D2B) : Colors.white,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                  labelText: 'Semester',
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always,
                ),
                hint: Text(
                  'Select semester',
                  style: TextStyle(
                    fontSize: 14.5,
                    color:
                        isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                items: semesters.map((semester) {
                  return DropdownMenuItem<int>(
                    value: semester['id'],
                    child: Text(semester['name'].toString()),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
    );
  }
}