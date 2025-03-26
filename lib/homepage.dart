import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalproj/components/logo.dart';
import 'package:finalproj/components/Button.dart';
import 'package:finalproj/auth/phoneauth.dart'; // Import the PhoneAuthPage

class HomePage extends StatefulWidget {
  // final String firstName;
  // final String secondName;
  // final String email;

  const HomePage({
    Key? key,
    // required this.firstName,
    // required this.secondName,
    // required this.email,
  }) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  int selectedIndex = 0;

  // Function to sign out the user
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate the user back to the phone authentication page after sign-out
      Navigator.pushReplacementNamed(
          context, 'Phoneauth'); // Use 'Phoneauth' route here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error signing out: $e"),
      ));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (val) {
          setState(() {
            selectedIndex = val;
          });
        },
        currentIndex: selectedIndex,
        backgroundColor: Color.fromARGB(255, 145, 129, 216),
        selectedFontSize: 18,
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(icon: IconButton(
            icon: Icon(Icons.home),color: Colors.white,
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'Home');
            },
          ), label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.directions_bus),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'Lines');
                },
              ),
              label: "Lines"),
          BottomNavigationBarItem(icon: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '');
            },
          ), label: "Settings")
        ],
      ),
      appBar: AppBar(
        actions: [CustomLogo()],
        // title: Text('Tramify'),
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[700],
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "",
                        // "${widget.firstName} ${widget.secondName}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "",
                        // "${widget.email}",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
            _buildDrawerItem(
                icon: Icon(Icons.account_box, color: Colors.white),
                title: "Account",
                onTap: () {}),
            _buildDrawerItem(
                icon: Icon(Icons.settings, color: Colors.white),
                title: "Settings",
                onTap: () {}),
            _buildDrawerItem(
                icon: Icon(Icons.help, color: Colors.white),
                title: "About Us",
                onTap: () {}),
            _buildDrawerItem(
              icon: Icon(Icons.headphones, color: Colors.white),
              title: "Help & Support",
              onTap: () {
                print("contact");
              },
            ),
            _buildDrawerItem(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              title: "Sign Out",
              onTap: () {
                signOut(context); // Call the logout function when tapped
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(children: [
        Column(
          children: [
            Card(
              color: const Color.fromARGB(255, 239, 239, 239),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  print("onTap");
                },
                trailing: IconButton(
                  onPressed: () {},
                  iconSize: 30,
                  icon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 145, 129, 216),
                  ),
                ),
                title: const Center(
                  child: Text(
                    'Where to go?',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            CustomButton(text: "Find On Map", onPressed: () {}, BtnWidth: 80),
            SizedBox(height: 30),
            _buildSectionBar("Favourites"),
            SizedBox(height: 20),
            _buildSectionBar("Recents"),
          ],
        ),
      ]),
    );
  }

  Widget _buildSectionBar(String title) {
    return Container(
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 40,
      child: Row(
        children: [
          Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
          Spacer(flex: 3),
          IconButton(
            onPressed: () {
              print("$title - Add");
            },
            iconSize: 24,
            icon: const Icon(Icons.add),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required Icon icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}

