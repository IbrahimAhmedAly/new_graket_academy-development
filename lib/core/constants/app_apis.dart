class AppApis {
  static const String domain = 'https://api.graketacademy.com/api/v1';

  /// Auth APIS
  static const String register = '$domain/auth/register';
  static const String emailVerification = '$domain/auth/verify-email';
  static const String login = '$domain/auth/login';
  static const String refreshToken = '$domain/auth/refresh-token';
  static const String forgotPassword = '$domain/auth/forgot-password';
  static const String verifyResetCode = '$domain/auth/verify-reset-code';
  static const String resetPassword = '$domain/auth/reset-password';

  /// Courses APIS
  static const String getAllCouses = '$domain/course';
  static String getCourseByID(String courseId) => '$domain/course/$courseId';
  static const String getRecommendedCourses = '$domain/course/recommended';
  static const String getPopularCourses = '$domain/course/popular';

  /// Purches APIS
  static const String purchaseVerificationCode = '$domain/purchase/verify';
  static const String redeemVerificationCode = '$domain/purchase/redeem';
  static const String getMyPurchase = '$domain/purchase';

  /// My Courses APIS
  static const String getMyCourses = '$domain/my-courses';
  static String getCourseProgressDetails(String courseId) =>
      '$domain/my-courses/$courseId/progress';

  /// Basket APIS
  static const String getBasket = '$domain/basket';
  static const String getBasketCount = '$domain/basket/count';
  static const String addBasket = '$domain/basket';
  static String removeFromBasket(String courseId) => '$domain/basket/$courseId';
  static const String deleteBasket = '$domain/basket';

  /// Progress APIS
  static const String markContentComplete = '$domain/progress/complete';
  static String getContentProgress(String contentId) =>
      '$domain/progress/content/$contentId';
  static String getCourseProgress(String courseId) =>
      '$domain/progress/course/$courseId';

  // Quiz APIS
  static String getQuiz(String quizId) => '$domain/quiz/$quizId';
  static String getQuizByContent(String contentId) =>
      '$domain/quiz/content/$contentId';
  static const String submitQuiz = '$domain/quiz/submit';
  static String getAttemptResult(String attemptId) =>
      '$domain/quiz/attempt/$attemptId';
  static String getQuizAttempts(String quizId) =>
      '$domain/quiz/$quizId/attempts';

  // Notifications APIS
  static const String getNotifications = '$domain/notifications';
  static const String getNotificationsGrouped = '$domain/notifications/grouped';
  static const String getUnreadCount = '$domain/notifications/unread-count';
  static String markAsRead(String id) => '$domain/notifications/$id/read';
  static const String markAllAsRead = '$domain/notifications/read-all';
  static String deleteNotification(String id) => '$domain/notifications/$id';
  static const String deleteAllRead = '$domain/notifications/read';

  /// home APIS
  static const String home = '$domain/home';

  static const String privacy = '$domain/privacy';
  static const String terms = '$domain/terms';
  static const String profile = '$domain/user';
  static const String courses = '$domain/course';
  static const String chapter = '$domain/chapter';
  static const String quizzes = '$domain/quiz/part';
  static const String quiz = '$domain/quiz';
  static const String quizResult = '$domain/quiz-result';
  static const String myCourses = '$domain/course/subscription/me';
  static const String subscription = '$domain/subscription/code';
  static const String uploadImage = '$domain/upload/image';
  static const String viewVideo = '$domain/video-user-view';

  /// buy course Api
  static const String buyCourseByCode = '$domain/subscription/code';

  /// MoDev APIs

  static const String videoSubscription =
      '$domain/video-subscription/redeem-code';
  static const String myVideos = '$domain/video-subscription';
  //    http://92.113.27.193:8086/part/chapter/$chapterId
}
