import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_icons.dart';

/// Shared scaffold for pushed sub-pages (Profile, Settings, FAQ, legal…):
/// white AppBar with back button + title, consistent across the app.
class SubPageScaffold extends StatelessWidget {
  const SubPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
  });

  final String title;
  final Widget body;

  /// Optional sticky bottom bar (e.g. Save button on Edit Profile).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTypography.title.copyWith(fontSize: 16)),
        titleSpacing: 0,
        leading: IconButton(
          icon: AppUiIcons.show(AppUiIcons.back, size: 15),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      bottomNavigationBar: bottom,
      body: body,
    );
  }
}
