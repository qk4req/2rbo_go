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

class NavigationBarFragment extends StatefulWidget {
  const NavigationBarFragment({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavigationBarFragmentState();
}

class _NavigationBarFragmentState extends State<NavigationBarFragment> {
  final DriverController _driver = TurboGoBloc.driverController;
  final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  final OrderController _order = TurboGoBloc.orderController;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
          child: BlocBuilder<TurboGoBloc, TurboGoState>(
            builder: (BuildContext ctx, TurboGoState state) {
              if (state is TurboGoNotSupportedState) {
                return _button(
                    Center(
                        child: Text(
                          'Обновить',
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                    ),
                        () {
                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoUpgradeAppEvent(state.upgradeUrl));
                    },
                    false
                );
              }

              if (state is TurboGoNotConnectedState) {
                return _button(
                    Center(
                        child: Text(
                          'Позвонить',
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                    ),
                        () async {
                      await FlutterPhoneDirectCaller.callNumber(TurboGoBloc.dispatcherPhoneNumber);
                    },
                    false
                );
              }

              return ValueListenableBuilder(
                  valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [_order.last?.uuid]),
                  builder: (ctx, Box<OrderModel> box, Widget? wid) {
                    OrderModel? last = box.get(_order.last?.uuid);
                    List? fromCoordinates = last?.from?['coordinates'];

                    return Container(
                      child:
                      last != null &&
                          fromCoordinates is List &&
                          fromCoordinates.length == 2 &&
                          fromCoordinates[0] is double &&
                          fromCoordinates[1] is double ?
                      BlocBuilder<TurboGoBloc, TurboGoState>(
                          builder: (BuildContext ctx, TurboGoState state) {
                            if (state is TurboGoLocationHasChangedState && state.prevState is TurboGoDriverState) {
                              return _callButton();
                            }

                            if (
                            ![TurboGoLocationHasChangedState, TurboGoHomeState].contains(state.runtimeType)
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
                                              null,
                                              false
                                          );
                                        }
                                      }
                                  );
                                case TurboGoSearchState:
                                  return _roundButton(
                                      icon: Icons.close,
                                      iconColor: Colors.red,
                                      text: 'Отменить',
                                      onPressed: () {
                                        BlocProvider.of<TurboGoBloc>(context).add(TurboGoCancelOrderEvent());
                                      }
                                  );
                                case TurboGoDriverState:
                                //TurboGoDriverState _state = state as TurboGoDriverState;

                                  return (_callButton());
                              }
                            }
                            return Container();
                          }
                      ) :
                      null,
                    );
                  }
              );
            },
          ),
        )
      ],
    );
  }

  Widget _callButton() {
    return Container(
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
                        await FlutterPhoneDirectCaller.callNumber(d.phoneNumber);
                      },
                      child: const SizedBox(
                        height: 50,
                        width: 50,
                        child: Icon(
                          Icons.phone,
                          color: Colors.green,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black38,
                        shape: const CircleBorder(),
                        //padding: const EdgeInsets.all(15),
                      ),
                    );
                  }
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _button(
      Widget child,
      [
        //bool enabled = true,
        void Function()? onPressed,
        bool withArrow = true
      ]
  ) {
    return OutlinedButton(
      style: ButtonStyle(
        splashFactory: onPressed is Function ? InkRipple.splashFactory : NoSplash.splashFactory,
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
        maximumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width * 0.8
        ), 60)),
        backgroundColor: MaterialStateProperty.all(Colors.black38),
      ),
      onPressed: onPressed ?? () {},
      child: Row(
        children: <Widget>[
          Expanded(child: child),
          Container(
            child: withArrow ? Row(
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

  Widget _roundButton(
      {
        required IconData icon,
        Color iconColor = Colors.white,
        Color buttonColor = Colors.black38,
        String? text,
        Color textColor = Colors.white,
        Function()? onPressed
      }
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPressed ?? () {},
            child: SizedBox(
              height: 50,
              width: 50,
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: buttonColor,
              shape: const CircleBorder(),
              //padding: const EdgeInsets.all(15),
            ),
          ),
          Container(
              child: text != null ? Text(
                text,
                style: TextStyle(
                    color: textColor
                ),
              ) : null
          )
        ],
      ),
    );
  }
}