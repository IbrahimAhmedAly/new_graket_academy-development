import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/onboarding_widgets/custom_indecator.dart';
import 'package:new_graket_acadimy/view/new_widgets/onboarding_widgets/onboard_page.dart';
import '../../../core/services/services.dart';
import '../../../routing/app_routes.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  late MyServices myServices;
  final PageController _controller = PageController();
  int index = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Learn Anywhere,\nAnytime',
      'subtitle': 'Access hundreds of courses from top instructors right from your pocket.',
    },
    {
      'title': 'Expert-Led\nCourses',
      'subtitle': 'Learn from industry professionals with real-world experience.',
    },
    {
      'title': 'Track Your\nProgress',
      'subtitle': 'Stay motivated with certificates and progress tracking as you grow.',
    },
  ];

  @override
  void initState() {
    super.initState();
    myServices = Get.find();
  }

  void _finish() {
    myServices.sharedPreferences.setBool(AppSharedPrefKeys.firstTimeKey, false);
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutesNames.welcomeScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: Column(
        children: [
          // ── Image area (top 60%) ──
          Expanded(
            flex: 60,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (value) => setState(() => index = value),
              itemCount: _pages.length,
              itemBuilder: (context, i) {
                final images = [
                  AssetsPath.onboarding_1,
                  AssetsPath.onboarding_2,
                  AssetsPath.onboarding_3,
                ];
                return OnboardPage(imagePath: images[i]);
              },
            ),
          ),

          // ── Bottom content area ──
          Container(
            width: double.infinity,
            color: AppColor.scaffoldBg,
            padding: EdgeInsets.fromLTRB(
              AppPadding.pad24,
              AppPadding.pad24,
              AppPadding.pad24,
              MediaQuery.of(context).padding.bottom + AppPadding.pad24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Dots ──
                Row(
                  children: List.generate(_pages.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(right: AppPadding.pad8),
                      child: CustomIndecator(isActive: i == index),
                    );
                  }),
                ),

                SizedBox(height: AppHeight.h20),

                // ── Title ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _pages[index]['title']!,
                    key: ValueKey(index),
                    style: TextStyle(
                      fontSize: AppTextSize.textSize24,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                SizedBox(height: AppHeight.h8),

                // ── Subtitle ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _pages[index]['subtitle']!,
                    key: ValueKey('sub_$index'),
                    style: TextStyle(
                      fontSize: AppTextSize.textSize14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: AppHeight.h28),

                // ── Navigation row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    GestureDetector(
                      onTap: _finish,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppPadding.pad8),
                        child: Text(
                          AppStrings.skip,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.textHint,
                          ),
                        ),
                      ),
                    ),

                    // Next / Start button
                    GestureDetector(
                      onTap: () {
                        if (index == _pages.length - 1) {
                          _finish();
                        } else {
                          _controller.animateToPage(
                            index + 1,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: AppHeight.h48,
                        width: index == _pages.length - 1 ? 130 : AppHeight.h48,
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(AppRadius.radius25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: index == _pages.length - 1
                              ? Text(
                                  AppStrings.start,
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
