import 'package:casaluxe/firebase_options.dart';
import 'package:casaluxe/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize Stream Chat client
  final chatService = ChatService();
  final streamClient = chatService.client;

  runApp(CasaLuxeApp(chatClient: streamClient));
}

class CasaLuxeApp extends StatelessWidget {
  final StreamChatClient chatClient;

  const CasaLuxeApp({super.key, required this.chatClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casa Luxe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
      ),
      builder: (context, child) => StreamChat(
        client: chatClient,
        child: child!,
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
