import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/models/order_model.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';

class PointsColumn extends StatefulWidget {
  const PointsColumn({Key? key}) : super(key: key);

  @override
  _PointsColumnState createState() => _PointsColumnState();
}

class _PointsColumnState extends State<PointsColumn> {
  final _startPointKey = GlobalKey<FormBuilderFieldState>();
  final _endPointKey = GlobalKey<FormBuilderFieldState>();

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}