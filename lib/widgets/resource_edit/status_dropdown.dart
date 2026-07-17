// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class StatusDropdown extends StatelessWidget {
  const StatusDropdown({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.statuses,
    required this.selectedStatus,
    required this.onChanged,
    this.primaryColor = const Color(0xFF1B3A6B),
  });

  final bool isDark;
  final bool isLoading;
  final List<Map<String, dynamic>> statuses;
  final String? selectedStatus;
  final ValueChanged<String?> onChanged;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final validStatuses = statuses.map((s) => s['id']).toSet();

    final safeValue =
        validStatuses.contains(selectedStatus) ? selectedStatus : null;

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
              child: DropdownButtonFormField<String>(
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
                  labelText: 'Status',
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
                  'Select status',
                  style: TextStyle(
                    fontSize: 14.5,
                    color:
                        isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status['id'],
                    child: Text(status['name'].toString()),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
    );
  }
}