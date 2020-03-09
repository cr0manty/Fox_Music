import 'package:flutter/cupertino.dart';

class BottomRoute extends PageRouteBuilder {
  final Widget page;

  BottomRoute({this.page})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                page,
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                SlideTransition(
                  position: animation.drive(
                      Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.ease))),
                  child: child,
                ));
}
