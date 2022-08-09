import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:http/http.dart' as http;

//enum GeocodingType {
//  direct, reverse
//}

enum Zooms {
  country,
  city,
  street,
  building
}

enum CoordinateTypes {
  from, whither
}

class GeocoderController extends ValueNotifier {
  List? points;
  final _orderController = TurboGoBloc.orderController;
  static String format = 'jsonv2';
  static final Map<String, int> _zooms = {
    'country': 3,
    'city': 10,
    'street': 16,
    'building': 18
  };

  GeocoderController({value}) : super(value);

  static String buildSearchUrl (List pieces) {
    return '${TurboGoBloc.GEOCODER_URL}/search?format=$format&q=${pieces.join('+')}';
  }

  static String buildReverseUrl (List coordinates, Zooms zoom) {
    return '${TurboGoBloc.GEOCODER_URL}/reverse?format=$format&zoom=${_zooms[zoom.name]}&lat=${coordinates[0]}&lon=${coordinates[1]}';
  }

  Future<http.Response>? search(List pieces) {
    Future<http.Response>? res;

    String? fromDesc = _orderController.newOrder.from?['desc'];
    if (fromDesc is String && fromDesc.isNotEmpty) {
      List entries = fromDesc.split(', ');
      pieces.insert(0, entries[0]);
      Future<http.Response> res = http.get(Uri.parse(buildSearchUrl(
        pieces
      )));
      res.then((res) {
        points = jsonDecode(res.body);
        notifyListeners();
      });//.onError((error, stackTrace) => {
      //});
    }

    return res;
  }

  Future<http.Response> reverse(List coordinates, [CoordinateTypes coordinateType = CoordinateTypes.from, Zooms zoom = Zooms.building]) {
    Future<http.Response> res = http.get(Uri.parse(buildReverseUrl(coordinates, zoom)));
    Map point = {
      'type': 'Point',
      'coordinates': coordinates
    };

    res.then((res) {
      Map data = jsonDecode(res.body.toString());

      if (data['address']['town'] is String && data['address']['road'] is String) {
        point.addEntries([
          MapEntry('desc', '${data['address']['town']}, ${data['address']['road']}${data['address']['house_number'] is String ? ', ${data['address']['house_number']}' : ''}')
        ]);
      }
      _orderController.updateNewOrder({
        coordinateType.name: point
      });
    }).catchError((error) {
      _orderController.updateNewOrder({
        coordinateType.name: point
      });
    });

    return res;
  }
}