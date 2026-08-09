import 'package:equatable/equatable.dart';
import '../../data/models/board_model.dart';

abstract class BoardState extends Equatable {
  const BoardState();
  @override
  List<Object?> get props => [];
}

class BoardInitial extends BoardState {}

// Listing boards state
class BoardsLoading extends BoardState {}

class BoardsLoaded extends BoardState {
  final List<BoardModel> boards;
  const BoardsLoaded(this.boards);
  @override
  List<Object?> get props => [boards];
}

// Single board detail / Kanban board state
class BoardDetailLoading extends BoardState {}

class BoardDetailLoaded extends BoardState {
  final BoardModel board;
  const BoardDetailLoaded(this.board);
  @override
  List<Object?> get props => [board];
}

// Global actions success/failure
class BoardActionInProgress extends BoardState {}

class BoardActionSuccess extends BoardState {
  final String message;
  const BoardActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class BoardFailure extends BoardState {
  final String message;
  const BoardFailure(this.message);
  @override
  List<Object?> get props => [message];
}
