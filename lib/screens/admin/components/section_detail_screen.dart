import 'package:flutter/material.dart';
import '../../../widgets/pixel_app_bar.dart';

// Helper StatelessWidget to display individual admin sections
class SectionDetailScreen extends StatelessWidget {
  final String title;
  final Widget contentWidget;

  const SectionDetailScreen({
    super.key,
    required this.title,
    required this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PixelAdminAppBar(title: title),
      body: contentWidget,
    );
  }
}