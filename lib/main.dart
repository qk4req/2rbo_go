import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';



import 'bloc/turbo_go_bloc.dart';
import 'bloc/turbo_go_event.dart';
import 'bloc/turbo_go_state.dart';
import 'models/driver_model.dart';
import 'models/order_model.dart';
import 'models/tariff_model.dart';
import 'screens/main_screen.dart';

const String appKey = '977848b3a1f6b221cb218a96aa750265';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DriverModelAdapter());
  Hive.registerAdapter(OrderModelAdapter());
  Hive.registerAdapter(TariffModelAdapter());

  //await Hive.deleteBoxFromDisk('client');
  await Hive.deleteBoxFromDisk('drivers');
  await Hive.deleteBoxFromDisk('orders');
  await Hive.deleteBoxFromDisk('tariffs');

  await Hive.openBox('client');
  await Hive.openBox<DriverModel>('drivers');
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
            )
          ),
          home: const MainScreen()
      )
    );
  }
}