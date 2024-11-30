import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_shop/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:coffee_shop/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:coffee_shop/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:coffee_shop/features/dashboard/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:coffee_shop/features/home/home_page.dart';
import 'package:coffee_shop/features/dashboard/pages/todays_special_page.dart';
import 'package:coffee_shop/features/profile/profile_page.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final List<Widget> _pages = [
    const HomePage(),
    const TodaySpecialPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const DashboardAppBar(),
            body: _pages[state.selectedIndex],
            bottomNavigationBar: DashboardBottomNav(
              currentIndex: state.selectedIndex,
              onTap: (index) =>
                  context.read<DashboardCubit>().updateSelectedIndex(index),
            ),
          );
        },
      ),
    );
  }
}
