import 'package:equatable/equatable.dart';
import 'card_model.dart';

class ColumnModel extends Equatable {
  final String id;
  final String boardId;
  final String name;
  final int order;
  final int? wipLimit;
  final List<CardModel> cards;

  const ColumnModel({
    required this.id,
    required this.boardId,
    required this.name,
    required this.order,
    this.wipLimit,
    this.cards = const [],
  });

  factory ColumnModel.fromJson(Map<String, dynamic> json) {
    final cardsList = (json['cards'] as List<dynamic>? ?? [])
        .map((c) => CardModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return ColumnModel(
      id: json['id'] ?? '',
      boardId: json['boardId'] ?? '',
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      wipLimit: json['wipLimit'],
      cards: cardsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'boardId': boardId,
        'name': name,
        'order': order,
        'wipLimit': wipLimit,
      };

  @override
  List<Object?> get props => [id, boardId, name, order, wipLimit, cards];
}
