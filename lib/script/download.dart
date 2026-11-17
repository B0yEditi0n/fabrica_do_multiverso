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
import 'package:fabrica_do_multiverso/script/importacao/importa_poder_supremo.dart';

class Download{
  Uint8List img = Uint8List(0);
  static genericDownload(fileImg) async{
    // Pega Json e Transforma em File
    // Criando um Zip de Saida
    // Crie uma lista de arquivos para adicionar ao ZIP
    // Não remover os escapes de aspas: sem eles um texto com " corrompe o JSON
    List<int> fichaByte = utf8.encode(json.encode(personagem.returnObjJson()));

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
        
        ..setAttribute('download', '${personagem.nomePersonagem} NP: ${personagem.np}, ${DateTime.now()}.zip')
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

  // Preenchidos quando o arquivo é um portfólio do Poder Supremo
  bool importadoPoderSupremo = false;
  List<String> avisos = [];
  String erro = '';

  Future<Map> _interpretaJson(Map json,
      Future<int?> Function(List<String> nomes)? escolherPersonagem) async {
    /*
      Ficha da Fábrica: devolve como está.
      Portfólio do Poder Supremo: converte o personagem escolhido.
    */
    if (!PoderSupremo.reconhece(json)) return json;

    String? recusa = PoderSupremo.motivoRecusa(json);
    if (recusa != null) {
      erro = recusa;
      return {};
    }

    int indice = 0;
    List<String> nomes = PoderSupremo.nomesPersonagens(json);
    if (nomes.length > 1 && escolherPersonagem != null) {
      int? escolhido = await escolherPersonagem(nomes);
      if (escolhido == null) return {}; // cancelado
      indice = escolhido;
    }

    ResultadoImportacao resultado = await PoderSupremo.converter(json, indice);
    importadoPoderSupremo = true;
    avisos = resultado.avisos;
    if (img.isEmpty) img = resultado.imagem;
    return resultado.ficha;
  }

  Future<dynamic> uploadFicha(
      {Future<int?> Function(List<String> nomes)? escolherPersonagem}) async{
    // Upload de Ficha: ZIP da Fábrica ou JSON (Fábrica ou Poder Supremo)
    const List<String> extension = ["zip", "ZIP", "json", "JSON"];
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

        List<int> bytes;
        if(!kIsWeb){
          String pathFile = respostaPath.files.first.path as String;
          bytes = File(pathFile).readAsBytesSync();
        }else{
          bytes = respostaPath.files.first.bytes!;
        }

        // Arquivo JSON solto (portfólio do Poder Supremo ou ficha da Fábrica)
        if (respostaPath.files.first.name.toLowerCase().endsWith('.json')) {
          var json = jsonDecode(utf8.decode(bytes));
          if (json is Map) {
            jsonFicha = await _interpretaJson(json, escolherPersonagem);
          }
          return jsonFicha;
        }

        archive = ZipDecoder().decodeBytes(bytes);

        
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
        if (jsonFicha.isNotEmpty) {
          jsonFicha = await _interpretaJson(jsonFicha, escolherPersonagem);
        }
      }
    } on FormatException catch (e) {
      erro = 'Arquivo inválido: ${e.message}';
      jsonFicha = {};
    } catch (e) {
      // Type Error
      print(e.toString());
    }

    return( jsonFicha );
  }

}