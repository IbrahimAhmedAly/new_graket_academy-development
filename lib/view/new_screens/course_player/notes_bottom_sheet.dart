import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/class/request_status.dart';
import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/colors.dart';
import '../../../data/notes_data/notes_data.dart';

/// Bottom sheet that loads the user's saved note for a given content id,
/// lets them edit it inline with debounced auto-save, and delete it.
class NotesBottomSheet extends StatefulWidget {
  final String contentId;
  final String contentTitle;
  final String userToken;

  const NotesBottomSheet({
    super.key,
    required this.contentId,
    required this.contentTitle,
    required this.userToken,
  });

  static Future<void> show({
    required BuildContext context,
    required String contentId,
    required String contentTitle,
    required String userToken,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotesBottomSheet(
        contentId: contentId,
        contentTitle: contentTitle,
        userToken: userToken,
      ),
    );
  }

  @override
  State<NotesBottomSheet> createState() => _NotesBottomSheetState();
}

class _NotesBottomSheetState extends State<NotesBottomSheet> {
  final NotesData _notes = NotesData(Get.find());
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  Timer? _debounce;
  String _lastSaved = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.contentId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Missing content reference';
      });
      return;
    }
    try {
      final res = await _notes.getNote(
        contentId: widget.contentId,
        userToken: widget.userToken,
      );
      if (res.$1 == RequestStatus.success && res.$2 is Map) {
        final raw = res.$2 as Map<String, dynamic>;
        final inner = raw['data'];
        final dataMap = inner is Map && inner['data'] is Map
            ? inner['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final body = dataMap['body']?.toString() ?? '';
        _controller.text = body;
        _lastSaved = body;
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load note');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!mounted) return;
    final body = _controller.text.trim();
    if (body == _lastSaved.trim() || _saving) return;
    setState(() => _saving = true);
    try {
      final res = await _notes.upsertNote(
        contentId: widget.contentId,
        body: body,
        userToken: widget.userToken,
      );
      if (res.$1 == RequestStatus.success) {
        _lastSaved = body;
      }
    } catch (_) {
      // silent — user can try again
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This will permanently remove your note.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColor.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _notes.deleteNote(
      contentId: widget.contentId,
      userToken: widget.userToken,
    );
    if (!mounted) return;
    _controller.clear();
    _lastSaved = '';
    Get.snackbar('Notes', 'Note deleted',
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final hasBody = _controller.text.trim().isNotEmpty;
    final hasUnsaved = _controller.text.trim() != _lastSaved.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColor.scaffoldBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: AppPadding.pad8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pad16,
                    vertical: AppPadding.pad8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'My Notes',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize16,
                                fontWeight: FontWeight.w800,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppHeight.h3),
                            Text(
                              widget.contentTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize12,
                                color: AppColor.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_saving)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        )
                      else if (!hasUnsaved && hasBody)
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 16, color: AppColor.greenColor),
                            SizedBox(width: AppWidth.w4),
                            Text(
                              'Saved',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize12,
                                color: AppColor.greenColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      if (hasBody)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColor.errorColor),
                          onPressed: _delete,
                          tooltip: 'Delete',
                        ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColor.primaryColor),
                        )
                      : _error.isNotEmpty
                          ? Center(
                              child: Text(
                                _error,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize14,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.all(AppPadding.pad16),
                              child: TextField(
                                controller: _controller,
                                scrollController: scroll,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText:
                                      'Write notes for this lesson... (auto-saved)',
                                  hintStyle: TextStyle(
                                    fontSize: AppTextSize.textSize14,
                                    color: AppColor.textHint,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.radius12),
                                  ),
                                  filled: true,
                                  fillColor: AppColor.cardBg,
                                ),
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize14,
                                  height: 1.5,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
