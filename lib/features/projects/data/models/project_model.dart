import 'package:equatable/equatable.dart';

class ProjectMemberModel extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  const ProjectMemberModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      userId: json['userId'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Member',
      avatarUrl: json['avatarUrl'],
    );
  }

  @override
  List<Object?> get props => [userId, fullName, email, role];
}

class ProjectModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int boardCount;
  final int memberCount;
  final List<ProjectMemberModel> members;

  const ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.updatedAt,
    this.boardCount = 0,
    this.memberCount = 0,
    this.members = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final membersList = (json['members'] as List<dynamic>? ?? [])
        .map((m) => ProjectMemberModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? json['owner']?['fullName'] ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      boardCount: json['boardCount'] ?? (json['boards'] as List?)?.length ?? 0,
      memberCount:
          json['memberCount'] ?? (json['members'] as List?)?.length ?? 0,
      members: membersList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, description, ownerId, boardCount, memberCount];
}
