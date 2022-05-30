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

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({Key? key}) : super(key: key);

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final OrderController _order = TurboGoBloc.orderController;
  final _startPointKey = GlobalKey<FormBuilderFieldState>();
  final _endPointKey = GlobalKey<FormBuilderFieldState>();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: BlocBuilder<TurboGoBloc, TurboGoState>(
                builder: (BuildContext ctx, TurboGoState state) {
                  if (state is TurboGoHomeState) {
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
                                width: double.maxFinite,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide.none
                                  ),
                                  onPressed: () {
                                    BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeStartPointEvent());
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 15),
                                          child: const ImageIcon(
                                            AssetImage('lib/assets/circle.png'),
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable: _order.repo.listenable(keys: [_order.newOrderKey]),
                                            builder: (BuildContext ctx, Box bx, Widget? wid) {
                                              OrderModel newOrder = bx.get(_order.newOrderKey)!;

                                              return //newOrder.from != null && newOrder.from!.isNotEmpty
                                              //?
                                              Text(
                                                newOrder.from?['desc'] ?? 'МЕТКА СТОИТ НА КАРТЕ',
                                                style: const TextStyle(
                                                  color: Colors.white38
                                                )
                                              );
                                              /*: Expanded(child: Shimmer.fromColors(
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
                                              ));*/
                                            }
                                        )
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
                                    BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeEndPointEvent());
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 15),
                                          child:
                                          const ImageIcon(
                                            AssetImage('lib/assets/square.png'),
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
                                child: const Center(
                                  child: Text(
                                    'Идёт поиск машины...',
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(
                                      //fontSize: 40.0,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
    );
  }

}