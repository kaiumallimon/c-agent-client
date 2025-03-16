import 'package:c_agent_client/app/modules/chat/services/_chat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final TextEditingController controller = TextEditingController();

  void showError(String title, String message) {
    Get.snackbar(title, message,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        maxWidth: 700);
  }

  List<MessageModel> messages = <MessageModel>[].obs;

  RxBool isLoading = false.obs;

  void sendMessage() async {
    if (controller.text.isEmpty) {
      showError("Error", "Message cannot be empty");
      return;
    }
    isLoading.value = true;
    try {
      ChatService chatService = ChatService();

      MessageModel message = MessageModel(
        message: controller.text,
        sender: "me",
        timestamp: DateTime.now(),
      );

      final loadingMessage = MessageModel(
        message: "Loading...",
        sender: "agent",
        timestamp: DateTime.now(),
      );

      messages.add(message);
      messages.add(loadingMessage);

      controller.clear();

      MessageModel response = await chatService.getResponse(message.message);
      // Remove the loading message
      messages.removeWhere((msg) => msg.message == "Loading...");
      messages.add(response);
      print(messages);
    } catch (e) {
      showError("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

class MessageModel {
  final String message;
  final String sender;
  final DateTime timestamp;

  MessageModel({
    required this.message,
    required this.sender,
    required this.timestamp,
  });
}
