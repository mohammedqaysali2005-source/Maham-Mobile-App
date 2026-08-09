import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_event.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../projects/presentation/widgets/project_form_sheet.dart';
import '../../../projects/presentation/screens/invitations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProjectBloc>()..add(ProjectsLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ));
        }
        if (state is ProjectFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ));
        }
      },
      builder: (context, state) {
        List<ProjectModel> projects = [];
        if (state is ProjectsLoaded) projects = state.projects;
        if (state is ProjectActionSuccess && state.updatedProjects != null) {
          projects = state.updatedProjects!;
        }
        final isLoading =
            state is ProjectsLoading || state is ProjectActionInProgress;

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            context.read<ProjectBloc>().add(ProjectsLoadRequested());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeCard(),
                const SizedBox(height: 16),
                _StatsRow(projects: projects, isLoading: isLoading),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'المشاريع النشطة',
                  onSeeAll: () => context.go('/projects'),
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (projects.isEmpty)
                  _buildEmptyProjects(context)
                else
                  _buildRecentProjects(context, projects.take(4).toList()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyProjects(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded,
                size: 36, color: AppColors.accent),
          ),
          const SizedBox(height: 14),
          const Text(
            'لا توجد مشاريع مضافة بعد',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ابدأ بإنشاء مشروعك الأول لتنظيم المهام وتوزيع العمل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              final bloc = context.read<ProjectBloc>();
              ProjectFormSheet.show(
                context: context,
                onSubmit: (name, desc) {
                  bloc.add(
                      ProjectCreateRequested(name: name, description: desc));
                },
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('إنشاء مشروع جديد'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjects(
      BuildContext context, List<ProjectModel> projects) {
    final bloc = context.read<ProjectBloc>();
    return Column(
      children: [
        ...projects.map((p) => ProjectCard(
              project: p,
              onEdit: () => ProjectFormSheet.show(
                context: context,
                title: 'تعديل المشروع',
                initialName: p.name,
                initialDesc: p.description,
                onSubmit: (name, desc) => bloc.add(ProjectUpdateRequested(
                    projectId: p.id, name: name, description: desc)),
              ),
              onDelete: () => _confirmDelete(context, bloc, p),
            )),
        if (context
                .read<ProjectBloc>()
                .state is ProjectsLoaded &&
            (context.read<ProjectBloc>().state as ProjectsLoaded)
                    .projects
                    .length >
                4)
          Center(
            child: TextButton.icon(
              onPressed: () => context.go('/projects'),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('عرض جميع المشاريع',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, ProjectBloc bloc, ProjectModel project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف المشروع',
            style: TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w800),
            textAlign: TextAlign.right),
        content: Text('هل أنت متأكد من حذف "${project.name}"؟ سيتم حذف جميع اللوحات والبطاقات التابعة له.',
            style: const TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(ProjectDeleteRequested(project.id));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تأكيد الحذف',
                style: TextStyle(
                    fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is Authenticated
        ? authState.user.fullName.split(' ').first
        : 'بك';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'منظومة مهام المؤسسية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أهلاً بك، $userName 👋',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'تتبّع سير أعمالك ولوحات الكانبان بكل سلاسة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Notification Bell with Glow
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_active_rounded,
                  color: Colors.amber, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => BlocProvider.value(
                      value: context.read<ProjectBloc>(),
                      child: const InvitationsScreen(),
                    ),
                  ),
                );
              },
              tooltip: 'دعوات المشاريع والتنبيهات',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<ProjectModel> projects;
  final bool isLoading;

  const _StatsRow({required this.projects, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final totalBoards =
        projects.fold<int>(0, (sum, p) => sum + p.boardCount);
    final totalMembers =
        projects.fold<int>(0, (sum, p) => sum + p.memberCount);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'المشاريع',
            value: isLoading ? '...' : '${projects.length}',
            icon: Icons.folder_rounded,
            color: AppColors.accent,
            bgColor: AppColors.accentLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'اللوحات',
            value: isLoading ? '...' : '$totalBoards',
            icon: Icons.grid_3x3_rounded,
            color: AppColors.info,
            bgColor: AppColors.infoLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'الأعضاء',
            value: isLoading ? '...' : '$totalMembers',
            icon: Icons.people_alt_rounded,
            color: AppColors.warning,
            bgColor: AppColors.warningLight,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'عرض الكل',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
