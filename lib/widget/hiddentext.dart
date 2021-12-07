import 'dart:math';

import 'package:flutter/material.dart';

class HiddenText extends StatefulWidget {
  final String text;
  final int len;
  final TextStyle style;
  const HiddenText({Key? key, required this.text, required this.len, required this.style}) : super(key: key);

  @override
  _HiddenTextState createState() => _HiddenTextState();
}

class _HiddenTextState extends State<HiddenText> {
  bool long = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          long = !long;
        });
      },
      child: Text(long ? widget.text : widget.text.substring(0, min(widget.text.length, widget.len)) + (widget.len < widget.text.length ? '...' : ''), style: widget.style,),
    );
  }
}
