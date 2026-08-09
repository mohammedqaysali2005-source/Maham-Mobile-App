import '../../data/models/project_model.dart';
import '../../data/models/project_invitation_model.dart';

abstract class ProjectRepository {
  /// Get all projects for the current user
  Future<List<ProjectModel>> getMyProjects();

  /// Get a single project by ID
  Future<ProjectModel> getProjectById(String projectId);

  /// Create a new project
  Future<ProjectModel> createProject({
    required String name,
    String? description,
  });

  /// Update an existing project
  Future<ProjectModel> updateProject({
    required String projectId,
    required String name,
    String? description,
  });

  /// Delete a project
  Future<void> deleteProject(String projectId);

  /// Add a member to a project
  Future<void> addMember({
    required String projectId,
    required String email,
    required String role,
  });

  /// Remove a member from a project
  Future<void> removeMember({
    required String projectId,
    required String userId,
  });

  /// Get pending invitations for the current user
  Future<List<ProjectInvitationModel>> getPendingInvitations();

  /// Accept an invitation
  Future<void> acceptInvitation(String memberId);

  /// Reject an invitation
  Future<void> rejectInvitation(String memberId);
}
