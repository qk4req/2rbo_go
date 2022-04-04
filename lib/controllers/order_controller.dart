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

  void create(Map order) {
    OrderModel o =
        OrderModel(
            order['id'],
            order['driverId'],
            order['clientId'],
            order['tariffId'],
            order['status'],
            order['totalTime'],
            (order['totalSum'] as num).toDouble(),
            order['from'],
            order['whither'],
            order['comment'],
            order['startedAt'],
            order['createdAt'],
            order['updatedAt']
        );

    repo.put(o.id, o);
  }

  void update(Map order) {
    OrderModel o = repo.get(order['id'])!;

    o.driverId = o.driverId ?? order['driverId'];
    o.clientId = o.clientId ?? order['clientId'];
    o.tariffId = o.tariffId ?? order['tariffId'];
    o.status = o.status ?? order['status'];
    o.totalTime = o.totalTime ?? order['totalTime'];
    o.totalSum = o.totalSum ?? order['totalSum'];
    o.from = o.from ?? order['from'];
    o.whither = o.whither ?? order['whither'];
    o.comment = o.comment ?? order['comment'];
    o.startedAt = o.startedAt ?? order['startedAt'];
    o.createdAt = o.createdAt ?? order['createdAt'];
    o.updatedAt = o.updatedAt ?? order['updatedAt'];

    repo.put(o.id, o);
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

  OrderModel? getLast() {
    return repo.values.last;
  }
}