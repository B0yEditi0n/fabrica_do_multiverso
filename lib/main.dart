import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

// Temas
import 'package:fabrica_do_multiverso/theme/theme.dart';
// Screens de Habilidades
import 'package:fabrica_do_multiverso/screens/habilidades/habilidades.dart';
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
        '/habilidades': (context) => Habilidades(),
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
              leading: const Icon(BootstrapIcons.yin_yang),
              title: const Text('Habilidades'),
              onTap: () {
                Navigator.pushNamed(context, '/habilidades');
              },
            ),

            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Defesas'),
              onTap: () {
                //Navigator.pushNamed(context, '/poderes');
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.fire),
              title: const Text('Poderes'),
              onTap: () {
                Navigator.pushNamed(context, '/poderes');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.paid),
              title: const Text('Vantagens'),
              onTap: () {
                //Navigator.pushNamed(context, '/poderes');
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.tools),
              title: const Text('Perícias'),
              onTap: () {
                //Navigator.pushNamed(context, '/poderes');
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.capsule),
              title: const Text('Complicações'),
              onTap: () {
                //Navigator.pushNamed(context, '/poderes');
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