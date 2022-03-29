import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:turbo_go/widgets/navigation_bar_widget.dart';

import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';
import '/widgets/map_widget.dart';
import '/widgets/bottom_sheet_widget.dart';

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
              //appBar: AppBar(title: Text("test"),),
                body: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: const <Widget>[
                    MapWidget(),
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