import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/global_controller.dart';
import '../utils/custom_colors.dart';
import '../widgets/header_widget.dart';
import 'package:weatherapp_starter_project/widgets/current_weather_widget.dart';
import 'package:weatherapp_starter_project/widgets/hourly_weather_widget.dart';
import 'package:weatherapp_starter_project/widgets/daily_data_forecast.dart';
import 'package:weatherapp_starter_project/widgets/comfort_level.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalController globalController =
      Get.put(GlobalController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Obx(() => globalController.checkLoading()
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/clouds.png", 
                        height: 200, width: 200,
                      ),
                      const CircularProgressIndicator()
                    ],
                  )
                ) : Center(
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const HeaderWidget(),
                        CurrentWeatherWidget(
                          weatherDataCurrent: globalController.getData().getCurrentWeather(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        HourlyWeatherWidget(
                          weatherDataHourly: globalController.getData().getHourlyWeather(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DailyDataForecast(
                          weatherDataDaily: globalController.getData().getDailyWeather(),
                        ),
                        Container(
                          height: 1,
                          color: CustomColors.dividerLine
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ComfortLevel(
                          weatherDataCurrent: globalController.getData().getCurrentWeather(),
                        )
                      ],
                    ),
                )
            )
        )
      );
  }
}
