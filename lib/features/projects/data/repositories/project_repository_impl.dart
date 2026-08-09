import '../../../../core/network/dio_client.dart';
import '../../data/models/project_model.dart';
import '../../data/models/project_invitation_model.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final DioClient _dioClient;
  static const _base = '/projects';

  ProjectRepositoryImpl(this._dioClient);

  @override
  Future<List<ProjectModel>> getMyProjects() async {
    final response = await _dioClient.get(_base);
    final data = response.data;

    // Handle both wrapped { success, data: [...] } and plain [...]
    if (data is Map<String, dynamic>) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is List<dynamic>) {
      return data
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<ProjectModel> getProjectById(String projectId) async {
    final response = await _dioClient.get('$_base/$projectId');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ProjectModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    String? description,
  }) async {
    final response = await _dioClient.post(
      _base,
      data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ProjectModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<ProjectModel> updateProject({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final response = await _dioClient.put(
      '$_base/$projectId',
      data: {
        'name': name,
        if (description != null) 'description': description,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ProjectModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Invalid response format');
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _dioClient.delete('$_base/$projectId');
  }

  @override
  Future<void> addMember({
    required String projectId,
    required String email,
    required String role,
  }) async {
    await _dioClient.post(
      '$_base/$projectId/members',
      data: {'email': email, 'role': role},
    );
  }

  @override
  Future<void> removeMember({
    required String projectId,
    required String userId,
  }) async {
    await _dioClient.delete('$_base/$projectId/members/$userId');
  }

  @override
  Future<List<ProjectInvitationModel>> getPendingInvitations() async {
    final response = await _dioClient.get('$_base/invitations/pending');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ProjectInvitationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is List<dynamic>) {
      return data
          .map((e) => ProjectInvitationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> acceptInvitation(String memberId) async {
    await _dioClient.post('$_base/invitations/$memberId/accept');
  }

  @override
  Future<void> rejectInvitation(String memberId) async {
    await _dioClient.post('$_base/invitations/$memberId/reject');
  }
}
