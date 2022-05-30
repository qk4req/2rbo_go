import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final OrderController _order = TurboGoBloc.orderController;
  final TariffController _tariff = TurboGoBloc.tariffController;
  CarouselController buttonCarouselController = CarouselController();

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
      return DraggableScrollableSheet(
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
                    ),
                  )
              )
          );
        },
      );/*
    );*/
  }
}