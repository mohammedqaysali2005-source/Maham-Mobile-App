import 'package:equatable/equatable.dart';

abstract class BoardEvent extends Equatable {
  const BoardEvent();
  @override
  List<Object?> get props => [];
}

class BoardsLoadRequested extends BoardEvent {
  final String projectId;
  const BoardsLoadRequested(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class BoardDetailLoadRequested extends BoardEvent {
  final String boardId;
  const BoardDetailLoadRequested(this.boardId);
  @override
  List<Object?> get props => [boardId];
}

class BoardCreateRequested extends BoardEvent {
  final String projectId;
  final String name;
  final String? description;

  const BoardCreateRequested({
    required this.projectId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [projectId, name, description];
}

class BoardUpdateRequested extends BoardEvent {
  final String boardId;
  final String name;
  final String? description;

  const BoardUpdateRequested({
    required this.boardId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [boardId, name, description];
}

class BoardDeleteRequested extends BoardEvent {
  final String boardId;
  final String projectId;

  const BoardDeleteRequested({required this.boardId, required this.projectId});

  @override
  List<Object?> get props => [boardId, projectId];
}

// Columns
class ColumnCreateRequested extends BoardEvent {
  final String boardId;
  final String name;

  const ColumnCreateRequested({required this.boardId, required this.name});

  @override
  List<Object?> get props => [boardId, name];
}

class ColumnUpdateRequested extends BoardEvent {
  final String boardId;
  final String columnId;
  final String name;

  const ColumnUpdateRequested({
    required this.boardId,
    required this.columnId,
    required this.name,
  });

  @override
  List<Object?> get props => [boardId, columnId, name];
}

class ColumnDeleteRequested extends BoardEvent {
  final String boardId;
  final String columnId;

  const ColumnDeleteRequested({required this.boardId, required this.columnId});

  @override
  List<Object?> get props => [boardId, columnId];
}

// Cards
class CardCreateRequested extends BoardEvent {
  final String boardId;
  final String columnId;
  final String title;
  final String? description;
  final String? priority;
  final DateTime? dueDate;

  const CardCreateRequested({
    required this.boardId,
    required this.columnId,
    required this.title,
    this.description,
    this.priority,
    this.dueDate,
  });

  @override
  List<Object?> get props => [boardId, columnId, title, description, priority, dueDate];
}

class CardUpdateRequested extends BoardEvent {
  final String boardId;
  final String cardId;
  final String title;
  final String? description;
  final String? priority;
  final String? status;
  final String? assigneeId;
  final DateTime? dueDate;

  const CardUpdateRequested({
    required this.boardId,
    required this.cardId,
    required this.title,
    this.description,
    this.priority,
    this.status,
    this.assigneeId,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        boardId,
        cardId,
        title,
        description,
        priority,
        status,
        assigneeId,
        dueDate,
      ];
}

class CardDeleteRequested extends BoardEvent {
  final String boardId;
  final String cardId;

  const CardDeleteRequested({required this.boardId, required this.cardId});

  @override
  List<Object?> get props => [boardId, cardId];
}

class CardMoveRequested extends BoardEvent {
  final String boardId;
  final String cardId;
  final String targetColumnId;
  final int newOrder;

  const CardMoveRequested({
    required this.boardId,
    required this.cardId,
    required this.targetColumnId,
    required this.newOrder,
  });

  @override
  List<Object?> get props => [boardId, cardId, targetColumnId, newOrder];
}
