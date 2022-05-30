import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:turbo_go/controllers/client_controller.dart';
import 'package:turbo_go/controllers/clients_online_controller.dart';
import 'package:uuid/uuid.dart';



import '/bloc/turbo_go_bloc.dart';
import '/controllers/timestamp_controller.dart';
import '/models/order_model.dart';

class OrderController {
  final TimestampController _timestamp = TurboGoBloc.timestampController!;
  final ClientsOnlineController _clientsOnline = TurboGoBloc.clientsOnlineController;
  final Socket _socket = TurboGoBloc.socket;
  late String newOrderKey;
  late OrderModel newOrder;
  OrderModel? last;
  Box<OrderModel> repo = Hive.box('orders');

  OrderController() {
    //createNewOrder();
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

  OrderModel create(Map order, [bool sync = true]) {
    OrderModel o = OrderModel(
        order['uuid'],
        order['driverId'],
        order['clientId'],
        order['tariffId'],
        order['carId'],
        order['status'] ?? 'filled',
        order['totalTime'] ?? 0,
        order['totalSum'] != null ? (order['totalSum'] as num).toDouble() : 0,
        order['from'] != null ? (order['from'] is String ? jsonDecode(order['from']) : order['from']) : null,
        order['whither'] != null ? (order['whither'] is String ? jsonDecode(order['whither']) : order['whither']) : null,
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

  OrderModel update(Map order, [bool sync = true, FutureOr<dynamic> Function()? onSaved]) {
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

    repo.put(o.uuid, o).then((value) async {
      if (onSaved != null) await onSaved();
    });

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
      'uuid': newOrderKey,
      'from': {
        'type': 'Point',
        'coordinates': [_clientsOnline.clientsOnlineModel?.location?['coordinates'][0], _clientsOnline.clientsOnlineModel?.location?['coordinates'][1]]
      }
    }, sync);
  }
  
  void updateNewOrder(Map order, [bool sync = true, FutureOr<dynamic> Function()? onSaved]) {
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
      }, sync, onSaved);
    //}
  }

  OrderModel? findLast() {
    //OrderModel? last;
    if (repo.isEmpty) return null;

    List m = repo.values.where((OrderModel o) {
      return (['confirmed', 'active', 'pause', 'wait'].contains(o.status));
    }).toList();

    if (m.isNotEmpty) {
      m.sort((a, b) {
        DateTime f = DateTime.parse(a.createdAt);
        DateTime s = DateTime.parse(b.createdAt);

        return f.compareTo(s);
      });
      last = m.last;
    } else {
      List n = repo.values.where((OrderModel o) {
        return o.status == 'refused';
      }).toList();

      if (n.isNotEmpty) {
        n.sort((a, b) {
          DateTime f = DateTime.parse(a.createdAt);
          DateTime s = DateTime.parse(b.createdAt);

          return f.compareTo(s);
        });
        last = n.last;
      } else {
        List n = repo.values.where((OrderModel o) {
          return o.status == 'filled';
        }).toList();

        if (n.isNotEmpty) {
          n.sort((a, b) {
            DateTime f = DateTime.parse(a.createdAt);
            DateTime s = DateTime.parse(b.createdAt);

            return f.compareTo(s);
          });
          last = n.last;
        }
      }
    }

    return last;
  }
}