import 'package:flutter/material.dart';
import 'package:flutter_laravel_auth/screens/login_screen.dart';
import 'package:flutter_laravel_auth/services/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    readToken();
  }

  void readToken() async {
    try {
      String? token = await storage.read(key: 'token');
      Provider.of<Auth>(context, listen: false).tryToken(token: token!);
      print(token);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laravel Auth')),
      body: const Center(child: Text('Home Page')),
      drawer: Drawer(child: Consumer<Auth>(
        builder: (context, auth, child) {
          if (!auth.authenticated) {
            return ListView(
              children: [
                ListTile(
                  title: const Text('Login'),
                  leading: const Icon(Icons.login),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                  },
                ),
              ],
            );
          } else {
            return ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(auth.user.name,
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(auth.user.email,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Logout'),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    Provider.of<Auth>(context, listen: false).logout();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        },
      )),
    );
  }
}
