import 'dart:io';

import 'package:edu_xchange/model/resource_model.dart';
import 'package:flutter/material.dart';

class ExtraImagesPicker extends StatelessWidget {
  final bool isDark;

  final List<ResourceImage> existingImages;
  final Set<int> imagesToDelete;

  final List<File> selectedExtraImages;

  final VoidCallback onAddImages;
  final Function(ResourceImage image) onImageTap;
  final Function(File file) onRemoveNewImage;

  const ExtraImagesPicker({
    super.key,
    required this.isDark,
    required this.existingImages,
    required this.imagesToDelete,
    required this.selectedExtraImages,
    required this.onAddImages,
    required this.onImageTap,
    required this.onRemoveNewImage,
  });

  @override
  Widget build(BuildContext context) {
    final visibleExisting = existingImages
        .where((img) => !imagesToDelete.contains(img.id))
        .toList();

    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...visibleExisting.map(
            (img) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onImageTap(img),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    img.image,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      color: isDark
                          ? Colors.grey[850]
                          : Colors.grey[200],
                    ),
                  ),
                ),
              ),
            ),
          ),

          ...selectedExtraImages.map(
            (file) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      file,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemoveNewImage(file),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: onAddImages,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161D2B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.grey[850]!
                      : Colors.grey[200]!,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}