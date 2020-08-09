import 'package:fox_music/utils/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppleTextInput extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  Widget suffixIcon;
  FormFieldValidator<String> validator;
  TextInputAction inputAction;
  TextInputType keyboardType;
  bool obscureText;
  ValueChanged<String> onChanged;

  AppleTextInput(
      {@required this.labelText,
      @required this.hintText,
      @required this.controller,
      this.suffixIcon,
      this.validator,
      this.inputAction,
      this.keyboardType,
      this.obscureText,
      this.onChanged});

  @override
  State<StatefulWidget> createState() => AppleTextInputState();
}

class AppleTextInputState extends State<AppleTextInput> {
  bool isEmpty;
  
  @override
  void initState() {
    isEmpty = widget.controller.text.isEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0.0,
      child: Stack(
        children: <Widget>[
          TextFormField(
            style: TextStyle(color: Colors.white),
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            obscureText: widget.obscureText ?? false,
            controller: widget.controller,
            onChanged: (String text) {
              setState(() {
                isEmpty = text.isEmpty;
              });
              widget.onChanged(text);
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 25, left: 16, bottom: 8),
                hintText: widget.hintText,
                focusColor: Colors.transparent,
                filled: true,
                suffixIcon: widget.suffixIcon,
                hintStyle: TextStyle(color: HexColor.icon(), fontSize: 15),
                fillColor: HexColor('#424242'),
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(9.0),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(9.0),
                  ),
                )),
          ),
          Padding(
              padding: EdgeInsets.only(top: 8, left: 16),
              child: Text(
                widget.labelText,
                style: TextStyle(
                    color: isEmpty ? Colors.white : Colors.grey, fontSize: 13),
              ))
        ],
      ),
    );
  }
}
