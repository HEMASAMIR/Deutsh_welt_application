part of 'levels_cubit.dart';

abstract class LevelsState extends Equatable {
  const LevelsState();

  @override
  List<Object?> get props => [];
}

class LevelsInitial extends LevelsState {
  const LevelsInitial();
}

class LevelsLoading extends LevelsState {
  const LevelsLoading();
}

class LevelsLoaded extends LevelsState {
  final List<LevelModel> levels;
  final bool isRefreshing;

  const LevelsLoaded(this.levels, {this.isRefreshing = false});

  @override
  List<Object?> get props => [levels, isRefreshing];
}

class LevelsError extends LevelsState {
  final String message;
  final bool isNoInternet;

  const LevelsError(this.message, {this.isNoInternet = false});

  @override
  List<Object?> get props => [message, isNoInternet];
}
