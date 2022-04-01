import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/models/order_model.dart';



import '/bloc/turbo_go_bloc.dart';

class DriverColumn extends StatefulWidget {
  const DriverColumn({Key? key}) : super(key: key);

  @override
  _DriverColumnState createState() => _DriverColumnState();
}

class _DriverColumnState extends State<DriverColumn> {
  Box<OrderModel> orders = TurboGoBloc.orderController.repo;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: orders.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
      builder: (BuildContext ctx, Box box, Widget? wid) {
        OrderModel? newOrder = box.get(TurboGoBloc.orderController.newOrderKey);
        return Container();
      }
    );
  }
}