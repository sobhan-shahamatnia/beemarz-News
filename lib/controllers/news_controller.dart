import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsController extends GetxController {
  // Observable variables for state management.
  var newsList = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Replace with your actual PHP endpoint URL.
  final String endpointUrl = 'https://beemarz.eu/get_news.php';

  // Retrieve the API key from the environment variables.
  final String apiKey = dotenv.env['FLUTTER_API_KEY'] ?? '';

  // Fetch news from the backend.
  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(endpointUrl),
        headers: {
          'X-API-KEY': apiKey,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          // Ensure data['data'] is a List of maps.
          newsList.assignAll(List<Map<String, dynamic>>.from(data['data']));
          errorMessage.value = '';
        } else {
          errorMessage.value = data['message'] ?? 'خطای نامشخص';
        }
      } else {
        errorMessage.value = 'خطا از سرور: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
