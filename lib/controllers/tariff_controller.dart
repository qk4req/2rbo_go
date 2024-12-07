import 'package:hive/hive.dart';
import '/models/tariff_model.dart';



class TariffController {
  Box<TariffModel> repo = Hive.box('tariffs');

  bool compare(Map tariff) {
    return tariff['updatedAt'] == repo.get(tariff['id'])?.updatedAt;
  }

  bool contains(Map tariff) {
    return repo.containsKey(tariff['id']);
  }

  bool containsById(int tariffId) {
    return contains({
      'id': tariffId
    });
  }

  void update(Map tariff) {
    //if (contains(tariff)) {
      TariffModel t = repo.get(tariff['id'])!;

      t.name = t.name ?? tariff['name'];
      t.mapIcon = t.mapIcon ?? tariff['mapIcon'];
      t.baseCost = t.baseCost ?? (tariff['baseCost'] as num).toDouble();
      t.submissionPerKm = t.submissionPerKm ?? (tariff['submissionPerKm'] as num).toDouble();
      t.ridePerKm = t.ridePerKm ?? (tariff['ridePerKm'] as num).toDouble();
      t.waitPerMin = t.waitPerMin ?? (tariff['waitPerMin'] as num).toDouble();
      t.createdAt = t.createdAt ?? tariff['createdAt'];
      t.updatedAt = t.updatedAt ?? tariff['updatedAt'];

      repo.put(t.id, t);
    //}
  }

  void create(Map tariff) async {
    //if (!contains(tariff)) {
      TariffModel t = TariffModel(
          tariff['id'],
          tariff['name'],
          tariff['mapIcon'],
          (tariff['baseCost'] as num).toDouble(),
          (tariff['submissionPerKm'] as num).toDouble(),
          (tariff['ridePerKm'] as num).toDouble(),
          (tariff['waitPerMin'] as num).toDouble(),
          tariff['createdAt'],
          tariff['updatedAt']
      );

      repo.put(t.id, t);
    //}
  }
}