import 'package:flutter/material.dart';

import '../app_bar_widget.dart';
import '../bottom_sheet_widget.dart';
import '../map_widget.dart';
import '../navigation_bar_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: const <Widget>[
        MapWidget(),
        AppBarWidget(),
        BottomSheetWidget(),
        NavigationBarWidget()
      ],
    );
  }
}