import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/bloc/turbo_go_state.dart';
import 'package:turbo_go/widgets/fragments/navigation_bar_fragment.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin<LoadingPage> {
  late Animation<double> animation;
  late AnimationController controller;
  final Curve curve = Curves.easeIn;
  int _state = 0;
  bool fromMain = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //if (fromMain) {
    //  _state = 1;
    //}
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<double>(begin: 0.6, end: 0.4).animate(controller);
    WidgetsBinding.instance!.addPostFrameCallback((duration) {
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurboGoBloc, TurboGoState>(
      listener: (BuildContext ctx, TurboGoState state) {
        if (state is TurboGoNotConnectedState) {
          controller.forward();
          setState(() {
            _state = 1;
          });
        }
        if (state is TurboGoNotSupportedState) {
          controller.forward();
          setState(() {
            _state = 2;
          });
        }
      },
      child:
        Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: const Color.fromRGBO(32, 33, 36, 1),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext ctx, Widget? child) {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height * animation.value,
                        child: child
                    );
                  },
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                      _state == 0 ?
                      Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                              transform: Matrix4.translationValues(-10, 0, 0),
                              child: Shimmer.fromColors(
                                child: AnimatedBuilder(
                                    animation: animation,
                                    builder: (BuildContext ctx, Widget? child) {
                                      return SizedBox(
                                        child: child,
                                        height: 250 * animation.value,
                                        width: 250 * animation.value,
                                      );
                                    },
                                    child: const Image(
                                        image: AssetImage('lib/assets/images/logo.png')
                                    )
                                ),
                                baseColor: Colors.white60,
                                highlightColor: Colors.white,
                                //baseColor: Colors.blueAccent,
                                //highlightColor: Colors.white60,
                              )
                          )
                        ],
                      ) :
                      Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                              transform: Matrix4.translationValues(-10, 0, 0),
                              child: AnimatedBuilder(
                                  animation: animation,
                                  builder: (BuildContext ctx, Widget? child) {
                                    return SizedBox(
                                      child: child,
                                      height: 250 * animation.value,
                                      width: 250 * animation.value,
                                    );
                                  },
                                  child: const Image(
                                    image: AssetImage('lib/assets/images/logo.png'),
                                    color: Colors.white,
                                  )
                              )
                          )
                        ],
                      )
                  ),
                ),
                AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext ctx, Widget? child) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * (1 - animation.value),
                          child: child
                      );
                    },
                    child:
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child:
                        _state == 1 ?
                        Column(
                          children: [
                            Text(
                                'Отсутствует подключение к Интернету!',
                                style: Theme.of(context).textTheme.headline5?.apply(
                                    color: Colors.red
                                )
                            ),
                            const SizedBox(
                                height: 15
                            ),
                            Text(
                                'Машину можно заказать, позвонив в диспетчерскую',
                                style: Theme.of(context).textTheme.subtitle2?.apply(
                                  color: Colors.white38
                                )
                            )
                          ],
                        ) :
                        _state == 2 ?
                        Column(
                          children: [
                            Text(
                                'Необходимо обновить приложение!',
                                style: Theme.of(context).textTheme.headline5?.apply(
                                    color: Colors.red
                                )
                            )
                          ],
                        ) : null
                    )
                )
              ],
            ),
            const NavigationBarFragment()
          ],
        )
    );
  }
}