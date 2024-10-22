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
import 'package:archive/archive_io.dart'; // Zip
import 'package:path_provider/path_provider.dart';
import 'dart:convert' show utf8; // Sei lá o que
import 'dart:io';

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
  Uint8List fileImg = Uint8List(0); // Imagem do Personagem;

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
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column( children: [
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

            const Divider(),

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
              leading: const Icon(BootstrapIcons.battery_charging /*(BootstrapIcons.fire*/ ),
              title: const Text('Poderes'),
              onTap: () {
                Navigator.pushNamed(context, '/poderes');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.paid),
              title: const Text('Vantagens'),
              onTap: () {
                Navigator.pushNamed(context, '/vantagens');
              },
            ),

            ListTile(
              leading: const Icon(BootstrapIcons.tools),
              title: const Text('Perícias'),
              onTap: () {
                Navigator.pushNamed(context, '/pericias');
              },
            ),

            ListTile(
              leading: const Icon(Icons.personal_injury),
              title: const Text('Complicações'),
              onTap: () {
                Navigator.pushNamed(context, '/complicacoes');
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
              ? Image.memory(fileImg) 
              : const Icon(BootstrapIcons.image, size: 50),

            onPressed: () async{
              const List<String> extension = ["img", "png", "jpeg", "jpg"];

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
              //Uint8List bytes = await file.readAsBytes();
              
              //Uint8List tmpFile = 
              setState(() {
                fileImg = File(pathFile).readAsBytesSync();
              });
              
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
          // Pega Json e Transforma em File 
          Map fichaFinal = personagem.returnObjJson();
          
          // Criando um Zip de Saida
          // Crie uma lista de arquivos para adicionar ao ZIP
          List<int> fichaByte = utf8.encode(fichaFinal.toString());

          // Crie um novo arquivo ZIP
          final archive = Archive();

          // Adicione arquivos ao ZIP
          archive.addFile(ArchiveFile('ficha.json', fichaByte.length, fichaByte));
          archive.addFile(ArchiveFile('imagem.jpg', fileImg.length, fileImg));

          // Obtenha o diretório temporário
          //final Directory directory = await getTemporaryDirectory();
          //final String zipFilePath = '${directory.path}/ficha.zip';

          // Crie o arquivo ZIP
          final List<int> listzipData = ZipEncoder().encode(archive)!;
          // final File zipFile = File(zipFilePath);
          // await zipFile.writeAsBytes(listzipData);
          
          //Directory
          Directory downladDir = await getApplicationDocumentsDirectory();
          final String dirPath = downladDir.path;
          
          final File file = File('/home/caio/Downloads/ficha.zip');
          
          
          await file.writeAsBytes(listzipData);
          

          //! Um download Output deve ser posteriomente adicionado
          //await zipFile.zipDirectoryAsync(Directory('/home/caio/Downloads'), filename: 'Personagem.zip');
          //await zipFile.addDirectory(Directory('/home/caio/Downloads'));
          // ArchiveFile jsonPersonage = 
          // ArchiveFile zipImg = ;
          
          // fichaFinal.to;
          // zipFile.addFile(); addArchiveFile(ArchiveFile.string("personage.json", fichaFinal.toString()));
          // zipFile.addArchiveFile(ArchiveFile.noCompress("personagem", fileImg.length, fileImg));
          // zipFile.closeSync();

        },
      ),
    );
    
  }
}