// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';

class ImagePickerCard extends StatelessWidget {
  const ImagePickerCard({
    super.key,
    required this.isDark,
    required this.selectedImage,
    required this.imageUrl,
    required this.onTap,
  });

  final bool isDark;
  final File? selectedImage;
  final String? imageUrl;
  final VoidCallback onTap;

  Widget _imagePlaceholder(bool isDark) => Container(
    color: isDark ? Colors.grey[850] : Colors.grey[200],
    alignment: Alignment.center,
    child: Icon(
      Icons.image_outlined,
      size: 32,
      color: isDark ? Colors.grey[600] : Colors.grey[400],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final hasNewImage = selectedImage != null;
    final hasExistingImage =
        imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161D2B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasNewImage)
              Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              )
            else if (hasExistingImage)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(isDark),
              )
            else
              _imagePlaceholder(isDark),

            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Change photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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