import 'package:c_agent_client/app/modules/chat/controller/_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = 700;

    final theme = Theme.of(context).colorScheme;

    final chatController = Get.put(ChatController());

    return Center(
      child: SizedBox(
        width: screenWidth,
        child: Scaffold(
          appBar: buildAppbar(theme),
          body: SafeArea(
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
                          return Row(
                            mainAxisAlignment:
                                chatController.messages[index].sender == "me"
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth * 0.7,
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color:
                                      chatController.messages[index].sender ==
                                              "me"
                                          ? theme.primary.withOpacity(.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      chatController.messages[index].sender ==
                                              "me"
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // MarkdownBody(
                                    //   data: chatController
                                    //       .messages[index].message,
                                    //   styleSheet: buildMarkdownStyle(theme),
                                    //   builders: {
                                    //     'code': CodeElementBuilder(),
                                    //   },
                                    // ),
                                    MarkdownWidget(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      data: chatController
                                          .messages[index].message,
                                    ),
                                    const SizedBox(height: 5),
                                    // Timestamp
                                    Text(
                                      chatController.messages[index].timestamp
                                          .toString(),
                                      style: TextStyle(
                                        color: theme.onSurface.withOpacity(.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
          )),
        ),
      ),
    );
  }
}

// class CodeElementBuilder extends MarkdownElementBuilder {
//   @override
//   Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
//     final code = element.textContent;
//     final language = element.attributes['language'] ?? 'plaintext';
//     return buildCodeBlock(code, language);
//   }
// }

// Widget buildCodeBlock(String code, String? language) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.grey[200], // Background color for code block
//       borderRadius: BorderRadius.circular(8),
//     ),
//     padding: const EdgeInsets.all(8),
//     child: SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: HighlightView(
//         code, // Pass the raw code, not parsed HTML
//         language: language ?? 'plaintext',
//         theme: githubTheme, // Use a theme from flutter_highlight
//         padding: const EdgeInsets.all(8),
//         textStyle: const TextStyle(
//           fontFamily: 'monospace',
//           fontSize: 14,
//         ),
//       ),
//     ),
//   );
// }

// MarkdownStyleSheet buildMarkdownStyle(ColorScheme theme) {
//   return MarkdownStyleSheet(
//     p: TextStyle(color: theme.onSurface, fontSize: 16),
//     code: TextStyle(
//       backgroundColor: theme.surfaceVariant.withOpacity(0.5),
//       color: theme.onSurface,
//       fontSize: 14,
//     ),
//     codeblockPadding: const EdgeInsets.all(16),
//     codeblockDecoration: BoxDecoration(
//       color: theme.surfaceVariant.withOpacity(0.5),
//       borderRadius: BorderRadius.circular(8),
//     ),
//   );
// }

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
          // Dynamic TextField
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
  );
}
