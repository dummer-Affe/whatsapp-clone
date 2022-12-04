import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_app/smart_app.dart';
import 'package:whatsapp_clone/app_design/page_control_panel.dart';
import 'package:whatsapp_clone/pages/home_page/home_page.dart';
import 'package:whatsapp_clone/states/contact_state.dart';
import 'package:whatsapp_clone/states/conversation_user_state.dart';
import 'states/conversation_state.dart';
import 'models/user/conversation_user.dart';
import 'firebase_options.dart';
import 'pages/login_page/login_page.dart';
import 'states/app_user_state.dart';

late AppUserState userState;
late ConversationUserState conversationUserState;
late ConversationState conversationState;
late AppColors appColors;
late AppFonts appFonts;
late AppSettings appSettings;
late PageState pageState;
late ContactState contactState;
late String appDir;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  appDir = (await getApplicationDocumentsDirectory()).path;
  userState = Get.put(AppUserState());
  //await checkAuth();
  String initPage = userState.userId == null ? "login" : "home";
  AppPages appPages = AppPages(pages: {
    "home": const HomePage(),
    "login": const LoginPage(),
  }, initPage: initPage);
  AppLanguages languages =
      AppLanguages(languages: ["English", "Turkish"], initLanguge: "English");
  AppAppearances appearances = AppAppearances(appearances: [
    Appearance.dark(),
    Appearance.light(),
  ], initAppearance: Appearance.dark());
  SmartApp.setup(
      pages: appPages, languages: languages, appearances: appearances);
  appSettings = SmartApp.appSettings;
  appFonts = SmartApp.appFonts;
  appColors = SmartApp.appColors;
  pageState = SmartApp.pageState;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Future<void> checkAuth() async {
  FirebaseAuth.instance.authStateChanges().listen((User? userTmp) async {
    if (userTmp == null) {
      print('AppUser is currently signed out!');
    } else {
      await userState.signIn(userTmp);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.<
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return PageControlPanel();
  }
}
