import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maham_app/features/projects/domain/repositories/board_repository.dart';
import 'package:maham_app/features/projects/data/models/card_model.dart';
import 'package:maham_app/shared/models/priority_enum.dart';
import 'package:maham_app/shared/models/card_status_enum.dart';
import 'package:maham_app/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:maham_app/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:maham_app/features/tasks/presentation/bloc/tasks_state.dart';

class MockBoardRepository extends Mock implements BoardRepository {}

void main() {
  late MockBoardRepository mockBoardRepository;
  late TasksBloc tasksBloc;

  setUp(() {
    mockBoardRepository = MockBoardRepository();
    tasksBloc = TasksBloc(repository: mockBoardRepository);
  });

  tearDown(() {
    tasksBloc.close();
  });

  test('initial state is TasksInitial', () {
    expect(tasksBloc.state, TasksInitial());
  });

  group('TasksLoadRequested', () {
    final tTasks = [
      CardModel(
        id: '1',
        columnId: 'col-1',
        title: 'Task 1',
        description: 'Description 1',
        order: 1,
        priority: Priority.medium,
        status: CardStatus.todo,
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoading, TasksLoaded] when load is successful',
      build: () {
        when(() => mockBoardRepository.getAssignedCards())
            .thenAnswer((_) async => tTasks);
        return tasksBloc;
      },
      act: (bloc) => bloc.add(TasksLoadRequested()),
      expect: () => [
        TasksLoading(),
        TasksLoaded(tTasks),
      ],
      verify: (_) {
        verify(() => mockBoardRepository.getAssignedCards()).called(1);
      },
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoading, TasksFailure] when load fails',
      build: () {
        when(() => mockBoardRepository.getAssignedCards())
            .thenThrow(Exception('Failed to load tasks'));
        return tasksBloc;
      },
      act: (bloc) => bloc.add(TasksLoadRequested()),
      expect: () => [
        TasksLoading(),
        const TasksFailure('Failed to load tasks'),
      ],
      verify: (_) {
        verify(() => mockBoardRepository.getAssignedCards()).called(1);
      },
    );
  });
}
