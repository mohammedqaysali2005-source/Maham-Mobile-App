import 'package:equatable/equatable.dart';
import '../../data/models/project_model.dart';
import '../../data/models/project_invitation_model.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectsLoading extends ProjectState {}

class ProjectsLoaded extends ProjectState {
  final List<ProjectModel> projects;
  const ProjectsLoaded(this.projects);
  @override
  List<Object?> get props => [projects];
}

class ProjectDetailLoading extends ProjectState {}

class ProjectDetailLoaded extends ProjectState {
  final ProjectModel project;
  const ProjectDetailLoaded(this.project);
  @override
  List<Object?> get props => [project];
}

class ProjectActionInProgress extends ProjectState {}

class ProjectActionSuccess extends ProjectState {
  final String message;
  final List<ProjectModel>? updatedProjects;
  const ProjectActionSuccess(this.message, {this.updatedProjects});
  @override
  List<Object?> get props => [message, updatedProjects];
}

class ProjectFailure extends ProjectState {
  final String message;
  const ProjectFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PendingInvitationsLoaded extends ProjectState {
  final List<ProjectInvitationModel> invitations;
  const PendingInvitationsLoaded(this.invitations);
  @override
  List<Object?> get props => [invitations];
}
