import 'package:http/http.dart' as http;
import 'dart:convert';

class PumpService {
  final String _baseUrl = 'https://is4ac-nursery.research-ai.my.id/api';

  // Fungsi untuk mengubah status pompa berdasarkan id_alat
  Future<bool> togglePumpStatus(int idAlat) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/aturpompamanual'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_alat': idAlat, // Kirimkan id_alat untuk mengidentifikasi alat
        }),
      );

      // Debugging log
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Periksa jika responseData mengandung status
        if (responseData.containsKey('status')) {
          final status = responseData['status']; // Ambil status dari response
          return status == 1; // Return true jika status pompa hidup
        } else {
          throw Exception('Format response tidak sesuai');
        }
      } else {
        throw Exception('Gagal menghubungi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
