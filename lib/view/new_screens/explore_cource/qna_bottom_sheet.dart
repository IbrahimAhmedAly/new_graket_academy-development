import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/class/request_status.dart';
import '../../../core/constants/app_dimentions.dart';
import '../../../core/constants/colors.dart';
import '../../../data/qa_data/qa_data.dart';

/// Bottom sheet that lists a course's Q&A threads and lets authorised users
/// ask a new question. Tapping a thread expands to show answers inline.
class QnaBottomSheet extends StatefulWidget {
  final String courseId;
  final String userToken;
  final bool canAsk;

  const QnaBottomSheet({
    super.key,
    required this.courseId,
    required this.userToken,
    required this.canAsk,
  });

  static Future<void> show({
    required BuildContext context,
    required String courseId,
    required String userToken,
    required bool canAsk,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QnaBottomSheet(
        courseId: courseId,
        userToken: userToken,
        canAsk: canAsk,
      ),
    );
  }

  @override
  State<QnaBottomSheet> createState() => _QnaBottomSheetState();
}

class _QnaBottomSheetState extends State<QnaBottomSheet> {
  final QaData _qa = QaData(Get.find());
  final ScrollController _scroll = ScrollController();

  List<_QaThread> _threads = [];
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await _qa.getQuestions(
        courseId: widget.courseId,
        userToken: widget.userToken,
      );
      if (res.$1 == RequestStatus.success && res.$2 is Map) {
        final raw = res.$2 as Map<String, dynamic>;
        final inner = raw['data'];
        List<dynamic> list = [];
        if (inner is Map && inner['data'] is List) {
          list = inner['data'] as List;
        }
        setState(() {
          _threads = list
              .whereType<Map>()
              .map((m) => _QaThread.fromJson(Map<String, dynamic>.from(m)))
              .toList();
        });
      } else {
        setState(() => _error = 'Could not load questions');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load questions');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ask() async {
    HapticFeedback.selectionClick();
    final res = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AskForm(),
    );
    if (res == null) return;
    final title = res['title']?.trim() ?? '';
    final body = res['body']?.trim() ?? '';
    if (title.isEmpty || body.isEmpty) return;

