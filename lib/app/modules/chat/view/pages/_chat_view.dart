import 'package:c_agent_client/app/modules/chat/controller/_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final theme = Theme.of(context).colorScheme;

    final chatController = Get.put(ChatController());

    return Scaffold(
      appBar: buildAppbar(theme),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: screenWidth > 700
                ? 700
                : screenWidth, // Limit width on larger screens
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // chats
                  Expanded(
                    child:
                        DynMouseScroll(builder: (context, controller, physics) {
                      return Obx(() {
                        if (chatController.messages.isEmpty) {
                          return Center(
                            child: Text(
                              "No messages yet",
                              style: TextStyle(color: theme.onSurface),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: chatController.messages.length,
                          controller: controller,
                          physics: physics,
                          itemBuilder: (context, index) {
                            return buildMessageCard(
                              theme,
                              chatController.messages[index],
                              index,
                              screenWidth,
                              chatController,
                            );
                          },
                        );
                      });
                    }),
                  ),

                  // text field
                  CustomExpandableTextfield(
                    theme: theme,
                    controller: chatController.controller,
                    onSendPressed: chatController.sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomExpandableTextfield extends StatelessWidget {
  const CustomExpandableTextfield({
    super.key,
    required this.theme,
    required this.controller,
    required this.onSendPressed,
  });

  final ColorScheme theme;
  final TextEditingController controller;
  final VoidCallback onSendPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // RawKeyboardListener to detect Enter key press
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50,
              maxHeight: 300,
            ),
            child: IntrinsicHeight(
              child: TextField(
                controller: controller,
                maxLines: null, // Allows unlimited lines
                expands: true, // Expands to fill available space
                style: TextStyle(color: theme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.onSurface.withOpacity(.5)),
                ),
                onChanged: (text) {
                  // Rebuild the widget to adjust the height
                },
                onSubmitted: (text) {
                  // This is called when the user presses the Enter key
                  if (text.trim().isNotEmpty) {
                    onSendPressed();
                  }
                },
                textInputAction: TextInputAction.send,
              ),
            ),
          ),

          // Send Button
          IconButton.filled(
            onPressed: () {
              onSendPressed();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(theme.primary),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

AppBar buildAppbar(ColorScheme theme) {
  return AppBar(
    title: const Text('C-Agent',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    toolbarHeight: 60,
    backgroundColor: theme.primary,
    foregroundColor: theme.onPrimary,
    actions: [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          Get.find<ChatController>().clearMessages();
        },
      ),
    ],
  );
}

Widget buildMessageCard(ColorScheme theme, MessageModel message, int index,
    double screenWidth, ChatController chatController) {
  return Align(
    alignment: message.sender == 'agent'
        ? Alignment.centerLeft
        : Alignment.centerRight,
    child: Container(
      constraints: BoxConstraints(
        maxWidth:
            screenWidth * 0.8, // Dynamically adjust width based on screen size
      ),
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: message.sender == 'agent'
            ? Colors.transparent
            : theme.primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownWidget(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            data: chatController.messages[index].message,
            config: MarkdownConfig(configs: [
              PreConfig(
                wrapper: (child, code, language) {
                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        code,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          color: theme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              )
            ]),
          ),

          const SizedBox(height: 5),

          // Message time
          Text(
            formatTime(message.timestamp),
            style: TextStyle(
              color: theme.onSurface.withOpacity(.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

String formatTime(DateTime time) {
  // output: 02:05 PM, 23/10/2023
  String formattedTime =
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}, ${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}";
  return formattedTime;
}
