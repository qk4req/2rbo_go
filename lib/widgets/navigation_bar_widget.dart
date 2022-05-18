import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/drivers_online_model.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/bloc/turbo_go_event.dart';
import '/controllers/driver_controller.dart';
import '/controllers/drivers_online_controller.dart';
import '/controllers/timestamp_controller.dart';
import '/models/driver_model.dart';
import '/models/order_model.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  final DriverController _driver = TurboGoBloc.driverController;
  final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  //final TimestampController _timestamp = TurboGoBloc.timestampController!;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
      child: BlocBuilder<TurboGoBloc, TurboGoState>(
        builder: (BuildContext ctx, TurboGoState state) {
          return ValueListenableBuilder(
              valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
              builder: (ctx, Box<OrderModel> box, wid) {
                OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey)!;

                return Container(
                  child:
                  newOrder.from == null ?
                    null :
                    BlocBuilder<TurboGoBloc, TurboGoState>(
                        builder: (ctx, state) {
                          if (
                          ![TurboGoLocationHasChangedState, TurboGoHomeState, TurboGoDriverState, TurboGoSearchState].contains(state.runtimeType)
                          ) {
                            switch (state.runtimeType) {
                              case TurboGoPointsState:
                                return _button(
                                    Text(
                                      ((newOrder.whither == null) ? 'Скажу водителю' : 'Далее'),
                                      style: const TextStyle(
                                          fontSize: 18
                                      ),
                                    ),
                                    true,
                                    () {
                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoSelectTariffEvent());
                                    }
                                );
                              case TurboGoTariffsState:
                                return ValueListenableBuilder(
                                    valueListenable: _driversOnline.repo.listenable(),
                                    builder: (BuildContext ctx, Box<DriversOnlineModel> bx, wid) {
                                      if (
                                        bx.values.where((DriversOnlineModel d) {
                                          return _driver.isOnline(d.driverId) && _driver.getById(d.driverId)!.car['tariffId'] == newOrder.tariffId;
                                        }).isNotEmpty
                                      ) {
                                        return _button(
                                          const Text('Заказать'),
                                          true,
                                          () {
                                            BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindDriverEvent());
                                          }
                                        );
                                      } else {
                                        return _button(
                                            const Text(
                                                'Нет доступных машин',
                                                textAlign: TextAlign.center
                                            ),
                                            false
                                        );
                                      }
                                    }
                                );
                            }
                          }
                          return Container();
                        }
                    ),
                );
              }
          );
        },
      ),
    );
  }

  Widget _button(
      Widget child,
      [
        bool enabled = true,
        void Function()? onPressed
      ]
  ) {
    return OutlinedButton(
      style: ButtonStyle(
        splashFactory: enabled ? InkRipple.splashFactory : NoSplash.splashFactory,
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
        maximumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width * 0.8
        ), 60)),
        backgroundColor: MaterialStateProperty.all(Colors.black38),
      ),
      onPressed: enabled ? onPressed : () {},
      child: Row(
        children: <Widget>[
          Expanded(child: child),
          Container(
            child: enabled ? Row(
              children: [
                Container(
                  color: Colors.black38,
                  height: 50,
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                const Icon(
                  Icons.arrow_forward_outlined,
                )
              ],
            ) : null,
          )
        ],
      ),
    );
  }
}