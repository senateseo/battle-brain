import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

part 'unlock_premium_category_state.dart';

class UnlockPremiumCategoryCubit extends Cubit<UnlockPremiumCategoryState> {
  final QuizRepository _quizRepository;

  UnlockPremiumCategoryCubit(this._quizRepository)
      : super(UnlockPremiumCategoryInitial());

  void unlockPremiumCategory({
    required String categoryId,
    String? subCategoryId,
  }) {
    emit(UnlockPremiumCategoryInProgress());

    _quizRepository
        .unlockPremiumCategory(
          categoryId: categoryId,
          subCategoryId: subCategoryId,
        )
        .then((_) => emit(UnlockPremiumCategorySuccess()))
        .catchError((e) => emit(UnlockPremiumCategoryFailure(e.toString())));
  }

  void reset() => emit(UnlockPremiumCategoryInitial());
}
