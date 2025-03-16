import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/theme/_theme.dart';
import 'app/modules/chat/controller/_chat_controller.dart';
import 'app/modules/chat/view/pages/_chat_view.dart';

void main() {
  Get.lazyPut(() => ChatController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: getTheme(),
      debugShowCheckedModeBanner: true,
      initialRoute: '/chat',
      defaultTransition: Transition.cupertino,
      getPages: [
        GetPage(name: '/chat', page: () => const ChatView()),
      ],
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
