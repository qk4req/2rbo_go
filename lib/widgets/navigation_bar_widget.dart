import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';


import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/bloc/turbo_go_event.dart';
import '/models/order_model.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.end,
        direction: Axis.vertical,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: BlocBuilder<TurboGoBloc, TurboGoState>(
              builder: (BuildContext ctx, TurboGoState state) {
                return ValueListenableBuilder(
                    valueListenable: TurboGoBloc.orderController.repo.listenable(keys: [TurboGoBloc.orderController.newOrderKey]),
                    builder: (ctx, Box<OrderModel> box, wid) {
                      OrderModel? newOrder = box.get(TurboGoBloc.orderController.newOrderKey);

                      return Container(
                        child:
                        newOrder?.from == null ?
                        null :
                        BlocBuilder<TurboGoBloc, TurboGoState>(
                            builder: (ctx, state) {
                              if (state is! TurboGoDriverState && state is! TurboGoSearchState) {
                                return _button(
                                    Text(
                                      (
                                          (state is TurboGoPointsState) ||
                                          (
                                            state is TurboGoLocationHasChangedState &&
                                            state.prevState is TurboGoPointsState
                                          ) ? ((newOrder?.whither == null) ? 'Скажу водителю' : 'Далее') : 'Заказать'
                                      ),
                                      style: const TextStyle(
                                          fontSize: 18
                                      ),
                                    ),
                                        () {
                                      switch (state.runtimeType) {
                                        case TurboGoPointsState:
                                        case TurboGoExtendedPointsState:
                                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoSelectTariffEvent());
                                          break;
                                        case TurboGoTariffsState:
                                          BlocProvider.of<TurboGoBloc>(context).add(TurboGoFindDriverEvent());
                                          break;
                                      }
                                    }
                                );
                              } else {
                                return Container();
                              }
                            }
                        ),
                      );
                    }
                );
              },
            ),
          )
        ]
    );
  }

  Widget _button(Widget child, void Function()? onPressed) {
    return OutlinedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
        maximumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width * 0.8
        ), 60)),
        backgroundColor: MaterialStateProperty.all(Colors.black38),
      ),
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          Expanded(child: child),
          Container(
            color: Colors.black38,
            height: 50,
            width: 2,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          ),
          const Icon(
            Icons.arrow_forward_outlined,
          )
        ],
      ),
    );
  }
}