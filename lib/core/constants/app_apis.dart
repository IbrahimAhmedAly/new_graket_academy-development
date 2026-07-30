class AppApis {
  static const String domain = 'https://api.graketacademy.com/api/v1';
  // static const String domain = 'http://localhost:3050/api/v1';

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

  /// Wishlist (Saved courses) APIS
  static String getSavedStatus(String courseId) =>
      '$domain/my-courses/$courseId/save';
  static String saveCourse(String courseId) =>
      '$domain/my-courses/$courseId/save';
  static String unsaveCourse(String courseId) =>
      '$domain/my-courses/$courseId/save';

  /// Reviews (paginated)
  static String getCourseReviews(String courseId) =>
      '$domain/course/$courseId/reviews';

  /// Related courses
  static String getRelatedCourses(String courseId) =>
      '$domain/course/$courseId/related';

  /// Q&A
  static String getCourseQuestions(String courseId) =>
      '$domain/course/$courseId/questions';
  static String askCourseQuestion(String courseId) =>
      '$domain/course/$courseId/questions';
  static String getQuestionThread(String questionId) =>
      '$domain/questions/$questionId';
  static String answerQuestion(String questionId) =>
      '$domain/questions/$questionId/answers';

  /// Content Notes
  static String getContentNote(String contentId) =>
      '$domain/notes/content/$contentId';
  static String upsertContentNote(String contentId) =>
      '$domain/notes/content/$contentId';
  static String deleteContentNote(String contentId) =>
      '$domain/notes/content/$contentId';
  static String getCourseNotes(String courseId) =>
      '$domain/notes/course/$courseId';

  /// Instructor APIS
  static String getInstructorById(String instructorId) =>
      '$domain/instructors/$instructorId';
  static String getInstructorCourses(String instructorId) =>
      '$domain/instructors/$instructorId/courses';

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

  /// banners (home-screen carousel)
  static const String getBanners = '$domain/banners';

  /// education levels & grades (onboarding pickers)
  static const String getEducationLevels = '$domain/education-levels';
  static String getGradesByLevel(String levelId) =>
      '$domain/education-levels/$levelId/grades';

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

  /// ── Activity tracking ────────────────────────────────────────────────
  /// Feeds the student's progress dashboard. Everything reported there is
  /// derived from these events, so a screen that fails to emit them simply
  /// goes unreported — it never guesses.
  static const String trackVideoProgress = '$domain/tracking/video-progress';
  static String getVideoWatchProgress(String contentId) =>
      '$domain/tracking/video-progress/$contentId';
  static const String startContentView = '$domain/tracking/content-view/start';
  static const String endContentView = '$domain/tracking/content-view/end';
  static const String startSession = '$domain/tracking/session/start';
  static const String sessionHeartbeat = '$domain/tracking/session/heartbeat';
  static const String endSession = '$domain/tracking/session/end';

  /// ── Progress reports ─────────────────────────────────────────────────
  /// Aggregations over the tracked activity above.
  static String reportsDashboard(int tzOffsetMinutes) =>
      '$domain/reports/dashboard?tzOffsetMinutes=$tzOffsetMinutes';
  static const String reportsQuizAnalytics = '$domain/reports/quiz-analytics';
  static const String reportsSuggestions = '$domain/reports/suggestions';
  static const String reportsRewards = '$domain/reports/rewards';
  static String reportsMission(int tzOffsetMinutes) =>
      '$domain/reports/mission?tzOffsetMinutes=$tzOffsetMinutes';
  static String reportsInsights(int tzOffsetMinutes) =>
      '$domain/reports/insights?tzOffsetMinutes=$tzOffsetMinutes';
  //    http://92.113.27.193:8086/part/chapter/$chapterId
}
