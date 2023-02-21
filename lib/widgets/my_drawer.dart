import 'package:flutter/material.dart';
import 'package:utransfer_user/global/global.dart';
import 'package:utransfer_user/mainScreens/profile_screen.dart';
import 'package:utransfer_user/mainScreens/trips_history_screen.dart';
import 'package:utransfer_user/splashScreen/splash_screen.dart';

import '../mainScreens/about_screen.dart';

class MyDrawer extends StatefulWidget
{
  String? name;
  String? email;

  MyDrawer({this.name, this.email});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
{
  @override
  Widget build(BuildContext context)
  {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 16,),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          widget.name.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                      ),

                      const SizedBox(height: 8,),

                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12.0,),

          //Drawer body
          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.history, color: Colors.black,),
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.person, color: Colors.black,),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c) => AboutScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.black,),
              title: Text(
                "About",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.logout, color: Colors.black,),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
