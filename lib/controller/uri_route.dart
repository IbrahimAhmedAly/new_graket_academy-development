class Apis{
  static const String domain='http://92.113.27.193:8086';
  static const String login='$domain/user/login';
  static const String register='$domain/user/register';
  static const String emailVerification = '$domain/user/verify-email';
  static const String home='$domain/home';
  static const String privacy='$domain/privacy';
  static const String terms='$domain/terms';
  static const String profile='$domain/user';
  static const String courses='$domain/course';
  static const String chapter='$domain/chapter';
  static const String quizzes='$domain/quiz/part';
  static const String quiz='$domain/quiz';
  static const String quizResult='$domain/quiz-result';
  static const String myCourses='$domain/course/subscription/me';
  static const String subscription='$domain/subscription/code';
  static const String uploadImage='$domain/upload/image';
  static const String viewVideo='$domain/video-user-view';
  static const String forgotPassword = '$domain/forgot-password';
  static const String verifyResetCode = '$domain/verify-reset-code';
  // static const String resetPassword = '$domain/reset-password';
  static const String userForgotPassword = '$domain/user/forgot-password';
  static const String userVerifyResetCode = '$domain/user/verify-reset-code';
  static const String userResetPassword = '$domain/user/reset-password';

  static const String deleteAccount = '$domain/user/delete-account';



  /// MoDev APIs

  static const String videoSubscription='$domain/video-subscription/redeem-code';
  static const String myVideos='$domain/video-subscription';
//    http://92.113.27.193:8086/part/chapter/$chapterId
}
