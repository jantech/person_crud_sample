import 'package:flutter/material.dart';
import 'package:person_crud_sample/person.dart';
import 'package:person_crud_sample/person_screen.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Person CRUD Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Future<void> _initPersonData;
  List<Person> lstPerson = [];

  @override
  void initState() {
    super.initState();

    _initPersonData = _initGetAllPersons();
  }

  Future<void> _initGetAllPersons() async {

    var url =
      Uri.https('www.jagandigitech.in', '/flutter/learn/crud/read.php', {'q': '{http}'});
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      lstPerson = jsonResponse.map((e) => Person.fromJson(e)).toList();    
    } else {
      //print('Request failed with status: ${response.statusCode}.');
    }

  }

  
  Future<bool> deletePerson(String id) async {

    bool isSuccess = false;

    var client = http.Client();
    try {
      var response = await client.post(
          Uri.https('jagandigitech.in', '/flutter/learn/crud/delete.php'),
          body: {'id': id});

      if (response.statusCode == 200) { 
          isSuccess = true;
      }

    } finally {
      client.close();
    }

    return isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Person List"),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initPersonData,
          builder:(BuildContext context, snapshot) {

              switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  case ConnectionState.done:
                    {        
                        return ListView.builder(itemCount: lstPerson.length, 
                              itemBuilder: (BuildContext context, index) {                
                                return Card(
                                  shadowColor: Colors.blueAccent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                        title: Text("${lstPerson[index].firstname} - ${lstPerson[index].lastname}"),
                                        subtitle: Text("${lstPerson[index].phone} ${lstPerson[index].address}"), 
                                        trailing: SizedBox(width: 60, child: Row(children: [
                                          Padding(padding: const EdgeInsets.all(3.0), 
                                                  child: GestureDetector(child: const Icon(Icons.edit, color: Colors.purple,),  
                                                  onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => const PersonScreen(), settings: RouteSettings(name: "editPerson", arguments: convert.jsonEncode(lstPerson[index]))),
                                                      );
                                
                                                  },),
                                                  ), 
                                          Padding( 
                                            padding: const EdgeInsets.all(3.0),
                                                child: GestureDetector(child: const Icon(Icons.delete, color: Colors.red,),
                                                onTap: (){
                                
                                                  showDialog(context: context, builder: ((context) {
                                                    
                                                    return AlertDialog(
                                                      title: const Text("Are you sure do you want to delete?"),
                                                      actions: [
                                                        ElevatedButton(onPressed: () async {
                                                          
                                                          var isDeleted = await deletePerson(lstPerson[index].id);
                                
                                                          if(isDeleted) {
                                
                                                            setState(() {
                                                              // remove card items from the list 
                                                              lstPerson.elementAt(index);
                                                            });
                                                            
                                                            Navigator.of(context).pop();
                                
                                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                content: Text("Removed Successfully"),
                                                                backgroundColor: Colors.green,
                                                                duration: Duration(seconds: 5),
                                                            ));
                                
                                                          }
                                
                                                        }, 
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all(Colors.red),),
                                                          child: const Text("Yes"), ),
                                                        ElevatedButton(
                                                          onPressed: (){
                                                          Navigator.of(context).pop();
                                                        }, 
                                                        child: const Text("No"),),
                                                      ],
                                                    );
                                                  }));
                                
                                                },),
                                          ),
                                        ],),),
                                      ),
                                  ),
                                );
                              },);
                    }
              }
          },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PersonScreen()),
          );
        },
        tooltip: 'Add new Person',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
