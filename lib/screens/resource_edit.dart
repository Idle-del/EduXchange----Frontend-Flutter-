// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/profile/view_profile.dart';
import 'package:edu_xchange/services/category_service.dart';
import 'package:edu_xchange/services/resources_service.dart';
import 'package:edu_xchange/services/semester_service.dart';
import 'package:edu_xchange/services/statuses_service.dart';
import 'package:edu_xchange/widgets/resource_edit/category_dropdown.dart';
import 'package:edu_xchange/widgets/resource_edit/edit_field.dart';
import 'package:edu_xchange/widgets/resource_edit/extra_images_picker.dart';
import 'package:edu_xchange/widgets/resource_edit/file_picker_card.dart';
import 'package:edu_xchange/widgets/resource_edit/image_picker_card.dart';
import 'package:edu_xchange/widgets/resource_edit/info_chip.dart';
import 'package:edu_xchange/widgets/resource_edit/section_heading.dart';
import 'package:edu_xchange/widgets/resource_edit/semester_dropdown.dart';
import 'package:edu_xchange/widgets/resource_edit/status_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ResourceEdit extends StatefulWidget {
  final Resource resource;

  const ResourceEdit({super.key, required this.resource});

  @override
  State<ResourceEdit> createState() => _ResourceEditState();
}

class _ResourceEditState extends State<ResourceEdit> {
  final SemesterService _semesterService = SemesterService();
  final CategoryService _categoryService = CategoryService();
  final StatusService _statusService = StatusService();
  final ImagePicker _picker = ImagePicker();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  bool _isEditingTitle = false;
  bool _isEditingDescription = false;
  bool _isEditingPrice = false;

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();

  bool isSemestersLoading = true;
  List<Map<String, dynamic>> _semesters = [];
  int? _selectedSemester;

  bool isCategoriesLoading = true;
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategory;

  bool isStatusesLoading = true;
  List<Map<String, dynamic>> _statuses = [];
  String? _selectedStatus;

  bool isLoading = true;
  bool _isSaving = false;

  // Newly picked media — only sent to the server if the user actually
  // changes them; otherwise the existing image/file/gallery is left as-is.
  File? _selectedImage;
  File? _selectedFile;
  final List<File> _selectedExtraImages = [];

  // Existing gallery image IDs the user removed via the viewer. They stay
  // hidden from the gallery immediately, but are only deleted from the
  // database once "Save Changes" succeeds.
  final Set<int> _imagesToDelete = {};

  // Formal, academic-leaning palette, matching the rest of the app.
  static const Color _primaryColor = Color(0xFF1B3A6B);

