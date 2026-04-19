import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/colors.dart';
import '../../../model/courses/get_course_by_id_model.dart';

/// Lists all accessible PDF content items in the course. Tapping a row
/// opens the PDF in the system viewer (where the user can save via the OS
/// share/download affordance).
class DownloadsBottomSheet extends StatelessWidget {
  final DataData? courseData;

  const DownloadsBottomSheet({super.key, required this.courseData});

  static Future<void> show({
    required BuildContext context,
    required DataData? courseData,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DownloadsBottomSheet(courseData: courseData),
    );
  }

  List<({Section section, Content content})> _pdfs() {
    final out = <({Section section, Content content})>[];
    for (final s in courseData?.sections ?? const <Section>[]) {
      for (final c in s.contents ?? const <Content>[]) {
        final url = c.pdfUrl ?? '';
        if ((c.type ?? '').toUpperCase() == 'PDF' &&
            c.hasAccess == true &&
            url.isNotEmpty) {
          out.add((section: s, content: c));
        }
      }
    }
    return out;
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    HapticFeedback.selectionClick();
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Download',
        'Could not open this file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _pdfs();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                    Text(
                      'Downloads',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize16,
                        fontWeight: FontWeight.w800,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppWidth.w8),
                    Text(
                      '(${items.length})',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize13,
                        color: AppColor.textHint,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(AppPadding.pad24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_off_outlined,
                                  size: 56, color: AppColor.textHint),
                              SizedBox(height: AppHeight.h12),
                              Text(
                                'No downloadable PDFs',
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppHeight.h4),
                              Text(
                                'This course has no PDFs you can currently access.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize12,
                                  color: AppColor.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scroll,
                        padding: EdgeInsets.all(AppPadding.pad12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppHeight.h8),
                        itemBuilder: (ctx, i) {
                          final item = items[i];
                          return Material(
                            color: AppColor.cardBg,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius12),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.radius12),
                              onTap: () => _open(item.content.pdfUrl ?? ''),
                              child: Padding(
                                padding: EdgeInsets.all(AppPadding.pad12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryLight,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.radius10),
                                      ),
                                      child: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: AppWidth.w12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.content.title ?? 'PDF',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                                  AppTextSize.textSize13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: AppHeight.h3),
                                          Text(
                                            item.section.title ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                                  AppTextSize.textSize10,
                                              color: AppColor.textHint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.download_rounded,
                                      color: AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

