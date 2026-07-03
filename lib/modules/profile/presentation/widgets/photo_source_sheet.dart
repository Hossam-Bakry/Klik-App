import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet offering "Take Photo" / "Choose from Gallery". Resolves to
/// the picked [ImageSource], or `null` if dismissed.
Future<ImageSource?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _PhotoSourceSheet(),
  );
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: context.edge(left: 20, right: 20, top: 12, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.r(40),
              height: context.r(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            context.gapH(16),
            _SourceTile(
              icon: Icons.photo_camera_outlined,
              label: context.tr(LocaleKeys.takePhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const Divider(height: 1, color: AppColors.border),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: context.tr(LocaleKeys.chooseFromGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.edgeSymmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: context.r(22)),
            context.gapW(14),
            Text(
              label,
              style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
