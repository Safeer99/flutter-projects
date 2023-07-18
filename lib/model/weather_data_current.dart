class WeatherDataCurrent{
  final Current current;
  WeatherDataCurrent({required this.current});

  factory WeatherDataCurrent.fromJson(Map<String, dynamic> json) => WeatherDataCurrent(current: Current.fromJson(json));

}

class Current {
  int? temp;
  int? humidity;
  int? pressure;
  double? feelsLike;
  Clouds? clouds;
  Wind? wind;
  List<Weather>? weather;

  Current({
    this.temp,
    this.pressure,
    this.feelsLike,
    this.humidity,
    this.wind,
    this.clouds,
    this.weather
  });

  factory Current.fromJson(Map<String, dynamic> json) => Current(
        temp: (json['main']['temp'] as num?)?.round(),
        pressure: (json['main']['pressure'] as num?)?.round(),
        feelsLike: (json['main']['feels_like'] as num?)?.toDouble(),
        humidity: json['main']['humidity'] as int?,
        wind: Wind.fromJson(json['wind'] as Map<String,dynamic>),
        clouds: Clouds.fromJson(json['clouds'] as Map<String,dynamic>),
        weather: (json['weather'] as List<dynamic>?)
          ?.map((e) => Weather.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'pressure': pressure,
        'humidity': humidity,
        'feels_like': feelsLike,
        'wind': wind,
        'clouds': clouds,
        'weather': weather
      };
}

class Wind {
  double? speed;
  int? deg;
  double? gust;

  Wind({this.speed, this.deg, this.gust});

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
        speed: (json['speed'] as num?)?.toDouble(),
        deg: json['deg'] as int?,
        gust: (json['gust'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'speed': speed,
        'deg': deg,
        'gust': gust,
      };
}

class Clouds {
  int? all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) => Clouds(
        all: json['all'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'all': all,
      };
}

class Weather{
  int? id;
  String? main;
  String? description;
  String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    id: json['id'] as int?,
    main: json['name'] as String?,
    description: json['description'] as String?,
    icon: json['icon'] as String?
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'main': main,
    'description': description,
    'icon': icon
  };
}

