import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: const Color.fromRGBO(32, 33, 36, 1),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Shimmer.fromColors(
                  child: const Image(
                    image: AssetImage('lib/assets/images/icon-tail.png'),
                    width: 100,
                    height: 100,
                  ),
                  baseColor: Colors.white60,
                  highlightColor: Colors.white,
                ),
                const Image(
                  image: AssetImage('lib/assets/images/icon-point.png'),
                  width: 100,
                  height: 100,
                ),
              ],
            ),
            Text(
                'Turbo.Go',
                style: Theme.of(context).textTheme.headline6
            )
          ],
        )
      ],
    );
  }
}