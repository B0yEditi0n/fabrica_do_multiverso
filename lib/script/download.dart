import 'package:archive/archive_io.dart'; // Zip
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Sei lá o que
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:archive/archive.dart';

import 'dart:convert' show utf8;

import 'package:background_downloader/background_downloader.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';

import 'package:file_picker/file_picker.dart';

class Download{
  Uint8List img = Uint8List(0);
  genericDownload(fileImg) async{
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

    //Directory
    Directory downladDir = await getApplicationDocumentsDirectory();
    final String dirPath = downladDir.path;

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

  Future<dynamic> uploadFicha() async{
    // Upload de Ficha
    const List<String> extension = ["zip", "ZIP"];
    Map jsonFicha = {};

    FilePickerResult respostaPath = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      //onFileLoading: (FilePickerStatus status) => ,
      allowedExtensions: extension,
      dialogTitle: "Arquivo de Heroi",
      initialDirectory: "",
      lockParentWindow: false, 
    ) as FilePickerResult;

    String pathFile = respostaPath.files.first.path as String;
    final archive = ZipDecoder().decodeBytes(File(pathFile).readAsBytesSync());

    

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

    return( jsonFicha );
  }
}