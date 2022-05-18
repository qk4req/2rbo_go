import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive_flutter/hive_flutter.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/bloc/turbo_go_event.dart';
import '/models/order_model.dart';

class PointsSheet extends StatefulWidget {
  LocationType focus;
  PointsSheet({Key? key, required this.focus}) : super(key: key);

  @override
  _PointsSheetState createState() => _PointsSheetState();
}

class _PointsSheetState extends State<PointsSheet> with TickerProviderStateMixin<PointsSheet> {
  final _startPointKey = GlobalKey<FormBuilderFieldState>();
  final _endPointKey = GlobalKey<FormBuilderFieldState>();

  late Animation<Offset> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;

  late LocationType _focus;
  //bool startLocationDecoded = false;
  //bool endLocationDecoded = false;


  @override
  void initState() {
    _focus = widget.focus;
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    /*animation = CurvedAnimation(
        parent: controller,
        curve: curve
    );*/
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
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) async {
        if (state is TurboGoLocationHasChangedState) {
          await controller.reverse();
        }

        if (state is TurboGoPointsState) {
          await controller.forward();
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
                                bottom: 100,
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
                                        ValueListenableBuilder(
                                            valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                                            builder: (ctx, Box<OrderModel> box, wid) {
                                              OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey)!;

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
                                                      AssetImage('lib/assets/circle.png'),
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
                                        ),
                                        Container(
                                          height: 1,
                                          color: Colors.black38,
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                                            builder: (ctx, Box<OrderModel> box, wid) {
                                              OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey)!;

                                              return Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(
                                                      left: 15,
                                                      right: 15
                                                    ),
                                                    child: const ImageIcon(
                                                        AssetImage('lib/assets/square.png'),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                /*const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        padding: EdgeInsets.zero,
                                        itemCount: 25,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            height: 50,
                                            color: Colors.amber,
                                            child: Center(child: Text('Entry $index')),
                                          );
                                        }
                                    )
                                )*/
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