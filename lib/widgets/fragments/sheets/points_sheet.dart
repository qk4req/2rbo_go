import 'dart:async';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:turbo_go/controllers/geocoder_controller.dart';
import 'package:turbo_go/controllers/order_controller.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/bloc/turbo_go_event.dart';

class PointsSheet extends StatefulWidget {
  final LocationTypes focus;
  const PointsSheet({Key? key, required this.focus}) : super(key: key);

  @override
  _PointsSheetState createState() => _PointsSheetState();
}

class _PointsSheetState extends State<PointsSheet> with TickerProviderStateMixin<PointsSheet> {
  static const int loadingDuration = 1500;

  final OrderController _order = TurboGoBloc.orderController;
  final GeocoderController _geocoder = TurboGoBloc.geocoderController;
  GlobalKey startPointKey = GlobalKey<FormBuilderFieldState>();
  GlobalKey endPointKey = GlobalKey<FormBuilderFieldState>();

  late Animation<Offset> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;

  late LocationTypes _focus;
  final Map<int, Timer?> _timers = {};
  Timer? _timer;
  bool loading = true;
  String? from;
  String? whither;
  //List? points;
  final List<FocusNode> _focusNodes = [FocusNode(), FocusNode()];


  @override
  void initState() {
    _focus = widget.focus;
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(controller);
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      controller.forward();
      _timer = Timer(const Duration(milliseconds: loadingDuration), () {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      });
      if (_focus == LocationTypes.start) {
        _focusNodes[0].requestFocus();
      } else {
        _focusNodes[1].requestFocus();
      }
    });
    _geocoder.addListener(() {
      _timers[1] = Timer(const Duration(milliseconds: loadingDuration), () {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      });
    });
    /*
    _order.repo.watch(key: _order.newOrderKey).listen((event) {
      points = (_focus == LocationType.start) ? _order.newOrder.from?['data'] : _order.newOrder.whither?['data'];
      if (_focus == LocationType.start &&
        points is List
      ) {

      }
    });
    */
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) async {
        //_startPointKey = GlobalKey<FormBuilderFieldState>();
        //_endPointKey = GlobalKey<FormBuilderFieldState>();
        if (state is TurboGoLocationHasChangedState) {
          await controller.reverse();
          _timer?.cancel();
          _timer = null;
          setState(() {
            if (mounted) {
              loading = true;
            }
          });
        }

        if (state is TurboGoPointsState) {
          await controller.forward();
          _timer = Timer(const Duration(milliseconds: loadingDuration), () {
            if (mounted) {
              setState(() {
                loading = false;
              });
              /*if (_focus == LocationType.start) {
                _focusNodes[0].requestFocus();
              } else {
                _focusNodes[1].requestFocus();
              }*/
            }
          });
        }
      },
      child:
      Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SlideTransition(
          position: animation,
          child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.8,
              maxChildSize: 0.8,
              //snap: true,
              //snapSizes: const [0.5, 0.8],
              builder: (BuildContext ctx, ScrollController ctrl) {
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
                                bottom: 80,
                                left: 15,
                                right: 15
                            ),
                            color: const Color.fromRGBO(32, 33, 36, 1),
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.stretch,
                              //mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    color: const Color.fromRGBO(48, 49, 52, 1),
                                    child: Column(
                                      children: [
                                        /*ValueListenableBuilder(
                                            valueListenable: _order.repo.listenable(keys: [_order.newOrderKey]),
                                            builder: (ctx, Box<OrderModel> box, wid) {
                                              OrderModel newOrder = box.get(_order.newOrderKey)!;

                                              return FormBuilderTextField(
                                                autofocus: (_focus == LocationType.start),
                                                onTap: () {
                                                  BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeStartPointEvent());
                                                },
                                                decoration: InputDecoration(
                                                  hintText:
                                                    (newOrder.from == null || newOrder.from!.isEmpty)
                                                    ? 'Откуда забрать?'
                                                    : ((newOrder.from!['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ')),
                                                  hintStyle: const TextStyle(
                                                      color: Colors.white38
                                                  ),
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  icon: Container(
                                                    margin: const EdgeInsets.only(left: 15),
                                                    child: const ImageIcon(
                                                      AssetImage('lib/assets/images/circle.png'),
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    decoration: TextDecoration.none
                                                ),
                                                key: _startPointKey,
                                                name: 'start_point',
                                              );
                                            }
                                        ),*/
                                        Row(
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 200),
                                              child:
                                              loading && _focus == LocationTypes.start ?
                                              Shimmer.fromColors(
                                                  child: Container(
                                                    margin: const EdgeInsets.only(left: 15, right: 15),
                                                    child: const ImageIcon(
                                                      AssetImage('lib/assets/images/circle.png'),
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                  baseColor: Colors.white.withOpacity(0.1),
                                                  highlightColor: Colors.white
                                              ) :
                                              Container(
                                                margin: const EdgeInsets.only(left: 15, right: 15),
                                                child: const ImageIcon(
                                                  AssetImage('lib/assets/images/circle.png'),
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 200),
                                                  child:
                                                  loading && _focus == LocationTypes.start ?
                                                  FormBuilderTextField(
                                                    key: startPointKey,
                                                    focusNode: _focusNodes[0],
                                                    //autofocus: (_focus == LocationType.start),
                                                    onTap: () {
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoStartPointEvent());
                                                    },
                                                    onChanged: (String? from) {
                                                      if (from is String && from.isNotEmpty) {
                                                        _geocoder.clearPoints();
                                                        if (_timers[1] is Timer) {
                                                          _timers[1]!.cancel();
                                                          _timers[1] = null;
                                                        }
                                                        setState(() {
                                                          _focus = LocationTypes.start;
                                                          loading = true;
                                                        });
                                                      }
                                                      this.from = from;
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindPointsEvent(from));
                                                    },
                                                    decoration: const InputDecoration(
                                                      hintText: '',
                                                      hintStyle: TextStyle(
                                                          color: Colors.white38
                                                      ),
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        decoration: TextDecoration.none
                                                    ),
                                                    name: 'start_point',
                                                  ) :
                                                  FormBuilderTextField(
                                                    key: startPointKey,
                                                    focusNode: _focusNodes[0],
                                                    //autofocus: (_focus == LocationType.start),
                                                    onTap: () {
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoStartPointEvent());
                                                    },
                                                    onChanged: (String? from) {
                                                      if (from is String && from.isNotEmpty) {
                                                        _geocoder.clearPoints();
                                                        if (_timers[1] is Timer) {
                                                          _timers[1]!.cancel();
                                                          _timers[1] = null;
                                                        }
                                                        setState(() {
                                                          _focus = LocationTypes.start;
                                                          loading = true;
                                                        });
                                                      }
                                                      this.from = from;
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindPointsEvent(from));
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                        (_order.newOrder.from == null || _order.newOrder.from!.isEmpty) ? 'Откуда забрать?' : ((_order.newOrder.from!['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ')),
                                                      hintStyle: const TextStyle(
                                                          color: Colors.white38
                                                      ),
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                      /*icon:
                                                      AnimatedSwitcher(
                                                          duration: const Duration(milliseconds: loadingDuration),
                                                          child:
                                                          loading && _focus == LocationType.start ?
                                                          Shimmer.fromColors(
                                                              child: Container(
                                                                margin: const EdgeInsets.only(left: 15),
                                                                child: const ImageIcon(
                                                                  AssetImage('lib/assets/images/circle.png'),
                                                                  color: Colors.white,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                              baseColor: Colors.white10,
                                                              highlightColor: Colors.white
                                                          ) :
                                                          Container(
                                                            margin: const EdgeInsets.only(left: 15),
                                                            child: const ImageIcon(
                                                              AssetImage('lib/assets/images/circle.png'),
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                          )
                                                      )*/
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        decoration: TextDecoration.none
                                                    ),
                                                    //key: _startPointKey,
                                                    name: 'start_point',
                                                  ),
                                                )
                                            )
                                          ],
                                        ),
                                        Container(
                                          height: 1,
                                          color: Colors.black38,
                                        ),
                                        /*ValueListenableBuilder(
                                            valueListenable: _order.repo.listenable(keys: [_order.newOrderKey]),
                                            builder: (ctx, Box<OrderModel> box, wid) {
                                              OrderModel newOrder = box.get(_order.newOrderKey)!;

                                              return Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(
                                                      left: 15,
                                                      right: 15
                                                    ),
                                                    child: const ImageIcon(
                                                        AssetImage('lib/assets/images/square.png'),
                                                        color: Colors.redAccent,
                                                        size: 15
                                                    ),
                                                  ),
                                                  Expanded(child: FormBuilderTextField(
                                                    autofocus: (_focus == LocationType.end),
                                                    onTap: () {
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeEndPointEvent());
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                        (newOrder.whither == null || newOrder.whither!.isEmpty)
                                                        ? 'Куда поедем?'
                                                        : (newOrder.whither!['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ'),
                                                      hintStyle: const TextStyle(
                                                          color: Colors.white38
                                                      ),
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.white
                                                    ),
                                                    key: _endPointKey,
                                                    name: 'end_point',
                                                    //autofocus: true,
                                                    onChanged: (String? value) {
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindEndPointsEvent(value));
                                                    },
                                                  ))
                                                ],
                                              );
                                            }
                                        ),*/
                                        Row(
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 200),
                                              child:
                                              loading && _focus == LocationTypes.end ?
                                              Shimmer.fromColors(
                                                  child: Container(
                                                    margin: const EdgeInsets.only(left: 15, right: 15),
                                                    child: const ImageIcon(
                                                      AssetImage('lib/assets/images/square.png'),
                                                      color: Colors.red,
                                                      size: 15,
                                                    ),
                                                  ),
                                                  baseColor: Colors.red.withOpacity(0.1),
                                                  highlightColor: Colors.red
                                              ) :
                                              Container(
                                                margin: const EdgeInsets.only(left: 15, right: 15),
                                                child: const ImageIcon(
                                                  AssetImage('lib/assets/images/square.png'),
                                                  color: Colors.red,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 200),
                                                  child:
                                                  loading && _focus == LocationTypes.end ?
                                                  FormBuilderTextField(
                                                    key: endPointKey,
                                                    focusNode: _focusNodes[1],
                                                    //autofocus: (_focus == LocationType.end),
                                                    onTap: () {
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndPointEvent());
                                                    },
                                                    onChanged: (String? whither) {
                                                      if (whither is String && whither.isNotEmpty) {
                                                        _geocoder.clearPoints();
                                                        if (_timers[1] is Timer) {
                                                          _timers[1]!.cancel();
                                                          _timers[1] = null;
                                                        }
                                                        setState(() {
                                                          _focus = LocationTypes.end;
                                                          loading = true;
                                                        });
                                                      }
                                                      this.whither = whither;
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindPointsEvent(whither));
                                                    },
                                                    decoration: const InputDecoration(
                                                      hintText: '',
                                                      hintStyle: TextStyle(
                                                          color: Colors.white38
                                                      ),
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        decoration: TextDecoration.none
                                                    ),
                                                    name: 'end_point',
                                                  ) :
                                                  FormBuilderTextField(
                                                    key: endPointKey,
                                                    focusNode: _focusNodes[1],
                                                    //autofocus: (_focus == LocationType.end),
                                                    onTap: () {
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndPointEvent());
                                                    },
                                                    onChanged: (String? whither) {
                                                      if (whither is String && whither.isNotEmpty) {
                                                        _geocoder.clearPoints();
                                                        if (_timers[1] is Timer) {
                                                          _timers[1]!.cancel();
                                                          _timers[1] = null;
                                                        }
                                                        setState(() {
                                                          _focus = LocationTypes.end;
                                                          loading = true;
                                                        });
                                                      }
                                                      this.whither = whither;
                                                      BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindPointsEvent(whither));
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                      (_order.newOrder.whither == null || _order.newOrder.whither!.isEmpty) ? 'Куда поедем?' : ((_order.newOrder.whither!['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ')),
                                                      hintStyle: const TextStyle(
                                                          color: Colors.white38
                                                      ),
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        decoration: TextDecoration.none
                                                    ),
                                                    //key: _startPointKey,
                                                    name: 'end_point',
                                                  ),
                                                )
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child:
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 100),
                                        child:
                                          loading ?
                                          Shimmer.fromColors(
                                            baseColor: Colors.white60,
                                            highlightColor: Colors.white,
                                            enabled: true,
                                            child: ListView.builder(
                                              itemBuilder: (_, __) => Padding(
                                                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container(
                                                            width: double.infinity,
                                                            height: 8.0,
                                                            color: Colors.white,
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.symmetric(vertical: 2.0),
                                                          ),
                                                          Container(
                                                            width: double.infinity,
                                                            height: 8.0,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              itemCount: 4,
                                            ),
                                          ) :
                                          Container(
                                            key: UniqueKey(),
                                            child:
                                              _geocoder.points.isNotEmpty ?
                                              ListView.builder(
                                                padding: const EdgeInsets.all(10),
                                                itemCount: _geocoder.points.length,
                                                itemBuilder: (BuildContext ctx, i) {
                                                  List<String> entries = (_geocoder.points[i]['display_name'] as String).split(', ');
                                                  entries.removeRange(entries.length-3, entries.length);
                                                  return OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        side: const BorderSide(
                                                          color: Colors.transparent,
                                                        ),
                                                        padding: const EdgeInsets.all(0),
                                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                                      ),
                                                      onPressed: () {
                                                        BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangePointEvent(
                                                            _geocoder.points[i], (_focus == LocationTypes.start ? CoordinateTypes.from : CoordinateTypes.whither)
                                                        ));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 5),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              //crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                if (_focus == LocationTypes.start) Container(
                                                                  margin: const EdgeInsets.only(left: 5, right: 15),
                                                                  child: const Icon(
                                                                    Icons.circle,
                                                                    size: 13,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                                if (_focus == LocationTypes.end) Container(
                                                                  margin: const EdgeInsets.only(left: 5, right: 15),
                                                                  child: const Icon(
                                                                    Icons.stop,
                                                                    size: 13,
                                                                    color: Colors.red,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      SizedBox(
                                                                        width: double.infinity,
                                                                        height: 20.0,
                                                                        child: Text(
                                                                          entries[0],
                                                                          style: Theme.of(context).textTheme.subtitle1,
                                                                        ),
                                                                        //color: Colors.white,
                                                                      ),
                                                                      const Padding(
                                                                        padding: EdgeInsets.symmetric(vertical: 2.0),
                                                                      ),
                                                                      SizedBox(
                                                                        width: double.infinity,
                                                                        height: 20.0,
                                                                        child: Text(
                                                                          entries.getRange(1, entries.length).join(', '),
                                                                          style: Theme.of(context).textTheme.subtitle2?.apply(
                                                                              color: Colors.white60
                                                                          ),
                                                                        ),
                                                                        //color: Colors.white,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                /*const Icon(
                                                          Icons.arrow_forward,
                                                          color: Colors.white60,
                                                        )*/
                                                              ],
                                                            ),
                                                            if ((_geocoder.points.length-1) != i) Container(
                                                              height: 1,
                                                              color: Colors.black38,
                                                              margin: const EdgeInsets.only(top: 5),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                  );
                                                },
                                              ) : null
                                          ),
                                      )
                                )
                              ],
                            ),
                          ),
                        )
                    )
                );
              }
          ),
        ),
      ),
    );
    /*return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: const Color.fromRGBO(48, 49, 52, 1),
            child: Column(
              children: [
                ValueListenableBuilder(
                    valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                    builder: (ctx, Box<OrderModel> box, wid) {
                      OrderModel? newOrder = box.get(TurboGoBloc.orderController.newOrderKey);
                      return FormBuilderTextField(
                        onTap: () {
                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeStartPointEvent());
                        },
                        decoration: InputDecoration(
                          hintText:
                          newOrder?.from == null ? 'Откуда забрать?' : newOrder?.from!['coordinates'].toString(),
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none
                        ),
                        key: _startPointKey,
                        name: 'start_point',
                      );
                    }
                ),
                Container(
                  height: 1,
                  color: Colors.black38,
                ),
                ValueListenableBuilder(
                    valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                    builder: (ctx, Box<OrderModel> box, wid) {
                      OrderModel? newOrder = box.get(TurboGoBloc.orderController.newOrderKey);
                      return FormBuilderTextField(
                        onTap: () {
                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeEndPointEvent());
                        },
                        decoration: InputDecoration(
                          hintText:
                            newOrder?.whither == null ? 'Куда отвезти?' : newOrder?.whither?['coordinates'].toString(),
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
                              Icons.adjust,
                              //size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.white
                        ),
                        key: _endPointKey,
                        name: 'end_point',
                        //autofocus: true,
                        onChanged: (String? value) {
                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindEndPointsEvent(value));
                        },
                      );
                    }
                )
              ],
            ),
          ),
        )
      ],
    );*/
  }
}