import 'package:c_agent_client/app/modules/chat/services/_chat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final TextEditingController controller = TextEditingController();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;

  final ChatService chatService = ChatService();

  void sendMessage() {
    final input = controller.text.trim();
    if (input.isEmpty) {
      Get.snackbar("Error", "Message cannot be empty");
      return;
    }

    // Add user message
    final userMessage = MessageModel(
      message: input,
      sender: "me",
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);

    // Prepare streamed assistant message
    final streamedMessage = MessageModel(
      message: "",
      sender: "agent",
      timestamp: DateTime.now(),
    );
    messages.add(streamedMessage);

    controller.clear();
    isLoading.value = true;

    // Start streaming response
    chatService.getResponseStream(input).listen(
      (chunk) {
        streamedMessage.message += chunk;
        messages.refresh(); // notify UI
      },
      onDone: () {
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar("Error", error.toString());
        messages.remove(streamedMessage); // remove incomplete agent msg
      },
    );
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  void clearMessages() {
    messages.clear();
  }
}

class MessageModel {
  String message; // <- removed 'final'
  final String sender;
  final DateTime timestamp;

  MessageModel({
    required this.message,
    required this.sender,
    required this.timestamp,
  });
}
