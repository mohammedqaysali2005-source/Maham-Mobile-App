import 'package:equatable/equatable.dart';
import '../../../../shared/models/priority_enum.dart';
import '../../../../shared/models/card_status_enum.dart';

class CardModel extends Equatable {
  final String id;
  final String columnId;
  final String title;
  final String? description;
  final Priority priority;
  final CardStatus status;
  final String? assigneeId;
  final String? assigneeName;
  final DateTime? dueDate;
  final String? coverImageUrl;
  final int order;
  final int? storyPoints;
  final String? labels;
  final DateTime createdAt;

  const CardModel({
    required this.id,
    required this.columnId,
    required this.title,
    this.description,
    this.priority = Priority.medium,
    this.status = CardStatus.todo,
    this.assigneeId,
    this.assigneeName,
    this.dueDate,
    this.coverImageUrl,
    this.order = 0,
    this.storyPoints,
    this.labels,
    required this.createdAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      columnId: json['columnId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      priority: PriorityExtension.fromApi(json['priority'] ?? 'Medium'),
      status: CardStatusExtension.fromApi(json['status'] ?? 'Todo'),
      assigneeId: json['assigneeId'],
      assigneeName: json['assigneeName'],
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      coverImageUrl: json['coverImageUrl'],
      order: json['order'] ?? 0,
      storyPoints: json['storyPoints'],
      labels: json['labels'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'columnId': columnId,
        'title': title,
        'description': description,
        'priority': priority.apiValue,
        'status': status.apiValue,
        'assigneeId': assigneeId,
        'assigneeName': assigneeName,
        'dueDate': dueDate?.toIso8601String(),
        'coverImageUrl': coverImageUrl,
        'order': order,
        'storyPoints': storyPoints,
        'labels': labels,
      };

  @override
  List<Object?> get props => [
        id,
        columnId,
        title,
        description,
        priority,
        status,
        assigneeId,
        assigneeName,
        dueDate,
        order,
      ];
}
