import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../services/analytics_service.dart';
import '../../../services/photo_storage_service.dart';
import '../../../services/snackbar_service.dart';

/// Provider that exposes the sorted list of progress photos.
final progressPhotosProvider =
    FutureProvider.autoDispose<List<ProgressPhotoMeta>>((ref) {
  return PhotoStorageService.instance.list();
});

/// Displays the full progress photo gallery with upload and optional
/// side-by-side comparison of the oldest vs newest photo.
class PhotoComparisonView extends ConsumerStatefulWidget {
  const PhotoComparisonView({super.key});

  @override
  ConsumerState<PhotoComparisonView> createState() =>
      _PhotoComparisonViewState();
}

class _PhotoComparisonViewState extends ConsumerState<PhotoComparisonView> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (file == null || !mounted) return;

    setState(() => _isUploading = true);
    final bytes = await file.readAsBytes();
    final result = await PhotoStorageService.instance.upload(
      bytes: bytes,
      date: DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _isUploading = false);

    if (result != null) {
      ref.invalidate(progressPhotosProvider);
      SnackbarService.success('Progress photo saved!');
    } else {
      SnackbarService.error('Upload failed. Check your connection.');
    }
  }

  Future<void> _delete(ProgressPhotoMeta meta) async {
    await PhotoStorageService.instance.delete(meta);
    if (mounted) ref.invalidate(progressPhotosProvider);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photosAsync = ref.watch(progressPhotosProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upload button
          OutlinedButton.icon(
            onPressed: _isUploading ? null : _pickAndUpload,
            icon: _isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_isUploading ? 'Uploading…' : 'Add Progress Photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.lime,
              side: BorderSide(color: colors.lime),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          photosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                Center(child: Text('Could not load photos',
                    style: AppTypography.body.copyWith(color: colors.textTertiary))),
            data: (photos) {
              if (photos.isEmpty) {
                return _EmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Before / After comparison (oldest vs newest)
                  if (photos.length >= 2) ...[
                    Text('BEFORE / AFTER',
                        style: AppTypography.overline
                            .copyWith(color: colors.textTertiary)),
                    const SizedBox(height: AppSpacing.sm),
                    _ComparisonRow(
                      before: photos.last,
                      after: photos.first,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  // Gallery grid
                  Text('ALL PHOTOS',
                      style: AppTypography.overline
                          .copyWith(color: colors.textTertiary)),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (ctx, i) => _PhotoTile(
                      meta: photos[i],
                      onDelete: () => _delete(photos[i]),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text('No progress photos yet',
              style: AppTypography.bodyMedium
                  .copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Text('Add your first photo to start tracking your transformation.',
              style: AppTypography.caption
                  .copyWith(color: context.colors.textTertiary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final ProgressPhotoMeta before;
  final ProgressPhotoMeta after;
  const _ComparisonRow({required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    AnalyticsService.instance.track('progress_photo_comparison_viewed');
    return Row(
      children: [
        Expanded(child: _LabeledPhoto(meta: before, label: 'BEFORE')),
        const SizedBox(width: 8),
        Expanded(child: _LabeledPhoto(meta: after, label: 'NOW')),
      ],
    );
  }
}

class _LabeledPhoto extends StatefulWidget {
  final ProgressPhotoMeta meta;
  final String label;
  const _LabeledPhoto({required this.meta, required this.label});

  @override
  State<_LabeledPhoto> createState() => _LabeledPhotoState();
}

class _LabeledPhotoState extends State<_LabeledPhoto> {
  String? _url;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url =
        await PhotoStorageService.instance.getDownloadUrl(widget.meta.storagePath);
    if (mounted) setState(() => _url = url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: AppTypography.overline
                .copyWith(color: context.colors.lime, fontSize: 10)),
        const SizedBox(height: 4),
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: _url != null
                ? CachedNetworkImage(imageUrl: _url!, fit: BoxFit.cover)
                : Container(color: context.colors.surfaceCard,
                    child: const Center(child: CircularProgressIndicator())),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(widget.meta.date),
          style: AppTypography.caption
              .copyWith(color: context.colors.textTertiary),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year.toString().substring(2)}';
}

class _PhotoTile extends StatefulWidget {
  final ProgressPhotoMeta meta;
  final VoidCallback onDelete;
  const _PhotoTile({required this.meta, required this.onDelete});

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  String? _url;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = await PhotoStorageService.instance
        .getDownloadUrl(widget.meta.storagePath);
    if (mounted) setState(() => _url = url);
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSecondary,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(Icons.delete_outline_rounded, color: context.colors.error),
              title: Text('Delete photo',
                  style:
                      AppTypography.body.copyWith(color: context.colors.error)),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showOptions,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: _url != null
            ? CachedNetworkImage(imageUrl: _url!, fit: BoxFit.cover)
            : Container(color: context.colors.surfaceCard,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      ),
    );
  }
}
