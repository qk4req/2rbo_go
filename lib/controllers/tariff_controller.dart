import 'dart:async';
import 'package:hive/hive.dart';



import 'package:turbo_go/models/tariff_model.dart';

class TariffController {
  Box<TariffModel> repo = Hive.box('tariffs');

  bool compare(Map tariff) {
    return tariff['updatedAt'] == repo.get(tariff['id'])?.updatedAt;
  }

  bool contains(Map tariff) {
    return repo.containsKey(tariff['id']);
  }

  void update(Map tariff) {
    if (contains(tariff)) {
      TariffModel t = repo.get(tariff['id'])!;

      t.name = t.name ?? tariff['name'];
      print(tariff['mapIcon']);
      t.mapIcon = t.mapIcon ?? tariff['mapIcon'];
      t.baseCost = t.baseCost ?? (tariff['baseCost'] as num).toDouble();
      t.ridePerMin = t.ridePerMin ?? (tariff['ridePerMin'] as num).toDouble();
      t.submissionPerMin = t.submissionPerMin ?? (tariff['submissionPerMin'] as num).toDouble();
      t.ridePerKm = t.ridePerKm ?? (tariff['ridePerKm'] as num).toDouble();
      t.submissionPerKm = t.submissionPerKm ?? (tariff['submissionPerKm'] as num).toDouble();
      t.waitPerMin = t.waitPerMin ?? (tariff['waitPerMin'] as num).toDouble();
      t.createdAt = t.createdAt ?? tariff['createdAt'];
      t.updatedAt = t.updatedAt ?? tariff['updatedAt'];

      repo.put(t.id, t);
    }
  }

  void create(Map tariff) {
    if (!contains(tariff)) {
      TariffModel t = TariffModel(
          tariff['id'],
          tariff['name'],
          tariff['mapIcon'],
          (tariff['baseCost'] as num).toDouble(),
          (tariff['ridePerMin'] as num).toDouble(),
          (tariff['submissionPerMin'] as num).toDouble(),
          (tariff['ridePerKm'] as num).toDouble(),
          (tariff['submissionPerKm'] as num).toDouble(),
          (tariff['waitPerMin'] as num).toDouble(),
          tariff['createdAt'],
          tariff['updatedAt']
      );

      repo.put(t.id, t);
    }
  }
}