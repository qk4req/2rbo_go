import 'package:equatable/equatable.dart';
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
  final Point point;

  TurboGoEndOfLocationChangeEvent(this.point);
}



class TurboGoHomeEvent extends TurboGoEvent {
  @override
  List<Object?> get props => [];
}



class TurboGoDriverEvent extends TurboGoEvent {
  @override
  List<Object?> get props => [];
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
  final String? value;

  const TurboGoFindEndPointsEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class TurboGoTariffsEvent extends TurboGoEvent {
  final int? tariffId;

  const TurboGoTariffsEvent([this.tariffId]);

  @override
  List<Object?> get props => [tariffId];
}



class TurboGoSearchEvent extends TurboGoEvent {
  @override
  List<Object?> get props => [];
}



class TurboGoAddClientDataEvent extends TurboGoEvent {
  final String? phoneNumber;

  const TurboGoAddClientDataEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}
