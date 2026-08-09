import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _repository;

  ProjectBloc({required ProjectRepository repository})
      : _repository = repository,
        super(ProjectInitial()) {
    on<ProjectsLoadRequested>(_onProjectsLoad);
    on<ProjectCreateRequested>(_onProjectCreate);
    on<ProjectUpdateRequested>(_onProjectUpdate);
    on<ProjectDeleteRequested>(_onProjectDelete);
    on<ProjectDetailLoadRequested>(_onProjectDetailLoad);
    on<PendingInvitationsLoadRequested>(_onPendingInvitationsLoad);
    on<InvitationAcceptRequested>(_onInvitationAccept);
    on<InvitationRejectRequested>(_onInvitationReject);
  }

  Future<void> _onProjectsLoad(
    ProjectsLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectsLoading());
    try {
      final projects = await _repository.getMyProjects();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onProjectDetailLoad(
    ProjectDetailLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectDetailLoading());
    try {
      final project = await _repository.getProjectById(event.projectId);
      emit(ProjectDetailLoaded(project));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onProjectCreate(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      await _repository.createProject(
        name: event.name,
        description: event.description,
      );
      final projects = await _repository.getMyProjects();
      emit(ProjectActionSuccess('تم إنشاء المشروع بنجاح', updatedProjects: projects));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onProjectUpdate(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      await _repository.updateProject(
        projectId: event.projectId,
        name: event.name,
        description: event.description,
      );
      final projects = await _repository.getMyProjects();
      emit(ProjectActionSuccess('تم تعديل المشروع بنجاح', updatedProjects: projects));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onProjectDelete(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      await _repository.deleteProject(event.projectId);
      final projects = await _repository.getMyProjects();
      emit(ProjectActionSuccess('تم حذف المشروع', updatedProjects: projects));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onPendingInvitationsLoad(
    PendingInvitationsLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectsLoading());
    try {
      final invitations = await _repository.getPendingInvitations();
      emit(PendingInvitationsLoaded(invitations));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onInvitationAccept(
    InvitationAcceptRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      await _repository.acceptInvitation(event.memberId);
      final projects = await _repository.getMyProjects();
      emit(ProjectActionSuccess('تم قبول الدعوة والانضمام بنجاح', updatedProjects: projects));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  Future<void> _onInvitationReject(
    InvitationRejectRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      await _repository.rejectInvitation(event.memberId);
      emit(const ProjectActionSuccess('تم رفض الدعوة'));
    } catch (e) {
      emit(ProjectFailure(_cleanError(e)));
    }
  }

  String _cleanError(Object e) =>
      e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
}
