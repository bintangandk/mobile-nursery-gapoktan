import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/control_state.dart';

class ControlService {
  final String baseUrl = 'https://your-api-url.com/api'; // Sesuaikan dengan URL Laravel API

  // Fetch status pompa dari server
  Future<ControlState> fetchControlState() async {
    final response = await http.get(Uri.parse('$baseUrl/control'));

    if (response.statusCode == 200) {
      return ControlState.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load control state');
    }
  }

  // Update status pompa (true/false) di server
  Future<void> updateControlState(bool isPumpActive) async {
    final response = await http.put(
      Uri.parse('$baseUrl/control'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'is_pump_active': isPumpActive}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update control state');
    }
  }
}
