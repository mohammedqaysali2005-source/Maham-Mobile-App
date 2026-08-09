import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/project_model.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_sheet.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProjectBloc>()..add(ProjectsLoadRequested()),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          if (state.updatedProjects != null) {
            // Bloc already emits refreshed list via updatedProjects
          }
        }
        if (state is ProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProjectsLoading || state is ProjectActionInProgress) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        List<ProjectModel> projects = [];
        if (state is ProjectsLoaded) projects = state.projects;
        if (state is ProjectActionSuccess && state.updatedProjects != null) {
          projects = state.updatedProjects!;
        }

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            context.read<ProjectBloc>().add(ProjectsLoadRequested());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: projects.isEmpty
              ? _buildEmpty(context)
              : _buildList(context, projects),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(Icons.folder_open_rounded,
                  size: 80, color: AppColors.border),
              const SizedBox(height: AppSizes.md),
              const Text(
                'لا توجد مشاريع بعد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'اضغط + لإنشاء مشروعك الأول',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton.icon(
                onPressed: () => _showCreateSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إنشاء مشروع',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<ProjectModel> projects) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (ctx, i) => ProjectCard(
        project: projects[i],
        onEdit: () => _showEditSheet(context, projects[i]),
        onDelete: () => _confirmDelete(context, projects[i]),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    final bloc = context.read<ProjectBloc>();
    ProjectFormSheet.show(
      context: context,
      onSubmit: (name, desc) {
        bloc.add(ProjectCreateRequested(name: name, description: desc));
      },
    );
  }

  void _showEditSheet(BuildContext context, ProjectModel project) {
    final bloc = context.read<ProjectBloc>();
    ProjectFormSheet.show(
      context: context,
      title: 'تعديل المشروع',
      initialName: project.name,
      initialDesc: project.description,
      onSubmit: (name, desc) {
        bloc.add(ProjectUpdateRequested(
          projectId: project.id,
          name: name,
          description: desc,
        ));
      },
    );
  }

  void _confirmDelete(BuildContext context, ProjectModel project) {
    final bloc = context.read<ProjectBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('حذف المشروع',
            style: TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف مشروع "${project.name}"؟ لا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(
                    fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(ProjectDeleteRequested(project.id));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
