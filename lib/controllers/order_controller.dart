import 'dart:async';
import 'package:hive/hive.dart';

import '/models/order_model.dart';

class OrderController {
  //OrderModel? lastOrder;
  Box<OrderModel> repo = Hive.box('orders');
  final String newOrderKey = 'default';
  final OrderModel newOrder = OrderModel();

  OrderController() {
    createNewOrder();
    /*if (repo.isNotEmpty) {
      OrderModel l = repo.values.last;
      last = OrderModel(
        l.id,
        l.driverId,
        l.clientId,
        l.status,
        l.totalTime,
        l.totalSum,
        l.from,
        l.whither,
        l.comment,
        l.startedAt,
        l.createdAt,
        l.updatedAt
      );
    }*/
  }

  bool compare(Map order) {
    return order['updatedAt'] == repo.get(order['id'])?.updatedAt;
  }

  void update(Map order) {
    /*if (order.isNotEmpty) {
      OrderModel? o;
      if (last?.id == order['id']) {
        last =
            OrderModel(
                order['id'],
                last?.driverId ?? order['driverId'],
                last?.clientId ?? order['clientId'],
                last?.status ?? order['status'],
                last?.totalTime ?? order['totalTime'],
                last?.totalSum ?? order['totalSum'],
                last?.from ?? order['from'],
                last?.whither ?? order['whither'],
                last?.comment ?? order['comment'],
                last?.startedAt ?? order['startedAt'],
                last?.createdAt ?? order['createdAt'],
                last?.updatedAt ?? order['updatedAt']
            );
        o = last;
      } else {
        //o = repo.get(order['id']);
        //o = OrderModel(
        //    o.id
        //);
      }

      repo.put(order['id'], o!).then((_) async {
        if (onSaved != null) {
          await onSaved();
        }
      });
    }*/
  }

  void createNewOrder() {
    repo.put(newOrderKey, newOrder);
  }
  
  void updateNewOrder(Map order, [FutureOr<dynamic> Function()? onSaved]) {
    if (repo.containsKey(newOrderKey)) {
      newOrder.driverId = order['driverId'] ?? newOrder.driverId;
      newOrder.clientId = order['clientId'] ?? newOrder.clientId;
      newOrder.tariffId = order['tariffId'] ?? newOrder.tariffId;
      newOrder.status = order['status'] ?? newOrder.status;
      newOrder.totalTime = order['totalTime'] ?? newOrder.totalTime;
      newOrder.totalSum = order['totalSum'] ?? newOrder.totalSum;
      newOrder.from = order['from'] ?? newOrder.from;
      newOrder.whither = order['whither'] ?? newOrder.whither;
      newOrder.comment = order['comment'] ?? newOrder.comment;
      newOrder.startedAt = order['startedAt'] ?? newOrder.startedAt;
      newOrder.createdAt = order['createdAt'] ?? newOrder.createdAt;
      newOrder.updatedAt = order['updatedAt'] ?? newOrder.updatedAt;
      repo.put(newOrderKey, newOrder).then((order) {
        if (onSaved != null) {
          onSaved();
        }
      });
    }
  }
}