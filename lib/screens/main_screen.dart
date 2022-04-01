import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_service/keyboard_service.dart';

import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/widgets/map_widget.dart';
import '/widgets/app_bar_widget.dart';
import '/widgets/bottom_sheet_widget.dart';
import '/widgets/navigation_bar_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TurboGoBloc, TurboGoState>(builder: (BuildContext ctx, TurboGoState state) {
      if (state is TurboGoConnectedState) {
        return
          KeyboardAutoDismiss(
            scaffold: Scaffold(
              resizeToAvoidBottomInset: true,
                body: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: const <Widget>[
                    MapWidget(),
                    AppBarWidget(),
                    BottomSheetWidget(),
                    NavigationBarWidget()
                  ],
                )
            ),
          )
          ;
      }
      return Container();
    });
  }
}