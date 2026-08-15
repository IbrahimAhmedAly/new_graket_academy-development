import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_graket_acadimy/controller/home_controller/courses_controller.dart';
import 'package:new_graket_acadimy/core/class/data_request.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/courses_data/courses_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MyServices services;
  late _PendingCoursesData coursesData;
  late CoursesControllerImp controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    services = await MyServices().init();
    coursesData = _PendingCoursesData();
    controller = CoursesControllerImp(
      initialType: 'all',
      coursesData: coursesData,
      myServices: services,
    );
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
  });

  test(
    'a newer search cannot be overwritten by a stale initial response',
    () async {
      expect(coursesData.requests, hasLength(1));

      final searchFuture = controller.applySearch('Dart');
      expect(coursesData.requests, hasLength(2));
      expect(coursesData.requests.last.search, 'Dart');

      coursesData.requests[1].completer.complete(
        _successResponse('new-course'),
      );
      await searchFuture;
      expect(controller.courses.single.id, 'new-course');

      coursesData.requests[0].completer.complete(
        _successResponse('old-course'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.courses.single.id, 'new-course');
      expect(controller.searchQuery, 'Dart');
    },
  );

  test('a search invalidates an in-flight load-more request', () async {
    coursesData.requests.single.completer.complete(
      _successResponse('first-course', hasNextPage: true),
    );
    await Future<void>.delayed(Duration.zero);

    final loadMoreFuture = controller.loadMore();
    expect(coursesData.requests.last.page, 2);

    final searchFuture = controller.applySearch('Flutter');
    expect(coursesData.requests.last.page, 1);
    expect(coursesData.requests.last.search, 'Flutter');

    coursesData.requests[2].completer.complete(
      _successResponse('search-course'),
    );
    await searchFuture;

    coursesData.requests[1].completer.complete(
      _successResponse('stale-page-course'),
    );
    await loadMoreFuture;

    expect(controller.courses.map((course) => course.id), ['search-course']);
    expect(controller.currentPage, 1);
    expect(controller.isLoadingMore, isFalse);
  });

  test('equivalent trimmed searches do not make duplicate calls', () async {
    coursesData.requests.single.completer.complete(
      _successResponse('first-course'),
    );
    await Future<void>.delayed(Duration.zero);

    final searchFuture = controller.applySearch('Dart');
    coursesData.requests.last.completer.complete(_successResponse('dart'));
    await searchFuture;
    final requestCount = coursesData.requests.length;

    await controller.applySearch('  Dart  ');

    expect(coursesData.requests, hasLength(requestCount));
  });

  test(
    'load-more failure preserves courses and requires explicit retry',
    () async {
      coursesData.requests.single.completer.complete(
        _successResponse('first-course', hasNextPage: true),
      );
      await Future<void>.delayed(Duration.zero);

      final loadMoreFuture = controller.loadMore();
      coursesData.requests.last.completer.complete((
        RequestStatus.serverFailure,
        <String, dynamic>{},
      ));
      await loadMoreFuture;

      expect(controller.courses.single.id, 'first-course');
      expect(controller.requestStatus, RequestStatus.success);
      expect(controller.hasLoadMoreError, isTrue);
      expect(controller.isLoadingMore, isFalse);

      final requestCount = coursesData.requests.length;
      await controller.loadMore();
      expect(coursesData.requests, hasLength(requestCount));

      final retryFuture = controller.retryLoadMore();
      expect(coursesData.requests, hasLength(requestCount + 1));
      coursesData.requests.last.completer.complete(
        _successResponse('second-course'),
      );
      await retryFuture;

      expect(controller.courses.map((course) => course.id), [
        'first-course',
        'second-course',
      ]);
      expect(controller.hasLoadMoreError, isFalse);
      expect(controller.currentPage, 2);
    },
  );

  test('malformed load-more payload does not replace valid courses', () async {
    coursesData.requests.single.completer.complete(
      _successResponse('first-course', hasNextPage: true),
    );
    await Future<void>.delayed(Duration.zero);

    final loadMoreFuture = controller.loadMore();
    coursesData.requests.last.completer.complete((
      RequestStatus.success,
      'malformed',
    ));
    await loadMoreFuture;

    expect(controller.courses.single.id, 'first-course');
    expect(controller.requestStatus, RequestStatus.success);
    expect(controller.hasLoadMoreError, isTrue);
  });
}

class _PendingCoursesData extends CoursesData {
  _PendingCoursesData() : super(DataRequest());

  final List<_PendingRequest> requests = [];

  @override
  Future<dynamic> getAllCourses({
    String? token,
    int? page,
    int? limit,
    String? search,
  }) {
    final completer = Completer<dynamic>();
    requests.add(
      _PendingRequest(page: page, search: search, completer: completer),
    );
    return completer.future;
  }
}

class _PendingRequest {
  const _PendingRequest({
    required this.page,
    required this.search,
    required this.completer,
  });

  final int? page;
  final String? search;
  final Completer<dynamic> completer;
}

(RequestStatus, Map<String, dynamic>) _successResponse(
  String id, {
  bool hasNextPage = false,
}) {
  return (
    RequestStatus.success,
    <String, dynamic>{
      'data': <String, dynamic>{
        'data': <String, dynamic>{
          'data': <Map<String, dynamic>>[
            <String, dynamic>{'id': id, 'title': id},
          ],
          'metadata': <String, dynamic>{'hasNextPage': hasNextPage},
        },
      },
    },
  );
}
