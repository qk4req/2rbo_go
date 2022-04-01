import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import 'columns/main_column.dart';
import 'columns/points_column.dart';
import 'columns/tariffs_column.dart';
import 'columns/driver_column.dart';
import 'columns/chat_column.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/bloc/turbo_go_state.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({Key? key}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget>  with TickerProviderStateMixin<BottomSheetWidget>{
  late Animation<double> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;
  int _column = 0;
  final List<Widget?> columns = [
    //const MainColumn(),
    const PointsColumn(),
    const TariffsColumn(),
    Container(),
    const DriverColumn(),
    const ChatColumn()
  ];


  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = CurvedAnimation(
      curve: curve,
      parent: controller,
    );
    //WidgetsBinding.instance?.addPostFrameCallback((duration) {
    //});
    /*Timer(const Duration(seconds: 10), () {
      controller.reverse(from: 1);
    });*/
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    //TurboGoBloc.orderController.repo.watch().listen((event) {
    //  if (event.value)
    //});
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (ctx, state) async {
        if (state is TurboGoLocationHasChangedState) {
          await controller.animateBack(0, duration: const Duration(milliseconds: 200), curve: curve);
        }

        /*if (state is TurboGoHomeState) {
          await controller.animateTo(0.3, duration: const Duration(milliseconds: 200), curve: curve);

          setState(() {
            _column = 0;
          });
        }*/

        if (state is TurboGoPointsState) {
          await controller.animateTo(state is TurboGoExtendedPointsState ? 0.8 : 0.42, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _column = 0;
          });
        }

        if (state is TurboGoTariffsState) {
          await controller.animateTo(0.4, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _column = 1;
          });
        }

        if (state is TurboGoSearchState) {
          await controller.animateTo(0, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _column = 2;
          });
        }

        if (state is TurboGoDriverState) {
          await controller.animateTo(0.5, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _column = 3;
          });
        }

        if (state is TurboGoChatState) {
          await controller.animateTo(1, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _column = 4;
          });
        }
      },
      child: AnimatedBuilder(
        builder: (ctx, child) {
          return SizedBox(
            height: height * animation.value,
            child: child,
          );
        },
        animation: animation,
        child: SingleChildScrollView(
          reverse: false,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: height,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        color: const Color.fromRGBO(32, 33, 36, 1),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: columns[_column]
                        ),
                      ),
                    ),
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
}