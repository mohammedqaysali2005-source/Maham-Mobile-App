import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projects/domain/repositories/board_repository.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final BoardRepository _repository;

  TasksBloc({required BoardRepository repository})
      : _repository = repository,
        super(TasksInitial()) {
    on<TasksLoadRequested>(_onTasksLoad);
  }

  Future<void> _onTasksLoad(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    try {
      final tasks = await _repository.getAssignedCards();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksFailure(e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '')));
    }
  }
}