  bool get _isSellType => widget.resource.type.toLowerCase() == 'sell';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    priceController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _toggleFieldEditing(
    bool currentlyEditing,
    void Function(bool) setEditing,
    FocusNode focusNode,
  ) {
    final nowEditing = !currentlyEditing;
    setState(() => setEditing(nowEditing));

    if (nowEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
    } else {
      focusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _initData() async {
    await Future.wait([
      loadResourceData(),
      _loadSemesters(),
      _loadCategories(),
      _loadStatuses(),
    ]);

    // Make sure the pre-selected semester actually exists in the fetched
    // list before it's ever handed to the DropdownButtonFormField —
    // otherwise Flutter throws an assertion error at build time.
    final validIds = _semesters.map((s) => s['id']).toSet();
    if (_selectedSemester != null && !validIds.contains(_selectedSemester)) {
      setState(() => _selectedSemester = null);
    }

    final validCategoryIds = _categories.map((c) => c['id']).toSet();
    if (_selectedCategory != null &&
        !validCategoryIds.contains(_selectedCategory)) {
      setState(() => _selectedCategory = null);
    }

    final validStatusIds = _statuses.map((s) => s['id']).toSet();
    if (_selectedStatus != null && !validStatusIds.contains(_selectedStatus)) {
      setState(() => _selectedStatus = null);
    }
  }

  Future<void> loadResourceData() async {
    setState(() => isLoading = true);
    try {
      titleController.text = widget.resource.title;
      descriptionController.text = widget.resource.description;
      typeController.text = widget.resource.type;
      if (widget.resource.price != null) {
        priceController.text = widget.resource.price!;
      }
      _selectedSemester = widget.resource.semester;
      _selectedCategory = widget.resource.category;
      _selectedStatus = widget.resource.status;
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadSemesters() async {
    try {
      final semesters = await _semesterService.fetchSemesters();

      setState(() {
        _semesters = List<Map<String, dynamic>>.from(semesters).map((s) {
          return {
            'id': s['id'] is int ? s['id'] : int.tryParse(s['id'].toString()),
            'name': s['name'],
          };
        }).toList();
        isSemestersLoading = false;
      });
    } catch (e) {
      setState(() {
        isSemestersLoading = false;
      });
    }
  }

  Future<void> _loadStatuses() async {
    try {
      final statuses = await _statusService.fetchStatuses();

      setState(() {
        _statuses = List<Map<String, dynamic>>.from(statuses).map((s) {
          return {
            'id': s['id'].toString(), // <-- String
            'name': s['name'],
          };
        }).toList();
        isStatusesLoading = false;
      });
    } catch (e) {
      setState(() {
        isStatusesLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.fetchCategories();

      setState(() {
        _categories = List<Map<String, dynamic>>.from(categories).map((c) {
          return {
            'id': c['id'] is int ? c['id'] : int.tryParse(c['id'].toString()),
            'name': c['name'],
          };
        }).toList();
        isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        isCategoriesLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickExtraImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        _selectedExtraImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _saveResource() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final success = await ResourceService().updateResource(
        resourceID: widget.resource.id.toString(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        semester: _selectedSemester,
        category: _selectedCategory,
        status: _selectedStatus,
        price: _isSellType ? priceController.text.trim() : null,
        image: _selectedImage,
        file: _selectedFile,
        uploadedImages: _selectedExtraImages.isNotEmpty
            ? _selectedExtraImages
            : null,
      );

      // Images removed via the viewer are only deleted from the database
      // once the rest of the changes have saved successfully.
      if (success && _imagesToDelete.isNotEmpty) {
        for (final imageId in _imagesToDelete) {
          try {
            await ResourceService().deleteImage(imageId);
          } catch (e) {
            debugPrint('Failed to delete image $imageId: $e');
          }
        }
      }

      if (success) {
        Get.snackbar(
          "Resource Updated",
          "Your changes have been saved successfully.",
          backgroundColor: _primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Navigator.of(context).pop(true);
      } else {
        Get.snackbar(
          "Update Failed",
          "We couldn't save your changes. Please try again.",
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stack) {
      debugPrint('$e\n$stack');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openGalleryImage(ResourceImage image, bool isDark) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewProfileImage(
          imageUrl: image.image,
          isDark: isDark,
          // Only this screen passes onDelete, so the delete icon only shows
          // up here — every other place that opens the viewer stays exactly
          // as it was, read-only with no delete option.
          onDelete: () {
            setState(() => _imagesToDelete.add(image.id));
          },
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
          'Edit Resource',
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Read-only reference chips: type is never editable and
                    // never sent back to the server.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        InfoChip(
                          label: typeController.text,
                          isDark: isDark,
                          accent: true,
                        ),
                        InfoChip(
                          label: widget.resource.categoryName,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SectionHeading(text: 'Details', isDark: isDark),
                    EditField(
                      label: 'Title',
                      controller: titleController,
                      isEditing: _isEditingTitle,
                      onEditChanged: () => _toggleFieldEditing(
                        _isEditingTitle,
                        (v) => _isEditingTitle = v,
                        _titleFocus,
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    EditField(
                      label: 'Description',
                      controller: descriptionController,
                      isEditing: _isEditingDescription,
                      minLines: 2,
                      maxLines: 5,
                      onEditChanged: () => _toggleFieldEditing(
                        _isEditingDescription,
                        (v) => _isEditingDescription = v,
                        _descriptionFocus,
                      ),
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),
                    SectionHeading(text: 'Organization', isDark: isDark),
                    SemesterDropdown(
                      isDark: isDark,
                      semesters: _semesters,
                      selectedSemester: _selectedSemester,
                      onChanged: (value) {
                        setState(() => _selectedSemester = value);
                      },
                      isLoading: isSemestersLoading,
                    ),
                    const SizedBox(height: 12),
                    CategoryDropdown(
                      isDark: isDark,
                      isLoading: isCategoriesLoading,
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    StatusDropdown(
                      isDark: isDark,
                      isLoading: isStatusesLoading,
                      statuses: _statuses,
                      selectedStatus: _selectedStatus,
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                      },
                    ),

                    // Price only applies to items being sold; free/lend
                    // items have no price to edit.
                    if (_isSellType) ...[
                      const SizedBox(height: 12),
                      EditField(
                        label: 'Price',
                        controller: priceController,
                        isEditing: _isEditingPrice,
                        onEditChanged: () => _toggleFieldEditing(
                          _isEditingPrice,
                          (v) => _isEditingPrice = v,
                          _priceFocus,
                        ),
                        isDark: isDark,
                      ),
                    ],

                    const SizedBox(height: 24),
                    SectionHeading(text: 'Cover Photo', isDark: isDark),
                    ImagePickerCard(
                      isDark: isDark,
                      selectedImage: _selectedImage,
                      imageUrl: widget.resource.image,
                      onTap: _pickImage,
                    ),

                    const SizedBox(height: 24),
                    SectionHeading(text: 'Gallery', isDark: isDark),
                    ExtraImagesPicker(
                      isDark: isDark,
                      existingImages: widget.resource.extraImages,
                      imagesToDelete: _imagesToDelete,
                      selectedExtraImages: _selectedExtraImages,
                      onAddImages: _pickExtraImages,
                      onImageTap: (image) => _openGalleryImage(image, isDark),
                      onRemoveNewImage: (file) {
                        setState(() {
                          _selectedExtraImages.remove(file);
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    SectionHeading(text: 'Attached File', isDark: isDark),
                    FilePickerWidget(
                      isDark: isDark,
                      selectedFile: _selectedFile,
                      existingFileUrl: widget.resource.file,
                      onPickFile: _pickFile,
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveResource,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primaryColor.withOpacity(
                            0.6,
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
