import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object?> get props => [];
}

class ProjectsLoadRequested extends ProjectEvent {}

class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String? description;

  const ProjectCreateRequested({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class ProjectUpdateRequested extends ProjectEvent {
  final String projectId;
  final String name;
  final String? description;

  const ProjectUpdateRequested({
    required this.projectId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [projectId, name, description];
}

class ProjectDeleteRequested extends ProjectEvent {
  final String projectId;

  const ProjectDeleteRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ProjectDetailLoadRequested extends ProjectEvent {
  final String projectId;

  const ProjectDetailLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class PendingInvitationsLoadRequested extends ProjectEvent {}

class InvitationAcceptRequested extends ProjectEvent {
  final String memberId;
  const InvitationAcceptRequested(this.memberId);
  @override
  List<Object?> get props => [memberId];
}

class InvitationRejectRequested extends ProjectEvent {
  final String memberId;
  const InvitationRejectRequested(this.memberId);
  @override
  List<Object?> get props => [memberId];
}
