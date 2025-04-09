import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:c_agent_client/app/modules/chat/controller/_chat_controller.dart';

class ChatService {
  Stream<String> getResponseStream(String message) async* {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.body = json.encode({
        "model": "codellama:7b-instruct",
        "prompt": message,
        "stream": true
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Process line by line as JSONL
        await for (var line in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (line.trim().isEmpty) continue;

          var jsonLine = json.decode(line);
          if (jsonLine.containsKey('response')) {
            yield jsonLine['response'];
          }
        }
      } else {
        throw Exception("Failed to load streamed response");
      }
    } catch (e) {
      throw Exception("Error streaming response: $e");
    }
  }
}
