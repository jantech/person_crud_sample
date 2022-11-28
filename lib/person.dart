class Person {
  Person({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.address,
    required this.createdat,
  });
  late final String id;
  late final String firstname;
  late final String lastname;
  late final String phone;
  late final String address;
  late final String createdat;
  
  Person.fromJson(Map<String, dynamic> json){
    id = json['id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    phone = json['phone'];
    address = json['address'];
    createdat = json['createdat'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['phone'] = phone;
    data['address'] = address;
    data['createdat'] = createdat;
    return data;
  }
}