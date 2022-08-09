import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/controllers/driver_controller.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/models/driver_model.dart';
import '/bloc/turbo_go_bloc.dart';
import '/models/order_model.dart';



class DriverSheet extends StatefulWidget {
  const DriverSheet({Key? key}) : super(key: key);

  @override
  _DriverSheetState createState() => _DriverSheetState();
}

class _DriverSheetState extends State<DriverSheet> with TickerProviderStateMixin<DriverSheet> {
  final DriverController _driver = TurboGoBloc.driverController;
  final OrderController _order = TurboGoBloc.orderController;
  late Animation<Offset> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;
  //String? _avatar;



  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(controller);
    WidgetsBinding.instance!.addPostFrameCallback((duration) {
      controller.forward();
    });

    /*_driver.repo.watch(
      key: _order.last?.driverId
    ).listen((event) {
      if (_avatar != event.value['avatar']) _avatar = event.value['avatar'];
    });*/
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _driver.repo.listenable(keys: [_order.last?.driverId]),
        builder: (BuildContext ctx, Box<DriverModel> box, wid) {
          DriverModel? d = box.get(_order.last?.driverId);

          if (d != null) {
            return SlideTransition(
                position: animation,
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.35,
                  minChildSize: 0.35,
                  maxChildSize: 0.35,
                  builder: (BuildContext ctx, ScrollController scrollController) {
                    return ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Container(
                          //padding: const EdgeInsets.all(15),
                            color: const Color.fromRGBO(32, 33, 36, 1),
                            child: NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (overScroll) {
                                overScroll.disallowIndicator();
                                return true;
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 15,
                                    bottom: 100,
                                    left: 15,
                                    right: 15
                                ),
                                color: const Color.fromRGBO(32, 33, 36, 1),
                                child: Column(
                                  children: <Widget>[
                                    ValueListenableBuilder(
                                        valueListenable: _order.repo.listenable(keys: [_order.last?.uuid]),
                                        builder: (BuildContext ctx, Box<OrderModel> bx, wid) {
                                          OrderModel last = bx.get(_order.last?.uuid)!;

                                          if (['confirmed', 'wait'].contains(last.status)) {
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(child: Text(
                                                      last.status == 'confirmed' ? 'Приедет' : 'Ожидает',
                                                      style: Theme.of(context).textTheme.headline5,
                                                      textAlign: TextAlign.center,
                                                    ))
                                                  ],
                                                )
                                                ,
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                '${d.car['brand']} ${d.car['model']}',
                                                                style: Theme.of(context).textTheme.headline6,
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              Container(
                                                                  margin: const EdgeInsets.only(left: 5, right: 5),
                                                                  height: 20,
                                                                  width: 20,
                                                                  decoration: BoxDecoration(
                                                                    color: d.determineCarColor(),
                                                                    borderRadius: BorderRadius.circular(3),
                                                                  )
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                                                                margin: const EdgeInsets.only(left: 5, right: 5),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(3),
                                                                    border: Border.all(
                                                                        color: Colors.white38,
                                                                        width: 2
                                                                    )
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      margin: const EdgeInsets.only(right: 2),
                                                                      child: Text(
                                                                          d.regNumberCar[0],
                                                                          style: Theme.of(context).textTheme.subtitle2
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      transform: Matrix4.translationValues(0, -1, 0),
                                                                      margin: const EdgeInsets.only(right: 2),
                                                                      child: Text(
                                                                          d.regNumberCar[1],
                                                                          style: Theme.of(context).textTheme.headline6
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                        d.regNumberCar[2],
                                                                        style: Theme.of(context).textTheme.subtitle2
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                                                      color: Colors.white38,
                                                                      height: 30,
                                                                      width: 2,
                                                                    ),
                                                                    Container(
                                                                      transform: Matrix4.translationValues(0, -6, 0),
                                                                      child: Text(
                                                                        d.regNumberCar[3],
                                                                        style: const TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 12
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                    )
                                                  ],
                                                ),
                                              ],
                                            );
                                          }

                                          if (
                                            ['active', 'pause'].contains(last.status)
                                          ) {
                                            return ValueListenableBuilder(
                                                valueListenable: _driver.repo.listenable(keys: [_order.last?.driverId]),
                                                builder: (BuildContext ctx, Box<DriverModel> bx, Widget? wid) {
                                                  DriverModel d = bx.get(_order.last?.driverId)!;

                                                  return Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Center(
                                                                child:
                                                                  d.avatar != null ? CircleAvatar(
                                                                    backgroundColor: Colors.transparent,
                                                                    foregroundColor: Colors.transparent,
                                                                    radius: 30,
                                                                    backgroundImage: MemoryImage(
                                                                        base64Decode(d.avatar!)
                                                                    ),
                                                                  ) : CircleAvatar(
                                                                    backgroundColor: Colors.black38,
                                                                    foregroundColor: Colors.black38,
                                                                    radius: 30,
                                                                    child: Text('${d.lastName.substring(0, 1).toUpperCase()}${d.firstName.substring(0, 1).toUpperCase()}'),
                                                                  ),
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                                d.firstName,
                                                                textAlign: TextAlign.center,
                                                                style: Theme.of(context).textTheme.subtitle1,
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      margin: const EdgeInsets.only(left: 5),
                                                                      child: Text(
                                                                          '${d.rating}',
                                                                          textAlign: TextAlign.left,
                                                                          style: Theme.of(context).textTheme.subtitle2
                                                                      )
                                                                  ),
                                                                  const Text(
                                                                    'рейтинг',
                                                                    style: TextStyle(
                                                                        color: Colors.white38
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      margin: const EdgeInsets.only(right: 5),
                                                                      child: Text(
                                                                          '${d.activity}',
                                                                          textAlign: TextAlign.right,
                                                                          style: Theme.of(context).textTheme.subtitle2
                                                                      )
                                                                  ),
                                                                  const Text(
                                                                    'активность',
                                                                    style: TextStyle(
                                                                      color: Colors.white38
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      margin: const EdgeInsets.only(right: 5),
                                                                      child: Text(
                                                                          '${d.experience['years']} ${d.experience['ending']}',
                                                                          textAlign: TextAlign.right,
                                                                          style: Theme.of(context).textTheme.subtitle2
                                                                      )
                                                                  ),
                                                                  const Text(
                                                                    'стаж',
                                                                    style: TextStyle(
                                                                        color: Colors.white38
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                }
                                            );
                                          }

                                          return Container();
                                        }
                                    )
                                  ],
                                ),
                              ),
                            )
                        )
                    );
                  },
                )
            );
          }

          return Container();
        }
    );
  }
}