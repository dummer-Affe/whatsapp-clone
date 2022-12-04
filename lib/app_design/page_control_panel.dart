import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_app/smart_app.dart';
import 'package:whatsapp_clone/states/contact_state.dart';
import '../../main.dart';
import '../states/conversation_state.dart';
import '../states/conversation_user_state.dart';
import 'appBar.dart';
import 'drawer.dart';

class PageControlPanel extends StatefulWidget {
  const PageControlPanel({Key? key}) : super(key: key);

  @override
  State<PageControlPanel> createState() => _PageControlPanelState();
}

class _PageControlPanelState extends State<PageControlPanel> {
  @override
  void initState() {
    appSettings.listenState(this);
    appSettings.onConnectionChange = (connection) {
      print("Current Conneciton:$connection");
    };
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appFonts.init(context);
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: MyAppbar(),
      drawer: appSettings.anyMobile ? MyDrawer() : null,
      body: SmartPage(),
    );
  }
}
