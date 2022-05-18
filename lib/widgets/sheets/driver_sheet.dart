import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/models/drivers_online_model.dart';
import 'package:turbo_go/models/order_model.dart';



import '/bloc/turbo_go_bloc.dart';

class DriverSheet extends StatefulWidget {
  const DriverSheet({Key? key}) : super(key: key);

  @override
  _DriverSheetState createState() => _DriverSheetState();
}

class _DriverSheetState extends State<DriverSheet> {
  Box<OrderModel> orders = TurboGoBloc.orderController.repo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder(
            valueListenable: orders.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
            builder: (BuildContext ctx, Box box, Widget? wid) {
              OrderModel? newOrder = box.get(TurboGoBloc.orderController.newOrderKey);

              //if (newOrder?.status == 'confirmed' && newOrder?.driverId != null) {
              //  DriversOnlineModel? driver = TurboGoBloc.driversOnlineController.getById(newOrder?.driverId!);
              //}
              return Container();
            }
        )
      ],
    );
  }
}