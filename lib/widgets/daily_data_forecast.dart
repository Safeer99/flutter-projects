import 'package:flutter/material.dart';
import 'package:weatherapp_starter_project/model/weather_data_hourly.dart';
import 'package:weatherapp_starter_project/utils/custom_colors.dart';
import 'package:intl/intl.dart';

class DailyDataForecast extends StatelessWidget {

  final WeatherDataHourly weatherDataDaily;

  const DailyDataForecast({super.key, required this.weatherDataDaily});

  String getDay(final day){
    DateTime time = DateTime.fromMillisecondsSinceEpoch(day * 1000, isUtc: true);
    String x = DateFormat('E').format(time);
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
       color:  CustomColors.dividerLine.withAlpha(150),
       borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text(
              "Next Days",
              style: TextStyle(color: CustomColors.textColorBlack, fontSize: 17),
            ),
          ),
          dailyList(),
        ],
      ),
    );
  }

  Widget dailyList(){
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: weatherDataDaily.hourly!.length,
        itemBuilder: (context, index){
          return Column(children: [
            Container(
              height: 60,
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      getDay(weatherDataDaily.hourly![index].dt), 
                      style: const TextStyle(color: CustomColors.textColorBlack, fontSize: 13),),
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset("assets/weather/${weatherDataDaily.hourly![index].weather![0].icon}.png")
                  ),
                  Text("${weatherDataDaily.hourly![index].temp}°")
              ]),
            ),
            Container(
              height: 1,
              color: CustomColors.dividerLine
            )
          ],);
        },
      ),
    );
  }

}