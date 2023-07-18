import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherapp_starter_project/api/fetch_weather.dart';

import '../model/weather_data.dart';

class GlobalController extends GetxController {
  final RxBool _isLoading = true.obs;

  final RxDouble _latitude = 0.0.obs;
  final RxDouble _longitude = 0.0.obs;

  final RxInt _currentIndex = 0.obs;

  RxBool get checkLoading => _isLoading;
  RxDouble get getLatitude => _latitude;
  RxDouble get getLongitude => _longitude;

  final weatherData = WeatherData().obs;

  WeatherData getData(){
    return weatherData.value;
  }

  RxInt getIndex(){
    return _currentIndex;
  }

  @override
  void onInit() {
    if (_isLoading.isTrue) {
      getLocation();
    }else{
      getIndex();
    }
    super.onInit();
  }

  getLocation() async {
    bool isServiceEnabled;
    LocationPermission locationPermission;

    isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServiceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error("Location not enabled");
    }

      // print("permission");

    //? status permission
    locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error("Location permission are denied forever");
    } else if (locationPermission == LocationPermission.denied) {
      //? request permission
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error("Location permission is denied");
      }
    }

    //? getting the current position
    return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      _latitude.value = value.latitude;
      _longitude.value = value.longitude;

      //? calling weather api
      return FetchWeatherAPI().processData(value.latitude, value.longitude)
        .then((value) {
          weatherData.value = value;
          _isLoading.value = false;
        });
    });
  }

}
