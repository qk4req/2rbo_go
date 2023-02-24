import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '/controllers/order_controller.dart';
import '/controllers/tariff_controller.dart';
import '/models/tariff_model.dart';
import '/models/order_model.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/bloc/turbo_go_event.dart';

final OrderController orderController = TurboGoBloc.orderController;
final TariffController tariffController = TurboGoBloc.tariffController;

class TariffsSheet extends StatefulWidget {
  const TariffsSheet({Key? key}) : super(key: key);

  @override
  _TariffsSheetState createState() => _TariffsSheetState();
}

class _TariffsSheetState extends State<TariffsSheet>/* with TickerProviderStateMixin<TariffsSheet>*/ {
  /*static const double _min = 0.3;
  static const double _max = 0.3;
  static const double _initial = 0.3;
  double _buttonExtent = _initial;*/
  final SnappingSheetController _snappingSheet = TurboGoBloc.snappingSheetController;
  final List<ScrollController> _scrollControllers = [ScrollController(), ScrollController()];
  final ValueNotifier<double> _opacity = ValueNotifier(0);
  final ValueNotifier<double> _height = ValueNotifier(0);
  final ValueNotifier<bool> _hidden = ValueNotifier(false);
  int _tariffId = 1;
  //CarouselController carouselController = CarouselController();

