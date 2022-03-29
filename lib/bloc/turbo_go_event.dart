import 'package:equatable/equatable.dart';
import 'package:turbo_go/models/tariff_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class TurboGoEvent extends Equatable {
  const TurboGoEvent();
}

class TurboGoStartEvent extends TurboGoEvent {
  @override
  List<Object> get props => [];
}

abstract class TurboGoMapEvent extends TurboGoEvent {
  @override
  List<Object> get props => [];
}

class TurboGoStartOfLocationChangeEvent extends TurboGoMapEvent {}

class TurboGoEndOfLocationChangeEvent extends TurboGoMapEvent {
  Point point;

  TurboGoEndOfLocationChangeEvent(this.point);
}

abstract class TurboGoChangePointEvent extends TurboGoEvent {
  @override
  List<Object?> get props => [];
}

class TurboGoChangeStartPointEvent extends TurboGoChangePointEvent {
}

class TurboGoChangeEndPointEvent extends TurboGoChangePointEvent {
}

class TurboGoFindEndPointsEvent extends TurboGoEvent {
  String? value;

  TurboGoFindEndPointsEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class TurboGoSelectTariffEvent extends TurboGoEvent {
  int? tariffId;

  TurboGoSelectTariffEvent([this.tariffId]);

  @override
  List<Object?> get props => [tariffId];
}


/*class TurboLoginEvent extends TurboEvent {
  final String phoneNumber;
  final String password;

  const TurboLoginEvent({required this.phoneNumber, required this.password});

  @override
  List<Object> get props => [phoneNumber, password];
}



abstract class TurboOrderEvent extends TurboEvent {
  @override
  List<Object> get props => [];
}
class TurboAddOrderEvent extends TurboOrderEvent {}
class TurboStartOrderEvent extends TurboOrderEvent {}
class TurboActiveOrderEvent extends TurboOrderEvent {}
class TurboPauseOrderEvent extends TurboOrderEvent {}
class TurboFinishOrderEvent extends TurboOrderEvent {}
class TurboRefuseOrderEvent extends TurboOrderEvent {}
class TurboConfirmOrderEvent extends TurboOrderEvent {}



class TurboBackPressedEvent extends TurboEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
*/
