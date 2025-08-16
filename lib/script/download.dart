import 'package:archive/archive_io.dart'; // Zip
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Conversões de Tipo
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

import 'package:fabrica_do_multiverso/script/ficha.dart';

class Download{
  Uint8List img = Uint8List(0);
  static genericDownload(fileImg) async{
    // Pega Json e Transforma em File
    // Criando um Zip de Saida
    // Crie uma lista de arquivos para adicionar ao ZIP
    List<int> fichaByte = utf8.encode(json.encode(personagem.returnObjJson()).replaceAll(r'\"', '"'));

    // Crie um novo arquivo ZIP
    final archive = Archive();

    // Adicione arquivos ao ZIP
    archive.addFile(ArchiveFile('ficha.json', fichaByte.length, fichaByte));
    archive.addFile(ArchiveFile('imagem.jpg', fileImg.length, fileImg));

    // Crie o arquivo ZIP
    final List<int> listzipData = ZipEncoder().encode(archive)!;

    try {
      if(kIsWeb){
        //
        // Salvar em Platafromas na Web
        //

        final blob = html.Blob([listzipData], 'application/zip');


        final String url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
        ..setAttribute('download', 'ficha.zip')
        ..click();

        // Libera a URL
        html.Url.revokeObjectUrl(url);
      }else{
        //
        // Salvar em Platafromas Normais
        //
      
        String respostaPath = await FilePicker.platform.saveFile(
          type: FileType.custom,
          allowedExtensions: ["zip"],
          dialogTitle: "Salvar Aquivo de Heroi",
          initialDirectory: "",
          lockParentWindow: false, 
        ) as String;
        
        
        final File file = File( // Adiciona zip caso não tenha
          respostaPath.contains(RegExp(r'\.zip$')) || respostaPath.contains(RegExp(r'\.ZIP$'))
            ? respostaPath
            : "$respostaPath.zip"
        );
        
        
        await file.writeAsBytes(listzipData);
      }
    } catch (e) {
      // Type Error.
      print(e.toString());
    }
  }

  Future<dynamic> uploadFicha() async{
    // Upload de Ficha
    const List<String> extension = ["zip", "ZIP"];
    Map jsonFicha = {};
    
    try {
      //
      // Cria o Pop UP dialogo
      //
      FilePickerResult respostaPath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        //onFileLoading: (FilePickerStatus status) => ,
        allowedExtensions: extension,
        dialogTitle: "Arquivo de Heroi",
        initialDirectory: "",
        lockParentWindow: false, 
      ) as FilePickerResult;        

      //
      // Pega os arquivos do popup
      //

      if(respostaPath.files.isNotEmpty){
        Archive archive;

        //
        // Navegadores não tem acessoa path porem carregam os byte consido
        // já Plataformas leam a path e precisam coletar o byte de outra forma
        //

        if(!kIsWeb){
          String pathFile = respostaPath.files.first.path as String;
          archive = ZipDecoder().decodeBytes(File(pathFile).readAsBytesSync());
        }else{
          archive = ZipDecoder().decodeBytes(respostaPath.files.first.bytes!);
        }
        
        
        for (final entry in archive) {
        if (entry.isFile && entry.name.contains(RegExp(r'\.jpg$'))) {
          try {
            // o Aquivo não é de Texto
            // Upload de Imagem
            img = entry.content;
          } catch (e) {
            //
          }
        }else if (entry.isFile && entry.name.contains(RegExp(r'\.json$'))){
          String txtFicha = utf8.decode(entry.content);
          jsonFicha = jsonDecode(txtFicha);
        }
        }
      }
    } catch (e) {
      // Type Error 
      print(e.toString());
    }

    return( jsonFicha );
  }

}