// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/services/api_service.dart';
import 'package:edu_xchange/services/resources_service.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';

/// Lightweight option model used for the category / semester dropdowns.
/// These are fetched from the same-style endpoints as `resources/`
/// (`categories/` and `semesters/`), returning `{id, name}` pairs.
/// Adjust the endpoint paths / field names in [_fetchOptions] below if your
/// API differs.
class _Option {
  final int id;
  final String name;
  const _Option({required this.id, required this.name});
}

class CreateResourceScreen extends StatefulWidget {
  const CreateResourceScreen({super.key});

  @override
  State<CreateResourceScreen> createState() => _CreateResourceScreenState();
}

class _CreateResourceScreenState extends State<CreateResourceScreen> {
  static const Color _primaryColor = Color(0xFF1B3A6B); // deep navy blue
  static const Color _accentColor = Color(0xFF2C5A8C);

  final ResourceService _resourceService = ResourceService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Resource "type" choices. Adjust to match your backend's actual choices.
  final List<String> _typeOptions = const ['sell', 'lend', 'free'];
  String? _selectedType = 'free';

  List<_Option> _categories = [];
  List<_Option> _semesters = [];
  _Option? _selectedCategory;
  _Option? _selectedSemester;
  bool _loadingOptions = true;

  final List<File> _pickedImages = []; // first = cover image, rest = extra images
  File? _pickedFile;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    setState(() => _loadingOptions = true);
    try {
      final baseUrl = ApiConstants.baseUrl;

      final categoriesRes = await ApiService().get(
        Uri.parse('$baseUrl/categories/'),
      );
      final semestersRes = await ApiService().get(
        Uri.parse('$baseUrl/semesters/'),
      );

      List<_Option> categories = [];
      List<_Option> semesters = [];

      if (categoriesRes.statusCode == 200) {
        final data = jsonDecode(categoriesRes.body);
        final list = (data is Map && data.containsKey('results'))
            ? data['results'] as List
            : data as List;
        categories = list
            .map((e) => _Option(id: e['id'], name: e['name'].toString()))
            .toList();
      }

      if (semestersRes.statusCode == 200) {
        final data = jsonDecode(semestersRes.body);
        final list = (data is Map && data.containsKey('results'))
            ? data['results'] as List
            : data as List;
        semesters = list
            .map((e) => _Option(id: e['id'], name: e['name'].toString()))
            .toList();
      }

      setState(() {
        _categories = categories;
        _semesters = semesters;
        _loadingOptions = false;
      });
    } catch (e) {
      setState(() => _loadingOptions = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() {
      _pickedImages.addAll(picked.map((x) => File(x.path)));
    });
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  void _makeCover(int index) {
    if (index == 0) return;
    setState(() {
      final img = _pickedImages.removeAt(index);
      _pickedImages.insert(0, img);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    setState(() => _pickedFile = File(result.files.single.path!));
  }

  void _removeFile() {
    setState(() => _pickedFile = null);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImages.isEmpty && _pickedFile == null) {
      _showSnackBar('Please add at least one image or a file.');
      return;
    }

    if (_selectedCategory == null) {
      _showSnackBar('Please select a category.');
      return;
    }

    if (_selectedType == null) {
      _showSnackBar('Please select a resource type.');
      return;
    }

    final isSell = _selectedType!.toLowerCase() == 'sell';
    if (isSell && _priceController.text.trim().isEmpty) {
      _showSnackBar('Please enter a price for items you are selling.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _resourceService.createResource(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!.id,
        type: _selectedType!,
        semester: _selectedSemester?.id,
        file: _pickedFile,
        image: _pickedImages.isNotEmpty ? _pickedImages.first : null,
        uploadedImages: _pickedImages.length > 1
            ? _pickedImages.sublist(1)
            : null,
        price: isSell ? int.tryParse(_priceController.text.trim()) : null,
      );

      if (!mounted) return;
      _showSnackBar('Resource uploaded successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Failed to upload resource. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSectionHeading(String text, bool isDark, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, bool isDark, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF161D2B) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 1.4),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildImagePickerSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Photos', isDark),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._pickedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                final isCover = index == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => _makeCover(index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isCover)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Cover',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
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
                );
              }),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161D2B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: _primaryColor, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        'Add Photos',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_pickedImages.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Tap a photo to set it as the cover image.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilePickerSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Attach File (optional)', isDark),
        if (_pickedFile == null)
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161D2B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file_outlined,
                      color: _primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Select a file',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
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
                  child: const Icon(Icons.description_outlined,
                      color: _primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _pickedFile!.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(Icons.close, size: 18),
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required bool isDark,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      decoration: _fieldDecoration(label, isDark),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownColor: isDark ? const Color(0xFF161D2B) : Colors.white,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSell = _selectedType?.toLowerCase() == 'sell';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E1420) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Upload Resource',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : _primaryColor,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0E1420) : Colors.white,
        elevation: 0,
      ),
      body: _loadingOptions
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePickerSection(isDark),
                    const SizedBox(height: 20),
                    _buildFilePickerSection(isDark),
                    const SizedBox(height: 20),
                    Divider(
                      color: isDark ? Colors.grey[850] : Colors.grey[300],
                      height: 1,
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeading('Title', isDark, required: true),
                    TextFormField(
                      controller: _titleController,
                      decoration: _fieldDecoration(
                        'Title',
                        isDark,
                        hint: 'e.g. Calculus II Textbook',
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    _buildSectionHeading('Description', isDark, required: true),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: _fieldDecoration(
                        'Description',
                        isDark,
                        hint: 'Describe the condition, edition, etc.',
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Please enter a description'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    _buildSectionHeading('Category', isDark, required: true),
                    _buildDropdown<_Option>(
                      label: 'Select category',
                      isDark: isDark,
                      value: _selectedCategory,
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 18),

                    _buildSectionHeading('Type', isDark, required: true),
                    _buildDropdown<String>(
                      label: 'Select type',
                      isDark: isDark,
                      value: _selectedType,
                      items: _typeOptions
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.capitalizeFirst!),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() {
                        _selectedType = val;
                        if (val?.toLowerCase() != 'sell') {
                          _priceController.clear();
                        }
                      }),
                    ),

                    if (isSell) ...[
                      const SizedBox(height: 18),
                      _buildSectionHeading('Price', isDark),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          'Price (Rs.)',
                          isDark,
                          hint: 'e.g. 500',
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        validator: (value) {
                          if (!isSell) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a price';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 18),
                    _buildSectionHeading('Semester (optional)', isDark),
                    _buildDropdown<_Option>(
                      label: 'Select semester',
                      isDark: isDark,
                      value: _selectedSemester,
                      items: _semesters
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSemester = val),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text(
                                'Upload Resource',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}