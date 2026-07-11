// import 'package:edu_xchange/controller/theme_controller.dart';
// import 'package:edu_xchange/model/resource_model.dart';
// import 'package:edu_xchange/screens/resource_detail_screen.dart';
// import 'package:edu_xchange/services/resources_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ResourceService _resourceService = ResourceService();

//   List<Resource> _resources = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadResources();
//   }

//   Future<void> loadResources() async {
//     setState(() => isLoading = true);
//     try {
//       final resources = await _resourceService.fetchResources();
//       print("Resources count: ${resources.length}");
//       setState(() {
//         _resources = resources;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("EduXchange"),
//         actions: [
//           GetBuilder<ThemeController>(
//             builder: (controller) {
//               return IconButton(
//                 onPressed: () {
//                   controller.toggleTheme();
//                 },
//                 icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
//               );
//             },
//           ),
//         ],
//       ),

//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _resources.length,
//               itemBuilder: (context, index) {
//                 final resource = _resources[index];

//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(12),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               ResourceDetailScreen(resourceId: resource.id),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           children: [
//                             /// Image
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: resource.image != null
//                                   ? Image.network(
//                                       resource.image!,
//                                       width: 90,
//                                       height: 90,
//                                       fit: BoxFit.cover,
//                                     )
//                                   : const SizedBox(
//                                       width: 90,
//                                       height: 90,
//                                       child: Icon(Icons.image),
//                                     ),
//                             ),

//                             const SizedBox(width: 15),

//                             /// Details
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     resource.title,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),

//                                   const SizedBox(height: 6),

//                                   Text(resource.categoryName),

//                                   const SizedBox(height: 4),

//                                   Text("By ${resource.uploadedByName}"),

//                                   const SizedBox(height: 4),

//                                   Text("Type: ${resource.type}"),

//                                   const SizedBox(height: 4),

//                                   Text(
//                                     "Rs. ${resource.price}",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:edu_xchange/controller/theme_controller.dart';
import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/screens/resource_detail_screen.dart';
import 'package:edu_xchange/services/resources_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ResourceService _resourceService = ResourceService();

  List<Resource> _resources = [];
  bool isLoading = true;

  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue
  static const Color _accentColor = Color(0xFF2C5A8C);

  @override
  void initState() {
    super.initState();
    loadResources();
  }

  Future<void> loadResources() async {
    setState(() => isLoading = true);
    try {
      final resources = await _resourceService.fetchResources();
      print("Resources count: ${resources.length}");
      setState(() {
        _resources = resources;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// Returns a short file-type label (e.g. "PDF", "DOCX") derived from the
  /// file's extension, or null if it cannot be determined.
  String? _fileExtensionLabel(String fileUrl) {
    final cleanUrl = fileUrl.split('?').first;
    final dotIndex = cleanUrl.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == cleanUrl.length - 1) {
      return null;
    }
    return cleanUrl.substring(dotIndex + 1).toUpperCase();
  }

  /// Builds the leading thumbnail for a resource card.
  ///
  /// - If an image is available, it is shown.
  /// - Otherwise, if only a file is available, a formal document icon with
  ///   the file type label is shown instead of a broken/null image.
  /// - If neither is available, a neutral placeholder icon is shown.
  Widget _buildThumbnail(Resource resource, bool isDark) {
    const double size = 88;

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
        size: 32,
      ),
    );
  }

  Widget _buildFileThumbnail(Resource resource, bool isDark, double size) {
    final label = resource.file != null ? _fileExtensionLabel(resource.file!) : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined, color: _primaryColor, size: 28),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: _primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// A small labeled row shown only when [value] is non-null and non-empty.
  Widget? _buildDetailRow(IconData icon, String? value, bool isDark) {
    if (value == null || value.trim().isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.grey[500] : Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1420) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
        title: Text(
          "EduXchange",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: isDark ? Colors.white : _primaryColor,
          ),
        ),
        actions: [
          GetBuilder<ThemeController>(
            builder: (controller) {
              return IconButton(
                onPressed: () {
                  controller.toggleTheme();
                },
                icon: Icon(
                  isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                  color: isDark ? Colors.white : _primaryColor,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _resources.isEmpty
              ? Center(
                  child: Text(
                    "No resources available yet",
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    final hasPrice = resource.price != null && resource.price!.trim().isNotEmpty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161D2B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ResourceDetailScreen(resourceId: resource.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildThumbnail(resource, isDark),
                                const SizedBox(width: 14),

                                /// Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              resource.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (hasPrice) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _primaryColor.withOpacity(
                                                  isDark ? 0.18 : 0.08,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "Rs. ${resource.price}",
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: _primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _accentColor.withOpacity(
                                                isDark ? 0.18 : 0.08,
                                              ),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              resource.categoryName,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: _accentColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.grey[850]
                                                  : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              resource.type,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          if (resource.semesterName != null &&
                                              resource.semesterName!.trim().isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.grey[850]
                                                    : Colors.grey[200],
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                resource.semesterName!,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      ..._buildNonNullWidgets([
                                        _buildDetailRow(
                                          Icons.person_outline,
                                          "By ${resource.uploadedByName}",
                                          isDark,
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  /// Filters out null entries from a list of optional widgets, so only
  /// details that actually exist are rendered.
  List<Widget> _buildNonNullWidgets(List<Widget?> widgets) {
    return widgets.whereType<Widget>().toList();
  }
}