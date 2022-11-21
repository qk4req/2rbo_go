import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/bloc/turbo_go_state.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/controllers/tariff_controller.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/models/order_model.dart';

class TariffsSheet extends StatefulWidget {
  const TariffsSheet({Key? key}) : super(key: key);

  @override
  _TariffsSheetState createState() => _TariffsSheetState();
}

class _TariffsSheetState extends State<TariffsSheet>/* with TickerProviderStateMixin<TariffsSheet>*/ {
  static const double _min = 0.3;
  static const double _max = 0.3;
  static const double _initial = 0.3;
  double _buttonExtent = _initial;
  final OrderController _order = TurboGoBloc.orderController;
  final TariffController _tariff = TurboGoBloc.tariffController;
  //CarouselController carouselController = CarouselController();

  /*late Animation<Offset> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;*/



  @override
  void initState() {
    super.initState();
    /*controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(controller);
    WidgetsBinding.instance!.addPostFrameCallback((duration) {
      controller.forward();
    });*/
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*return SlideTransition(
      position: animation,
      child:*/
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
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                        children:
                                        _tariff.repo.isNotEmpty ?
                                        _tariff.repo.values.map<Widget>((t) {
                                          return ValueListenableBuilder(
                                              valueListenable: _order.repo.listenable(keys: [_order.newOrderKey]),
                                              builder: (ctx, Box<OrderModel> box, wid) {
                                                OrderModel newOrder = box.get(_order.newOrderKey)!;

                                                return Opacity(
                                                  opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                                                  child: Container(
                                                    margin: const EdgeInsets.only(right: 10),
                                                    child: OutlinedButton(
                                                        onPressed: () {
                                                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoTariffsEvent(t.id));
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
    /*);*/
  }
}