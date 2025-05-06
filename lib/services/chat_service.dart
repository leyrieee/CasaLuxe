import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  late final StreamChatClient client;

  ChatService._internal() {
    client = StreamChatClient(
      'naktakq7n2jc',
      logLevel: Level.INFO,
    );
  }

  Future<void> connectUser({
    required String userId,
    required String userName,
  }) async {
    final user = User(id: userId, name: userName);
    final token = client.devToken(userId);
    await client.connectUser(user, token.rawValue);
  }

  Future<Channel> createOrGetChannelWithArtisan(String artisanId) async {
    final channel = client.channel(
      'messaging',
      extraData: {
        'members': [client.state.currentUser!.id, artisanId],
      },
    );
    await channel.watch();
    return channel;
  }

  Future<void> disconnectUser() async {
    await client.disconnectUser();
  }
}
