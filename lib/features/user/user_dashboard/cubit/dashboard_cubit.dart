import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  void updateSelectedIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
