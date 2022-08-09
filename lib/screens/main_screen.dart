import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_service/keyboard_service.dart';



import '/widgets/pages/error_page.dart';
import '/widgets/pages/loading_page.dart';
import '/widgets/pages/main_page.dart';
import '/widgets/pages/reg_page.dart';

import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>/* with TickerProviderStateMixin<MainScreen>*/ {
  /*late Animation<double> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;*/
  int _state = 0;
  bool fromReg = false;

  @override
  void initState() {
    //controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    //animation = Tween<double>(begin: 0, end: 1).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) {
        if (state is TurboGoConnectedState) {
          setState(() {
            _state = 1;

            if (state is TurboGoSearchState) {
              fromReg = state.fromReg;
            }
          });
        }

        if (state is TurboGoRegState) {
          setState(() {
            _state = 2;
          });
        }

        if (
        [
          TurboGoNotConnectedState,
          TurboGoNotSupportedState
        ].contains(state.runtimeType) && _state != 0
        ) {
          setState(() {
            _state = 3;
          });
        }
      },
      child: KeyboardAutoDismiss(
        scaffold: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body:
                PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (List<Widget> entries) {
                    return Container(
                      transform: Matrix4.translationValues(0.5, 0.5, 0),
                      color: Colors.black,//const Color.fromRGBO(32, 33, 36, 1),
                      child: Stack(
                        children: entries,
                        alignment: Alignment.center,
                      ),
                    );
                  },
                  transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
                    return FadeThroughTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        child: child,
                    );
                  },
                  child:
                    _state == 0 ? const LoadingPage() :
                    _state == 1 ? MainPage(fromReg: fromReg) :
                    _state == 2 ? const RegPage() :
                    _state == 3 ? const ErrorPage() :
                    null
                )
            /*AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                        begin: const Offset(1.5, 0), end: Offset.zero
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: Tween<double>(
                          begin: 0.0, end: 1.0
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child:
                _state == 0 ? LoadingPage(fromMain: fromMain) :
                _state == 1 ? MainPage(fromReg: fromReg) :
                _state == 2 ? const RegPage() :
                _state == 3 ? const ErrorPage() :
                null
            )*/
        ),
      )
    );
  }
}