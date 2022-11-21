import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http_client_helper/http_client_helper.dart';
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
  static const List<String> urls = ['https://nominatim.openstreetmap.org'];//'http://92.255.107.194:8080'
  static String get url => urls[0];
  Map<int, CancellationToken> cancelTokens = {};
  final OrderController _order = TurboGoBloc.orderController;
  static const Duration _timeLimit = Duration(milliseconds: 5000);
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
  static List<String> countryCodes = ['ru'];
  List points = [];
  ValueNotifier<Map> r = ValueNotifier({});

  GeocoderController({value}) : super(value);

  void clearPoints () {
    points.clear();
    //notifyListeners();
  }

  static String buildSearchUrl (List pieces) {
    return '$url/search.php?format=$format&q=${pieces.join('+')}&countrycodes=${countryCodes.join(',')}';
  }

  static String buildReverseUrl (List coordinates, Zooms zoom) {
    return '$url/reverse.php?format=$format&zoom=${zooms[zoom.name]}&lat=${coordinates[0]}&lon=${coordinates[1]}';
  }

  void _parseResponse(http.Response res, Map? from, [int? max]) {
    dynamic decodedBody = jsonDecode(res.body);
    if (decodedBody is List && decodedBody.isNotEmpty) {
      if (max != null) {
        decodedBody = decodedBody.getRange(0, decodedBody.length < max ? decodedBody.length : max);
      }

      points.addAll(decodedBody.where((a) {
        if (a['lat'] == null || a['lon'] == null) return false;
        if (a['lat'] is String) a['lat'] = double.parse(a['lat']);
        if (a['lon'] is String) a['lon'] = double.parse(a['lon']);

        if (!amenities.containsKey(a['type'])/* || (a['display_name'] is String && !['россия', 'russia'].contains(a['display_name'].toLowerCase()))*/) return false;
        for (Map b in points) {
          if ((a['place_id'] == b['place_id']) || (a['osm_id'] == b['osm_id'])) return false;
        }

        if (a['osm_type'] == 'node') {
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
        if (a['lat'] != null && a['lon'] != null &&
            b['lat'] != null && b['lon'] != null &&
            from?['coordinates'] is List &&
            from!['coordinates'][0] is double &&
            from['coordinates'][0] is double) {
          //if (a['lat'] is String) a['lat'] = double.parse(a['lat']);
          //if (a['lon'] is String) a['lon'] = double.parse(a['lon']);
          //if (b['lat'] is String) b['lat'] = double.parse(b['lat']);
          //if (b['lon'] is String) b['lon'] = double.parse(b['lon']);

          num distanceA = SphericalUtil.computeDistanceBetween(LatLng(from['coordinates'][0], from['coordinates'][1]), LatLng(a['lat'], a['lon']));
          num distanceB = SphericalUtil.computeDistanceBetween(LatLng(from['coordinates'][0], from['coordinates'][1]), LatLng(b['lat'], b['lon']));

          return distanceA > distanceB ? 1 : -1;
        }

        return 0;
      });
      points = points.getRange(0, points.length >= maxPoints ? maxPoints : points.length).toList();
    }
    //notifyListeners();
  }

  void _addCancelToken(int i) {
    if (cancelTokens.containsKey(i)) {
      cancelTokens[i]!.cancel();
      cancelTokens.remove(i);
    }
    cancelTokens.addAll({
      i: CancellationToken()
    });
  }

  void search(List pieces) async {
    clearPoints();

    try {
      _addCancelToken(1);
      await HttpClientHelper.get(
        Uri.parse(buildSearchUrl(pieces)),
        retries: 0,
        cancelToken: cancelTokens[1],
        timeLimit: _timeLimit,
        onTimeout: () => Response('Request Timeout', 408)
      )
      .then((Response? res) async {
        if (res == null || res.statusCode == 408) {
          notifyListeners();
        } else {
          Map? from = _order.newOrder.from;
          _parseResponse(res, from, 5);

          String? fromDesc = from?['desc'];
          if (/*points.length < maxPoints && */fromDesc is String && fromDesc.isNotEmpty) {
            cancelTokens[1]!.cancel();
            _addCancelToken(2);
            List entries = fromDesc.split(', ');
            List first = List.from([entries[0]])..addAll(pieces);

            await HttpClientHelper.get(
              Uri.parse(buildSearchUrl(first)),
              retries: 0,
              cancelToken: cancelTokens[2],
              timeLimit: _timeLimit,
              onTimeout: () => Response('Request Timeout', 408)
            ).then((Response? res) async {
              if (res == null || res.statusCode == 408) {
                notifyListeners();
              } else {
                _parseResponse(res, from);

                if (points.length < maxPoints && from?['address']['state'] != null) {
                  cancelTokens[2]!.cancel();
                  _addCancelToken(3);
                  List second = List.from([from?['address']['state']])..addAll(pieces);

                  await HttpClientHelper.get(
                    Uri.parse(buildSearchUrl(second)),
                    retries: 0,
                    cancelToken: cancelTokens[3],
                    timeLimit: _timeLimit,
                    onTimeout: () => Response('Request Timeout', 408)
                  ).then((res) {
                    if (res != null && res.statusCode != 408) {
                      _parseResponse(res, from);
                    }

                    notifyListeners();
                  });
                } else {
                  notifyListeners();
                }
              }
            });
          } else {
            notifyListeners();
          }
        }
      });
    } on OperationCanceledError catch (_) {
    } catch (_) {
      notifyListeners();
    }

    /*http.get(Uri.parse(buildSearchUrl(
        pieces
    ))).then((res) {
      _parseResponse(res, from, 5);

      String? fromDesc = from?['desc'];
      if (/*points.length < maxPoints && */fromDesc is String && fromDesc.isNotEmpty) {
        points.clear();
        List entries = fromDesc.split(', ');
        List first = List.from([entries[0]])..addAll(pieces);

        http.get(Uri.parse(buildSearchUrl(
            first
        ))).then((res) {
          _parseResponse(res, from);

          if (points.length < maxPoints && from?['address']['state'] != null) {
            List second = List.from([from?['address']['state']])..addAll(pieces);

            http.get(Uri.parse(buildSearchUrl(
                second
            ))).then((res) {
              _parseResponse(res, from);

              notifyListeners();
            }).timeout(const Duration(milliseconds: _timeLimit), onTimeout: () {
              notifyListeners();
            });
          } else {
            notifyListeners();
          }
        }).timeout(const Duration(milliseconds: _timeLimit), onTimeout: () {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    }).timeout(const Duration(milliseconds: _timeLimit), onTimeout: () {
      notifyListeners();
    });*/
  }

  void reverse(List coordinates, [CoordinateTypes coordinateType = CoordinateTypes.from, Zooms zoom = Zooms.building]) async {
    Map point = {
      'type': 'Point',
      'coordinates': coordinates
    };

    try {
      _addCancelToken(0);
      await HttpClientHelper.get(Uri.parse(buildReverseUrl(coordinates, zoom)),
          retries: 0,
          cancelToken: cancelTokens[0],
          timeLimit: _timeLimit,
          onTimeout: () => Response('Request Timeout', 408)
      ).then((res) {
        if (res == null || res.statusCode == 408) {
          r.value = {
            coordinateType.name: point
          };
          _order.updateNewOrder(r.value);
          notifyListeners();
        }
        else {
          if (res.body.isNotEmpty) {
            Map data = jsonDecode(res.body.toString());
            Map<String, dynamic>? address = data['address'];

            if (address != null) {
              point.addEntries([MapEntry('address', data['address'])]);
              address = address.map((key, value) {
                if (unnecessaryTags.isNotEmpty &&
                    ['village', 'town', 'city'].contains(key)) {
                  for (RegExp tag in unnecessaryTags) {
                    if (value is String && value.toLowerCase().contains(tag)) {
                      value = value.replaceAll(tag, '').trim();
                    }
                  }
                }
                return MapEntry(key, value);
              });
              String? object = address['village'] is String
                  ? address['village']
                  : address['town'] is String
                  ? address['town']
                  : address['city'] is String
                  ? address['city']
                  : null;
              if (object is String && address['road'] is String) {
                String? name = data['name'];

                if (name is String &&
                    name.isNotEmpty &&
                    amenities.containsKey(data['type'])) {
                  //String? amenity;
                  name = name
                      .replaceAll(
                      RegExp(amenities[data['type']], caseSensitive: false),
                      '')
                      .trim();
                  if (!name.contains(RegExp('\'|"')) &&
                      !['school'].contains(data['type'])) {
                    name = '"$name"';
                  }

                  point.addEntries([
                    MapEntry('desc', '${amenities[data['type']]} $name'
                      //'$object, ${address['road']}${address['house_number'] is String ? ', ${address['house_number']}' : ''}'
                    )
                  ]);
                } else {
                  point.addEntries([
                    MapEntry('desc',
                        '$object, ${address['road']}${address['house_number'] is String ? ', ${address['house_number']}' : ''}')
                  ]);
                }
              }
              r.value = {coordinateType.name: point};
              _order.updateNewOrder(r.value);
              r.notifyListeners();
            }
          }
        }
      });
    }/* on TimeoutException catch (_) {
    } on OperationCanceledError catch (_) {
    }*/ catch (_) {
      r.value = {
        coordinateType.name: point
      };
      _order.updateNewOrder(r.value);
      notifyListeners();
    }
  }
}