import 'package:flutter/material.dart';

// Temas
import 'package:fabrica_do_multiverso/theme/theme.dart';

// Screens de Poderes
import 'package:fabrica_do_multiverso/screens/screenPoderes/controlePoderes.dart';

void main() {
  runApp(FabricaHerois());

}

class FabricaHerois extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabrica de Heróis',
      theme: temaPadrao(),//(
      //   primarySwatch: Colors.blue,
      // ),
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/poderes': (context) => const Poderes(),
      },
    );
  }
}


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              /*decoration: BoxDecoration(
                color: Colors.blue,
              ),*/
              child: Text(
                'Menu',
                //style: TextStyle(
                  //color: Colors.white,
                  //fontSize: 24,
                //),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Poderes'),
              onTap: () {
                Navigator.pushNamed(context, '/poderes');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: const Center(
        child: Text('Settings Page Content'),
      ),
    );
  }
}