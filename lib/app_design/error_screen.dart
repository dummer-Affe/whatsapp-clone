import 'package:flutter/material.dart';
import 'package:smart_app/smart_app.dart';

import '../../main.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: appFonts.appWidth,
      height: appFonts.appHeight,
      child: Column(
        children: [
          Spacer(),
          ExpandedText(
            "404",
            alignment: Alignment.center,
            style: appFonts.mega(color: const Color(0xFF82b7ff)),
          ),
          ExpandedText(
            "Sorry, we couldn’t find that page…",
            alignment: Alignment.center,
            style: appFonts.M(color: const Color(0xFF82b7ff)),
          ),
          Expanded(
            flex: 5,
            child: Image(
              image: AssetImage("assets/confused.png"),
            ),
          ),
          ExpandedText(
            "But Dash is here to help - maybe one of these will point you in the right direction?",
            alignment: Alignment.center,
            style: appFonts.M(color: const Color(0xFF82b7ff)),
          ),
          Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }
}
