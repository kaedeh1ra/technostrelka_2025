import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technostrelka_2025/global/commands/toast.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text('Welocme, а теперь пошёл отсюда')),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () async {
              _createData(
                UserModel(username: "Steve", age: 12, country: "china"),
              );
            },
            child: Container(
              height: 45,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Create data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          StreamBuilder<List<UserModel>>(
            stream: _readData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return Center(child: Text("No data"));
              }
              final users = snapshot.data;
              return Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children:
                      users!.map((user) {
                        return ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              _deleteData(user.id!);
                            },
                            child: Icon(Icons.delete),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              _updateData(
                                UserModel(
                                  id: user.id,
                                  username: "john",
                                  country: "pakistan",
                                  age: user.age,
                                ),
                              );
                            },
                            child: Icon(Icons.update),
                          ),
                          title: Text(user.username!),
                          subtitle: Text(user.country!),
                        );
                      }).toList(),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
              showToast(message: 'Sign out is successful');
            },
            child: Container(
              height: 45,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<UserModel>> _readData() {
    final userCollection = FirebaseFirestore.instance.collection('users');
    return userCollection.snapshots().map(
      (querySnapshot) =>
          querySnapshot.docs
              .map((user) => UserModel.fromSnapshot(user))
              .toList(),
    );
  }

  void _createData(UserModel userModel) {
    final userCollection = FirebaseFirestore.instance.collection("users");
    String id = userCollection.doc().id;
    final newUser =
        UserModel(
          username: userModel.username,
          age: userModel.age,
          country: userModel.country,
          id: id,
        ).toJson();
    userCollection.doc(id).set(newUser);
  }

  void _updateData(UserModel userModel) {
    final userCollection = FirebaseFirestore.instance.collection("users");
    final newData =
        UserModel(
          username: userModel.username,
          age: userModel.age,
          country: userModel.country,
          id: userModel.id,
        ).toJson();
    userCollection.doc(userModel.id).update(newData);
  }

  void _deleteData(String id) {
    final userCollection = FirebaseFirestore.instance.collection("users");
    userCollection.doc(id).delete();
  }
}

class UserModel {
  final String? username;
  final int? age;
  final String? country;
  final String? id;

  var firestore = FirebaseFirestore.instance;

  UserModel({this.username, this.age, this.country, this.id});

  static UserModel fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return UserModel(
      username: snapshot['username'],
      age: snapshot['age'],
      country: snapshot['country'],
      id: snapshot['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'age': age, 'country': country, 'id': id};
  }
}
