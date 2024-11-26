import 'package:archive/archive_io.dart'; // Zip
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Sei lá o que
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:background_downloader/background_downloader.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';

class Download{
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

  }
}