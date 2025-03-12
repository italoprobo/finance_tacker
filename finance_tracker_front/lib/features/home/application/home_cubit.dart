import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_tracker_front/features/home/application/home_controller.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void changePage(int index) {
    HomeController.instance.pageController.jumpToPage(index);
    emit(state.copyWith(selectedIndex: index));
  }
}
