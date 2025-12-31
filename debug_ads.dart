
import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final url = Uri.parse('https://kazuki-development.github.io/my_checklist_app/app-ads.txt');
  final expectedId = 'pub-9575784455721701';

  try {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(url);
    final response = await request.close();

    print('Status: ${response.statusCode}');
    print('Headers:');
    response.headers.forEach((name, values) {
      print('$name: $values');
    });

    final content = await response.transform(utf8.decoder).join();
    print('Content: "$content"');

    if (content.contains(expectedId)) {
      print('SUCCESS: ID found in content.');
    } else {
      print('FAILURE: ID NOT found in content.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
