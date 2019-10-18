



import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'GooglePlace.dart';



class GoogleAPI {


  static var googleApiUrl = "maps.googleapis.com/maps/api";
  static String apiKey;
  

  static Future<List<GooglePlace>> autocomplete(String text, {String type, String country, double lat, double lon, int metersBias, String language}) async {

    var completer = new Completer<List<GooglePlace>>();

    var mapQuery = Map<String, String>();
    mapQuery["input"] = text;
    mapQuery["key"] = apiKey;
    if (type != null) {
      mapQuery["types"] = type;
    }
    if (country != null) {
      mapQuery["components"] = "country:$country";
    }
    if (lat != null && lon != null) {
      mapQuery["location"] = "$lat,$lon";
    }
    if (metersBias != null) {
      mapQuery["radius"] = metersBias.toString();
    }
    if (language != null) {
      mapQuery["language"] = language;
    }
    var uri = Uri.https("maps.googleapis.com", "/maps/api/place/autocomplete/json", mapQuery);

    var client = new Client();
    var request = new Request("POST", uri);

    request.headers[HttpHeaders.contentTypeHeader] = "application/json";

    var response = await client.send(request);
    var str = await response.stream.bytesToString();
    var jsonResult = json.decode(str);
    var predictions = jsonResult["predictions"];

    var places = List<GooglePlace>();
    predictions.forEach((prediction) {
      var place = GooglePlace.autocompletion(prediction);
      places.add(place);
    });

    completer.complete(places);
    return completer.future;
  }


  static Future<List<GooglePlace>> geocodeCoordinates({double lat, double lon}) async {

    var completer = new Completer<List<GooglePlace>>();

    var requestUrl = "$googleApiUrl/geocode/json?&latlng=$lat,$lon&language=en&key=$apiKey";

    var client = new Client();
    var request = new Request("POST", Uri.parse(requestUrl));

    request.headers[HttpHeaders.contentTypeHeader] = "application/json";
    var response = await client.send(request);
    var str = await response.stream.bytesToString();

    var jsonResult = json.decode(str);
    var errorMessage = jsonResult["error_message"];
    if (errorMessage != null) {
      print(errorMessage);
    }
    var jsonToParse = jsonResult["results"];
    var places = List<GooglePlace>();
    jsonToParse.forEach((map) {
      var place = GooglePlace.geocode(map);
      places.add(place);
    });

    completer.complete(places);
    return completer.future;
  }


  static Future<Map> geocodePlaceId({String placeId}) async {

    var completer = new Completer<Map>();

    var requestUrl = "$googleApiUrl/geocode/json?&place_id=$placeId&language=en&key=$apiKey";

    var client = new Client();
    var request = new Request("POST", Uri.parse(requestUrl));

    request.headers[HttpHeaders.contentTypeHeader] = "application/json";
    var response = await client.send(request);
    var str = await response.stream.bytesToString();
    
    var jsonResult = json.decode(str);
    var result = jsonResult["results"].first;
    completer.complete(result);

    return completer.future;
  }
}



