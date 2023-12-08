import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/musicPlayer/musicPlayerCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionCubit.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/music_player_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/questionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/report_question_bottom_sheet.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ReviewAnswersScreen extends StatefulWidget {
  final List<Question> questions;
  final QuizTypes quizType;
  final List<GuessTheWordQuestion> guessTheWordQuestions;

  const ReviewAnswersScreen({
    super.key,
    required this.questions,
    required this.guessTheWordQuestions,
    required this.quizType,
  });

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    //arguments will map and keys of the map are following
    //questions and guessTheWordQuestions
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateBookmarkCubit>(
            create: (context) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
          BlocProvider<ReportQuestionCubit>(
            create: (_) => ReportQuestionCubit(ReportQuestionRepository()),
          ),
        ],
        child: ReviewAnswersScreen(
          quizType: arguments!['quizType'],
          guessTheWordQuestions: arguments['guessTheWordQuestions'] ??
              List<GuessTheWordQuestion>.from([]),
          questions: arguments['questions'] ?? List<Question>.from([]),
        ),
      ),
    );
  }

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  late final _pageController = PageController();
  int _currQueIdx = 0;

  late final _firebaseId = context.read<UserDetailsCubit>().getUserFirebaseId();

  late final _isGuessTheWord = widget.quizType == QuizTypes.guessTheWord;
  late final _isAudioQuestions = widget.quizType == QuizTypes.audioQuestions;

  late final questionsLength = _isGuessTheWord
      ? widget.guessTheWordQuestions.length
      : widget.questions.length;

  late final _musicPlayerKeys = List.generate(
    widget.questions.length,
    (_) => GlobalKey<MusicPlayerContainerState>(),
    growable: false,
  );
  late final _correctAnswerIds = List.generate(
    widget.questions.length,
    (i) => AnswerEncryption.decryptCorrectAnswer(
      rawKey: _firebaseId,
      correctAnswer: widget.questions[i].correctAnswer!,
    ),
    growable: false,
  );

  void _onTapReportQuestion() {
    showReportQuestionBottomSheet(
      context: context,
      questionId: _isGuessTheWord
          ? widget.guessTheWordQuestions[_currQueIdx].id
          : widget.questions[_currQueIdx].id!,
      reportQuestionCubit: context.read<ReportQuestionCubit>(),
    );
  }

  void _onPageChanged(idx) {
    if (_isAudioQuestions) {
      _musicPlayerKeys[_currQueIdx].currentState?.stopAudio();
      _musicPlayerKeys[idx].currentState?.playAudio();
    }
    setState(() => _currQueIdx = idx);
  }

  Color _optionBackgroundColor(String? optionId) {
    if (optionId == _correctAnswerIds[_currQueIdx]) {
      return Colors.green;
    }

    if (optionId == widget.questions[_currQueIdx].submittedAnswerId) {
      return Colors.red;
    }

    return Theme.of(context).colorScheme.background;
  }

  Color _optionTextColor(String? optionId) {
    final correctAnswerId = _correctAnswerIds[_currQueIdx];
    final submittedAnswerId = widget.questions[_currQueIdx].submittedAnswerId;

    return optionId == correctAnswerId || optionId == submittedAnswerId
        ? Theme.of(context).colorScheme.background
        : Theme.of(context).colorScheme.onTertiary;
  }

  Widget _buildBottomMenu() {
    final colorScheme = Theme.of(context).colorScheme;

    void onTapPageChange({required bool flipLeft}) {
      if (_currQueIdx != (flipLeft ? 0 : questionsLength - 1)) {
        final idx = _currQueIdx + (flipLeft ? -1 : 1);
        _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      height: MediaQuery.of(context).size.height * UiUtils.bottomMenuPercentage,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 5, left: 8, right: 2, bottom: 5),
            child: GestureDetector(
              onTap: () => onTapPageChange(flipLeft: true),
              child: Icon(
                Icons.arrow_back_ios,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
          // Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              "${_currQueIdx + 1} / $questionsLength",
              style: TextStyle(
                color: colorScheme.onTertiary,
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              onTap: () => onTapPageChange(flipLeft: false),
              child: Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //to build option of given question
  Widget _buildOption(AnswerOption option) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: _optionBackgroundColor(option.id),
      ),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 15.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Center(
        child: widget.quizType == QuizTypes.mathMania
            ? TeXView(
                child: TeXViewDocument(option.title!),
                style: TeXViewStyle(
                  contentColor: Theme.of(context).colorScheme.onTertiary,
                  backgroundColor: Colors.transparent,
                  sizeUnit: TeXViewSizeUnit.pixels,
                  textAlign: TeXViewTextAlign.center,
                  fontStyle: TeXViewFontStyle(fontSize: 19),
                ),
              )
            : Text(
                option.title!,
                style: TextStyle(
                  color: _optionTextColor(option.id),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _buildOptions() => Column(
        children: widget.questions[_currQueIdx].answerOptions!
            .map((option) => _buildOption(option))
            .toList(),
      );

  Widget _buildGuessTheWordOptionAndAnswer(
      GuessTheWordQuestion guessTheWordQuestion) {
    final isCorrect = UiUtils.buildGuessTheWordQuestionAnswer(
            guessTheWordQuestion.submittedAnswer) ==
        guessTheWordQuestion.answer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25.0),
        Padding(
          padding: EdgeInsets.zero,
          child: Text(
            "${AppLocalization.of(context)!.getTranslatedValues("yourAnsLbl")!} : ${UiUtils.buildGuessTheWordQuestionAnswer(guessTheWordQuestion.submittedAnswer)}",
            style: TextStyle(
              fontSize: 18.0,
              color: isCorrect
                  ? Colors.green
                  : Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
        if (!isCorrect) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 0.0),
            child: Text(
              "${AppLocalization.of(context)!.getTranslatedValues("correctAndLbl")!}: ${guessTheWordQuestion.answer}",
              style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotes(String notes) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      margin: const EdgeInsets.only(top: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context)!.getTranslatedValues(notesKey)!,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 10.0),

          ///
          widget.quizType == QuizTypes.mathMania
              ? TeXView(
                  child: TeXViewDocument(notes),
                  style: TeXViewStyle(
                    contentColor: primaryColor,
                    sizeUnit: TeXViewSizeUnit.pixels,
                    textAlign: TeXViewTextAlign.center,
                  ),
                )
              : Text(
                  notes,
                  style: TextStyle(color: primaryColor),
                ),
        ],
      ),
    );
  }

  Widget _buildQuestionAndOptions(Question question, int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: widget.quizType == QuizTypes.mathMania,
            question: question,
            questionColor: Theme.of(context).colorScheme.onTertiary,
          ),
          _isAudioQuestions
              ? BlocProvider<MusicPlayerCubit>(
                  create: (_) => MusicPlayerCubit(),
                  child: MusicPlayerContainer(
                    currentIndex: _currQueIdx,
                    index: index,
                    url: question.audio!,
                    key: _musicPlayerKeys[index],
                  ),
                )
              : const SizedBox(),

          //build options
          _buildOptions(),
          _buildNotes(question.note!),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildGuessTheWordQuestionAndOptions(GuessTheWordQuestion question) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: false,
            questionColor: Theme.of(context).colorScheme.onTertiary,
            question: Question(
              marks: "",
              id: question.id,
              question: question.question,
              imageUrl: question.image,
            ),
          ),
          //build options
          _buildGuessTheWordOptionAndAnswer(question),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * (0.85),
      child: PageView.builder(
        onPageChanged: _onPageChanged,
        controller: _pageController,
        itemCount: questionsLength,
        itemBuilder: (_, idx) => _isGuessTheWord
            ? _buildGuessTheWordQuestionAndOptions(
                widget.guessTheWordQuestions[idx])
            : _buildQuestionAndOptions(widget.questions[idx], idx),
      ),
    );
  }

  Widget _buildReportButton() {
    return IconButton(
      onPressed: _onTapReportQuestion,
      icon: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: QAppBar(
        title: Text(AppLocalization.of(context)!
            .getTranslatedValues("reviewAnswerLbl")!),
        actions: [
          if (widget.questions.isNotEmpty &&
              (widget.quizType == QuizTypes.quizZone ||
                  widget.quizType == QuizTypes.selfChallenge ||
                  widget.quizType == QuizTypes.battle ||
                  widget.quizType == QuizTypes.groupPlay)) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildReportButton()],
            )
          ]
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * UiUtils.vtMarginPct,
                horizontal: size.width * UiUtils.hzMarginPct,
              ),
              child: _buildQuestions(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomMenu(),
          ),
        ],
      ),
    );
  }
}
