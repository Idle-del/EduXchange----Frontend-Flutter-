// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';

class FilePickerWidget extends StatelessWidget {
  final bool isDark;
  final File? selectedFile;
  final String? existingFileUrl;
  final VoidCallback onPickFile;

  static const Color primaryColor = Color(0xFF1B3A6B);

  const FilePickerWidget({
    super.key,
    required this.isDark,
    required this.selectedFile,
    required this.existingFileUrl,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final hasNewFile = selectedFile != null;
    final hasExistingFile =
        existingFileUrl != null && existingFileUrl!.isNotEmpty;

    String? label;

    if (hasNewFile) {
      label = selectedFile!.path.split('/').last;
    } else if (hasExistingFile) {
      label = existingFileUrl!.split('?').first.split('/').last;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161D2B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(isDark ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label ?? 'No file attached',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: label != null
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey[500] : Colors.grey[500]),
              ),
            ),
          ),

          const SizedBox(width: 8),

          TextButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.upload_file_outlined, size: 16),
            label: Text(label != null ? 'Replace' : 'Add'),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}