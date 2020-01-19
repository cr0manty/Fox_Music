import 'package:flutter/material.dart';

void chooseDialog(
    BuildContext context, String title, String fButton, String sButton,
    {firstFunction, secondFunction}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        actions: <Widget>[
          new FlatButton(
              child: new Text(fButton),
              onPressed: () {
                Navigator.of(context).pop();
                if (firstFunction != null) firstFunction();
              }),
          new FlatButton(
            child: new Text(sButton),
            onPressed: () {
              Navigator.of(context).pop();
              if (secondFunction != null) secondFunction();
            },
          ),
        ],
      );
    },
  );
}
