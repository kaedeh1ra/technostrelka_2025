import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? profileImageBase64;
  Color accentColor = Colors.blue;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;

  final List<Color> availableColors = [
    Colors.black,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndProfileData();
  }

  Future<void> _loadUserAndProfileData() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;

    final prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('avatarPath');
    Color savedColor = Color(prefs.getInt('accentColor') ?? Colors.blue.value);

    setState(() {
      _user = user;
      profileImageBase64 = savedImagePath;
      accentColor = savedColor;
      isLoading = false;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', accentColor.value);
    if (profileImageBase64 != null) {
      await prefs.setString('avatarPath', profileImageBase64!);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImageBase64 = image.path;
      });
      _saveProfileData();
    }
  }

  void _changeAccentColor(Color color) {
    setState(() {
      accentColor = color;
    });
    _saveProfileData();
  }

  Future<void> _clearProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('avatarPath');
    setState(() {
      profileImageBase64 = null;
    });
  }

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Письмо для восстановления пароля отправлено на вашу почту.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке письма для восстановления пароля: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 360,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      profileImageBase64 != null && profileImageBase64!.isNotEmpty
                          ? Image.file(
                        File(profileImageBase64!),
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.add,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 20, // Положение сверху
                        right: 20, // Положение справа
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: _pickImage,
                          child: Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 0),
              ),
            ],
          ),
          Positioned(
            top: 280,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Container(
                      width: 250,
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _user?.displayName ?? 'Technostrelka',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),

                          Text(
                            _user?.email ?? 'technostrelka@gmail.com',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          Divider(color: Colors.white),
                          Text(
                            '********',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          Divider(color: Colors.white),
                          TextButton(
                            onPressed: _resetPassword,
                            child: Text(
                              'Забыли пароль?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            children: availableColors.map((color) {
                              return GestureDetector(
                                onTap: () => _changeAccentColor(color),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          await _clearProfileImage();
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Выйти'),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}