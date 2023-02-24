import 'package:flutter/material.dart';
import 'package:version/version.dart';

abstract class TurboGoState extends ValueNotifier/* extends Equatable*/ {
  TurboGoState(value) : super(value);
}

class TurboGoInitState extends TurboGoState {
  TurboGoInitState() : super(null);
  //@override
  //List<Object> get props => [];
}

class TurboGoConnectedState extends TurboGoState {
  TurboGoConnectedState(value) : super(null);
  //@override
  //List<Object?> get props => [];
}

class TurboGoNotConnectedState extends TurboGoState {
  TurboGoNotConnectedState() : super(null);
  //@override
  //List<Object?> get props => [];
}

class TurboGoNotSupportedState extends TurboGoState {
  final Version current;
  final Version required;
  //final List? releaseNotes;
  final String upgradeUrl;

  TurboGoNotSupportedState(
      this.current, this.required/*, this.releaseNotes*/, this.upgradeUrl
  ) : super(null);
}

class TurboGoBannedState extends TurboGoState {
  TurboGoBannedState() : super(null);
}

class TurboGoRegState extends TurboGoState {
  TurboGoRegState() : super(null);
  //@override
  //List<Object?> get props => [];
}

class TurboGoLocationHasChangedState extends TurboGoConnectedState {
  final TurboGoState prevState;

  TurboGoLocationHasChangedState(this.prevState) : super(null);
}

class TurboGoHomeState extends TurboGoConnectedState {
  bool reset = true;
  //final bool reset;

  TurboGoHomeState(
      [this.reset = true]
  ) : super(null);
}

class TurboGoPointsState extends TurboGoConnectedState {
  LocationTypes type = LocationTypes.end;
  List<bool> loaders = [false, false];
  //List<Map?> hints = [null, null];

  TurboGoPointsState(
      [this.type = LocationTypes.end, List<bool>? l/*, List<Map?>? h*/]
  ) : super(null) {
    loaders = l ?? [false, false];
    //hints = h ?? [null, null];
  }
}

enum LocationTypes {
  start,
  end
}

class TurboGoTariffsState extends TurboGoConnectedState {
  TurboGoTariffsState() : super(null);
}

class TurboGoSearchState extends TurboGoConnectedState {
  late bool fromReg;

  TurboGoSearchState(
    a, [bool b = false]
      ) : super(a) {
    value = a;
    fromReg = b;
  }
}

class TurboGoDriverState extends TurboGoConnectedState {
  //late final OrderModel order;
  //late final DriverModel driver;

  TurboGoDriverState() : super(null) {
    //order = TurboGoBloc.orderController.last!;
    //driver = TurboGoBloc.driverController.getById(order.driverId!)!;
  }
}

class TurboGoChatState extends TurboGoConnectedState {
  TurboGoChatState() : super(null);
}

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
