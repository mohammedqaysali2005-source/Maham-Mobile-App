import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../features/shell/widgets/app_drawer.dart';
import '../../features/shell/widgets/bottom_nav_bar.dart';
import '../../features/shell/widgets/sheet_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../projects/presentation/bloc/project_bloc.dart';
import '../projects/presentation/bloc/project_event.dart';
import '../projects/presentation/screens/invitations_screen.dart';
import '../projects/presentation/widgets/project_form_sheet.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _currentIndex {
    final loc = widget.location;
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/projects')) return 1;
    if (loc.startsWith('/tasks')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  String get _currentTitle {
    switch (_currentIndex) {
      case 0:
        return AppStrings.home;
      case 1:
        return AppStrings.projects;
      case 2:
        return AppStrings.tasks;
      case 3:
        return AppStrings.profile;
      default:
        return AppStrings.appName;
    }
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/tasks');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _onFabPressed() {
    if (_currentIndex == 1) {
      ProjectFormSheet.show(
        context: context,
        onSubmit: (name, desc) {
          sl<ProjectBloc>().add(
            ProjectCreateRequested(name: name, description: desc),
          );
        },
      );
    } else {
      SheetModal.show(
        context: context,
        title: _getFabTitle(),
        content: _getFabContent(),
      );
    }
  }

  String _getFabTitle() {
    switch (_currentIndex) {
      case 1:
        return 'إضافة مشروع جديد';
      case 2:
        return 'إضافة مهمة جديدة';
      default:
        return 'إضافة';
    }
  }

  Widget _getFabContent() {
    return const Column(
      children: [
        SizedBox(height: AppSizes.sm),
        Text(
          'يمكنك إدارة هذه الميزة من شاشات الكانبان المخصصة',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Cairo',
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.md),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: AppDrawer(scaffoldKey: _scaffoldKey),
      body: widget.child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: _shouldShowFab ? _buildFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool get _shouldShowFab => _currentIndex == 1 || _currentIndex == 2;

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'القائمة الجانبية',
      ),
      title: Text(
        _currentTitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w800,
          fontSize: 19,
          color: Colors.white,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => BlocProvider.value(
                  value: sl<ProjectBloc>(),
                  child: const InvitationsScreen(),
                ),
              ),
            );
          },
          tooltip: 'دعوات الانضمام',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        onPressed: _onFabPressed,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
