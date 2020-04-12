import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text,
    {int seconds, SnackBarAction action}) {
  return;
  Scaffold.of(context).showSnackBar(SnackBar(
    backgroundColor: Color.fromRGBO(20, 20, 20, 0.9),
    content: Text(text, style: TextStyle(color: Colors.grey)),
    duration: Duration(seconds: seconds ?? 3),
    action: action ??
        SnackBarAction(
          textColor: Colors.grey,
          label: 'OK',
          onPressed: () {},
        ),
  ));
}
