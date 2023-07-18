import 'package:weatherapp_starter_project/model/weather_data_current.dart';
import 'package:weatherapp_starter_project/model/weather_data_hourly.dart';

class WeatherData{
  final WeatherDataCurrent? current;
  final WeatherDataHourly? hourly;

  WeatherData([this.current, this.hourly]);

  String getTime(final timeStamp) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000, isUtc: true);
    return time.toString().substring(11, 13);
  }

  WeatherDataCurrent getCurrentWeather() => current!;
  WeatherDataHourly getHourlyWeather() => hourly!;
  WeatherDataHourly getDailyWeather(){
    WeatherDataHourly? daily = WeatherDataHourly();
    daily.hourly = [];
    hourly?.hourly?.forEach((element) {
      String x = getTime(element.dt);
      if(x == "12"){
        daily.hourly!.add(element);
      }else if(daily.hourly!.isEmpty && (x == "15" || x == "18" || x == "21")){
        daily.hourly!.add(element);
      }
    });
    return daily;
  }

}