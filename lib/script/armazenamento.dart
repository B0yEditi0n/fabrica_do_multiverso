import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';

/*
  Persistência local da ficha.

  O aplicativo gerencia UMA ficha por vez. Ela fica em dois arquivos
  na pasta do aplicativo:
    ficha.json  - o mesmo JSON exportado em "Baixar Ficha"
    ficha.jpg   - a imagem do personagem (se houver)

  Para trocar de personagem usa-se "Baixar Ficha" e "Upload".

  No navegador não há sistema de arquivos: os métodos não fazem nada
  (lá continua valendo exportar e importar o ZIP).
*/
class Armazenamento {
  /// Pasta alternativa, usada pelos testes.
  static Directory? pastaTeste;

  static bool get disponivel => !kIsWeb;

  static Future<Directory> _pasta() async {
    Directory pasta = pastaTeste ??
        Directory(
            '${(await getApplicationDocumentsDirectory()).path}/fabrica_do_multiverso');
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    return pasta;
  }

  /// Ficha sem nome e sem nenhum ponto gasto não precisa ser guardada.
  static bool _emBranco(Ficha ficha) {
    return ficha.nomePersonagem.trim().isEmpty &&
        ficha.complicacoes.isEmpty &&
        ficha.poderes.poderesLista.isEmpty &&
        ficha.resumoPontos()["total"] == 0;
  }

  static Future<bool> salvar(Ficha ficha, [Uint8List? imagem]) async {
    /*
      Grava a ficha por cima da anterior. Escreve em arquivo temporário e
      renomeia, para uma falha no meio da gravação não estragar o que havia.
      Ficha em branco não é gravada (nem apaga a guardada: para isso, limpar()).
      Return: true se gravou.
    */
    if (!disponivel || _emBranco(ficha)) return false;

    Directory pasta = await _pasta();
    File destino = File('${pasta.path}/ficha.json');
    File temporario = File('${destino.path}.tmp');
    await temporario.writeAsString(json.encode(ficha.returnObjJson()),
        flush: true);
    await temporario.rename(destino.path);

    File arquivoImagem = File('${pasta.path}/ficha.jpg');
    if (imagem != null && imagem.isNotEmpty) {
      await arquivoImagem.writeAsBytes(imagem, flush: true);
    } else if (await arquivoImagem.exists()) {
      await arquivoImagem.delete();
    }
    return true;
  }

  static Future<Map?> carregar() async {
    /*
      Lê a ficha guardada.
      Return: { ficha: Map do JSON, imagem: Uint8List }
              ou null se não houver ficha (ou se o arquivo estiver ilegível).
    */
    if (!disponivel) return null;

    Directory pasta = await _pasta();
    File arquivo = File('${pasta.path}/ficha.json');
    if (!await arquivo.exists()) return null;

    Map ficha;
    try {
      ficha = jsonDecode(await arquivo.readAsString());
    } catch (e) {
      // Arquivo ilegível: não é apagado, mas o aplicativo abre em branco
      return null;
    }

    File arquivoImagem = File('${pasta.path}/ficha.jpg');
    Uint8List imagem = await arquivoImagem.exists()
        ? await arquivoImagem.readAsBytes()
        : Uint8List(0);

    return {"ficha": ficha, "imagem": imagem};
  }

  static Future<void> limpar() async {
    /* Apaga a ficha guardada (usado ao começar uma ficha nova). */
    if (!disponivel) return;

    Directory pasta = await _pasta();
    for (String nome in ['ficha.json', 'ficha.jpg']) {
      File arquivo = File('${pasta.path}/$nome');
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    }
  }
}
