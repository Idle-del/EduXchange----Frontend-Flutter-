// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewProfileImage extends StatefulWidget {
  final String? imageUrl;
  final bool isDark;

  // When provided, a delete button is shown alongside the back button.
  // Leave this null (the default) to keep every other usage of this page
  // exactly as it was — read-only, no delete option. The resource-edit
  // gallery is currently the only caller that passes this.
  final VoidCallback? onDelete;

  const ViewProfileImage({
    super.key,
    required this.imageUrl,
    required this.isDark,
    this.onDelete,
  });

  @override
  State<ViewProfileImage> createState() => _ViewProfileImageState();
}

class _ViewProfileImageState extends State<ViewProfileImage> {
  bool showControls = false;

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove image'),
        content: const Text(
          'This image will be removed once you save your changes. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close the dialog
              widget.onDelete?.call(); // stage the deletion
              Navigator.pop(context); // close the viewer
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.grey[900] : Colors.white,
      body: Stack(
        children: [
          ?showControls
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40.0,
                    horizontal: 10,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                )
              : null,
          ?showControls && widget.onDelete != null
              ? Positioned(
                  bottom: 40,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ),
                )
              : null,
          GestureDetector(
            onTap: toggleControls,
            child: Center(
              child: Image(image: CachedNetworkImageProvider(widget.imageUrl!)),
            ),
          ),
        ],
      ),
    );
  }
}
