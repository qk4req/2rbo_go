import 'package:ntp/ntp.dart';
import 'package:socket_io_client/socket_io_client.dart';



import '../bloc/turbo_go_bloc.dart';

class TimestampController {
  final Socket _socket = TurboGoBloc.socket;
  Duration? _serverOffset;
  Duration? _networkOffset;

  TimestampController() {
    determine();
  }

  determine() async {
    _socket.on('_', (vars) {
      DateTime now = DateTime.now().toUtc();
      _serverOffset = now.difference(DateTime.parse(vars['datetime']));
    });
    _networkOffset = Duration(milliseconds: await NTP.getNtpOffset());
  }

  DateTime create() {
    DateTime now = DateTime.now().toUtc();
    if (_networkOffset != null) {
      return(now.add(_networkOffset!));
    } else if (_serverOffset != null) {
      if (_serverOffset!.isNegative) {
        return(now.add(_serverOffset!));
      } else {
        return(now.subtract(_serverOffset!));
      }
    } else {
      return (now);
    }
  }
}