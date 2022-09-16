import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import 'sheets/points_sheet.dart';
import 'sheets/tariffs_sheet.dart';
import 'sheets/driver_sheet.dart';
import 'sheets/chat_sheet.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';

class BottomSheetFragment extends StatefulWidget {
  const BottomSheetFragment({Key? key}) : super(key: key);

  @override
  _BottomSheetFragmentState createState() => _BottomSheetFragmentState();
}

class _BottomSheetFragmentState extends State<BottomSheetFragment>/* with TickerProviderStateMixin<BottomSheetWidget>*/{
  /* Animation<double> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;*/
  int _state = 0;
  late LocationTypes _focus;
  /*static const List<Widget> sheets = [
    const MainColumn(),
    PointsColumn(),
    TariffsColumn(),
    SizedBox(),
    DriverColumn(),
    ChatColumn()
  ];*/


  @override
  void initState() {
    super.initState();
    /*controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = CurvedAnimation(
      curve: curve,
      parent: controller,
    );
    Timer(const Duration(seconds: 10), () {
      controller.reverse(from: 1);
    });*/
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*double height = MediaQuery.of(context).size.height;
    TurboGoBloc.orderController.repo.watch().listen((event) {
      if (event.value)
    });*/
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) async {
        //if (state is TurboGoLocationHasChangedState) {
        //  await controller.animateTo(0, duration: const Duration(milliseconds: 200), curve: curve);
        //}

        /*if (state is TurboGoHomeState) {
          await controller.animateTo(0.3, duration: const Duration(milliseconds: 200), curve: curve);

          setState(() {
            _column = 0;
          });
        }*/

        if ([TurboGoHomeState, TurboGoSearchState].contains(state.runtimeType)) {
          //await controller.animateTo(0, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _state = 0;
          });
        }

        if (state is TurboGoPointsState) {
          //await controller.animateTo(state is TurboGoExtendedPointsState ? 0.8 : 0.42, curve: curve, duration: const Duration(milliseconds: 200));
          _focus = state.type;

          setState(() {
            _state = 1;
          });
        }

        if (state is TurboGoTariffsState) {
          //await controller.animateTo(0.4, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _state = 2;
          });
        }

        if (state is TurboGoDriverState) {
          //await controller.animateTo(0.5, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _state = 3;
          });
        }

        if (state is TurboGoChatState) {
          //await controller.animateTo(1, curve: curve, duration: const Duration(milliseconds: 200));

          setState(() {
            _state = 4;
          });
        }
      },
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position:
                Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                child: child,
              )
            );
          },
          child:
          _state == 1 ? PointsSheet(key: UniqueKey(), focus: _focus) :
          _state == 2 ? const TariffsSheet() :
          _state == 3 ? const DriverSheet() :
          _state == 4 ? const ChatSheet() :
          null
      ),
    );
  }
}