    final resp = await _qa.askQuestion(
      courseId: widget.courseId,
      title: title,
      body: body,
      userToken: widget.userToken,
    );
    if (resp.$1 == RequestStatus.success) {
      Get.snackbar('Q&A', 'Question posted',
          snackPosition: SnackPosition.BOTTOM);
      _load();
    } else {
      final msg = resp.$2 is Map
          ? (resp.$2 as Map)['message']?.toString()
          : null;
      Get.snackbar('Q&A', msg?.isNotEmpty == true ? msg! : 'Could not post',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
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
                    Text(
                      'Q&A',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize16,
                        fontWeight: FontWeight.w800,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppWidth.w8),
                    Text(
                      '(${_threads.length})',
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
                child: _loading && _threads.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      )
                    : _error.isNotEmpty && _threads.isEmpty
                        ? _buildError()
                        : _threads.isEmpty
                            ? _buildEmpty()
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColor.primaryColor,
                                child: ListView.separated(
                                  controller: scroll,
                                  padding: EdgeInsets.all(AppPadding.pad16),
                                  itemCount: _threads.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: AppHeight.h8),
                                  itemBuilder: (ctx, i) => _QaThreadCard(
                                    thread: _threads[i],
                                    qa: _qa,
                                    userToken: widget.userToken,
                                    canAnswer: widget.canAsk,
                                  ),
                                ),
                              ),
              ),
              if (widget.canAsk)
                Container(
                  padding: EdgeInsets.only(
                    left: AppPadding.pad16,
                    right: AppPadding.pad16,
                    top: AppPadding.pad8,
                    bottom: AppPadding.pad16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.cardBg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: GestureDetector(
                      onTap: _ask,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: AppPadding.pad12),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: AppWidth.w8),
                            Text(
                              'Ask a question',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return ListView(
      padding: EdgeInsets.all(AppPadding.pad40),
      children: [
        const Icon(Icons.forum_outlined, size: 56, color: AppColor.textHint),
        SizedBox(height: AppHeight.h12),
        Center(
          child: Text(
            'No questions yet',
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: AppHeight.h4),
        Center(
          child: Text(
            widget.canAsk
                ? 'Be the first to ask.'
                : 'Once students ask questions, you\'ll see them here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              color: AppColor.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.pad24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColor.textHint),
            SizedBox(height: AppHeight.h12),
            Text(_error,
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: AppTextSize.textSize14,
                )),
            SizedBox(height: AppHeight.h16),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad20,
                  vertical: AppPadding.pad10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.radius25),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QaThread {
  final String id;
  final String title;
  final String body;
  final int answersCount;
  final String? userName;
  final DateTime? createdAt;

  _QaThread({
    required this.id,
    required this.title,
    required this.body,
    required this.answersCount,
    required this.userName,
    required this.createdAt,
  });

  factory _QaThread.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return _QaThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      answersCount: (json['answersCount'] as num?)?.toInt() ?? 0,
      userName: user is Map ? user['name']?.toString() : null,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}

class _QaThreadCard extends StatefulWidget {
  final _QaThread thread;
  final QaData qa;
  final String userToken;
  final bool canAnswer;
  const _QaThreadCard({
    required this.thread,
    required this.qa,
    required this.userToken,
    required this.canAnswer,
  });

  @override
  State<_QaThreadCard> createState() => _QaThreadCardState();
}

class _QaThreadCardState extends State<_QaThreadCard> {
  bool _expanded = false;
  bool _loading = false;
  List<_QaAnswer> _answers = [];
  final TextEditingController _answerController = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }
    setState(() {
      _expanded = true;
      _loading = _answers.isEmpty;
    });
    if (_answers.isEmpty) {
      await _loadAnswers();
    }
  }

  Future<void> _loadAnswers() async {
    final res = await widget.qa.getQuestionThread(
      questionId: widget.thread.id,
      userToken: widget.userToken,
    );
    if (res.$1 == RequestStatus.success && res.$2 is Map) {
      final raw = res.$2 as Map<String, dynamic>;
      final inner = raw['data'];
      final dataMap = inner is Map && inner['data'] is Map
          ? inner['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final answers = dataMap['answers'];
      if (answers is List) {
        setState(() {
          _answers = answers
              .whereType<Map>()
              .map((m) => _QaAnswer.fromJson(Map<String, dynamic>.from(m)))
              .toList();
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _postAnswer() async {
    final body = _answerController.text.trim();
    if (body.isEmpty || _posting) return;
    HapticFeedback.selectionClick();
    setState(() => _posting = true);
    final res = await widget.qa.answerQuestion(
      questionId: widget.thread.id,
      body: body,
      userToken: widget.userToken,
    );
    if (res.$1 == RequestStatus.success) {
      _answerController.clear();
      await _loadAnswers();
    } else {
      final msg = res.$2 is Map
          ? (res.$2 as Map)['message']?.toString()
          : null;
      Get.snackbar('Q&A',
          msg?.isNotEmpty == true ? msg! : 'Could not post your reply',
          snackPosition: SnackPosition.BOTTOM);
    }
    if (mounted) setState(() => _posting = false);
  }

  String _timeAgo(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.thread;
    return Container(
      padding: EdgeInsets.all(AppPadding.pad12),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: AppColor.gray.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                SizedBox(height: AppHeight.h4),
                Text(
                  t.body,
                  maxLines: _expanded ? null : 2,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize13,
                    color: AppColor.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: AppHeight.h8),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: AppColor.textHint,
                    ),
                    SizedBox(width: AppWidth.w4),
                    Text(
                      '${t.answersCount} ${t.answersCount == 1 ? 'answer' : 'answers'}',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        color: AppColor.textHint,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${t.userName ?? 'Student'} · ${_timeAgo(t.createdAt)}',
                      style: TextStyle(
                        fontSize: AppTextSize.textSize10,
                        color: AppColor.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            Divider(color: AppColor.gray.withValues(alpha: 0.12)),
            if (_loading)
              Padding(
                padding: EdgeInsets.all(AppPadding.pad8),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              )
            else ...[
              if (_answers.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppPadding.pad8),
                  child: Text(
                    'No answers yet',
                    style: TextStyle(
                      fontSize: AppTextSize.textSize12,
                      color: AppColor.textHint,
                    ),
                  ),
                )
              else
                ..._answers.map((a) => Padding(
                      padding: EdgeInsets.symmetric(vertical: AppPadding.pad6),
                      child: Container(
                        padding: EdgeInsets.all(AppPadding.pad10),
                        decoration: BoxDecoration(
                          color: AppColor.primaryLight
                              .withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  a.userName ?? 'Student',
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                                if (a.isInstructor) ...[
                                  SizedBox(width: AppWidth.w4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.pad6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.radius10),
                                    ),
                                    child: Text(
                                      'Instructor',
                                      style: TextStyle(
                                        fontSize: AppTextSize.textSize10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  _timeAgo(a.createdAt),
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize10,
                                    color: AppColor.textHint,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppHeight.h4),
                            Text(
                              a.body,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize13,
                                color: AppColor.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              if (widget.canAnswer)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write an answer...',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppWidth.w8),
                    IconButton(
                      onPressed: _posting ? null : _postAnswer,
                      icon: _posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primaryColor,
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: AppColor.primaryColor),
                    ),
                  ],
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _QaAnswer {
  final String id;
  final String body;
  final String? userName;
  final bool isInstructor;
  final DateTime? createdAt;

  _QaAnswer({
    required this.id,
    required this.body,
    required this.userName,
    required this.isInstructor,
    required this.createdAt,
  });

  factory _QaAnswer.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return _QaAnswer(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      userName: user is Map ? user['name']?.toString() : null,
      isInstructor: json['isInstructor'] == true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}

/// Simple composer form used by the "Ask a question" FAB.
class _AskForm extends StatefulWidget {
  const _AskForm();

  @override
  State<_AskForm> createState() => _AskFormState();
}

class _AskFormState extends State<_AskForm> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(AppPadding.pad16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppPadding.pad12),
                  decoration: BoxDecoration(
                    color: AppColor.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Ask a question',
                style: TextStyle(
                  fontSize: AppTextSize.textSize16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textPrimary,
                ),
              ),
              SizedBox(height: AppHeight.h12),
              TextField(
                controller: _titleCtrl,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Short summary of your question',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radius10),
                  ),
                ),
              ),
              SizedBox(height: AppHeight.h8),
              TextField(
                controller: _bodyCtrl,
                maxLines: 5,
                maxLength: 5000,
                decoration: InputDecoration(
                  labelText: 'Details',
                  hintText: 'Provide as much detail as you can',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radius10),
                  ),
                ),
              ),
              SizedBox(height: AppHeight.h8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: AppWidth.w12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final title = _titleCtrl.text.trim();
                        final body = _bodyCtrl.text.trim();
                        if (title.isEmpty || body.isEmpty) return;
                        Navigator.of(context)
                            .pop({'title': title, 'body': body});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
