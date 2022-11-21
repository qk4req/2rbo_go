import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/bloc/turbo_go_event.dart';
import 'package:turbo_go/controllers/reg_controller.dart';

class RegPage extends StatefulWidget {
  const RegPage({Key? key}) : super(key: key);

  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final RegController reg = TurboGoBloc.regController;
  final _phoneNumberKey = GlobalKey<FormBuilderFieldState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _phoneNumberValue;

  @override
  void initState() {
    reg.addListener(() {
      if (reg.response == null) {
        _showTopFlash(context, 'Не удалось подключиться к серверу!');
      } else {
        if (!reg.response!['success'] && reg.response!['message'] is String) {
          _showTopFlash(context, reg.response!['message']);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            color: const Color.fromRGBO(32, 33, 36, 1),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 25),
                  child: Text(
                    'ЕЩЁ НЕМНОГО',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                  color: Colors.black38,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10,
                            right: 10
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Text(
                          '+7',
                          style: Theme.of(context).textTheme.subtitle1?.apply(color: Colors.white38),
                        ),
                      ),
                      Expanded(child: FormBuilderTextField(
                          key: _phoneNumberKey,
                          name: 'phoneNumber',
                          keyboardType: TextInputType.number,
                          controller: _phoneNumberController,
                          autofocus: true,
                          decoration: const InputDecoration(
                              hintText: 'Номер телефона',
                              hintStyle: TextStyle(
                                  color: Colors.white38
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                          ),
                          style: Theme.of(context).textTheme.subtitle1,
                          onChanged: (String? text) {
                            if (text != null) {
                              setState(() {
                                _phoneNumberValue = text;
                              });
                            }
                          }
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0
                          ).animate(animation),
                          child: child
                      );
                    },
                    child:
                      _phoneNumberValue == null || (_phoneNumberValue != null && _phoneNumberValue!.isEmpty) ?
                        const Text(
                          'Номер телефона нужен для связи с вами',
                          style: TextStyle(
                            color: Colors.red
                          ),
                        ) :
                          _phoneNumberValue?.length != 10 ?
                            const Text(
                              'Длина номера телефона должна быть равна 10',
                              style: TextStyle(
                                  color: Colors.red
                              ),
                            ) : Container()
                  ),
                )
              ],
            )
        ),
        ValueListenableBuilder(
            valueListenable: _phoneNumberController,
            builder: (BuildContext ctx, TextEditingValue text, Widget? wid) {

              return Container(
                child:
                  _phoneNumberController.text.length == 10 ?
                    Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              splashFactory: InkRipple.splashFactory,
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                              fixedSize: MaterialStateProperty.all(
                                  Size(
                                      (MediaQuery.of(context).size.width * 0.8),
                                      60
                                  )
                              ),
                              backgroundColor: MaterialStateProperty.all(Colors.black38),
                            ),
                            onPressed: () {
                              BlocProvider.of<TurboGoBloc>(context).add(TurboGoSignUpEvent(_phoneNumberValue!));
                            },
                            child: Row(
                              children: <Widget>[
                                Expanded(child:
                                Text(
                                  'Продолжить',
                                  style: Theme.of(context).textTheme.headline6,
                                )
                                ),
                                Row(
                                  children: [
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
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ) :
                    null
              );
            }
        )
      ],
    );
  }

  _showTopFlash(BuildContext context, String message) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 10),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          /*backgroundGradient: RadialGradient(
                colors: [Colors.redAccent, Colors.black87],
                center: Alignment.topLeft,
                radius: 2.5,
              ),*/
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          boxShadows: const [BoxShadow(blurRadius: 4)],
          barrierBlur: 3.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          behavior: FlashBehavior.fixed,
          position: FlashPosition.top,
          useSafeArea: true,
          child: FlashBar(
            title: const Text('Ошибка'),
            content: Text(message),
            showProgressIndicator: false,
            primaryAction: TextButton(
              onPressed: () => controller.dismiss(),
              child: const Text('ПОНЯТНО', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        );
      },
    );
  }
}