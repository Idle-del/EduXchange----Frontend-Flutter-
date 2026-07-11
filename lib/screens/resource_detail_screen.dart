import 'package:flutter/material.dart';

class ResourceDetailScreen extends StatefulWidget {
  final int resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}