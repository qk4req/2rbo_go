import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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



class TurboGoLocationHasChangedState extends TurboGoConnectedState {
  TurboGoState prevState;
  TurboGoLocationHasChangedState(this.prevState);
}

//class TurboGoLocationHasNotChangedState extends TurboGoConnectedState {
//}



class TurboGoHomeState extends TurboGoConnectedState {
}

class TurboGoPointsState extends TurboGoConnectedState {
  late LocationType type = LocationType.end;

  TurboGoPointsState(
    [this.type=LocationType.end]
  );
}

enum LocationType {
  start,
  end
}

class TurboGoTariffsState extends TurboGoConnectedState {}

class TurboGoDriverState extends TurboGoConnectedState {}

class TurboGoChatState extends TurboGoConnectedState {}

class TurboGoExtendedPointsState extends TurboGoPointsState {
  late LocationType type = LocationType.end;

  TurboGoExtendedPointsState(
      this.type
  );
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
