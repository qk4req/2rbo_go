import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/models/order_model.dart';
import '/models/tariff_model.dart';

class TariffsColumn extends StatefulWidget {
  const TariffsColumn({Key? key}) : super(key: key);

  @override
  _TariffsColumnState createState() => _TariffsColumnState();
}

class _TariffsColumnState extends State<TariffsColumn> {
  Box<OrderModel> orders = TurboGoBloc.orderController.repo;
  Box<TariffModel> tariffs = TurboGoBloc.tariffController.repo;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    /*TurboGoBloc.mapController?.moveCamera(
      CameraUpdate.newBounds(
        const BoundingBox(northEast: Point(latitude: 5.0, longitude: 5.0), southWest: Point(latitude: 5.5, longitude: 5.5))
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 2)
    );*/
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
              tariffs.values.map((t) {
                return ValueListenableBuilder(
                    valueListenable: orders.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                    builder: (ctx, Box box, wid) {
                      OrderModel newOrder = box.get(TurboGoBloc.orderController.newOrderKey);
                      return Opacity(
                        opacity: (newOrder.tariffId == t.id) ? 1 : 0.3,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: OutlinedButton(
                            onPressed: () {
                              BlocProvider.of<TurboGoBloc>(context).add(TurboGoSelectTariffEvent(t.id));
                              /*TurboGoBloc.orderController.updateNewOrder({
                                  'tariff': {
                                    'id': t.id
                                  }
                                }
                              );*/
                              buttonCarouselController.animateToPage(tariffs.values.toList().indexOf(t));
                            },
                            child: Text('${t.name}')
                          ),
                        ),
                      );
                    }
                );
              }).toList()
          ),
        ),
        SingleChildScrollView(
          child: CarouselSlider(
              carouselController: buttonCarouselController,
              items: tariffs.values.map((t) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    '${t.name}',
                    style: const TextStyle(
                        color: Colors.white
                    )
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 200,
                aspectRatio: 16/9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: false,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal
              )
          ),
        )
      ],
    );
  }
}