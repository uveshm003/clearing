import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers.dart';
import '../../domain/attachment.dart';
import '../../l10n/l10n.dart';

/// Photos kept with an item (§4.6): a receipt, a form, a label. Taken with
/// the camera or picked from the gallery, stored in the app's own files and
/// included in backups.
class AttachmentsSection extends ConsumerWidget {
  const AttachmentsSection({super.key, required this.itemId});

  final String itemId;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.itemTakePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.itemPickPhoto),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 80,
    );
    if (picked == null) return;
    await ref
        .read(attachmentRepositoryProvider)
        .add(
          itemId,
          await picked.readAsBytes(),
          mime: picked.mimeType ?? 'image/jpeg',
        );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    final file = await ref
        .read(attachmentRepositoryProvider)
        .fileOf(attachment);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: InteractiveViewer(child: Image.file(file))),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(attachmentRepositoryProvider)
                        .delete(attachment);
                  },
                  child: Text(context.l10n.itemRemovePhoto),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.commonClose),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachments =
        ref.watch(attachmentsProvider(itemId)).value ?? const [];
    final repository = ref.read(attachmentRepositoryProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.itemPhotos,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(context.l10n.itemAddPhoto),
                onPressed: () => _add(context, ref),
              ),
            ],
          ),
          if (attachments.isNotEmpty) ...[
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final (i, attachment) in attachments.indexed)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Semantics(
                        button: true,
                        label: context.l10n.itemPhotoLabel(i + 1),
                        child: InkWell(
                          onTap: () => _open(context, ref, attachment),
                          borderRadius: BorderRadius.circular(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FutureBuilder(
                              future: repository.fileOf(attachment),
                              builder: (context, snapshot) => SizedBox(
                                width: 88,
                                height: 88,
                                child: snapshot.data == null
                                    ? ColoredBox(
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      )
                                    : Image.file(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        cacheWidth: 200,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.itemPhotosHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
