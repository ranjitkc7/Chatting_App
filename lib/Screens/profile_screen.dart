import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/Screens/auth/auth_services.dart';
import 'package:we_chat/Screens/auth/login_page.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialog.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_users.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUsers users;

  const ProfileScreen({super.key, required this.users});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imageUrl; // Stores local image path

  @override
  void initState() {
    super.initState();
    _loadSavedImage(); // Load saved local image on startup
  }

  /// Load saved image path from SharedPreferences
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("profile_image");
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imageUrl = path;
      });
    }
  }

  /// Pick image from camera/gallery and save locally
  Future<void> _pickAndSaveImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    // Save image to app's document directory
    final dir = await getApplicationDocumentsDirectory();
    final savedImage = await File(image.path).copy("${dir.path}/profile.jpg");

    // Save path to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_image", savedImage.path);

    setState(() {
      _imageUrl = savedImage.path;
    });

    Navigator.pop(context);
  }

  /// Widget to build profile image (local -> remote -> placeholder)
  Widget _buildProfileImage() {
    if (_imageUrl != null && File(_imageUrl!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(mq.width * 0.53 / 2),
        child: Image.file(
          File(_imageUrl!),
          height: mq.width * 0.53,
          width: mq.width * 0.53,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.users.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(mq.width * 0.53 / 2),
        child: CachedNetworkImage(
          height: mq.width * 0.53,
          width: mq.width * 0.53,
          fit: BoxFit.cover,
          imageUrl: widget.users.imageUrl,
          errorWidget: (context, url, error) => CircleAvatar(
            radius: mq.width * 0.53 / 2,
            child: Icon(
              Icons.person,
              color: Color(0xFF3AAA35),
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: mq.width * 0.53 / 2,
        child: Icon(
          Icons.person,
          color: Color(0xFF3AAA35),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Screen"),
          backgroundColor: Color(0xFF3AAA35),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () async {
            CustomDialog.showProgressBar(context);
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await AuthService.logout();

              if (!context.mounted) return;
              CustomDialog.hideProgressBar(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            });
          },
          icon: const Icon(Icons.logout, size: 22, color: Colors.white),
          label: const Text("Logout", style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      _buildProfileImage(),
                      Positioned(
                        bottom: 4,
                        right: 8,
                        child: MaterialButton(
                          onPressed: _showBottomSheet,
                          elevation: 1,
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(
                            Icons.edit,
                            size: 28,
                            color: Color(0xFF3AAA35),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * 0.02),
                  Text(
                    widget.users.email,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: mq.height * 0.03),
                  // Name TextField
                  TextFormField(
                    initialValue: widget.users.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Name cannot be empty",
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Color(0xFF3AAA35)),
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.02),
                  // About TextField
                  TextFormField(
                    initialValue: widget.users.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "About cannot be empty",
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Color(0xFF3AAA35),
                      ),
                      labelText: 'About',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.04),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          CustomDialog.showSnackbar(
                            context,
                            "Profile Updated Successfully!",
                            backgroundColor: Color(0xFF3AAA35),
                            textColor: Colors.white,
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.edit, color: Colors.white, size: 28),
                    label: Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3AAA35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * 0.03,
            bottom: mq.height * 0.1,
          ),
          children: [
            const Text(
              "Choose Profile Photo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: mq.height * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _pickAndSaveImage(ImageSource.camera);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * 0.35, mq.width * 0.20),
                    padding: EdgeInsets.all(5),
                  ),
                  child: Image.asset(
                    "assets/images/camera.png",
                    height: 65,
                    width: 65,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _pickAndSaveImage(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * 0.35, mq.width * 0.20),
                    padding: EdgeInsets.all(5),
                  ),
                  child: Image.asset(
                    "assets/images/gallery.png",
                    height: 65,
                    width: 65,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
