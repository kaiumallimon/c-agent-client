import 'package:c_agent_client/app/modules/chat/controller/_chat_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  final String baseUrl = "https://api.openai.com/v1/chat/completions";

  Future<MessageModel> getResponse(String message) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('http://localhost:3000/api/query/ask'));
      request.body = json.encode({"question": message});

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return MessageModel(
          message: jsonResponse['response'],
          sender: "agent",
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception("Failed to load response");
      }
    } catch (e) {
      throw Exception("Error fetching response: $e");
    }
  }
}
