import 'package:ntp/ntp.dart';



import '../bloc/turbo_go_bloc.dart';

extension Timestamp on DateTime {
  static String fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String toTimestamp() {
    String _year = fourDigits(year);
    String _month = twoDigits(month);
    String _day = twoDigits(day);
    String _hour = twoDigits(hour);
    String _minute = twoDigits(minute);
    String _second = twoDigits(second);

    if (isUtc) {
      return "$_year-$_month-${_day}T$_hour:$_minute:${_second}Z";
    } else {
      return "$_year-$_month-${_day}T$_hour:$_minute:$_second";
    }
  }
}

class TimestampController {
  /*static Socket socket = io(
      TurboWorkBloc.apiUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          //.enableAutoConnect()
          .enableReconnection()
          .setTimeout(3000)
          .build()
  );*/
  static Duration? serverOffset;
  static Duration? networkOffset;

  TimestampController() {
    determine();
  }

  void determine() async {
    /*socket.connect();
    socket.onConnect((_) {
      socket.emit('timesync');
      socket.on('timesync', (data) {
        DateTime now = DateTime.now().toUtc();
        serverOffset = now.difference(DateTime.parse(data['datetime']));
      });
    });*/
    TurboGoBloc.mainSocket.on('timesync', (data) {
      DateTime now = DateTime.now().toUtc();
      serverOffset = now.difference(DateTime.parse(data['datetime']));
    });
    networkOffset = Duration(milliseconds: await NTP.getNtpOffset(lookUpAddress: 'pool.ntp.org'));
  }

  DateTime create() {
    DateTime now = DateTime.now().toUtc();
    if (networkOffset != null) {
      return(now.add(networkOffset!));
    } else if (serverOffset != null) {
      if (serverOffset!.isNegative) {
        return(now.subtract(serverOffset!));
      } else {
        return(now.add(serverOffset!));
      }
    } else {
      return (now);
    }
  }
}