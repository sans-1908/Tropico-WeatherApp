import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/components/weather_item.dart';
import 'package:weatherapp/ui/details_page.dart';
import 'package:weatherapp/widget/constants.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: unused_fiel, unused_field
  final TextEditingController _cityController=TextEditingController();
  final Constants _constants=Constants();

  // ignore: non_constant_identifier_names
  static String API_KEY ='e68a4750654f43e3a5b131052233108';

  String location='Mumbai';
  String weatherIcon='heavycloudy.png';
  int temperature=0;
  int humidity=0;
  int windSpeed=0;
  int cloud=0;
  String currentDate='';

  List hourlyWeatherForecast=[];
  List dailyWeatherForecast=[];

  String currentWeatherStatus='';

  //api call
  String searchWeatherAPI="http://api.weatherapi.com/v1/forecast.json?key=" + API_KEY +"&days=7&q=";

  void fetchWeatherData(String searchText)async{
   try{
    var searchResult=await http.get(Uri.parse(searchWeatherAPI +searchText));
    final weatherData=Map<String,dynamic>.from(json.decode(searchResult.body) ?? 'No Data');
    // ignore: unused_local_variable
    var locationData=weatherData['location'];
    // ignore: unused_local_variable
    var currentWeather=weatherData['current'];
    setState(() {
      location=getShortLocationName(locationData['name']);

      var parsedDate=DateTime.parse(locationData["localtime"].substring(0,10));
      var newDate=DateFormat('MMMMEEEEd').format(parsedDate);
      currentDate=newDate;

      //update weather

      currentWeatherStatus=currentWeather['condition']['text'];
      weatherIcon=currentWeatherStatus.replaceAll(' ','').toLowerCase() + '.png';
      temperature=currentWeather['temp_c'].toInt();
      humidity=currentWeather['humidity'].toInt();
      windSpeed=currentWeather['wind_kph'].toInt();
      cloud=currentWeather['cloud'].toInt();

      //update hourly weather forecast
      dailyWeatherForecast=weatherData['forecast']['forecastday'];
      hourlyWeatherForecast=dailyWeatherForecast[0]['hour'];
      print(dailyWeatherForecast);
    });
   }
   catch(e){
    print(e);
   }
  }
//function to get short location name

static String getShortLocationName(String s){
  List<String> wordList=s.split(" ");
   
  if(wordList.isNotEmpty){
    if(wordList.length>1){
      return wordList[0] + " " + wordList[1];
    }
     else{
      return wordList[0];
    }
  }
   else{
      return " ";
    }
}
 
  @override
  Widget build(BuildContext context) {
     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    Size size=MediaQuery.of(context).size;
    return Scaffold(
    
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 70,left: 10,right: 10),
        color: _constants.primaryColor.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
              height: size.height*.7,
              decoration: BoxDecoration(
                gradient: _constants.linearGradientBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _constants.primaryColor.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0,3)
                   )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.menu),
                      SizedBox(width: 60,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,size: 30,),
                          SizedBox(width: 3,),
                          Text(location,style: const TextStyle(color: Colors.white,fontSize: 16),),
                          IconButton(
                            onPressed: (){
                            _cityController.clear();
                            showBarModalBottomSheet(
                            context: context,
                             builder: (context)=>
                             SingleChildScrollView(
                              controller: ModalScrollController.of(context),
                              child: Container(
                                height: size.height * 0.2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Divider(
                                        thickness: 3.5,
                                        color: _constants.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                     TextField(
                                      onChanged: (searchText){
                                        fetchWeatherData(searchText);
                                      },
                                      controller: _cityController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: _constants.primaryColor,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: ()=>
                                          _cityController.clear(),
                                          child: Icon(
                                            Icons.close,
                                            color: _constants.primaryColor,
                                          ),
                                        
                                        ),
                                        hintText: 'Search city e.g. London',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: _constants.primaryColor,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        )
                                      ),
                                     )
                                  ],
                                ),
                              ),
                             )
                             );
                          }, 
                          icon:Icon(Icons.keyboard_arrow_down_outlined,color: Colors.white,) )
                        ],
                      ),
                      SizedBox(width: 80,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/profile.png",width: 35,height: 35,),
                    )
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: Image.asset("assets/"+weatherIcon),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(temperature.toString(),
                        style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold,foreground: Paint()..shader=_constants.shader),),
                        ),
                        Text("o",style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader=_constants.shader
                        ),
                        )
                    ],
                  ),
                  Text(currentWeatherStatus,style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20
                  ),),
                  Text(currentDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20
                  ),),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                    child: const Divider(
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      WeatherItem(
                        value: windSpeed.toInt(),
                        unit: 'Km/h',
                        imageUrl: 'assets/windspeed.png'),
                          WeatherItem(
                        value: humidity.toInt(),
                        unit: 'Km/h',
                        imageUrl: 'assets/humidity.png'),
                          WeatherItem(
                        value: cloud.toInt(),
                        unit: 'Km/h',
                        imageUrl: 'assets/cloud.png'),
                    ]),
                  )
                ],
              ),
            ),
            Container(
              padding:const EdgeInsets.only(top: 10),
              height: size.height* .2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Text('Today ,',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                     GestureDetector(
                      onTap: ()=> Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailPage(
                                      dailyForecastWeather:
                                          dailyWeatherForecast,
                                    ))),
                      child: Text('Forecasts',style: TextStyle(fontSize: 16,color:_constants.primaryColor),))
                    ],
                  ),
                  const SizedBox(height: 8,),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      itemCount: hourlyWeatherForecast.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String currentTime=DateFormat('HH:mm:ss').format(DateTime.now());
                        String currentHour=currentTime.substring(0,2);
                        String forcastTime=hourlyWeatherForecast[index]['time'].substring(11,16);
                        String forcastHour=hourlyWeatherForecast[index]["time"].substring(11,13);
                        String forecastWeatherName=hourlyWeatherForecast[index]["condition"]["text"];
                        String forecastWeatherIcon=forecastWeatherName.replaceAll(' ','').toLowerCase()+".png";
                        String forecastTemperature=hourlyWeatherForecast[index]["temp_c"].round().toString();

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          margin: EdgeInsets.only(right: 20),
                          width: 65,
                          decoration: BoxDecoration(
                            color: currentHour==forcastHour ? Colors.white:_constants.primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            boxShadow:[
                              BoxShadow(
                                offset: const Offset(0,1),
                                blurRadius: 5,
                                color: _constants.primaryColor.withOpacity(0.2),

                              )
                            ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: 
                            [
                              Text(forcastTime,style: TextStyle(fontSize: 17,color: _constants.greyColor,fontWeight: FontWeight.bold),),
                              Image.asset("assets/"+forecastWeatherIcon,
                              width: 20,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(forecastTemperature,
                                  style: TextStyle(
                                    fontSize: 17,
                                    foreground: Paint()
                                          ..shader = _constants.shader,
                                    fontWeight: FontWeight.bold,

                                  ),  
                                  ),
                                  Text('o',
                                  style: TextStyle(
                                    fontSize: 17,
                                    foreground: Paint()
                                          ..shader = _constants.shader,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  
                                  )
                                ],
                              )
                            ]),
                        );
                        }
                      ),
                  )
                ],
              ),
            )
        ]),
      ),
    );
  }
}