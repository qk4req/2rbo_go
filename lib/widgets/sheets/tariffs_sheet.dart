import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/controllers/driver_controller.dart';
import 'package:turbo_go/controllers/drivers_online_controller.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/controllers/tariff_controller.dart';
import 'package:turbo_go/controllers/timestamp_controller.dart';
import 'package:turbo_go/models/driver_model.dart';
import 'package:turbo_go/models/drivers_online_model.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/models/order_model.dart';
import '/models/tariff_model.dart';

class TariffsSheet extends StatefulWidget {
  const TariffsSheet({Key? key}) : super(key: key);

  @override
  _TariffsSheetState createState() => _TariffsSheetState();
}

class _TariffsSheetState extends State<TariffsSheet> with TickerProviderStateMixin<TariffsSheet> {
  final OrderController _order = TurboGoBloc.orderController;
  final TariffController _tariff = TurboGoBloc.tariffController;
  //final DriverController _driver = TurboGoBloc.driverController;
  //final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  //final TimestampController _timestamp = TurboGoBloc.timestampController!;
  CarouselController buttonCarouselController = CarouselController();

  late Animation<Offset> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;



  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(controller);
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*Map t = {};
    if (_driversOnline.repo.isNotEmpty) {
      for (DriversOnlineModel d in _driversOnline.repo.values) {
        DriverModel? c = _driver.getById(d.driverId);
        if (c != null) {
          if (
              d.location != null && d.direction != null &&
              DateTime.parse(d.updatedAt).isAfter(_timestamp.create().subtract(const Duration(seconds: 30))) &&
              (c.balance > (c.car['tariff']['baseCost'] * c.car['tariff']['commission'])) &&
              c.status == 'active'
          ) {
            //DriverModel? c = _driver.getById(d.driverId);
            //if (c != null) {
              Map _car = c.car;

              if (!t.containsKey(_car['tariffId'])) {
                t.addAll({
                  _car['tariffId']: _car['tariff']
                });
              }
            //}
          }
        }
      }
    }
    List tariffs = t.values.toList();
    tariffs.sort((a, b) {
      return DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt']));
    });*/

    return SlideTransition(
      position: animation,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.3,
        minChildSize: 0.3,
        maxChildSize: 0.3,
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
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        //mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children:
                              _tariff.repo.isNotEmpty ?
                                _tariff.repo.values.map<Widget>((t) {
                                  return ValueListenableBuilder(
                                      valueListenable: _order.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                                      builder: (ctx, Box box, wid) {
                                        OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey);

                                        return Opacity(
                                          opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 10),
                                            child: OutlinedButton(
                                                onPressed: () {
                                                  BlocProvider.of<TurboGoBloc>(context).add(TurboGoSelectTariffEvent(t.id));
                                                  /*buttonCarouselController.animateToPage(tariffs.values.toList().indexOf(t));*/
                                                },
                                                child: Text('${t.name}')
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                }).toList() :
                                [
                                  const Expanded(
                                    child: Text(
                                      'Нет доступных тарифов',
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  )
                                ]
                              //drivers.values.s
                              /*tariffs.values.map((t) {
                                return ValueListenableBuilder(
                                  valueListenable: orders.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                                  builder: (ctx, Box box, wid) {
                                    OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey);
                                    return Opacity(
                                      opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        child: OutlinedButton(
                                          onPressed: () {
                                            BlocProvider.of<TurboGoBloc>(context).add(TurboGoSelectTariffEvent(t.id));
                                            /*buttonCarouselController.animateToPage(tariffs.values.toList().indexOf(t));*/
                                          },
                                          child: Text('${t.name}')
                                        ),
                                      ),
                                    );
                                  }
                                );
                              }).toList()*/
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
    /*return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
              tariffs.values.map((t) {
                return ValueListenableBuilder(
                    valueListenable: orders.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                    builder: (ctx, Box box, wid) {
                      OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey);
                      return Opacity(
                        opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: OutlinedButton(
                            onPressed: () {
                              BlocProvider.of<TurboGoBloc>(context).add(TurboGoSelectTariffEvent(t.id));
                              /*buttonCarouselController.animateToPage(tariffs.values.toList().indexOf(t));*/
                            },
                            child: Text('${t.name}')
                          ),
                        ),
                      );
                    }
                );
              }).toList()
          ),
        ),
        SingleChildScrollView(
          child: CarouselSlider(
              carouselController: buttonCarouselController,
              items: tariffs.values.map((t) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    '${t.name}',
                    style: const TextStyle(
                        color: Colors.white
                    )
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 200,
                aspectRatio: 16/9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: false,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal
              )
          ),
        )
      ],
    );*/
  }
}