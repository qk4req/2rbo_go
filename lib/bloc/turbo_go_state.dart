import 'package:equatable/equatable.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/models/driver_model.dart';
import 'package:turbo_go/models/order_model.dart';

abstract class TurboGoState extends Equatable {
}

class TurboGoInitState extends TurboGoState {
  @override
  List<Object> get props => [];
}

class TurboGoConnectedState extends TurboGoState {
  @override
  List<Object?> get props => [];
}

class TurboGoNotConnectedState extends TurboGoState {
  @override
  List<Object?> get props => [];
}

class TurboGoRegState extends TurboGoState {
  @override
  List<Object?> get props => [];
}



class TurboGoLocationHasChangedState extends TurboGoConnectedState {
  final TurboGoState prevState;

  TurboGoLocationHasChangedState(this.prevState);
}

//class TurboGoLocationHasNotChangedState extends TurboGoConnectedState {
//}

class TurboGoHomeState extends TurboGoConnectedState {
  bool reset = true;

  TurboGoHomeState(
      [this.reset = true]
  );
}

class TurboGoPointsState extends TurboGoConnectedState {
  LocationType type = LocationType.end;

  TurboGoPointsState(
      [this.type = LocationType.end]
  );
}

enum LocationType {
  start,
  end
}

class TurboGoTariffsState extends TurboGoConnectedState {}

class TurboGoSearchState extends TurboGoConnectedState {}

class TurboGoDriverState extends TurboGoConnectedState {
  //late final OrderModel order;
  //late final DriverModel driver;

  TurboGoDriverState() {
    //order = TurboGoBloc.orderController.last!;
    //driver = TurboGoBloc.driverController.getById(order.driverId!)!;
  }
}

class TurboGoChatState extends TurboGoConnectedState {}

/*
class TurboNotAuthState extends TurboState {
  @override
  List<Object> get props => [];
}

class TurboNotAuthErrorState extends TurboNotAuthState {
  final String errorText;

  TurboNotAuthErrorState({
    required this.errorText
  });

  @override
  List<Object> get props => [errorText];
}

class TurboAuthState extends TurboState {
  @override
  List<Object> get props => [];
}

class TurboAuthErrorState extends TurboAuthState {
  final String errorText;

  TurboAuthErrorState({
    required this.errorText
  });

  @override
  List<Object> get props => [errorText];
}
*/
