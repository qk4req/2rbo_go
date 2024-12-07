import 'package:equatable/equatable.dart';
import 'package:turbo_go/bloc/turbo_go_state.dart';
import 'package:turbo_go/controllers/geocoder_controller.dart';
import 'package:version/version.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class TurboGoEvent {
  const TurboGoEvent();
}

class TurboGoStartEvent extends TurboGoEvent {
  //@override
  //List<Object?> get props => [];
}



abstract class TurboGoMapEvent extends TurboGoEvent {
  //@override
  //List<Object?> get props => [];
}

class TurboGoStartOfLocationChangeEvent extends TurboGoMapEvent {}

class TurboGoEndOfLocationChangeEvent extends TurboGoMapEvent {
  final Point point;

  TurboGoEndOfLocationChangeEvent(this.point);
}



class TurboGoNotSupportedEvent extends TurboGoEvent {
  final Version current;
  final Version required;
  //final List? releaseNotes;
  final String upgradeUrl;

  const TurboGoNotSupportedEvent(
      this.current, this.required/*, this.releaseNotes*/, this.upgradeUrl
  );

  //@override
  //List<Object?> get props => [];
}

class TurboGoUpgradeAppEvent extends TurboGoEvent {
  final String upgradeUrl;

  const TurboGoUpgradeAppEvent(
      this.upgradeUrl
  );

  //@override
  //List<Object?> get props => [];
}

class TurboGoHomeEvent extends TurboGoEvent {
  //@override
  //List<Object?> get props => [];
}



class TurboGoDriverEvent extends TurboGoEvent {
  //@override
  //List<Object?> get props => [];
}



class TurboGoChangePointEvent extends TurboGoEvent {
  Map point;
  CoordinateTypes type = CoordinateTypes.whither;

  TurboGoChangePointEvent(
      this.point, [this.type = CoordinateTypes.whither]
  );
  //@override
  //List<Object?> get props => [];
}

class TurboGoStartPointEvent extends TurboGoEvent/* extends TurboGoChangePointEvent*/ {
  //@override
  //List<Object?> get props => [];
}

class TurboGoEndPointEvent extends TurboGoEvent/* extends TurboGoChangePointEvent*/ {
  //@override
  //List<Object?> get props => [];
}



class TurboGoFindPointsEvent extends TurboGoEvent {
  final String? value;

  const TurboGoFindPointsEvent(this.value);

  //@override
  //List<Object?> get props => [value];
}

/*class TurboGoAddPointEvent extends TurboGoEvent {
  @override
  List<Object?> get props => [];
}*/

class TurboGoTariffsEvent extends TurboGoEvent {
  final int? tariffId;

  const TurboGoTariffsEvent([this.tariffId]);

  //@override
  //List<Object?> get props => [tariffId];
}



class TurboGoSearchEvent extends TurboGoEvent {
  //final bool isFirst;

  /*const TurboGoSearchEvent([this.isFirst = true]);*/

  //@override
  //List<Object?> get props => [/*isFirst*/];
}

class TurboGoCancelOrderEvent extends TurboGoEvent {
}

class TurboGoSignUpEvent extends TurboGoEvent {
  final String phoneNumber;

  const TurboGoSignUpEvent(this.phoneNumber);

  //@override
  //List<Object?> get props => [phoneNumber];
}



class TurboGoBackEvent extends TurboGoEvent {
  final TurboGoState prevState;

  const TurboGoBackEvent(this.prevState);
}
