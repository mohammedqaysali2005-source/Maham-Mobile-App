import 'package:equatable/equatable.dart';
import '../../../projects/data/models/card_model.dart';

abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<CardModel> tasks;
  const TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TasksFailure extends TasksState {
  final String message;
  const TasksFailure(this.message);
  @override
  List<Object?> get props => [message];
}
