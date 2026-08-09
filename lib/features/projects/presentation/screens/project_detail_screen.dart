import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/board_model.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/board_state.dart';
import '../widgets/board_form_sheet.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<BoardBloc>()..add(BoardsLoadRequested(projectId)),
      child: _ProjectDetailView(projectId: projectId),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  final String projectId;

  const _ProjectDetailView({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحات المشروع', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/projects'),
        ),
      ),
      body: BlocConsumer<BoardBloc, BoardState>(
        listener: (context, state) {
          if (state is BoardActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ));
          }
          if (state is BoardFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          if (state is BoardsLoading || state is BoardActionInProgress) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          List<BoardModel> boards = [];
          if (state is BoardsLoaded) boards = state.boards;

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async {
              context.read<BoardBloc>().add(BoardsLoadRequested(projectId));
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: boards.isEmpty ? _buildEmpty(context) : _buildList(context, boards),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(Icons.dashboard_customize_rounded, size: 80, color: AppColors.border),
              const SizedBox(height: AppSizes.md),
              const Text(
                'لا توجد لوحات عمل بعد',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'انقر على الزر لإضافة لوحة كانبان جديدة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<BoardModel> boards) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: boards.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (ctx, i) {
        final b = boards[i];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
            leading: CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha: 0.1),
              child: const Icon(Icons.dashboard_rounded, color: AppColors.accent),
            ),
            title: Text(
              b.name,
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              b.description ?? 'لا يوجد وصف للوحة',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditSheet(context, b);
                if (val == 'delete') _confirmDelete(context, b);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              context.push('/projects/$projectId/boards/${b.id}');
            },
          ),
        );
      },
    );
  }

  void _showCreateSheet(BuildContext context) {
    final bloc = context.read<BoardBloc>();
    BoardFormSheet.show(
      context: context,
      onSubmit: (name, desc) {
        bloc.add(BoardCreateRequested(projectId: projectId, name: name, description: desc));
      },
    );
  }

  void _showEditSheet(BuildContext context, BoardModel board) {
    final bloc = context.read<BoardBloc>();
    BoardFormSheet.show(
      context: context,
      title: 'تعديل اللوحة',
      initialName: board.name,
      initialDesc: board.description,
      onSubmit: (name, desc) {
        bloc.add(BoardUpdateRequested(boardId: board.id, name: name, description: desc));
      },
    );
  }

  void _confirmDelete(BuildContext context, BoardModel board) {
    final bloc = context.read<BoardBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('حذف اللوحة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        content: Text('هل أنت متأكد من حذف لوحة "${board.name}"؟', style: const TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(BoardDeleteRequested(boardId: board.id, projectId: projectId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
