import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/models/clients_online_model.dart';
import 'bloc/turbo_go_bloc.dart';
import 'bloc/turbo_go_event.dart';
import 'bloc/turbo_go_state.dart';
import 'models/driver_model.dart';
import 'models/drivers_online_model.dart';
import 'models/tariff_model.dart';
import 'models/order_model.dart';
import 'screens/main_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ClientsOnlineModelAdapter());
  Hive.registerAdapter(DriverModelAdapter());
  Hive.registerAdapter(DriversOnlineModelAdapter());
  Hive.registerAdapter(TariffModelAdapter());
  Hive.registerAdapter(OrderModelAdapter());

  //await Hive.deleteBoxFromDisk('client');
  await Hive.deleteBoxFromDisk('drivers');
  await Hive.deleteBoxFromDisk('drivers_online');
  await Hive.deleteBoxFromDisk('orders');
  await Hive.deleteBoxFromDisk('tariffs');

  await Hive.openBox('client');
  await Hive.openBox<ClientsOnlineModel>('clients_online');
  await Hive.openBox<DriverModel>('drivers');
  await Hive.openBox<DriversOnlineModel>('drivers_online');
  await Hive.openBox<OrderModel>('orders');
  await Hive.openBox<TariffModel>('tariffs');

  return runApp(MultiBlocProvider(providers: [
    BlocProvider<TurboGoBloc>(
      create: (context) => TurboGoBloc(TurboGoInitState())..add(TurboGoStartEvent()),
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return BlocListener<TurboGoBloc, TurboGoState>(
    listener: (BuildContext ctx, state) {

    },
    child: MaterialApp(
          title: 'Turbo.Go',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Oswald',
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  primary: Colors.white
                )
            ),
              textTheme: const TextTheme(
                  subtitle1: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400
                  ),
                  subtitle2: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400
                  ),
                  headline5: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w400,
                  ),
                  headline6: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  )
              ).apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white
              )
          ),
          home: const MainScreen()
      )
    );
  }
}
