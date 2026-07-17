// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/screens/resource_detail_screen.dart';
import 'package:edu_xchange/screens/resource_edit.dart';
import 'package:edu_xchange/services/resources_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageResources extends StatefulWidget {
  const ManageResources({super.key});

  @override
  State<ManageResources> createState() => _ManageResourcesState();
}

class _ManageResourcesState extends State<ManageResources> {
  final ResourceService _resourceService = ResourceService();
  List<Resource> _resources = [];

  bool isLoading = true;

  // Which resource's action row (View / Edit / Delete) is currently expanded.
  // Only one can be open at a time.
  int? _expandedResourceId;

  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue
  static const Color _accentColor = Color(0xFF2C5A8C);

  @override
  void initState() {
    super.initState();
    loadResources(); // Fetch resources when the widget is initialized
    // You can fetch resources here if needed
  }

  void loadResources() async {
    setState(() => isLoading = true);
    try {
      final resources = await _resourceService.fetchUserResources();
      setState(() {
        _resources = resources;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _viewResource(Resource resource) {
    Get.to(() => ResourceDetailScreen(resourceId: resource.id));
  }

  void _editResource(Resource resource) {
    () async {
      final updated = await Get.to(() => ResourceEdit(resource: resource));

      if (updated == true) {
        loadResources();
      }
    }();
  }

  void _deleteResource(Resource resource) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this resource?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  await _resourceService.deleteResource(resource.id);
                  setState(() {
                    _resources.removeWhere((r) => r.id == resource.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resource deleted successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting resource: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _toggleExpanded(int resourceId) {
    setState(() {
      _expandedResourceId = _expandedResourceId == resourceId
          ? null
          : resourceId;
    });
  }

  /// Same thumbnail treatment as the home screen: image if available,
  /// otherwise a document icon derived from the file, otherwise a neutral
  /// placeholder.
  Widget _buildThumbnail(Resource resource, bool isDark) {
    const double size = 64;

    if (resource.image != null && resource.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          resource.image!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFileThumbnail(resource, isDark, size),
        ),
      );
    }

    if (resource.file != null && resource.file!.isNotEmpty) {
      return _buildFileThumbnail(resource, isDark, size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.menu_book_outlined,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
        size: 26,
      ),
    );
  }

  Widget _buildFileThumbnail(Resource resource, bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.description_outlined,
        color: _primaryColor,
        size: 26,
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    final isAvailable = status.toLowerCase() == 'available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.red).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isAvailable ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color ?? _primaryColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: color ?? _primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E1420)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Manage Resources',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : _primaryColor,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _resources.isEmpty
          ? Center(
              child: Text(
                "You haven't uploaded any resources yet",
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 14.5,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _resources.length,
              itemBuilder: (context, index) {
                final resource = _resources[index];
                final isExpanded = _expandedResourceId == resource.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161D2B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _toggleExpanded(resource.id),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildThumbnail(resource, isDark),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resource.title,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        _buildStatusPill(resource.status),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _accentColor.withOpacity(
                                              isDark ? 0.18 : 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            resource.categoryName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                            ],
                          ),
                        ),
                      ),

                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: [
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.grey[850]
                                  : Colors.grey[200],
                            ),
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.visibility_outlined,
                                  label: 'View',
                                  onTap: () => _viewResource(resource),
                                ),
                                _buildActionButton(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit',
                                  onTap: () => _editResource(resource),
                                ),
                                _buildActionButton(
                                  icon: Icons.delete_outline,
                                  label: 'Delete',
                                  color: Colors.red[700],
                                  onTap: () => _deleteResource(resource),
                                ),
                              ],
                            ),
                          ],
                        ),
                        secondChild: const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
