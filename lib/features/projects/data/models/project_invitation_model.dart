class ProjectInvitationModel {
  final String memberId;
  final String projectId;
  final String projectName;
  final String? projectDescription;
  final String inviterName;
  final String role;
  final DateTime invitedAt;

  ProjectInvitationModel({
    required this.memberId,
    required this.projectId,
    required this.projectName,
    this.projectDescription,
    required this.inviterName,
    required this.role,
    required this.invitedAt,
  });

  factory ProjectInvitationModel.fromJson(Map<String, dynamic> json) {
    return ProjectInvitationModel(
      memberId: json['memberId'] ?? '',
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'] ?? '',
      projectDescription: json['projectDescription'],
      inviterName: json['inviterName'] ?? '',
      role: json['role'] ?? 'Member',
      invitedAt: DateTime.tryParse(json['invitedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
