import 'package:flutter/services.dart';

import 'package:fabrica_do_multiverso/screens/defesas/defesas.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';
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
      home: ScreenInicial(),
      routes: {
        '/home': (context) => ScreenInicial(),
        '/habilidades': (context) => const ScreenHabilidades(),
        '/defesas': (context) => const screenDefesas(),
        '/poderes': (context) => const ScreenPoderes(),
      },
    );
  }
}


class ScreenInicial extends StatelessWidget {  

  TextEditingController txtControlName = TextEditingController();
  TextEditingController txtNP = TextEditingController();

  void _updateValue(){
    txtControlName.text = personagem.nomePersonagem;
    txtNP.text = personagem.np.toString();    
  }
  
  @override
  Widget build(BuildContext context) {
    txtControlName.text = personagem.nomePersonagem;
    txtNP.text = personagem.np.toString();    
    return Scaffold(      
      appBar: AppBar(
        title: const Text('Visão Geral do Pesonagem'),
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
                Navigator.pushNamed(context, '/defesas');
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisSize: ,
        children: [
          //; descomentar quando for colcoar titulo
          // const Text(
          //   'Fabrica de Heróis',
          //   style: TextStyle(
          //     fontFamily: 'Impact',
          //     fontSize: 20,
          //   ),
          // ),
          Expanded(
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                //? Nome
                SizedBox(
                  width: (MediaQuery.of(context).size.width * 0.6),
                  child: TextField(
                    controller: txtControlName,
                    decoration: const InputDecoration(hintText: "Nome do Personagem"),
                    onChanged: (value)=>{
                      personagem.nomePersonagem = value,
                      _updateValue()
                    },
                  ),
                ),
                const SizedBox(width: 10),
                //? NP
                SizedBox(
                  width: (MediaQuery.of(context).size.width * 0.3),
                  child: TextField(
                    controller: txtNP,
                    decoration: const InputDecoration(hintText: "Nível de Poder"),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value)=>{
                      if(int.tryParse(value) != null){
                        personagem.np = int.parse(value)
                      },
                      _updateValue()
                    },
                  ),
                )
              ]
            ),
          )
        ],
      ),
    );
  }
}

// class SettingsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings Page'),
//       ),
//       body: const Center(
//         child: Text('Settings Page Content'),
//       ),
//     );
//   }
// }