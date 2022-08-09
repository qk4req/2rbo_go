import 'package:flutter/material.dart';

import '../fragments/app_bar_fragment.dart';
import '../fragments/bottom_sheet_fragment.dart';
import '../fragments/map_fragment.dart';
import '../fragments/navigation_bar_fragment.dart';

class MainPage extends StatefulWidget {
  final bool fromReg;
  const MainPage({Key? key, required this.fromReg}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late bool fromReg;

  @override
  void initState() {
    fromReg = widget.fromReg;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        MapFragment(fromReg: fromReg),
        const AppBarFragment(),
        const BottomSheetFragment(),
        const NavigationBarFragment()
      ],
    );
  }
}