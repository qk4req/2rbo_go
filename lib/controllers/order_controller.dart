import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';



import '/bloc/turbo_go_bloc.dart';
import '/controllers/timestamp_controller.dart';
import '/models/order_model.dart';

class OrderController {
  final TimestampController _timestamp = TurboGoBloc.timestampController!;
  final Socket _socket = TurboGoBloc.socket;
  late String newOrderKey;
  late OrderModel newOrder;
  Box<OrderModel> repo = Hive.box('orders');

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

  bool contains(Map order) {
    return repo.containsKey(order['uuid']);
  }

  bool compare(Map order) {
    return order['updatedAt'] == repo.get(order['uuid'])?.updatedAt;
  }

  OrderModel create(Map order, [bool sync = false]) {
    OrderModel o = OrderModel(
        order['uuid'],
        order['driverId'],
        order['clientId'],
        order['tariffId'],
        order['carId'],
        order['status'] ?? 'filled',
        order['totalTime'] ?? 0,
        order['totalSum'] != null ? (order['totalSum'] as num).toDouble() : 0,
        order['from'] != null ? jsonDecode(order['from']) : null,
        order['whither'] != null ? jsonDecode(order['whither']) : null,
        order['comment'],
        order['startedAt'],
        order['createdAt'] ?? _timestamp.create().toString(),
        order['updatedAt'] ?? _timestamp.create().toString(),
    );

    repo.put(o.uuid, o);

    if (sync) {
      _socket.emit('orders.create', [
        {
          'uuid': o.uuid,
          'driverId': o.driverId,
          'clientId': o.clientId,
          'tariffId': o.tariffId,
          'carId': o.carId,
          'status': o.status,
          'from': o.from,
          'whither': o.whither,
          'comment': o.comment,
          'totalTime': o.totalTime,
          'totalSum': o.totalSum,
          'startedAt': o.startedAt,
          'createdAt': o.createdAt,
          'updatedAt': o.updatedAt
        }
      ]);
    }

    return o;
  }

  OrderModel update(Map order, [bool sync = false]) {
    OrderModel o = repo.get(order['uuid'])!;

    o.driverId = order['driverId'] ?? o.driverId;
    o.clientId = order['clientId'] ?? o.clientId;
    o.tariffId = order['tariffId'] ?? o.tariffId;
    o.carId = order['carId'] ?? o.carId;
    o.status = order['status'] ?? o.status;
    o.totalTime = order['totalTime'] ?? o.totalTime;
    o.totalSum = order['totalSum'] != null ? (order['totalSum'] as num).toDouble() : o.totalSum;
    o.from = order['from'] != null ? (order['from'] is String ? jsonDecode(order['from']) : order['from']) : o.from;
    o.whither = order['whither'] != null ? (order['whither'] is String ? jsonDecode(order['whither']) : order['whither']) : o.whither;
    o.comment = order['comment'] ?? o.comment;
    o.startedAt = order['startedAt'] ?? o.startedAt;
    o.createdAt = order['createdAt'] ?? o.createdAt;
    o.updatedAt = order['updatedAt'] ?? _timestamp.create().toString();

    repo.put(o.uuid, o);

    if (sync) {
      _socket.emit('orders.update', [
        {
          'driverId': o.driverId,
          'clientId': o.clientId,
          'tariffId': o.tariffId,
          'carId': o.carId,
          'status': o.status,
          'from': o.from,
          'whither': o.whither,
          'comment': o.comment,
          'totalTime': o.totalTime,
          'totalSum': o.totalSum,
          'startedAt': o.startedAt,
          'createdAt': o.createdAt,
          'updatedAt': o.updatedAt,
        },
        {
          'uuid': o.uuid
        }
      ]);
    }

    return o;
  }

  void createNewOrder([bool sync = true]) {
    newOrderKey = const Uuid().v4();
    newOrder = create({
      'uuid': newOrderKey
    }, sync);
  }
  
  void updateNewOrder(Map order, [bool sync = true]) {
    //if (repo.containsKey(newOrderKey)) {
      newOrder = update({
        'uuid': newOrderKey,
        'driverId': order['driverId'],
        'clientId': order['clientId'],
        'tariffId': order['tariffId'],
        'carId': order['carId'],
        'status': order['status'],
        'from': order['from'],
        'whither': order['whither'],
        'comment': order['comment'],
        'totalTime': order['totalTime'],
        'totalSum': order['totalSum'],
        'startedAt': order['startedAt'],
        'createdAt': order['createdAt'],
        'updatedAt': order['updatedAt']
      }, sync);
    //}
  }
}