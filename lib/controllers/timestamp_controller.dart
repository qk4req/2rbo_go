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
    if (_serverOffset != null) {
      DateTime now = DateTime.now().toUtc();
      //if (_serverOffset!.isNegative) {
      //  now.subtract(_serverOffset!);
      //} else {
      //  now.add(_serverOffset!);
      //}
      if (_serverOffset != null) {
        now.add(_serverOffset!);
      }

      return(now);
    } else {
      DateTime now = DateTime.now().toUtc();

      if (_networkOffset != null) {
        now.add(_networkOffset!);
      }

      return(now);
    }
  }
}