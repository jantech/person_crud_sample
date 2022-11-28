import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:person_crud_sample/main.dart';

import 'person.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {

  bool isEditMode = false;

  String editPersonId = "0";

  Person? person;

  final TextEditingController _firstNameCtlr = TextEditingController();
  final TextEditingController _lastNameCtlr = TextEditingController();
  final TextEditingController _phoneCtlr = TextEditingController();
  final TextEditingController _addressCtlr = TextEditingController();


  Future<bool> addPerson(String firstName, String lastName, String phone, String address) async {

    bool isSuccess = false;

    var client = http.Client();
    try {
      var response = await client.post(
          Uri.https('jagandigitech.in', '/flutter/learn/crud/add.php'),
          body: {'firstname': firstName, 'lastname': lastName, 'phone': phone, 'address': address});

      if (response.statusCode == 200) { 
          isSuccess = true;
      }

    } finally {
      client.close();
    }

    return isSuccess;
  }

  
  Future<bool> editPerson(String id, String firstName, String lastName, String phone, String address) async {

    bool isSuccess = false;

    var client = http.Client();
    try {
      var response = await client.post(
          Uri.https('jagandigitech.in', '/flutter/learn/crud/edit.php'),
          body: {'id': id, 'firstname': firstName, 'lastname': lastName, 'phone': phone, 'address': address});

      if (response.statusCode == 200) { 
          isSuccess = true;
      }

    } finally {
      client.close();
    }

    return isSuccess;
  }

  resetInputFields() {

    _firstNameCtlr.clear();
    _lastNameCtlr.clear();
    _phoneCtlr.clear();
    _addressCtlr.clear();

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _firstNameCtlr.dispose();
    _lastNameCtlr.dispose();
    _phoneCtlr.dispose();
    _addressCtlr.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ModalRoute.of(context)?.settings.arguments != null) {
      var personString = ModalRoute.of(context)?.settings.arguments as String;
      // print(personString);

      if(personString.isNotEmpty) {

        setState(() {
          isEditMode = true;  
          person = Person.fromJson(jsonDecode(personString));

          if (person != null) {
            _firstNameCtlr.text = person!.firstname;
            _lastNameCtlr.text = person!.lastname;
            _phoneCtlr.text = person!.phone;
            _addressCtlr.text = person!.address;


            editPersonId = person!.id;
          }
          
        });

      }
    }     

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${(isEditMode == true) ? "Edit" : 'Add'} Person")),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const SizedBox(height: 15,),
          TextFormField(
            controller: _firstNameCtlr,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "First Name",
            ),
          ),
          const SizedBox(height: 15,),
          TextFormField(
            controller: _lastNameCtlr,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Last Name",
            ),
          ),
          const SizedBox(height: 15,),
          TextFormField(
            controller: _phoneCtlr,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Phone Number",
            ),
          ),
          const SizedBox(height: 15,),
          TextFormField(
            controller: _addressCtlr,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Address",
            ),
          ),
          const SizedBox(height: 15,),
          ElevatedButton(child: Text((isEditMode == true) ? "Update" : "Create New"),
           onPressed: () async {

            var firstName = _firstNameCtlr.text;
            var lastName = _lastNameCtlr.text;
            var phone = _phoneCtlr.text;
            var address = _addressCtlr.text;

            if (firstName.isNotEmpty && lastName.isNotEmpty && phone.isNotEmpty && address.isNotEmpty) {

              bool isSaved = false;
              String resultText = "";

              if (isEditMode == true) {
                isSaved = await editPerson(editPersonId, firstName, lastName, phone, address);
                resultText = "Person detail updated sucessfully";
              } else {
                isSaved = await addPerson(firstName, lastName, phone, address);
                resultText = "Person detail added sucessfully";
              }

              if(isSaved) {

                resetInputFields();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(resultText),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                ));

                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
                    return const MyHomePage();
                  }), (r){
                    return false;
                  });

              } else {
                
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Error while saving data'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                ));

              }

            } else {
              
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please Fill all the fields'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
              ));

            }


           },
          ),

        ],
        ),
      ),),
    );
  }
}