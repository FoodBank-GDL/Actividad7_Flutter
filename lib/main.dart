import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ViewRequest(exampleArgs: "HOLA A TODOS",),
    );
  }
}

class ViewRequest extends StatefulWidget{

  final String exampleArgs;
  ViewRequest({required this.exampleArgs});


  @override
  _ViewRequestState createState() => _ViewRequestState(stateArgs: exampleArgs);
}

class _ViewRequestState extends State<ViewRequest>{

  final String stateArgs;

  late Future<List<Country>> countries;

  _ViewRequestState({required this.stateArgs});

  @override
  void initState(){
    super.initState();

    countries = getInfoCountry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Covid reports")),
      body: Center(
        child: FutureBuilder<List<Country>>(
          future: countries,
          builder: (context, snapshot){
            if(snapshot.hasData){
              return ListWidget(countries: snapshot.data!);
            } else if(snapshot.hasError){
              return Text("SOMETHING WENT WRONG!");
            }


            return CircularProgressIndicator();
          },
        )
      ),
    );
  }
}

class ListWidget extends StatefulWidget {
  final List<Country> countries;

  ListWidget({required this.countries});

  @override
  _ListWidgetState createState() => _ListWidgetState(stateArgs: countries);
}

class _ListWidgetState extends State<ListWidget>{

  final List<Country> stateArgs;
  _ListWidgetState({required this.stateArgs});
  TextStyle _style = const TextStyle(fontSize: 16.0);

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: stateArgs.length,
      itemBuilder: (context, i) {
        return _buildRow(stateArgs[i]);
      }
    );
  }

  Widget _buildRow(Country country){
    return ListTile(
      title: Text(
        country.country,
        style: _style,
      ),
      onTap: () {

       Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) => DetailView(country: country)
         )
       );
      },
    );
  }

}

class DetailView extends StatefulWidget {
  final Country country;

  DetailView({required this.country});

  @override
  _DetailViewState createState() => _DetailViewState(stateArgs: country);
}

class _DetailViewState extends State<DetailView> {

  final Country stateArgs;
  _DetailViewState({required this.stateArgs});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stateArgs.country),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Reports from"),
            const Text("TODAY:",
              style: TextStyle(fontSize: 50),),
            Text("Cases: ${stateArgs.todayCases}",
              style: TextStyle(fontSize: 36)),
            Text("Deaths: ${stateArgs.todayDeaths}",
                style: TextStyle(fontSize: 36)),
            Image.network(stateArgs.flag)
          ],
        ),
      ),
    );
  }
  
}

class Country {
  final String country;
  final int todayCases;
  final int todayDeaths;
  final String flag;
  Country({
    required this.country,
    required this.todayCases,
    required this.todayDeaths,
    required this.flag
  });

  factory Country.fromJson(Map<String, dynamic> json){
    return Country(
      country: json['country'],
      todayCases: json['todayCases'],
      todayDeaths: json['todayDeaths'],
      flag: json['countryInfo']['flag']
    );
  }
}

Future<List<Country>> getInfoCountry() async {
  final response = await http.get(
      Uri.parse(
          "https://disease.sh/v3/covid-19/countries"
      )
  );

  if(response.statusCode == 200){
    List<dynamic> list = jsonDecode(response.body);
    List<Country> result = [];

    for (var current in list) {
      Country currentCountry = Country.fromJson(current);
      result.add(currentCountry);
    }

    return result;
  } else {
    throw Exception("ERROR IN REQUEST.");
  }
}