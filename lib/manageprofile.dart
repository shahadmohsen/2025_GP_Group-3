import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';
import 'help_center_page.dart';
import 'login.dart';
import 'reviews_page.dart';
import 'manage_posts.dart'; // إضافة استيراد صفحة المنشورات


class ManageProfile extends StatefulWidget {
  const ManageProfile({super.key});

  @override
  State<ManageProfile> createState() => _ManageProfileState();
}

class _ManageProfileState extends State<ManageProfile> {
  bool _notificationsEnabled = true;
  String _userName = ""; // Variable to store user's name

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ?? "User"; // Default to "User" if name is not found
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        setState(() {
          _userName = "User";
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Logout error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج')),
      );
    }
  }

  // Method to navigate to edit profile page
  void _navigateToEditProfile() async {
    // Wait for result from edit profile page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );

    // If name was updated (result is not null)
    if (result != null && result is String) {
      setState(() {
        _userName = result;
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث الاسم بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7ECCA),
      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 150,
              decoration: const BoxDecoration(
                color: Color(0xFFFEFBFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                'الحساب',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Positioned(
            top: 50,
            right: 20,
            child: Icon(Icons.notifications, color: Colors.white, size: 28),
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    _userName, // Dynamic username
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 40),
                  profileOption(Icons.person, 'تعديل الحساب', _navigateToEditProfile),

                  // خانة إدارة المنشورات
                  profileOption(Icons.article, 'إدارة المنشورات', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagePostsPage(),
                      ),
                    );
                  }),

                  // جديد: صفحة التقييمات
                  profileOption(Icons.star_rate, 'التقييمات', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReviewsPage(),
                      ),
                    );
                  }),

                  profileOption(Icons.help_outline, 'مساعدة', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterPage(),
                      ),
                    );
                  }),
                  profileOption(Icons.exit_to_app, 'تسجيل الخروج', () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تسجيل الخروج'),
                        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _logout(); // Call logout method
                            },
                            child: const Text('تأكيد'),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value
                                    ? 'تم تفعيل الإشعارات'
                                    : 'تم إيقاف الإشعارات'),
                              ),
                            );
                          },
                          activeColor: Colors.green,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text(
                              'الإشعارات',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE399),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _notificationsEnabled
                                    ? Icons.notifications
                                    : Icons.notifications_off,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE399),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}