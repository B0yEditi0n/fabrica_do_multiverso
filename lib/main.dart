import 'package:fabrica_do_multiverso/screens/pericias/ScreenPericias.dart';
import 'package:fabrica_do_multiverso/screens/vantagens/ScreenVantagens.dart';
import 'package:flutter/services.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

// Import de imagens
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Salvamento de Arquivos
import 'script/download.dart';


// Temas
import 'package:fabrica_do_multiverso/theme/theme.dart';
// Screen de Habilidades
import 'package:fabrica_do_multiverso/screens/habilidades/ScreenHabilidades.dart';
// Screen de Defesas
import 'package:fabrica_do_multiverso/screens/defesas/ScreenDefesas.dart';
// Screens de Poderes
import 'package:fabrica_do_multiverso/screens/poderes/ScreenPoderes.dart';
// Screen de Poderes
import 'package:fabrica_do_multiverso/screens/complicacoes/ScreenComplicacoes.dart';

void main() {
  runApp(FabricaHerois());
}

class FabricaHerois extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    personagem.init();
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
        '/vantagens': (context) => const ScreenVantagens(),
        '/pericias': (context) => const ScreenPericias(),
        '/complicacoes': (context) => const ScreenComplicacoes(),
      },
    );
  }
}

class ScreenInicial extends StatefulWidget {
  const ScreenInicial({super.key});

  @override
  State<ScreenInicial> createState() => _ScreenInicialState();
}

class _ScreenInicialState extends State<ScreenInicial> {
  validaNpPersonagem validador = validaNpPersonagem(); // objeto de validação 
  List logError = [];

  Uint8List fileImg = Uint8List(0); // Imagem do Personagem;

  TextEditingController txtControlName = TextEditingController();
  TextEditingController txtNP = TextEditingController();

  void _updateValue(){
    txtControlName.text = personagem.nomePersonagem;
    txtNP.text = personagem.np.toString();
  }

  void _validaFicha(){
    setState((){
      logError =  validador.validacaoGeral();
    });

  }

  
  @override
  Widget build(BuildContext context) {
    txtControlName.text = personagem.nomePersonagem;
    txtNP.text = personagem.np.toString();

    _validaFicha();

    return Scaffold(      
      appBar: AppBar(
        title: const Text('Visão Geral do Pesonagem'),
      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column( children: [
            const DrawerHeader(
              child: Text('Menu',),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(BootstrapIcons.yin_yang),
              title: const Text('Habilidades'),
              onTap: () {
                Navigator.pushNamed(context, '/habilidades')
                .then((value) => _validaFicha());
              },
            ),

            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Defesas'),
              onTap: () {
                Navigator.pushNamed(context, '/defesas')
                .then((value) => _validaFicha());
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.battery_charging /*(BootstrapIcons.fire*/ ),
              title: const Text('Poderes'),
              onTap: () {
                Navigator.pushNamed(context, '/poderes')
                .then((value) => _validaFicha());
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.paid),
              title: const Text('Vantagens'),
              onTap: () {
                Navigator.pushNamed(context, '/vantagens')
                .then((value) => _validaFicha());
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.tools),
              title: const Text('Perícias'),
              onTap: () {
                Navigator.pushNamed(context, '/pericias')
                .then((value) => _validaFicha());
              },
            ),

            ListTile(
              leading: const Icon(Icons.personal_injury),
              title: const Text('Complicações'),
              onTap: () {
                Navigator.pushNamed(context, '/complicacoes')
                .then((value) => _validaFicha());
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.upload),
              title: const Text('Upload'),
              onTap: () async {
                Download upload = Download();
                var ficha = await upload.uploadFicha();
                if(ficha.isNotEmpty){
                  personagem.reInit(ficha);
                }                
                // Repassa a imagem
                setState((){
                  fileImg = upload.img;
                });
              },
            ),

            const Divider(),
            
          ]),
        ),
        
      ),
      body: Column(
        children: [
          //; descomentar quando for colcoar titulo
          // const Text(
          //   'Fabrica de Heróis',
          //   style: TextStyle(
          //     fontFamily: 'Impact',
          //     fontSize: 20,
          //   ),
          // ),


          // teste upload de ficha
          IconButton(
            icon: fileImg.isNotEmpty 
              ? Image.memory(fileImg, 
                  height: 300,                  
                )
              : const Icon(BootstrapIcons.image, size: 50),
          
            onPressed: () async{
              const List<String> extension = ["img", "png", "jpeg", "jpg"];

              try {
                              
                FilePickerResult respostaPath = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                  onFileLoading: (FilePickerStatus status) => print(status),
                  allowedExtensions: extension,
                  dialogTitle: "Imagem de Herói",
                  initialDirectory: "",
                  lockParentWindow: false, 
                ) as FilePickerResult;
            
                String pathFile = respostaPath.files.first.path as String;
            
                setState(() {
                  fileImg = File(pathFile).readAsBytesSync();
                });
              } catch (e) {
                // typeError
              }
            },
          ),

          const SizedBox( height:  50 ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Wrap(
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
                    ),
                  ],
                ),
              ]
            ),
          )
        ],
      ),

      floatingActionButton: IconButton(
        icon: const Icon(BootstrapIcons.floppy2_fill),
        onPressed: () async{
          Download baixar = Download();
          baixar.genericDownload(fileImg);
        },
      ),
    );
    
  }
}