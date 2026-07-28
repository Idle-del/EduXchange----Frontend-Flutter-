import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/screens/resource_detail_screen.dart';
import 'package:edu_xchange/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  static const Color _primaryColor = Color(0xFF1B3A6B);

  bool _isLoading = true;
  bool _hasError = false;
  List<Resource> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final favorites = await _favoriteService.fetchFavoriteResources();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unfavorite(Resource resource) async {
    // Optimistically remove it from the visible list right away.
    final index = _favorites.indexWhere((r) => r.id == resource.id);
    if (index == -1) return;

    final removed = _favorites[index];
    setState(() => _favorites.removeAt(index));

    try {
      await _favoriteService.removeFavorite(resource.id);
    } catch (_) {
      // Failed — put it back and let the user know.
      if (mounted) {
        setState(() => _favorites.insert(index, removed));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove favorite.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E1420) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : _primaryColor,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: _primaryColor,
        onRefresh: _loadFavorites,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (_hasError) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              'Failed to load favorites.',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      );
    }

    if (_favorites.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resource = _favorites[index];
        return _FavoriteCard(
          key: ValueKey(resource.id),
          resource: resource,
          isDark: isDark,
          onTap: () async {
            await Get.to(
              () => ResourceDetailScreen(resourceId: resource.id),
            );
            // In case it was unfavorited from the detail screen while away.
            _loadFavorites();
          },
          onUnfavorite: () => _unfavorite(resource),
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Resource resource;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _FavoriteCard({
    super.key,
    required this.resource,
    required this.isDark,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = resource.image != null && resource.image!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161D2B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasImage
                  ? Image.network(
                      resource.image!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.categoryName,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onUnfavorite,
              icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 22,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }
}