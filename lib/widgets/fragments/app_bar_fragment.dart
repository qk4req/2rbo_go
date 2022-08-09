import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:turbo_go/bloc/turbo_go_event.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/models/order_model.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';

class AppBarFragment extends StatefulWidget {
  const AppBarFragment({Key? key}) : super(key: key);

  @override
  _AppBarFragmentState createState() => _AppBarFragmentState();
}

class _AppBarFragmentState extends State<AppBarFragment> {
  static const loadingDuration = 1500;

  final OrderController _order = TurboGoBloc.orderController;
  final _startPointKey = GlobalKey<FormBuilderFieldState>();
  final _endPointKey = GlobalKey<FormBuilderFieldState>();
  Timer? _timer;
  bool loading = true;

  @override
  void initState() {
    //_order.repo.watch(key: [_order.newOrderKey]).listen((event) {
    //});
    _timer = Timer(const Duration(milliseconds: loadingDuration), () {
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) {
        if (state is TurboGoLocationHasChangedState) {
          _timer?.cancel();
          _timer = null;
          setState(() {
            loading = true;
          });
        }

        if (state is TurboGoHomeState) {
          _timer = Timer(const Duration(milliseconds: loadingDuration), () {
            setState(() {
              loading = false;
            });
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              child: BlocBuilder<TurboGoBloc, TurboGoState>(
                  builder: (BuildContext ctx, TurboGoState state) {
                    if (state is TurboGoHomeState) {
                      List? fromCoordinates = _order.newOrder.from?['coordinates'];
                      return Row(
                        children: [
                          Expanded(child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(32, 33, 36, 1),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.all(15),
                            //color: Colors.black54,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 50,
                                  //width: double.maxFinite,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide.none
                                    ),
                                    onPressed: () {
                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoStartPointEvent());
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child:
                                              !loading ?
                                              Container(
                                                margin: const EdgeInsets.only(right: 15),
                                                child: const ImageIcon(
                                                  AssetImage('lib/assets/images/circle.png'),
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ) :
                                              Shimmer.fromColors(
                                                  child: Container(
                                                    margin: const EdgeInsets.only(right: 15),
                                                    child: const ImageIcon(
                                                      AssetImage('lib/assets/images/circle.png'),
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                  baseColor: Colors.white.withOpacity(0.1),
                                                  highlightColor: Colors.white
                                              ),
                                          ),
                                          AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 200),
                                              child:
                                              !loading ?
                                              Text(
                                                  fromCoordinates is List && fromCoordinates.length == 2 &&
                                                      fromCoordinates[0] is double && fromCoordinates[1] is double ?
                                                  (_order.newOrder.from?['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ') :
                                                  'Откуда забрать?',
                                                  style: const TextStyle(
                                                      color: Colors.white38
                                                  )
                                              ) :
                                              Container()
                                          )
                                          /*ValueListenableBuilder(
                                              valueListenable: _order.repo.listenable(keys: [_order.newOrderKey]),
                                              builder: (BuildContext ctx, Box bx, Widget? wid) {
                                                OrderModel newOrder = bx.get(_order.newOrderKey)!;
                                                List? fromCoordinates = newOrder.from?['coordinates'];

                                                return //newOrder.from != null && newOrder.from!.isNotEmpty
                                                  //?
                                                  Text(
                                                      fromCoordinates is List && fromCoordinates.length == 2 &&
                                                          fromCoordinates[0] is double && fromCoordinates[1] is double ?
                                                      (newOrder.from?['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ') :
                                                      'Откуда забрать?',
                                                      style: const TextStyle(
                                                          color: Colors.white38
                                                      )
                                                  );
                                                : Expanded(child: Shimmer.fromColors(
                                                enabled: true,
                                                child: Row(
                                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: Colors.white38
                                                        ),
                                                        height: 15
                                                    ))
                                                  ],
                                                ),
                                                baseColor: Colors.white38,
                                                highlightColor: Colors.white,
                                              ));
                                              }
                                          )*/
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.black38,
                                  height: 1,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: double.maxFinite,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                    ),
                                    onPressed: () {
                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndPointEvent());
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 15),
                                            child:
                                            const ImageIcon(
                                                AssetImage('lib/assets/images/square.png'),
                                                color: Colors.redAccent,
                                                size: 15
                                            ),
                                          ),
                                          const Text(
                                            'Куда поедем?',
                                            style: TextStyle(
                                                color: Colors.white38
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                /*FormBuilderTextField(
                                onTap: () {
                                  BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeEndPointEvent());
                                },
                                decoration: InputDecoration(
                                  //hintText:
                                  //newOrder?.from == null ? 'Откуда забрать?' : newOrder?.from!['coordinates'].toString(),
                                  hintStyle: const TextStyle(
                                      color: Colors.white38
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  icon: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    child: const Icon(
                                      Icons.place,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.none
                                ),
                                key: _endPointKey,
                                name: 'end_point',
                                enabled: false,
                              )*/,
                              ],
                            ),
                          ))
                        ],
                      );
                    }
                    if (state is TurboGoSearchState) {
                      return Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.white38,
                                  highlightColor: Colors.white,
                                  child: Center(
                                    child: ValueListenableBuilder(
                                        valueListenable: state,
                                        builder: (BuildContext ctx, val, Widget? wid) {
                                          return const Text(
                                            'ИДЁТ ПОИСК МАШИНЫ...',//val == true ? 'ИДЁТ ПОИСК МАШИНЫ...' : 'ВОДИТЕЛЬ ОТКАЗАЛСЯ ОТ ЗАКАЗА, ИДЁТ ПОИСК ДРУГОЙ МАШИНЫ...',
                                            //textAlign: TextAlign.center,
                                            style: TextStyle(
                                              //fontSize: 40.0,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        }
                                    ),
                                  ),
                                ),
                                height: 100,
                                //width: MediaQuery.of(context).size.height/2,
                              )
                          )
                        ],
                      );
                    }
                    return Container();
                  }
              )
          )
        ],
      ),
    );
  }
}