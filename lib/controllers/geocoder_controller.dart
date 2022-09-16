import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:turbo_go/controllers/order_controller.dart';

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
  final OrderController _order = TurboGoBloc.orderController;
  static int maxPoints = 20;
  static final Map<String, int> zooms = {
    'country': 3,
    'city': 10,
    'street': 16,
    'building': 18
  };
  static final List<RegExp> unnecessaryTags = [
    RegExp('городской', caseSensitive: false), RegExp('округ', caseSensitive: false)
  ];
  static final Map amenities = {
    'supermarket': 'Супермаркет',
    'bar': 'Бар',
    'nightclub': 'Ночной клуб',
    'convenience': 'Магазин',
    'water_park': 'Аквапарк',
    'kindergarten': 'Детский сад',
    'school': 'Школа',
    'library': 'Библиотека',
    'bank': 'Банк',
    'hospital': 'Больница',
    'yes': '',
    'house': '',
    'apartments': '',
    'insurance': ''
  };
  static String format = 'jsonv2';
  List points = [];

  GeocoderController({value}) : super(value);

  void clearPoints () {
    points.clear();
    //notifyListeners();
  }

  static String buildSearchUrl (List pieces) {
    return '${TurboGoBloc.GEOCODER_URL}/search.php?format=$format&q=${pieces.join('+')}';
  }

  static String buildReverseUrl (List coordinates, Zooms zoom) {
    return '${TurboGoBloc.GEOCODER_URL}/reverse.php?format=$format&zoom=${zooms[zoom.name]}&lat=${coordinates[0]}&lon=${coordinates[1]}';
  }

  void _parseResponse(http.Response res, Map? from) {
    dynamic decodedBody = jsonDecode(res.body);
    if (decodedBody is List && decodedBody.isNotEmpty) {
      points.addAll(decodedBody.where((a) {
        if (!amenities.containsKey(a['type'])) return false;
        for (Map b in points) {
          if ((a['place_id'] == b['place_id']) || (a['osm_id'] == b['osm_id'])) return false;
        }

        if (a['osm_type'] == 'node') {
          if (a['lat'] == null || a['lon'] == null) return false;
          if (a['lat'] is String) a['lat'] = double.parse(a['lat']);
          if (a['lon'] is String) a['lon'] = double.parse(a['lon']);

          for (Map b in decodedBody.where(
              (c) =>
              c['osm_type']=='way' &&
              c['boundingbox'] is List &&
              c['boundingbox'].length == 4
          ).toList()) {
            double p1 = double.parse(b['boundingbox'][0]);
            double p2 = double.parse(b['boundingbox'][1]);
            double p3 = double.parse(b['boundingbox'][2]);
            double p4 = double.parse(b['boundingbox'][3]);
            List<LatLng> boundingBox = [
              LatLng(p1, p3),
              LatLng(p1, p4),
              LatLng(p2, p4),
              LatLng(p2, p3),
              LatLng(p1, p3)
            ];
            if (PolygonUtil.containsLocation(
                LatLng(a['lat'], a['lon']), boundingBox, true
            )) {
              return false;
            }
          }
        }

        return true;
      }));
      points.sort((a, b) {
        if (
        a['lat'] != null && a['lon'] != null &&
            b['lat'] != null && b['lon'] != null &&
            from?['coordinates'] is List &&
            from!['coordinates'][0] is double &&
            from['coordinates'][0] is double
        ) {
          if (a['lat'] is String) a['lat'] = double.parse(a['lat']);
          if (a['lon'] is String) a['lon'] = double.parse(a['lon']);
          if (b['lat'] is String) b['lat'] = double.parse(b['lat']);
          if (b['lon'] is String) b['lon'] = double.parse(b['lon']);

          num distanceA = SphericalUtil.computeDistanceBetween(LatLng(from['coordinates'][0], from['coordinates'][1]), LatLng(a['lat'], a['lon']));
          num distanceB = SphericalUtil.computeDistanceBetween(LatLng(from['coordinates'][0], from['coordinates'][1]), LatLng(b['lat'], b['lon']));

          return distanceA > distanceB ? 1 : -1;
        }

        return 0;
      });
      points = points.getRange(0, points.length >= maxPoints ? maxPoints : points.length).toList();
    }
    notifyListeners();
  }

  void search(List pieces) {
    //Future<http.Response>? res;
    Map? from = _order.newOrder.from;
    String? fromDesc = from?['desc'];

    if (fromDesc is String && fromDesc.isNotEmpty) {
      points.clear();
      List entries = fromDesc.split(', ');
      List first = List.from([entries[0]])..addAll(pieces);
      //pieces.insert(0, entries[0]);
      //res =
      http.get(Uri.parse(buildSearchUrl(
        first
      )))/*;
      res*/.then((res) {
        _parseResponse(res, from);
        /*if (points.isEmpty) {
          pieces.removeAt(0);

          res = http.get(Uri.parse(buildSearchUrl(
              pieces
          )));
          res?.then((response2) {
            _parseResponse(response2, from);
          });
        }*/
        if (points.length < (maxPoints / 2) && from?['address']['state'] != null) {
          List second = List.from([from?['address']['state']])..addAll(pieces);

          http.get(Uri.parse(buildSearchUrl(
              second
          ))).then((res) {
            _parseResponse(res, from);

            if (points.length < (maxPoints / 2)) {
              http.get(Uri.parse(buildSearchUrl(
                  pieces
              ))).then((res) {
                _parseResponse(res, from);
              });
            }
          });
        }
      });//.onError((error, stackTrace) => {
      //});
    }
    //return res;
  }

  void reverse(List coordinates, [CoordinateTypes coordinateType = CoordinateTypes.from, Zooms zoom = Zooms.building]) {
    Future<http.Response> res = http.get(Uri.parse(buildReverseUrl(coordinates, zoom)));
    Map point = {
      'type': 'Point',
      'coordinates': coordinates
    };

    res.then((res) {
      Map data = jsonDecode(res.body.toString());
      Map<String, dynamic>? address = data['address'];

      if (address != null) {
        point.addEntries([
          MapEntry('address', data['address'])
        ]);
        address = address.map((key, value) {
          if (unnecessaryTags.isNotEmpty && ['village', 'town', 'city'].contains(key)) {
            for (RegExp tag in unnecessaryTags) {
              if (value is String && value.toLowerCase().contains(tag)) {
                value = value.replaceAll(tag, '').trim();
              }
            }
          }
          return MapEntry(key, value);
        });
        String? object =
        address['village'] is String ?
        address['village'] :
        address['town'] is String ?
        address['town'] :
        address['city'] is String ?
        address['city'] : null;
        if (object is String && address['road'] is String) {
          String? name = data['name'];

          if (name is String && name.isNotEmpty && amenities.containsKey(data['type'])) {
            //String? amenity;
            name = name.replaceAll(RegExp(amenities[data['type']], caseSensitive: false), '').trim();
            if (!name.contains(RegExp('\'|"')) && !['school'].contains(data['type'])) {
              name = '"$name"';
            }

            point.addEntries([
              MapEntry(
                  'desc',
                  '${amenities[data['type']]} $name'
                  //'$object, ${address['road']}${address['house_number'] is String ? ', ${address['house_number']}' : ''}'
              )
            ]);
          } else {
            point.addEntries([
              MapEntry('desc', '$object, ${address['road']}${address['house_number'] is String ? ', ${address['house_number']}' : ''}')
            ]);
          }
        }
        _order.updateNewOrder({
          coordinateType.name: point
        });
      }
    }).catchError((error) {
      _order.updateNewOrder({
        coordinateType.name: point
      });
    });
  }
}