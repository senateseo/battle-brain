import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/referAndEarnCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardDailyCubit.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/home/widgets/app_under_maintenance_dialog.dart';
import 'package:flutterquiz/ui/screens/home/widgets/guest_mode_dialog.dart';
import 'package:flutterquiz/ui/screens/home/widgets/quiz_grid_card.dart';
import 'package:flutterquiz/ui/screens/home/widgets/update_app_container.dart';
import 'package:flutterquiz/ui/screens/home/widgets/user_achievements.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/premium_category_access_badge.dart';
import 'package:flutterquiz/ui/widgets/unlock_premium_category_dialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/user_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutterquiz/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.isGuest});

  final bool isGuest;

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
          BlocProvider<LeaderBoardDailyCubit>(
            create: (_) => LeaderBoardDailyCubit(),
          ),
        ],
        child: HomeScreen(isGuest: routeSettings.arguments as bool),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Leaderboard
  final controllerD = ScrollController();

  /// Animations
  late AnimationController slideAnimationController;
  late Animation<Offset> slideAnimation;
  late AnimationController _controller;

  /// Quiz Zone globals
  int oldCategoriesToShowCount = 0;
  bool isCateListExpanded = false;
  bool canExpandCategoryList = false;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<String> battleName = ["battleQuiz"];

  List<String> battleImg = ["group_battle_icon.svg", "one_vs_one_icon.svg"];

  List<String> examSelf = ["exam", "selfChallenge"];

  List<String> examSelfDesc = ["desExam", "challengeYourselfLbl"];

  List<String> examSelfImg = ["exam_icon.svg", "self_challenge.svg"];

  List<String> battleDesc = ["desGroupPlay", "desBattleQuiz"];

  List<String> playDifferentZone = [
    "dailyQuiz",
    "funAndLearn",
    "guessTheWord",
    "audioQuestions",
    "mathMania",
    "truefalse",
  ];

  List<String> playDifferentImg = [
    "daily_quiz_icon.svg",
    "fun_icon.svg",
    "guess_icon.svg",
    "audio_icon.svg",
    "maths_icon.svg",
    "true_false_icon.svg",
  ];

  List<String> playDifferentZoneDesc = [
    "desDailyQuiz",
    "desFunAndLearn",
    "desGuessTheWord",
    "desAudioQuestions",
    "desMathMania",
    "desTrueFalse",
  ];

  // Screen dimensions
  double get scrWidth => MediaQuery.of(context).size.width;

  double get scrHeight => MediaQuery.of(context).size.height;

  // HomeScreen horizontal margin, change from here
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  get _statusBarPadding => MediaQuery.of(context).padding.top;

  // TextStyles
  // check build() method
  late var _boldTextStyle = GoogleFonts.montserrat(
      textStyle: TextStyle(
    fontWeight: FontWeights.extrabold,
    fontSize: 18.0,
    color: Theme.of(context).colorScheme.onTertiary,
  ));

  ///
  late final String _userId;
  late final String _currLangId;
  late final SystemConfigCubit _sysConfigCubit;
  final _quizZoneId =
      UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.quizZone);

  @override
  void initState() {
    super.initState();
    initAnimations();
    showAppUnderMaintenanceDialog();
    setQuizMenu();
    _initLocalNotification();
    checkForUpdates();
    setupInteractedMessage();
    controllerD.addListener(scrollListenerD);

    _userId = context.read<UserDetailsCubit>().userId();

    /// Create Ads
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createDailyRewardAd(context);
      context.read<InterstitialAdCubit>().createInterstitialAd(context);
      context.read<LeaderBoardDailyCubit>().fetchLeaderBoard("20", _userId);
    });

    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
    );

    ///
    _currLangId = UiUtils.getCurrentQuestionLanguageId(context);
    _sysConfigCubit = context.read<SystemConfigCubit>();
    final quizCubit = context.read<QuizCategoryCubit>();
    final quizZoneCubit = context.read<QuizoneCategoryCubit>();

    if (widget.isGuest) {
      quizCubit.getQuizCategory(languageId: _currLangId, type: _quizZoneId);
      quizZoneCubit.getQuizCategory(languageId: _currLangId);
    } else {
      fetchUserDetails();

      quizCubit.getQuizCategoryWithUserId(
        languageId: _currLangId,
        type: _quizZoneId,
        userId: _userId,
      );
      quizZoneCubit.getQuizCategoryWithUserId(
        languageId: _currLangId,
        userId: _userId,
      );
      context.read<ContestCubit>().getContest(_userId);
    }
  }

  void initAnimations() {
    slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 85),
    );

    slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -0.0415))
            .animate(
      CurvedAnimation(parent: slideAnimationController, curve: Curves.easeIn),
    );
  }

  void showAppUnderMaintenanceDialog() {
    Future.delayed(Duration.zero, () {
      if (_sysConfigCubit.isAppUnderMaintenance) {
        showDialog(
          context: context,
          builder: (_) => const AppUnderMaintenanceDialog(),
        );
      }
    });
  }

  void _initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payLoad) {
        log("For ios version <= 9 notification will be shown here");
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapLocalNotification,
    );

    /// Request Permissions for IOS
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  void setQuizMenu() {
    Future.delayed(Duration.zero, () {
      if (!_sysConfigCubit.isDailyQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == "dailyQuiz");
        playDifferentImg.removeWhere((e) => e == "daily_quiz_icon.svg");
        playDifferentZoneDesc.removeWhere((e) => e == "desDailyQuiz");
      }

      if (!_sysConfigCubit.isTrueFalseQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == "truefalse");
        playDifferentImg.removeWhere((e) => e == "true_false_icon.svg");
        playDifferentZoneDesc.removeWhere((e) => e == "desTrueFalse");
      }

      if (!_sysConfigCubit.isFunNLearnEnabled) {
        playDifferentZone.removeWhere((e) => e == "funAndLearn");
        playDifferentImg.removeWhere((e) => e == "fun_icon.svg");
        playDifferentZoneDesc.removeWhere((e) => e == "desFunAndLearn");
      }

      if (!_sysConfigCubit.isGuessTheWordEnabled) {
        playDifferentZone.removeWhere((e) => e == "guessTheWord");
        playDifferentImg.removeWhere((e) => e == "guess_icon.svg");
        playDifferentZoneDesc.removeWhere((e) => e == "desGuessTheWord");
      }

      if (!_sysConfigCubit.isAudioQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == "audioQuestions");
        playDifferentImg.removeWhere((e) => e == "audio_icon.svg");
        playDifferentZoneDesc.removeWhere((e) => e == "desAudioQuestions");
      }

      if (!_sysConfigCubit.isMathQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == "mathMania");
        playDifferentImg.removeWhere((e) => e == "maths_icon.svg");
        playDifferentZoneDesc.removeWhere((e) => e == "desMathMania");
      }

      if (!_sysConfigCubit.isExamQuizEnabled) {
        examSelf.removeWhere((e) => e == "exam");
        examSelfDesc.removeWhere((e) => e == "desExam");
        examSelfImg.removeWhere((e) => e == "exam_icon.svg");
      }

      if (!_sysConfigCubit.isSelfChallengeQuizEnabled) {
        examSelf.removeWhere((e) => e == "selfChallenge");
        examSelfDesc.removeWhere((e) => e == "challengeYourselfLbl");
        examSelfImg.removeWhere((e) => e == "self_challenge.svg");
      }

      if (!_sysConfigCubit.isGroupBattleEnabled) {
        battleName.removeWhere((e) => e == "groupPlay");
        battleImg.removeWhere((e) => e == "group_battle_icon.svg");
        battleDesc.removeWhere((e) => e == "desGroupPlay");
      }

      if (!_sysConfigCubit.isOneVsOneBattleEnabled) {
        battleName.removeWhere((e) => e == "battleQuiz");
        battleImg.removeWhere((e) => e == "one_vs_one_icon.svg");
        battleDesc.removeWhere((e) => e == "desBattleQuiz");
      }
      setState(() {});
    });
  }

  late bool showUpdateContainer = false;

  void checkForUpdates() async {
    await Future.delayed(Duration.zero);
    if (_sysConfigCubit.isForceUpdateEnable) {
      try {
        bool forceUpdate =
            await UiUtils.forceUpdate(_sysConfigCubit.appVersion);

        if (forceUpdate) {
          setState(() => showUpdateContainer = true);
        }
      } catch (e) {
        log('Force Update Error', error: e);
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        provisional: true,
      );
    } else {
      bool isGranted = (await Permission.notification.status).isGranted;
      if (!isGranted) Permission.notification.request();
    }
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(UiUtils.onBackgroundMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Notification arrives : ${message.toMap().toString()}");
      Map<String, dynamic> data = message.data;
      log(data.toString(), name: "notification data msg");
      final title = data['title'].toString();
      final body = data['body'].toString();
      final type = data['type'].toString();
      final image = data['image'].toString();

      //if notification type is badges then update badges in cubit list
      if (type == "badges") {
        Future.delayed(Duration.zero, () {
          context.read<BadgesCubit>().unlockBadge(data['badge_type'] as String);
        });
      }

      if (type == "payment_request") {
        Future.delayed(Duration.zero, () {
          context.read<UserDetailsCubit>().updateCoins(
                addCoin: true,
                coins: int.parse(data['coins'] as String),
              );
        });
      }
      log(image.toString(), name: "notification image data");
      //payload is some data you want to pass in local notification
      if (image != "null" && image.isNotEmpty) {
        log("image ${image.runtimeType}");
        generateImageNotification(title, body, image, type, type);
      } else {
        generateSimpleNotification(title, body, type);
      }
    });
  }

  //quiz_type according to the notification category
  QuizTypes _getQuizTypeFromCategory(String category) {
    return switch (category) {
      'audio-question-category' => QuizTypes.audioQuestions,
      'guess-the-word-category' => QuizTypes.guessTheWord,
      'fun-n-learn-category' => QuizTypes.funAndLearn,
      _ => QuizTypes.quizZone,
    };
  }

  // notification type is category then move to category screen
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (message.data['type'].toString().contains('category')) {
        Navigator.of(context).pushNamed(Routes.category, arguments: {
          "quizType": _getQuizTypeFromCategory(message.data['type'])
        });
      } else if (message.data['type'] == 'badges') {
        //if user open app by tapping
        UiUtils.updateBadgesLocally(context);
        Navigator.of(context).pushNamed(Routes.badges);
      } else if (message.data['type'] == "payment_request") {
        Navigator.of(context).pushNamed(Routes.wallet);
      }
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> _onTapLocalNotification(NotificationResponse? payload) async {
    String type = payload!.payload ?? "";
    if (type == "badges") {
      Navigator.of(context).pushNamed(Routes.badges);
    } else if (type.toString().contains('category')) {
      Navigator.of(context).pushNamed(Routes.category, arguments: {
        "quizType": _getQuizTypeFromCategory(type),
      });
    } else if (type == "payment_request") {
      Navigator.of(context).pushNamed(Routes.wallet);
    }
  }

  Future<void> generateImageNotification(
    String title,
    String msg,
    String image,
    String payloads,
    String type,
  ) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      packageName, //channel id
      appName, //channel name
      channelDescription: appName,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      msg,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
    String title,
    String body,
    String payloads,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      packageName, //channel id
      appName, //channel name
      channelDescription: appName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  @override
  void dispose() {
    ProfileManagementLocalDataSource.updateReversedCoins(0);
    slideAnimationController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();

    super.dispose();
  }

  // Leaderboard Daily
  scrollListenerD() {
    if (controllerD.position.maxScrollExtent == controllerD.offset) {
      if (context.read<LeaderBoardDailyCubit>().hasMoreData()) {
        context.read<LeaderBoardDailyCubit>().fetchMoreLeaderBoardData(
              "20",
              _userId,
            );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);
    } else {
      ProfileManagementLocalDataSource.updateReversedCoins(0);
    }
  }

  void _onTapProfile() => Navigator.of(context).pushNamed(
        Routes.menuScreen,
        arguments: widget.isGuest,
      );

  void _onTapLeaderboard() => widget.isGuest
      ? showLoginDialog()
      : Navigator.of(context).pushNamed(Routes.leaderBoard);

  void _onPressedZone(String index) {
    if (widget.isGuest) {
      showLoginDialog();
      return;
    }

    switch (index) {
      case "dailyQuiz":
        Navigator.of(context).pushNamed(Routes.quiz, arguments: {
          "quizType": QuizTypes.dailyQuiz,
          "numberOfPlayer": 1,
          "quizName": "Daily Quiz"
        });
        return;
      case "funAndLearn":
        Navigator.of(context).pushNamed(Routes.category, arguments: {
          "quizType": QuizTypes.funAndLearn,
        });
        return;
      case "guessTheWord":
        Navigator.of(context).pushNamed(Routes.category, arguments: {
          "quizType": QuizTypes.guessTheWord,
        });
        return;
      case "audioQuestions":
        Navigator.of(context).pushNamed(Routes.category, arguments: {
          "quizType": QuizTypes.audioQuestions,
        });
        return;
      case "mathMania":
        Navigator.of(context).pushNamed(Routes.category, arguments: {
          "quizType": QuizTypes.mathMania,
        });
        return;
      case "truefalse":
        Navigator.of(context).pushNamed(Routes.quiz, arguments: {
          "quizType": QuizTypes.trueAndFalse,
          "numberOfPlayer": 1,
          "quizName": "True/False Quiz"
        });
        return;
    }
  }

  void _onPressedSelfExam(String index) {
    if (widget.isGuest) {
      showLoginDialog();
      return;
    }

    if (index == "exam") {
      context.read<ExamCubit>().updateState(ExamInitial());
      Navigator.of(context).pushNamed(Routes.exams);
    } else if (index == "selfChallenge") {
      context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
      context.read<SubCategoryCubit>().updateState(SubCategoryInitial());
      Navigator.of(context).pushNamed(Routes.selfChallenge);
    }
  }

  void _onPressedBattle(String index) {
    if (widget.isGuest) {
      showLoginDialog();
      return;
    }

    context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
    if (index == "groupPlay") {
      context
          .read<MultiUserBattleRoomCubit>()
          .updateState(MultiUserBattleRoomInitial());

      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (context) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
            child: CreateOrJoinRoomScreen(
              quizType: QuizTypes.groupPlay,
              title: AppLocalization.of(context)!
                  .getTranslatedValues("groupPlay")!,
            ),
          ),
        ),
      );
    } else if (index == "battleQuiz") {
      context.read<BattleRoomCubit>().updateState(
            BattleRoomInitial(),
            cancelSubscription: true,
          );

      Navigator.of(context).pushNamed(Routes.randomBattle);
    }
  }

  Future<void> showLoginDialog() {
    return showDialog(
      context: context,
      builder: (_) => GuestModeDialog(
        onTapYesButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.login);
        },
      ),
    );
  }

  late String _userName =
      AppLocalization.of(context)!.getTranslatedValues("guest")!;
  late String _userProfileImg = UiUtils.getprofileImagePath("2.png");

  Widget _buildProfileContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: _onTapProfile,
        child: SlideTransition(
          position: slideAnimation,
          child: Container(
            margin: EdgeInsets.only(
              top: _statusBarPadding * .2,
              left: hzMargin,
              right: hzMargin,
            ),
            width: scrWidth,
            child: LayoutBuilder(
              builder: (_, constraint) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      width: constraint.maxWidth * 0.15,
                      height: constraint.maxWidth * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        /// profile Border
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: _userProfileImg.startsWith("assets/")
                          ? Image.asset(
                              _userProfileImg,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.2),
                              width: double.maxFinite,
                              height: double.maxFinite,
                            )
                          : UserUtils.getUserProfileWidget(
                              pngBackgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.2),
                              profileUrl: _userProfileImg,
                              width: double.maxFinite,
                              height: double.maxFinite,
                            ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * .03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: constraint.maxWidth * 0.5,
                          child: Text(
                            "${AppLocalization.of(context)!.getTranslatedValues(helloKey)!} $_userName",
                            maxLines: 1,
                            style: _boldTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues(letsPlay)!,
                          style: TextStyle(
                            fontSize: 13.0,
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// LeaderBoard
                    Container(
                      width: MediaQuery.of(context).size.width * 0.11,
                      height: MediaQuery.of(context).size.width * 0.11,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        onPressed: _onTapLeaderboard,
                        icon: widget.isGuest
                            ? const Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                              )
                            : SvgPicture.asset(
                                UiUtils.getImagePath("icon_leaderboard.svg"),
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.08,
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// Settings
                    Container(
                      width: MediaQuery.of(context).size.width * 0.11,
                      height: MediaQuery.of(context).size.width * 0.11,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.settings);
                        },
                        icon: SvgPicture.asset(
                          UiUtils.getImagePath("settings.svg"),
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width * 0.08,
                          height: MediaQuery.of(context).size.width * 0.08,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hzMargin),
          child: Row(
            children: [
              Text(
                AppLocalization.of(context)!.getTranslatedValues("quizZone")!,
                style: _boldTextStyle,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.isGuest
                      ? showLoginDialog()
                      : Navigator.of(context).pushNamed(Routes.category,
                          arguments: {"quizType": QuizTypes.quizZone});
                },
                child: Text(
                  AppLocalization.of(context)
                          ?.getTranslatedValues(viewAllKey) ??
                      viewAllKey,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (canExpandCategoryList) ...[
                  Positioned(
                    top: 0,
                    left: scrWidth * .1,
                    right: scrWidth * .1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 40),
                            blurRadius: 30,
                            spreadRadius: 2,
                            color: Color(0xbf000000),
                          ),
                        ],
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(scrWidth * (0.225)),
                        ),
                      ),
                      width: scrWidth,
                      height: scrWidth * .3,
                    ),
                  ),
                ],
                Positioned(
                  child: Container(
                    decoration: ShapeDecoration(
                        color: white,
                        shadows: [
                          BoxShadow(
                            color: wood_smoke,
                            offset: Offset(
                              0.0, // Move to right 10  horizontally
                              6.0, // Move to bottom 5 Vertically
                            ),
                          )
                        ],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            side: BorderSide(color: wood_smoke, width: 2))),
                    clipBehavior: Clip.none,
                    margin: EdgeInsets.only(
                      left: hzMargin,
                      right: hzMargin,
                      top: 10,
                      bottom: 26,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: quizZoneCategories(),
                  ),
                ),

                /// Expand Arrow
                if (canExpandCategoryList) ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    // Position the center bottom arrow, from here
                    bottom: -9,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isCateListExpanded = !isCateListExpanded;
                        }),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            !isCateListExpanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget quizZoneCategories() {
    return BlocConsumer<QuizoneCategoryCubit, QuizoneCategoryState>(
      bloc: context.read<QuizoneCategoryCubit>(),
      listener: (context, state) {
        if (state is QuizoneCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      builder: (context, state) {
        if (state is QuizoneCategoryFailure) {
          return ErrorContainer(
            showRTryButton: false,
            showBackButton: false,
            showErrorImage: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage),
            ),
            onTapRetry: () {
              context.read<QuizoneCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    userId: _userId,
                  );
            },
          );
        }

        if (state is QuizoneCategorySuccess) {
          final categories = state.categories;
          final int categoriesToShowCount;

          /// Min/Max Categories to Show.
          const minCount = 2;
          const maxCount = 5;

          /// need to check old cate list with new cate list, when we change languages.
          /// and rebuild the list.
          if (oldCategoriesToShowCount != categories.length) {
            Future.delayed(Duration.zero, () {
              oldCategoriesToShowCount = categories.length;
              canExpandCategoryList = oldCategoriesToShowCount > minCount;
              setState(() {});
            });
          }

          if (!isCateListExpanded) {
            categoriesToShowCount =
                categories.length <= minCount ? categories.length : minCount;
          } else {
            categoriesToShowCount =
                categories.length <= maxCount ? categories.length : maxCount;
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 10),
            shrinkWrap: true,
            itemCount: categoriesToShowCount,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              final category = categories[i];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: () {
                  if (widget.isGuest) {
                    showLoginDialog();
                    return;
                  }

                  if (category.isPremium && !category.hasUnlocked) {
                    showUnlockPremiumCategoryDialog(
                      context,
                      categoryId: category.id!,
                      categoryName: category.categoryName!,
                      requiredCoins: category.requiredCoins,
                      isQuizZone: true,
                    );
                    return;
                  }

                  //noOf means how many subcategory it has
                  //if subcategory is 0 then check for level
                  if (category.noOf == "0") {
                    //means this category does not have level
                    if (category.maxLevel == "0") {
                      //direct move to quiz screen pass level as 0
                      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
                        "numberOfPlayer": 1,
                        "quizType": QuizTypes.quizZone,
                        "categoryId": category.id,
                        "subcategoryId": "",
                        "level": "0",
                        "subcategoryMaxLevel": "0",
                        "unlockedLevel": 0,
                        "contestId": "",
                        "comprehensionId": "",
                        "quizName": "Quiz Zone",
                        'showRetryButton': category.noOfQues! != '0'
                      });
                    } else {
                      Navigator.of(context)
                          .pushNamed(Routes.levels, arguments: {
                        "Category": category,
                      });
                    }
                  } else {
                    Navigator.of(context).pushNamed(
                      Routes.subcategoryAndLevel,
                      arguments: {
                        "category_id": category.id,
                        "category_name": category.categoryName
                      },
                    );
                  }
                },
                horizontalTitleGap: 15,
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        memCacheWidth: 90,
                        memCacheHeight: 90,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width * 0.125,
                        height: MediaQuery.of(context).size.width * 0.125,
                        placeholder: (_, __) => const SizedBox(),
                        imageUrl: category.image!,
                        errorWidget: (_, i, e) => Image(
                          image: AssetImage(
                            UiUtils.getImagePath("ic_launcher.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// right_arrow
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumCategoryAccessBadge(
                      hasUnlocked: category.hasUnlocked,
                      isPremium: category.isPremium,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
                title: Text(
                  category.categoryName!,
                  style: _boldTextStyle.copyWith(fontSize: 16),
                ),
                subtitle: Text(
                  "${AppLocalization.of(context)!.getTranslatedValues("questionLbl")}: ${category.noOfQues!}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.6),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildBattle() {
    return battleName.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Zone Title: Battle
                Text(
                  AppLocalization.of(context)
                          ?.getTranslatedValues(battleOfTheDayKey) ??
                      battleOfTheDayKey, //
                  style: _boldTextStyle,
                ),

                /// Categories
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 1,
                  childAspectRatio: (50 / 15),
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  // padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    battleName.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedBattle(battleName[i]),
                      title: AppLocalization.of(context)!
                          .getTranslatedValues(battleName[i])!,
                      desc: AppLocalization.of(context)!
                          .getTranslatedValues(battleDesc[i])!,
                      img: UiUtils.getImagePath(battleImg[i]),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildExamSelf() {
    return examSelf.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalization.of(context)
                          ?.getTranslatedValues(selfExamZoneKey) ??
                      selfExamZoneKey,
                  style: _boldTextStyle,
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    examSelf.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedSelfExam(examSelf[i]),
                      title: AppLocalization.of(context)!
                          .getTranslatedValues(examSelf[i])!,
                      desc: AppLocalization.of(context)!
                          .getTranslatedValues(examSelfDesc[i])!,
                      img: UiUtils.getImagePath(examSelfImg[i]),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildZones() {
    return Padding(
      padding: EdgeInsets.only(
        left: hzMargin,
        right: hzMargin,
        top: scrHeight * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          playDifferentZone.isNotEmpty
              ? Text(
                  AppLocalization.of(context)
                          ?.getTranslatedValues(playDifferentZoneKey) ??
                      playDifferentZoneKey,
                  style: _boldTextStyle,
                )
              : const SizedBox(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 20,
            padding: EdgeInsets.only(
              top: _statusBarPadding * 0.2,
              bottom: _statusBarPadding * 0.6,
            ),
            crossAxisSpacing: 20,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              playDifferentZone.length,
              (i) => QuizGridCard(
                onTap: () => _onPressedZone(playDifferentZone[i]),
                title: AppLocalization.of(context)!
                    .getTranslatedValues(playDifferentZone[i])!,
                desc: AppLocalization.of(context)!
                    .getTranslatedValues(playDifferentZoneDesc[i])!,
                img: UiUtils.getImagePath(playDifferentImg[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAds() {
    bool clicked = false;
    return BlocBuilder<RewardedAdCubit, RewardedAdState>(
      builder: (context, state) {
        if (state is RewardedAdLoaded &&
            context.read<UserDetailsCubit>().isDailyAdAvailable) {
          return GestureDetector(
            onTap: () {
              if (!clicked) {
                context.read<RewardedAdCubit>().showDailyAd(context: context);
                clicked = true;
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: hzMargin,
                right: hzMargin,
                top: scrHeight * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.background,
              ),
              width: scrWidth,
              height: scrWidth * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      UiUtils.getImagePath("daily_coins.svg"),
                      width: scrWidth * .23,
                      height: scrWidth * .23,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("dailyAdsTitle")!,
                        style: TextStyle(
                          fontWeight: FontWeights.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${AppLocalization.of(context)!.getTranslatedValues("get")!} "
                        "${_sysConfigCubit.coinsPerDailyAdView()} "
                        "${AppLocalization.of(context)!.getTranslatedValues("dailyAdsDesc")!}",
                        style: TextStyle(
                          fontWeight: FontWeights.regular,
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLiveContestSection() {
    void onTapViewAll() {
      if (_sysConfigCubit.isContestEnabled) {
        Navigator.of(context).pushNamed(Routes.contest);
      } else {
        UiUtils.setSnackbar(
          AppLocalization.of(context)!
              .getTranslatedValues(currentlyNotAvailableKey)!,
          context,
          false,
        );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hzMargin, vertical: 10),
      child: Column(
        children: [
          /// Contest Section Title
          // Row(
          //   children: [
          //     Text(
          //       AppLocalization.of(context)!.getTranslatedValues(contest) ??
          //           contest,
          //       style: _boldTextStyle,
          //     ),
          //     const Spacer(),
          //     GestureDetector(
          //       onTap: onTapViewAll,
          //       child: Text(
          //         AppLocalization.of(context)
          //                 ?.getTranslatedValues(viewAllKey) ??
          //             viewAllKey,
          //         style: TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeight.w600,
          //           color: Theme.of(context)
          //               .colorScheme
          //               .onTertiary
          //               .withOpacity(0.6),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 10),

          /// Contest Card
          // BlocConsumer<ContestCubit, ContestState>(
          //   bloc: context.read<ContestCubit>(),
          //   listener: (context, state) {
          //     if (state is ContestFailure) {
          //       if (state.errorMessage == errorCodeUnauthorizedAccess) {
          //         UiUtils.showAlreadyLoggedInDialog(context: context);
          //       }
          //     }
          //   },
          //   builder: (context, state) {
          //     if (state is ContestFailure) {
          //       return Container(
          //         decoration: BoxDecoration(
          //           color: Theme.of(context).colorScheme.background,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         height: 100,
          //         alignment: Alignment.center,
          //         child: Text(
          //           AppLocalization.of(context)!.getTranslatedValues(
          //             convertErrorCodeToLanguageKey(state.errorMessage),
          //           )!,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeights.regular,
          //             color: Theme.of(context).primaryColor,
          //           ),
          //           maxLines: 2,
          //         ),
          //       );
          //     }

          //     if (state is ContestSuccess) {
          //       final colorScheme = Theme.of(context).colorScheme;
          //       final textStyle = GoogleFonts.montserrat(
          //         textStyle: TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeights.regular,
          //           color: colorScheme.onTertiary.withOpacity(0.6),
          //         ),
          //       );

          //       ///
          //       final live = state.contestList.live;

          //       /// No Contest
          //       if (live.errorMessage.isNotEmpty) {
          //         return Container(
          //           decoration: BoxDecoration(
          //             color: colorScheme.background,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           height: 100,
          //           alignment: Alignment.center,
          //           child: Text(
          //             AppLocalization.of(context)!.getTranslatedValues(
          //               convertErrorCodeToLanguageKey(live.errorMessage),
          //             )!,
          //             style: _boldTextStyle.copyWith(
          //               fontSize: 16,
          //               color: Theme.of(context).primaryColor,
          //             ),
          //           ),
          //         );
          //       }

          //       final contest = live.contestDetails.first;
          //       final entryFee = int.parse(contest.entry!);

          //       return SizedBox(
          //         height: 140,
          //         width: scrWidth,
          //         child: LayoutBuilder(
          //           builder: (context, constraints) {
          //             final maxWidth = constraints.maxWidth;
          //             final maxHeight = constraints.maxHeight;

          //             void onTapPlayNow() {
          //               var userDetailsCubit = context.read<UserDetailsCubit>();

          //               if (int.parse(userDetailsCubit.getCoins()!) >=
          //                   entryFee) {
          //                 context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          //                       _userId,
          //                       entryFee,
          //                       false,
          //                       AppLocalization.of(context)!
          //                               .getTranslatedValues(
          //                                   playedContestKey) ??
          //                           "-",
          //                     );
          //                 userDetailsCubit.updateCoins(
          //                   addCoin: false,
          //                   coins: entryFee,
          //                 );

          //                 Navigator.of(context)
          //                     .pushNamed(Routes.quiz, arguments: {
          //                   "numberOfPlayer": 1,
          //                   "quizType": QuizTypes.contest,
          //                   "contestId": contest.id,
          //                   "quizName": "Contest"
          //                 });
          //               } else {
          //                 UiUtils.setSnackbar(
          //                   AppLocalization.of(context)!
          //                       .getTranslatedValues(noCoinsMsg)!,
          //                   context,
          //                   false,
          //                 );
          //               }
          //             }

          //             return Stack(
          //               children: [
          //                 /// Shadow
          //                 Positioned(
          //                   top: 0,
          //                   left: maxWidth * .1,
          //                   right: maxWidth * .1,
          //                   child: Container(
          //                     decoration: BoxDecoration(
          //                       color: Colors.transparent,
          //                       boxShadow: const [
          //                         BoxShadow(
          //                           offset: Offset(0, 40),
          //                           blurRadius: 30,
          //                           spreadRadius: 5,
          //                           color: Color(0xbf000000),
          //                         ),
          //                       ],
          //                       borderRadius: BorderRadius.vertical(
          //                         bottom: Radius.circular(maxWidth * .525),
          //                       ),
          //                     ),
          //                     width: maxWidth,
          //                     height: maxHeight * .6,
          //                   ),
          //                 ),

          //                 ///
          //                 Align(
          //                   child: Container(
          //                     height: maxHeight,
          //                     width: maxWidth,
          //                     decoration: BoxDecoration(
          //                       color: colorScheme.background,
          //                       borderRadius: BorderRadius.circular(10),
          //                     ),
          //                     padding: const EdgeInsets.all(12.5),
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       mainAxisAlignment:
          //                           MainAxisAlignment.spaceBetween,
          //                       mainAxisSize: MainAxisSize.max,
          //                       children: [
          //                         Row(
          //                           crossAxisAlignment:
          //                               CrossAxisAlignment.start,
          //                           children: [
          //                             /// Contest Image
          //                             Container(
          //                               padding: const EdgeInsets.all(5),
          //                               decoration: BoxDecoration(
          //                                 color: Colors.transparent,
          //                                 borderRadius:
          //                                     BorderRadius.circular(10),
          //                                 border: Border.all(
          //                                   color: Theme.of(context)
          //                                       .scaffoldBackgroundColor,
          //                                 ),
          //                               ),
          //                               child: ClipRRect(
          //                                 borderRadius:
          //                                     BorderRadius.circular(5),
          //                                 child: CachedNetworkImage(
          //                                   placeholder: (_, __) =>
          //                                       const Center(
          //                                     child:
          //                                         CircularProgressContainer(),
          //                                   ),
          //                                   memCacheWidth: 90,
          //                                   memCacheHeight: 90,
          //                                   errorWidget: (_, i, e) => Center(
          //                                     child: Icon(
          //                                       Icons.error,
          //                                       color: Theme.of(context)
          //                                           .primaryColor,
          //                                     ),
          //                                   ),
          //                                   width: 45,
          //                                   height: 45,
          //                                   fit: BoxFit.cover,
          //                                   imageUrl: contest.image.toString(),
          //                                 ),
          //                               ),
          //                             ),
          //                             const SizedBox(width: 8),

          //                             /// Contest Name & Description
          //                             Expanded(
          //                               child: Column(
          //                                 crossAxisAlignment:
          //                                     CrossAxisAlignment.start,
          //                                 children: [
          //                                   Text(
          //                                     contest.name.toString(),
          //                                     style: _boldTextStyle.copyWith(
          //                                         fontSize: 16),
          //                                   ),
          //                                   Text(
          //                                     contest.description.toString(),
          //                                     softWrap: true,
          //                                     textAlign: TextAlign.left,
          //                                     overflow: TextOverflow.ellipsis,
          //                                     maxLines: 2,
          //                                     style: textStyle,
          //                                   ),
          //                                 ],
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                         const SizedBox(height: 10),

          //                         ///
          //                         Row(
          //                           mainAxisAlignment:
          //                               MainAxisAlignment.spaceBetween,
          //                           children: [
          //                             Column(
          //                               crossAxisAlignment:
          //                                   CrossAxisAlignment.start,
          //                               children: [
          //                                 /// Entry Fees
          //                                 Text.rich(
          //                                   TextSpan(
          //                                     children: [
          //                                       TextSpan(
          //                                         text: AppLocalization.of(
          //                                                 context)!
          //                                             .getTranslatedValues(
          //                                                 "entryFeesLbl")!,
          //                                       ),
          //                                       const TextSpan(text: " : "),
          //                                       TextSpan(
          //                                         text:
          //                                             "$entryFee ${AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!}",
          //                                         style: textStyle.copyWith(
          //                                           color:
          //                                               colorScheme.onTertiary,
          //                                         ),
          //                                       ),
          //                                     ],
          //                                   ),
          //                                   style: textStyle,
          //                                 ),
          //                                 const SizedBox(height: 5),

          //                                 /// Ends on
          //                                 Text.rich(
          //                                   style: textStyle,
          //                                   TextSpan(
          //                                     children: [
          //                                       TextSpan(
          //                                         text: AppLocalization.of(
          //                                                 context)!
          //                                             .getTranslatedValues(
          //                                                 "endsOnLbl")!,
          //                                       ),
          //                                       const TextSpan(text: " : "),
          //                                       TextSpan(
          //                                         text:
          //                                             "${contest.endDate}  |  ",
          //                                         style: textStyle.copyWith(
          //                                           color:
          //                                               colorScheme.onTertiary,
          //                                         ),
          //                                       ),
          //                                       TextSpan(
          //                                         text: contest.participants
          //                                             .toString(),
          //                                         style: textStyle.copyWith(
          //                                           color:
          //                                               colorScheme.onTertiary,
          //                                         ),
          //                                       ),
          //                                       const TextSpan(text: " : "),
          //                                       TextSpan(
          //                                           text: AppLocalization.of(
          //                                                   context)!
          //                                               .getTranslatedValues(
          //                                                   "playersLbl")!),
          //                                     ],
          //                                   ),
          //                                 ),
          //                               ],
          //                             ),

          //                             /// Play Now
          //                             GestureDetector(
          //                               onTap: onTapPlayNow,
          //                               child: Container(
          //                                 padding: const EdgeInsets.symmetric(
          //                                   vertical: 8,
          //                                   horizontal: 5,
          //                                 ),
          //                                 decoration: BoxDecoration(
          //                                   borderRadius:
          //                                       BorderRadius.circular(8),
          //                                   color: Theme.of(context)
          //                                       .scaffoldBackgroundColor,
          //                                 ),
          //                                 child: Text(
          //                                   AppLocalization.of(context)!
          //                                       .getTranslatedValues(
          //                                           "playnowLbl")!,
          //                                   style: TextStyle(
          //                                     fontSize: 16,
          //                                     fontWeight: FontWeight.bold,
          //                                     color: Theme.of(context)
          //                                         .primaryColor,
          //                                   ),
          //                                 ),
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             );
          //           },
          //         ),
          //       );
          //     }

          //     return const Center(child: CircularProgressContainer());
          //   },
          // ),
        ],
      ),
    );
  }

  String _userRank = "0";
  String _userCoins = "0";
  String _userScore = "0";

  Widget _buildHome() {
    return Stack(
      children: [
        RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: () async {
            final quizCubit = context.read<QuizCategoryCubit>();
            final quizZoneCubit = context.read<QuizoneCategoryCubit>();

            if (widget.isGuest) {
              quizCubit.getQuizCategory(
                languageId: _currLangId,
                type: _quizZoneId,
              );
              quizZoneCubit.getQuizCategory(languageId: _currLangId);
            } else {
              quizCubit.getQuizCategoryWithUserId(
                languageId: UiUtils.getCurrentQuestionLanguageId(context),
                type: _quizZoneId,
                userId: _userId,
              );

              quizZoneCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
                userId: _userId,
              );
              context.read<ContestCubit>().getContest(_userId);

              fetchUserDetails();
            }
            setState(() {});
          },
          child: ListView(
            children: [
              _buildProfileContainer(),
              UserAchievements(
                userRank: _userRank,
                userCoins: _userCoins,
                userScore: _userScore,
                animation: slideAnimation,
              ),
              _buildCategory(),
              // if (_sysConfigCubit.isAdsEnable() &&
              //     _sysConfigCubit.isDailyAdsEnabled()) ...[
              //   _buildDailyAds(),
              // ],
              // if (_sysConfigCubit.isContestEnabled && !widget.isGuest) ...[
              //   _buildLiveContestSection(),
              // ],
              _buildBattle(),
              // _buildExamSelf(),
              // _buildZones(),
              _buildLeaderBoard()
            ],
          ),
        ),
        if (showUpdateContainer) const UpdateAppContainer(),
      ],
    );
  }

  Widget _buildLeaderBoard() {
    return (Container(
      margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      padding: EdgeInsets.only(
        left: hzMargin,
        right: hzMargin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Zone Title: Battle
          Text(
            '${AppLocalization.of(context)?.getTranslatedValues(dailyLbl) ?? dailyLbl} 1st place', //
            style: _boldTextStyle,
          ),
          const SizedBox(
            height: 20.0,
          ),

          /// Categories
          BlocConsumer<LeaderBoardDailyCubit, LeaderBoardDailyState>(
            bloc: context.read<LeaderBoardDailyCubit>(),
            listener: (context, state) {
              if (state is LeaderBoardDailyFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  UiUtils.showAlreadyLoggedInDialog(context: context);

                  return;
                }
              }
            },
            builder: (context, state) {
              if (state is LeaderBoardDailyFailure) {
                return ErrorContainer(
                  showBackButton: false,
                  errorMessage:
                      AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage),
                  )!,
                  onTapRetry: fetchDailyLeaderBoard,
                  showErrorImage: true,
                  errorMessageColor: Theme.of(context).primaryColor,
                );
              }

              ///
              if (state is LeaderBoardDailySuccess) {
                final dailyList = state.leaderBoardDetails;
                final hasMore = state.hasMore;

                /// API returns empty list if there is no leaderboard data.
                if (dailyList.isEmpty) {
                  return noLeaderboard(fetchDailyLeaderBoard);
                }

                log(name: 'Leaderboard Daily', jsonEncode(dailyList));
                log(name: 'Leaderboard Daily', 'Has More: $hasMore');

                return Wrap(
                  children: [
                    leaderBoardList(dailyList, controllerD, hasMore),
                    // if (LeaderBoardDailyCubit.scoreD != "0" &&
                    //     int.parse(LeaderBoardDailyCubit.rankD) > 3)
                    //   myRank(
                    //     LeaderBoardDailyCubit.rankD,
                    //     LeaderBoardDailyCubit.profileD,
                    //     LeaderBoardDailyCubit.scoreD,
                    //   ),
                  ],
                );
              }

              return const Center(child: CircularProgressContainer());
            },
          )
        ],
      ),
    ));
  }

  void fetchUserDetails() {
    context.read<UserDetailsCubit>().fetchUserDetails();
  }

  bool profileComplete = false;

  @override
  Widget build(BuildContext context) {
    /// need to add this here, cause textStyle doesn't update automatically when changing theme.
    _boldTextStyle = GoogleFonts.montserrat(
        textStyle: TextStyle(
      fontWeight: FontWeights.bold,
      fontSize: 24.0,
      color: Theme.of(context).colorScheme.onTertiary,
    ));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: Scaffold(
          body: widget.isGuest
              ? _buildHome()

              /// Build home with User
              : BlocConsumer<UserDetailsCubit, UserDetailsState>(
                  bloc: context.read<UserDetailsCubit>(),
                  listener: (context, state) {
                    log("current page state ${state.toString()}");
                    if (state is UserDetailsFetchSuccess) {
                      UiUtils.fetchBookmarkAndBadges(
                        context: context,
                        userId: state.userProfile.userId!,
                      );
                      if (state.userProfile.profileUrl!.isEmpty ||
                          state.userProfile.name!.isEmpty) {
                        if (!profileComplete) {
                          profileComplete = true;

                          Navigator.of(context).pushNamed(
                            Routes.selectProfile,
                            arguments: false,
                          );
                        }
                        return;
                      }
                    } else if (state is UserDetailsFetchFailure) {
                      if (state.errorMessage == errorCodeUnauthorizedAccess) {
                        UiUtils.showAlreadyLoggedInDialog(context: context);
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is UserDetailsFetchInProgress ||
                        state is UserDetailsInitial) {
                      return const Center(child: CircularProgressContainer());
                    }
                    if (state is UserDetailsFetchFailure) {
                      return Center(
                        child: ErrorContainer(
                          showBackButton: true,
                          errorMessage:
                              AppLocalization.of(context)!.getTranslatedValues(
                            convertErrorCodeToLanguageKey(state.errorMessage),
                          )!,
                          onTapRetry: fetchUserDetails,
                          showErrorImage: true,
                        ),
                      );
                    }

                    final user = (state as UserDetailsFetchSuccess).userProfile;

                    _userName = user.name!;
                    _userProfileImg = user.profileUrl!;
                    _userRank = user.allTimeRank!;
                    _userCoins = user.coins!;
                    _userScore = user.allTimeScore!;

                    return _buildHome();
                  },
                ),
        ),
      ),
    );
  }

  void fetchDailyLeaderBoard() =>
      context.read<LeaderBoardDailyCubit>().fetchLeaderBoard("20", _userId);
  Widget noLeaderboard(VoidCallback onTapRetry) => Center(
        child: ErrorContainer(
          topMargin: 0,
          errorMessage: AppLocalization.of(context)!
              .getTranslatedValues("noLeaderboardLbl")!,
          onTapRetry: onTapRetry,
          showErrorImage: false,
        ),
      );
  Widget leaderBoardList(
    List leaderBoardList,
    ScrollController controller,
    bool hasMore,
  ) {
    // if (leaderBoardList.length <= 3) return const SizedBox();

    final leaderBoardTextStyle = GoogleFonts.montserrat(
        textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontSize: 16,
            fontWeight: FontWeights.extrabold));
    final leaderBoardScoreTextStyle = GoogleFonts.montserrat(
        textStyle: TextStyle(
            color: santas_gray,
            fontSize: 16,
            fontWeight: FontWeights.extrabold));
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        decoration: ShapeDecoration(
            color: white,
            shadows: [
              BoxShadow(
                color: wood_smoke,
                offset: Offset(
                  0.0, // Move to right 10  horizontally
                  6.0, // Move to bottom 5 Vertically
                ),
              )
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(color: wood_smoke, width: 2))),
        padding: EdgeInsets.only(
            top: 10, left: width * .02, right: width * .02, bottom: 10.0),
        child: ListView.separated(
          controller: controller,
          shrinkWrap: true,
          itemCount: leaderBoardList.length,
          separatorBuilder: (_, i) => i > 2
              ? Divider(
                  color: Colors.grey,
                  indent: width * 0.03,
                  endIndent: width * 0.03,
                )
              : const SizedBox(),
          itemBuilder: (context, index) {
            return index >= 0
                ? (hasMore && index == (leaderBoardList.length - 1))
                    ? const Center(child: CircularProgressContainer())
                    : Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              leaderBoardList[index]['user_rank']!,
                              style: leaderBoardTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.only(right: 20),
                              title: Text(
                                leaderBoardList[index]['name'] ?? "...",
                                overflow: TextOverflow.ellipsis,
                                style: leaderBoardTextStyle,
                              ),
                              leading: Container(
                                width: width * .12,
                                height: height * .3,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: UserUtils.getUserProfileWidget(
                                  profileUrl:
                                      leaderBoardList[index]['profile'] ?? "",
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                ),
                              ),
                              trailing: SizedBox(
                                width: width * .12,
                                child: Center(
                                  child: Text(
                                    UiUtils.formatNumber(
                                      int.parse(leaderBoardList[index]
                                              ['score'] ??
                                          "0"),
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    style: leaderBoardScoreTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                : const SizedBox();
          },
        ),
      ),
    );
  }
}
