import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

infoDialog(BuildContext context, String title, String message) {
  return showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
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

pickDialog(BuildContext context, String title, String message, String url) {
  return showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Open"),
                    onPressed: () async {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    }),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ]));
}
