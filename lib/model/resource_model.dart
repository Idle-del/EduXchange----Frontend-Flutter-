class Resource {
  final int id;
  final String status;
  final String title;
  final String description;
  final String? file;
  final String? image;
  final List<ResourceImage> extraImages;
  final int? category;
  final String categoryName;
  final int? uploadedBy;
  final int? semester;
  final String? semesterName;
  final String uploadedByName;
  // final DateTime createdAt;
  // final DateTime updatedAt;
  final String type;
  final String? price;

  Resource({
    required this.id,
    required this.status,
    required this.title,
    required this.description,
    this.file,
    this.image,
    required this.extraImages,
    this.category,
    this.uploadedBy,
    this.semester,
    required this.categoryName,
    this.semesterName,
    required this.uploadedByName,
    required this.type,
    required this.price,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      status: json['status'],
      title: json['title'],
      description: json['description'] ?? '',
      file: json['file'],
      image: json['image'],
      extraImages: (json['extra_images'] as List)
          .map((e) => ResourceImage.fromJson(e))
          .toList(),
      category: json['category'],
      categoryName: json['category_name'],
      uploadedBy: json['uploaded_by'],
      semester: json['semester'],
      semesterName: json['semester_name'],
      uploadedByName: json['uploaded_by_name'],
      // createdAt: DateTime.parse(json['created_at']),
      // updatedAt: DateTime.parse(json['updated_at']),
      type: json['type'],
      price: json['price'],
    );
  }
}

class ResourceImage {
  final int id;
  final String image;

  ResourceImage({required this.id, required this.image});

  factory ResourceImage.fromJson(Map<String, dynamic> json) {
    return ResourceImage(id: json['id'], image: json['image']);
  }
}
