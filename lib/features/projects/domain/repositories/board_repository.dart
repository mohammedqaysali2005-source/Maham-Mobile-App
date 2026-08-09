import '../../data/models/board_model.dart';
import '../../data/models/column_model.dart';
import '../../data/models/card_model.dart';

abstract class BoardRepository {
  Future<List<BoardModel>> getBoards(String projectId);
  Future<BoardModel> getBoardDetails(String boardId);
  Future<BoardModel> createBoard(String projectId, String name, String? description);
  Future<BoardModel> updateBoard(String boardId, String name, String? description);
  Future<void> deleteBoard(String boardId);

  Future<ColumnModel> createColumn(String boardId, String name);
  Future<ColumnModel> updateColumn(String columnId, String name);
  Future<void> deleteColumn(String columnId);

  Future<CardModel> createCard(String columnId, {
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  });
  Future<CardModel> updateCard(String cardId, {
    required String title,
    String? description,
    String? priority,
    String? status,
    String? assigneeId,
    DateTime? dueDate,
  });
  Future<void> deleteCard(String cardId);
  Future<void> moveCard(String cardId, String targetColumnId, int newOrder);
  Future<List<CardModel>> getAssignedCards();
}
