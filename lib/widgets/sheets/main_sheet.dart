import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';



import '../map_widget.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';

class MainSheet extends StatefulWidget {
  const MainSheet({Key? key}) : super(key: key);

  @override
  _MainSheetState createState() => _MainSheetState();
}

class _MainSheetState extends State<MainSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            BlocProvider.of<TurboGoBloc>(context).add(TurboGoChangeEndPointEvent());
          },
          child: Row(
            children: <Widget>[
              const Expanded(child: Text(
                'Куда поедем?',
                style: TextStyle(
                    fontSize: 20
                ),
              )),
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
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(48, 49, 52, 1))
          ),
        )
      ],
    );
  }
}