import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:turbo_go/widgets/pages/error_page.dart';
import 'package:turbo_go/widgets/pages/loading_page.dart';
import 'package:turbo_go/widgets/pages/main_page.dart';
import 'package:turbo_go/widgets/pages/reg_page.dart';

import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  int _state = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) {
        if (state is TurboGoConnectedState) {
          setState(() {
            _state = 1;
          });
        }

        if (state is TurboGoRegState) {
          setState(() {
            _state = 2;
          });
        }

        if (state is TurboGoNotConnectedState) {
          setState(() {
            _state = 3;
          });
        }
      },
      child: KeyboardAutoDismiss(
        scaffold: Scaffold(
            resizeToAvoidBottomInset: false,
            body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
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
                _state == 0 ? const LoadingPage() :
                _state == 1 ? const MainPage() :
                _state == 2 ? const RegPage() :
                _state == 3 ? const ErrorPage() :
                null
            )
        ),
      )
    );
  }
}