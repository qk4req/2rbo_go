import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/bloc/turbo_go_state.dart';
import 'package:turbo_go/widgets/fragments/navigation_bar_fragment.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        BlocBuilder<TurboGoBloc, TurboGoState>(
            builder: (BuildContext ctx, TurboGoState state) {
              return Container(
                  color: const Color.fromRGBO(32, 33, 36, 1),
                  child:
                  state is TurboGoNotSupportedState ?
                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              'Необходимо обновить приложение!',
                              style: Theme.of(context).textTheme.headline5?.apply(
                                  color: Colors.redAccent
                              )
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Установленная версия: ${state.current}',
                              style: Theme.of(context).textTheme.subtitle2?.apply(
                                  color: Colors.white38
                              )
                          ),
                          Text(
                              'Необходимая версия: ${state.required}',
                              style: Theme.of(context).textTheme.subtitle2?.apply(
                                  color: Colors.white38
                              )
                          ),
                          /*const SizedBox(height: 10),
                          if (state.releaseNotes != null && state.releaseNotes!.isNotEmpty)
                            Column(
                              children: [
                                Text(
                                    'Изменения:',
                                    style: Theme.of(context).textTheme.subtitle1
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(3),
                                    itemCount: state.releaseNotes!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Center(
                                        child: Text(
                                            '- ${state.releaseNotes![index]}',
                                            style: Theme.of(context).textTheme.subtitle2?.apply(
                                                color: Colors.white38
                                            )
                                        ),
                                      );
                                    }
                                )
                              ],
                            )*/
                        ]
                    ),
                  ) :
                  state is TurboGoBannedState ?
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Ваш аккаунт заблокирован!',
                          style: Theme.of(context).textTheme.headline5?.apply(
                              color: Colors.redAccent
                          ),
                        )
                      ],
                    ),
                  ) :
                  state is TurboGoNotConnectedState ?
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                    ),
                  )
                  : null
              );
            }
        ),
        const NavigationBarFragment()
      ],
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/bloc/turbo_go_state.dart';
import 'package:turbo_go/widgets/fragments/navigation_bar_fragment.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(32, 33, 36, 1),
        child: Stack(
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
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                            transform: Matrix4.translationValues(-10, 0, 0),
                            child: const SizedBox(
                              child: Image(
                                image: AssetImage('lib/assets/images/logo.png'),
                                color: Colors.white,
                              ),
                              height: 100,
                              width: 100,
                            )
                        )
                      ],
                    )
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: BlocBuilder<TurboGoBloc, TurboGoState>(
                        builder: (BuildContext ctx, TurboGoState state) {
                          if (state is TurboGoNotConnectedState) {
                            return Column(
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
                            );
                          }

                          if (state is TurboGoNotSupportedState) {
                            Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      'Необходимо обновить приложение!',
                                      style: Theme.of(context).textTheme.headline5?.apply(
                                          color: Colors.red
                                      )
                                  ),
                                  /*const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      'Установленная версия: ${state.current}',
                                      style: Theme.of(context).textTheme.subtitle2?.apply(
                                          color: Colors.white38
                                      )
                                  ),
                                  Text(
                                      'Доступная версия: ${state.required}',
                                      style: Theme.of(context).textTheme.subtitle2?.apply(
                                          color: Colors.white38
                                      )
                                  ),
                                  const SizedBox(height: 10),
                                  if (state.releaseNotes != null && state.releaseNotes!.isNotEmpty)
                                    Column(
                                      children: [
                                        Text(
                                            'Изменения:',
                                            style: Theme.of(context).textTheme.subtitle1
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.all(3),
                                            itemCount: state.releaseNotes!.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Center(
                                                child: Text(
                                                    '- ${state.releaseNotes![index]}',
                                                    style: Theme.of(context).textTheme.subtitle2?.apply(
                                                        color: Colors.white38
                                                    )
                                                ),
                                              );
                                            }
                                        )
                                      ],
                                    )*/
                                ]
                            );
                          }

                          return Container();
                        }
                    )
                )
              ],
            ),
            const NavigationBarFragment()
          ],
        )
    );
  }
}*/