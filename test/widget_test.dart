import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';

void main() {
  testWidgets('course list renders the home-style shimmer grid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 640),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(body: CourseGridShimmerSkeleton()),
        ),
      ),
    );

    expect(find.byType(CourseGridShimmerSkeleton), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);
  });
}
