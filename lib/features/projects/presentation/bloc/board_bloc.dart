import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/board_repository.dart';
import 'board_event.dart';
import 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final BoardRepository _repository;

  BoardBloc({required BoardRepository repository})
      : _repository = repository,
        super(BoardInitial()) {
    on<BoardsLoadRequested>(_onBoardsLoad);
    on<BoardDetailLoadRequested>(_onBoardDetailLoad);
    on<BoardCreateRequested>(_onBoardCreate);
    on<BoardUpdateRequested>(_onBoardUpdate);
    on<BoardDeleteRequested>(_onBoardDelete);

    // Columns
    on<ColumnCreateRequested>(_onColumnCreate);
    on<ColumnUpdateRequested>(_onColumnUpdate);
    on<ColumnDeleteRequested>(_onColumnDelete);

    // Cards
    on<CardCreateRequested>(_onCardCreate);
    on<CardUpdateRequested>(_onCardUpdate);
    on<CardDeleteRequested>(_onCardDelete);
    on<CardMoveRequested>(_onCardMove);
  }

  Future<void> _onBoardsLoad(
    BoardsLoadRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardsLoading());
    try {
      final boards = await _repository.getBoards(event.projectId);
      emit(BoardsLoaded(boards));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onBoardDetailLoad(
    BoardDetailLoadRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardDetailLoading());
    try {
      final board = await _repository.getBoardDetails(event.boardId);
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onBoardCreate(
    BoardCreateRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.createBoard(event.projectId, event.name, event.description);
      final boards = await _repository.getBoards(event.projectId);
      emit(const BoardActionSuccess('تم إنشاء اللوحة بنجاح'));
      emit(BoardsLoaded(boards));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onBoardUpdate(
    BoardUpdateRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.updateBoard(event.boardId, event.name, event.description);
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم تعديل اللوحة بنجاح'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onBoardDelete(
    BoardDeleteRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.deleteBoard(event.boardId);
      final boards = await _repository.getBoards(event.projectId);
      emit(const BoardActionSuccess('تم حذف اللوحة'));
      emit(BoardsLoaded(boards));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  // Columns
  Future<void> _onColumnCreate(
    ColumnCreateRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.createColumn(event.boardId, event.name);
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم إضافة العمود بنجاح'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onColumnUpdate(
    ColumnUpdateRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.updateColumn(event.columnId, event.name);
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم تعديل اسم العمود'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onColumnDelete(
    ColumnDeleteRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.deleteColumn(event.columnId);
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم حذف العمود'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  // Cards
  Future<void> _onCardCreate(
    CardCreateRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.createCard(
        event.columnId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم إضافة البطاقة بنجاح'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onCardUpdate(
    CardUpdateRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.updateCard(
        event.cardId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        status: event.status,
        assigneeId: event.assigneeId,
        dueDate: event.dueDate,
      );
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم تعديل البطاقة بنجاح'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onCardDelete(
    CardDeleteRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(BoardActionInProgress());
    try {
      await _repository.deleteCard(event.cardId);
      final board = await _repository.getBoardDetails(event.boardId);
      emit(const BoardActionSuccess('تم حذف البطاقة'));
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  Future<void> _onCardMove(
    CardMoveRequested event,
    Emitter<BoardState> emit,
  ) async {
    // Keep optimistic state update / UI side update if possible, or reload details on complete
    try {
      await _repository.moveCard(event.cardId, event.targetColumnId, event.newOrder);
      final board = await _repository.getBoardDetails(event.boardId);
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardFailure(_cleanError(e)));
    }
  }

  String _cleanError(Object e) =>
      e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
}