  /*late Animation<Offset> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;*/



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
    /*controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(controller);
    WidgetsBinding.instance!.addPostFrameCallback((duration) {
      controller.forward();
    });*/
    orderController.repo.watch(key: orderController.last?.uuid).listen((event) {
      OrderModel? last = event.value;

      if (last is OrderModel) {
        if (last.tariffId != null && _tariffId != last.tariffId && mounted) {
          setState(() {
            _tariffId = last.tariffId!;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        AnimatedBuilder(
          animation: _hidden,
          builder: (BuildContext context, Widget? child) {
            return !_hidden.value ? AnimatedBuilder(
                animation: _height,
                builder: (ctx, wid) {
                  if (_height.value < 0.9) {
                    return Container(
                      margin: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * _height.value)+10),
                      child: ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoBackEvent(TurboGoPointsState()));
                        },
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black38,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                            splashFactory: InkRipple.splashFactory
                        ),
                      ),
                    );
                  }
                  return Container();
                }
            ) : Container();
          }
        ),
        SnappingSheet(
            controller: _snappingSheet,
            /*onSnapStart: (_, __) {
              print(12333);
            },*/
            onSnapCompleted: (_, __) {
              _hidden.value = false;
            },
            onSheetMoved: (sheetPosition) {
              double position = sheetPosition.relativeToSnappingPositions;

              if (position >= 1.0) {
                _opacity.value = 1.0;
              } else if (position <= 0.0) {
                _opacity.value = 0.0;
              } else {
                _opacity.value = position;
              }

              _height.value = sheetPosition.relativeToSheetHeight;
              if (sheetPosition.relativeToSheetHeight != 0.4) _hidden.value = true;
            },
            initialSnappingPosition: const SnappingPosition.factor(positionFactor: 0.4),
            snappingPositions: const [
              SnappingPosition.factor(
                grabbingContentOffset: GrabbingContentOffset.bottom,
                snappingCurve: Curves.elasticOut,
                snappingDuration: Duration(seconds: 1),
                positionFactor: 0.3,
              ),
              SnappingPosition.factor(
                grabbingContentOffset: GrabbingContentOffset.bottom,
                snappingCurve: Curves.elasticOut,
                snappingDuration: Duration(seconds: 1),
                positionFactor: 0.8,
              ),
            ],
            lockOverflowDrag: true,
            sheetAbove: null,
            sheetBelow: SnappingSheetContent(
                draggable: true,
                childScrollController: _scrollControllers[0],
                child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        color: const Color.fromRGBO(32, 33, 36, 1),
                        child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _scrollControllers[0],
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  width: 30,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                NotificationListener<OverscrollIndicatorNotification>(
                                    onNotification: (notification) {
                                      notification.disallowIndicator();
                                      return true;
                                    },
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollControllers[1],
                                      child: Row(
                                          children:
                                          tariffController.repo.isNotEmpty ?
                                          tariffController.repo.values.map<Widget>((t) {
                                            return ValueListenableBuilder(
                                                valueListenable: orderController.repo.listenable(keys: [orderController.newOrderKey]),
                                                builder: (ctx, Box<OrderModel> box, wid) {
                                                  OrderModel newOrder = box.get(orderController.newOrderKey)!;

                                                  return Opacity(
                                                    opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 10),
                                                      child: OutlinedButton(
                                                          onPressed: () {
                                                            BlocProvider.of<TurboGoBloc>(context).add(TurboGoTariffsEvent(t.id));
                                                            /*buttonCarouselController.animateToPage(tariffs.values.toList().indexOf(t));*/
                                                          },
                                                          child: Column(
                                                            children: [
                                                              CachedNetworkImage(
                                                                  width: 100,
                                                                  height: 50,
                                                                  imageBuilder: (ctx, image) {
                                                                    return Container(
                                                                      margin: const EdgeInsets.all(10),
                                                                      child: Image(image: image),
                                                                    );
                                                                  },
                                                                  imageUrl: '${TurboGoBloc.storageUrl}/tariffs/${t.id}/icon.png'
                                                              ),
                                                              Text('${t.name}')
                                                            ],
                                                          )
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
                                      ),
                                    )
                                ),
                                AnimatedBuilder(
                                    animation: _opacity,
                                    builder: (ctx, child) {
                                      double opacity = _opacity.value;
                                      if ((opacity + 0.1) >= 1.0) _opacity.value = 0.9;

                                      return Opacity(
                                        opacity: _opacity.value + 0.1,
                                        child: AnimatedSwitcher(
                                            key: ValueKey<int>(_tariffId),
                                            duration: const Duration(milliseconds: 200),
                                            child: tariffController.contains({'id': _tariffId}) ? Container(
                                              margin: const EdgeInsets.all(25),
                                              child: ValueListenableBuilder (
                                                valueListenable: tariffController.repo.listenable(keys: [_tariffId]),
                                                builder: (ctx, Box tariffs, wid) {
                                                  TariffModel tariff = tariffs.get(_tariffId);

                                                  return Column(
                                                    children: [
                                                      if (tariff.baseCost is double) Wrap(
                                                        children: [
                                                          Row(
                                                              children: [
                                                                Text(
                                                                  'Посадка от:',
                                                                  style: Theme.of(context).textTheme.headline6?.apply(
                                                                      color: Colors.white.withOpacity(0.4),
                                                                      fontSizeFactor: 0.8
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  tariff.baseCost!.toInt().toString(),
                                                                  style: Theme.of(context).textTheme.headline6
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(color: Colors.black38)],
                                                      ),
                                                      if (tariff.ridePerKm is double) Wrap(
                                                        children: [
                                                          Row(
                                                              children: [
                                                                Text(
                                                                  'За км пути:',
                                                                  style: Theme.of(context).textTheme.headline6?.apply(
                                                                      color: Colors.white.withOpacity(0.4),
                                                                      fontSizeFactor: 0.8
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  tariff.ridePerKm!.toInt().toString(),
                                                                  style: Theme.of(context).textTheme.headline6
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(color: Colors.black38)],
                                                      ),
                                                      if (tariff.waitPerMin is double) Wrap(
                                                        children: [
                                                          Row(
                                                              children: [
                                                                Text(
                                                                  'За мин ожидания:',
                                                                  style: Theme.of(context).textTheme.headline6?.apply(
                                                                      color: Colors.white.withOpacity(0.4),
                                                                      fontSizeFactor: 0.8
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  tariff.waitPerMin!.toInt().toString(),
                                                                  style: Theme.of(context).textTheme.headline6
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(color: Colors.black38)],
                                                      )
                                                    ],
                                                  );
                                                },
                                              ),
                                            ) : null
                                        ),
                                      );
                                    }
                                )
                              ],
                            )
                        )
                    )
                )
            )
        )
      ],
    );



    /*return SlideTransition(
      position: animation,
      child:
      return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            setState(() {
              _buttonExtent = notification.extent;
            });
            return true;
          },
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              DraggableScrollableSheet(
                expand: false,
                initialChildSize: _initial,
                minChildSize: _min,
                maxChildSize: _max,
                builder: (BuildContext ctx, ScrollController scrollController) {
                  return ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Container(
                        //padding: const EdgeInsets.all(15),
                          color: const Color.fromRGBO(32, 33, 36, 1),
                          child: NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (notification) {
                              notification.disallowIndicator();
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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                        children:
                                        tariffController.repo.isNotEmpty ?
                                        tariffController.repo.values.map<Widget>((t) {
                                          return ValueListenableBuilder(
                                              valueListenable: orderController.repo.listenable(keys: [orderController.newOrderKey]),
                                              builder: (ctx, Box<OrderModel> box, wid) {
                                                OrderModel newOrder = box.get(orderController.newOrderKey)!;

                                                return Opacity(
                                                  opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                                                  child: Container(
                                                    margin: const EdgeInsets.only(right: 10),
                                                    child: OutlinedButton(
                                                        onPressed: () {
                                                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoTariffsEvent(t.id));
                                                          /*buttonCarouselController.animateToPage(tariffs.values.toList().indexOf(t));*/
                                                        },
                                                        child: Column(
                                                          children: [
                                                            CachedNetworkImage(
                                                                width: 100,
                                                                height: 50,
                                                                imageBuilder: (ctx, image) {
                                                                  return Container(
                                                                    margin: const EdgeInsets.all(10),
                                                                    child: Image(image: image),
                                                                  );
                                                                },
                                                                imageUrl: '${TurboGoBloc.storageUrl}/tariffs/${t.id}/icon.png'
                                                            ),
                                                            Text('${t.name}')
                                                          ],
                                                        )
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
                                    )
                                  ],
                                ),
                                controller: scrollController,
                              ),
                            ),
                          )
                      )
                  );
                },
              ),
              if (_buttonExtent < 0.8) Container(
                margin: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * _buttonExtent)+10),
                child: ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<TurboGoBloc>(context).add(TurboGoBackEvent(TurboGoPointsState()));
                  },
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black38,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                      splashFactory: InkRipple.splashFactory
                  ),
                ),
              )
            ],
          )
      );;
    );*/
  }
}