import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

infoDialog(BuildContext context, String title, String message) {
  return showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]));
}
