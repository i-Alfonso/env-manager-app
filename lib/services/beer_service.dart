import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class BeerService {
  // Function to fetch beer data from the API
  Future<Map<String, dynamic>> fetchBeer() async {
    var beerOptions = ["ale", "stouts"];
    var beerType = beerOptions[Random().nextInt(2)];
    var beerId = Random().nextInt(beerType == "ale" ? 181 : 118);
    final response = await http.get(Uri.parse("https://api.sampleapis.com/beers/$beerType"));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      List<dynamic> data = jsonDecode(response.body);
      // Filter the element with id value equal to 3
      var filteredElement = data.where((element) => element['id'] == beerId).toList();
      // print(filteredElement);
      return filteredElement.first as Map<String, dynamic>;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load beer data');
    }
  }
}