import 'package:equatable/equatable.dart';
import 'column_model.dart';

class BoardModel extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String? backgroundColor;
  final DateTime createdAt;
  final List<ColumnModel> columns;

  const BoardModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.backgroundColor,
    required this.createdAt,
    this.columns = const [],
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    final colsList = (json['columns'] as List<dynamic>? ?? [])
        .map((c) => ColumnModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return BoardModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      backgroundColor: json['backgroundColor'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      columns: colsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'description': description,
        'backgroundColor': backgroundColor,
      };

  @override
  List<Object?> get props => [id, projectId, name, description, backgroundColor, columns];
}
