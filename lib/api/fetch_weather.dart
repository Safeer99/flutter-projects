import 'dart:convert';

import 'package:weatherapp_starter_project/api/api_key.dart';
import 'package:weatherapp_starter_project/model/weather_data_current.dart';
import 'package:weatherapp_starter_project/model/weather_data_hourly.dart';
import '../model/weather_data.dart';
import 'package:http/http.dart' as http;

class FetchWeatherAPI{

  WeatherData? weatherData;

  //? processing the data from response to json
  Future<WeatherData> processData(lat, lon) async {
    var response = await http.get(Uri.parse(apiUrl(lat,lon)));
    var jsonString = jsonDecode(response.body);
    var responseHourly = await http.get(Uri.parse(apiUrlHourly(lat,lon)));
    var jsonStringHourly = jsonDecode(responseHourly.body);
    weatherData = WeatherData(WeatherDataCurrent.fromJson(jsonString), WeatherDataHourly.fromJson(jsonStringHourly));
    return weatherData!;
  }

}

String apiUrl(var lat, var lon){
  String url;
  url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
  return url;
}

String apiUrlHourly(var lat, var lon){
  String url;
  url = "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
  return url;
}