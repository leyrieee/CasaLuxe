import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../app_config.dart';

class ChatScreen extends StatelessWidget {
  final String channelId;
  final String artisanName;

  const ChatScreen({
    super.key,
    required this.channelId,
    required this.artisanName,
  });

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;
    final channel = client.channel('messaging', id: channelId);

    return StreamChannel(
      channel: channel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            artisanName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(
                  //messageBuilder: _customMessageBuilder,
                  ),
            ),
            const StreamMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _customMessageBuilder(
    BuildContext context,
    Message message,
    int index,
    List<Message> messages,
  ) {
    final isMyMessage =
        message.user?.id == StreamChat.of(context).currentUser?.id;
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMyMessage ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text ?? '',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isMyMessage ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
