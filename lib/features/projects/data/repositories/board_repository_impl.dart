import '../../../../core/network/dio_client.dart';
import '../../data/models/board_model.dart';
import '../../data/models/column_model.dart';
import '../../data/models/card_model.dart';
import '../../domain/repositories/board_repository.dart';

class BoardRepositoryImpl implements BoardRepository {
  final DioClient _dioClient;

  BoardRepositoryImpl(this._dioClient);

  @override
  Future<List<BoardModel>> getBoards(String projectId) async {
    final response = await _dioClient.get('/projects/$projectId/boards');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((e) => BoardModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is List<dynamic>) {
      return data.map((e) => BoardModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<BoardModel> getBoardDetails(String boardId) async {
    final response = await _dioClient.get('/boards/$boardId');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return BoardModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<BoardModel> createBoard(String projectId, String name, String? description) async {
    final response = await _dioClient.post(
      '/projects/$projectId/boards',
      data: {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return BoardModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<BoardModel> updateBoard(String boardId, String name, String? description) async {
    final response = await _dioClient.put(
      '/boards/$boardId',
      data: {
        'name': name,
        if (description != null) 'description': description,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return BoardModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<void> deleteBoard(String boardId) async {
    await _dioClient.delete('/boards/$boardId');
  }

  @override
  Future<ColumnModel> createColumn(String boardId, String name) async {
    final response = await _dioClient.post(
      '/boards/$boardId/columns',
      data: {'name': name},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ColumnModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<ColumnModel> updateColumn(String columnId, String name) async {
    final response = await _dioClient.put(
      '/columns/$columnId',
      data: {'name': name},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ColumnModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<void> deleteColumn(String columnId) async {
    await _dioClient.delete('/columns/$columnId');
  }

  @override
  Future<CardModel> createCard(String columnId, {
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    final response = await _dioClient.post(
      '/columns/$columnId/cards',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CardModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<CardModel> updateCard(String cardId, {
    required String title,
    String? description,
    String? priority,
    String? status,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    final response = await _dioClient.put(
      '/cards/$cardId',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      },
    );
    final data = response.data;

    // Check if status is different and update it
    if (status != null) {
      await _dioClient.put('/cards/$cardId/status', data: {'status': status});
    }

    if (assigneeId != null) {
      await _dioClient.put('/cards/$cardId/assign', data: {'assigneeId': assigneeId});
    }

    if (data is Map<String, dynamic>) {
      return CardModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await _dioClient.delete('/cards/$cardId');
  }

  @override
  Future<void> moveCard(String cardId, String targetColumnId, int newOrder) async {
    await _dioClient.put(
      '/cards/$cardId/move',
      data: {
        'toColumnId': targetColumnId,
        'newOrder': newOrder,
      },
    );
  }

  @override
  Future<List<CardModel>> getAssignedCards() async {
    final response = await _dioClient.get('/cards/assigned-to-me');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is List<dynamic>) {
      return data.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
