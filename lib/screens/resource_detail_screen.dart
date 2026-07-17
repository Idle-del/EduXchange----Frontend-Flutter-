// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:edu_xchange/gallery/full_screen_gallery.dart';
import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/services/resources_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends StatefulWidget {
  final int resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final ResourceService _resourceService = ResourceService();
  Resource? resource;
  bool isLoading = true;

  final PageController _heroPageController = PageController();
  int _currentHeroPage = 0;

  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue
  static const Color _accentColor = Color(0xFF2C5A8C);

  @override
  void initState() {
    super.initState();
    loadResourceDetails();
  }

  @override
  void dispose() {
    _heroPageController.dispose();
    super.dispose();
  }

  Future<void> loadResourceDetails() async {
    setState(() => isLoading = true);
    try {
      final resource = await _resourceService.fetchResourceDetail(
        widget.resourceId,
      );
      setState(() {
        this.resource = resource;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<String> getAllImages(Resource resource) {
    final images = <String>[];
    if (resource.image != null && resource.image!.isNotEmpty) {
      images.add(resource.image!);
    }
    images.addAll(resource.extraImages.map((e) => e.image));
    return images;
  }

  String _fileExtensionLabel(String fileUrl) {
    final cleanUrl = fileUrl.split('?').first;
    final dotIndex = cleanUrl.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == cleanUrl.length - 1) return 'FILE';
    return cleanUrl.substring(dotIndex + 1).toUpperCase();
  }

  String _fileNameLabel(String fileUrl) {
    final cleanUrl = fileUrl.split('?').first;
    return cleanUrl.split('/').isNotEmpty ? cleanUrl.split('/').last : cleanUrl;
  }

  Future<void> _openFile(String fileUrl) async {
    final launched = await launchUrl(
      Uri.parse(fileUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the file.')));
    }
  }

  void _openGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullScreenGallery(images: images, initialIndex: initialIndex),
      ),
    );
  }

  /// Full-width, swipeable hero carousel shown at the very top of the page.
  Widget _buildHeroCarousel(List<String> allImages, bool isDark) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openGallery(allImages, _currentHeroPage),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: PageView.builder(
              controller: _heroPageController,
              itemCount: allImages.length,
              onPageChanged: (index) =>
                  setState(() => _currentHeroPage = index),
              itemBuilder: (context, index) {
                return Image.network(
                  allImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? Colors.grey[850] : Colors.grey[200],
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 32,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Subtle gradient so the dot indicator stays legible over any photo.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0.45),
                ],
              ),
            ),
          ),
        ),

        if (allImages.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(allImages.length, (index) {
                final isActive = index == _currentHeroPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

        // Tap-for-fullscreen hint, bottom-right corner.
        Positioned(
          bottom: 12,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fullscreen, size: 14, color: Colors.white),
                const SizedBox(width: 3),
                Text(
                  '${_currentHeroPage + 1}/${allImages.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(String fileUrl, bool isDark) {
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
              color: _primaryColor.withOpacity(isDark ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileNameLabel(fileUrl),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fileExtensionLabel(fileUrl),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              _openFile(fileUrl);
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open'),
            style: TextButton.styleFrom(foregroundColor: _primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isDark, {bool accent = false}) {
    final color = accent
        ? _accentColor
        : (isDark ? Colors.grey[300]! : Colors.grey[700]!);
    final bg = accent
        ? _accentColor.withOpacity(isDark ? 0.18 : 0.08)
        : (isDark ? Colors.grey[850] : Colors.grey[200]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
          color: isDark ? Colors.grey[300] : Colors.grey[800],
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
          'Resource Details',
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
          : resource == null
          ? Center(
              child: Text(
                'Failed to load resource details.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            )
          : Builder(
              builder: (context) {
                final loadedResource = resource!;
                final allImages = getAllImages(loadedResource);
                final hasImages = allImages.isNotEmpty;
                final hasFile =
                    loadedResource.file != null &&
                    loadedResource.file!.isNotEmpty;
                final hasPrice =
                    loadedResource.price != null &&
                    loadedResource.price!.trim().isNotEmpty;
                final isAvailable =
                    loadedResource.status.toLowerCase() == 'available';

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo hero, front and center at the top of the page.
                      if (hasImages) _buildHeroCarousel(allImages, isDark),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    loadedResource.title,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (hasPrice) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _primaryColor.withOpacity(
                                        isDark ? 0.18 : 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Rs. ${loadedResource.price}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Status pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: (isAvailable ? Colors.green : Colors.red)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    loadedResource.status,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isAvailable
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Category / type / semester chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildChip(
                                  loadedResource.categoryName,
                                  isDark,
                                  accent: true,
                                ),
                                _buildChip(loadedResource.type, isDark),
                                if (loadedResource.semesterName != null &&
                                    loadedResource.semesterName!
                                        .trim()
                                        .isNotEmpty)
                                  _buildChip(
                                    loadedResource.semesterName!,
                                    isDark,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            Divider(
                              color: isDark
                                  ? Colors.grey[850]
                                  : Colors.grey[300],
                              height: 1,
                            ),
                            const SizedBox(height: 16),

                            // Uploaded by
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Uploaded by ${loadedResource.uploadedByName}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // Description
                            _buildSectionHeading('Description', isDark),
                            Text(
                              loadedResource.description,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                              ),
                            ),

                            // Attached file
                            if (hasFile) ...[
                              const SizedBox(height: 22),
                              _buildSectionHeading('Attached File', isDark),
                              _buildFileCard(loadedResource.file!, isDark),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
