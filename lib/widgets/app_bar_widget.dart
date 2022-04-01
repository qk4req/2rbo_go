import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';



import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_state.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({Key? key}) : super(key: key);

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<TurboGoBloc, TurboGoState>(
              builder: (BuildContext ctx, TurboGoState state) {
                if (state is TurboGoSearchState) {
                  return Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                            child: Shimmer.fromColors(
                              baseColor: Colors.white38,
                              highlightColor: Colors.white,
                              child: const Center(
                                child: Text(
                                  'Идёт поиск машины...',
                                  //textAlign: TextAlign.center,
                                  style: TextStyle(
                                    //fontSize: 40.0,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            height: 100,
                            //width: MediaQuery.of(context).size.height/2,
                          )
                      )
                    ],
                  );
                }
                return Container();
              }
          )
        ],
    );
  }

}