import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

showPickerDialog(BuildContext context, int count, _builder) {
  showDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Add song to playlist'),
        content: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Container(
                    height: 250,
                    child: ListView.builder(
                        itemCount: count,
                        itemBuilder: (context, index) => _builder(index))))),
        actions: <Widget>[
          CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Confirm"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      );
    },
  );
}
