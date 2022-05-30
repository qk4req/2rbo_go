import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/models/driver_model.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/bloc/turbo_go_event.dart';
import '/controllers/driver_controller.dart';
import '/controllers/drivers_online_controller.dart';
import '/models/order_model.dart';
import '/models/drivers_online_model.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  final DriverController _driver = TurboGoBloc.driverController;
  final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  final OrderController _order = TurboGoBloc.orderController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
      child: BlocBuilder<TurboGoBloc, TurboGoState>(
        builder: (BuildContext ctx, TurboGoState state) {
          return ValueListenableBuilder(
              valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [_order.last?.uuid]),
              builder: (ctx, Box<OrderModel> box, Widget? wid) {
                OrderModel? last = box.get(_order.last?.uuid);

                return last != null ? Container(
                  child:
                  last.from == null ?
                  null :
                  BlocBuilder<TurboGoBloc, TurboGoState>(
                      builder: (ctx, state) {
                        if (
                        ![TurboGoLocationHasChangedState, TurboGoHomeState, TurboGoSearchState].contains(state.runtimeType)
                        ) {
                          switch (state.runtimeType) {
                            case TurboGoPointsState:
                              return _button(
                                  Text(
                                    ((last.whither == null) ? 'Скажу водителю' : 'Далее'),
                                    style: const TextStyle(
                                        fontSize: 18
                                    ),
                                  ),
                                  true,
                                      () {
                                    BlocProvider.of<TurboGoBloc>(context).add(const TurboGoTariffsEvent());
                                  }
                              );
                            case TurboGoTariffsState:
                              return ValueListenableBuilder(
                                  valueListenable: _driversOnline.repo.listenable(),
                                  builder: (BuildContext ctx, Box<DriversOnlineModel> bx, wid) {
                                    if (
                                    bx.values.where((DriversOnlineModel d) {
                                      return d.isOnline() && d.checkAvailability() && _driver.getById(d.driverId)?.car['tariffId'] == last.tariffId;
                                    }).isNotEmpty
                                    ) {
                                      return _button(
                                          const Text(
                                              'Заказать',
                                              style: TextStyle(
                                                  fontSize: 18
                                              )
                                          ),
                                          true,
                                              () {
                                            BlocProvider.of<TurboGoBloc>(context).add(TurboGoSearchEvent());
                                          }
                                      );
                                    } else {
                                      return _button(
                                          const Text(
                                              'Нет доступных машин',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 18
                                              )
                                          ),
                                          false
                                      );
                                    }
                                  }
                              );
                            case TurboGoDriverState:
                            //TurboGoDriverState _state = state as TurboGoDriverState;

                              return (
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Wrap(
                                          children: [
                                            ValueListenableBuilder(
                                                valueListenable: _driver.repo.listenable(keys: [_order.last?.driverId]),
                                                builder: (BuildContext ctx, Box<DriverModel> bx, wid) {
                                                  DriverModel d = bx.get(_order.last?.driverId)!;

                                                  return ElevatedButton(
                                                    onPressed: () async {
                                                      print(d);
                                                      await FlutterPhoneDirectCaller.callNumber(d.phoneNumber);
                                                    },
                                                    child: const Icon(
                                                      Icons.phone,
                                                      color: Colors.black,
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.green,
                                                      shape: const CircleBorder(),
                                                      padding: const EdgeInsets.all(15),
                                                    ),
                                                  );
                                                }
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                              );
                          }
                        }
                        return Container();
                      }
                  ),
                ) : Container();
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