import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/routing/extention.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/login_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/signup_button.dart';

import '../../../core/constants/colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final ImageProvider _backgroundImage;
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _backgroundImage = const AssetImage(AssetsPath.welcome);

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Precache then start fade animation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(_backgroundImage, context);
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.welcomeScreenInitialColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Smooth fade background
          FadeTransition(
            opacity: _opacity,
            child: Image(
              image: _backgroundImage,
              fit: BoxFit.cover, // smoother than fill
            ),
          ),

          /// Foreground content
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppPadding.pad15,
                  horizontal: AppPadding.pad6,
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    LoginButton(
                      onTap: () =>
                          context.pushNamed(AppRoutesNames.loginScreen),
                    ),
                    SignupButton(
                      onTap: () =>
                          context.pushNamed(AppRoutesNames.signUpScreen),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
