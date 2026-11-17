// Testes do armazenamento local: o aplicativo guarda uma única ficha.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/armazenamento.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory pasta;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('fabrica_teste_');
    Armazenamento.pastaTeste = pasta;
    personagem = Ficha();
    await personagem.init();
  });

  tearDown(() async {
    Armazenamento.pastaTeste = null;
    await pasta.delete(recursive: true);
  });

  List<File> arquivos() => pasta.listSync(recursive: true).whereType<File>().toList();

  test('ficha em branco não é gravada', () async {
    expect(await Armazenamento.salvar(personagem), false);
    expect(await Armazenamento.carregar(), isNull);
  });

  test('salvar e carregar devolvem a mesma ficha', () async {
    personagem.nomePersonagem = 'Capitão "Teste"';
    personagem.np = 8;
    personagem.habilidades.getItem("FOR")["valor"] = 4;
    Uint8List imagem = Uint8List.fromList([1, 2, 3]);

    expect(await Armazenamento.salvar(personagem, imagem), true);

    Map dados = (await Armazenamento.carregar())!;
    Ficha outra = Ficha();
    await outra.reInit(dados["ficha"]);
    expect(outra.nomePersonagem, 'Capitão "Teste"');
    expect(outra.np, 8);
    expect(outra.habilidades.getItem("FOR")["valor"], 4);
    expect(dados["imagem"], imagem);
  });

  test('só existe uma ficha: salvar outra substitui a anterior', () async {
    personagem.nomePersonagem = 'A';
    await Armazenamento.salvar(personagem, Uint8List.fromList([1]));

    Ficha outra = Ficha();
    await outra.init();
    outra.nomePersonagem = 'B';
    await Armazenamento.salvar(outra);

    Map dados = (await Armazenamento.carregar())!;
    expect(dados["ficha"]["pesonagem"]["nome"], 'B');
    // A imagem da ficha anterior não sobra para a nova
    expect(dados["imagem"], isEmpty);
    expect(arquivos().length, 1);
  });

  test('ficha em branco não apaga a ficha guardada', () async {
    personagem.nomePersonagem = 'Guardada';
    await Armazenamento.salvar(personagem);

    Ficha branca = Ficha();
    await branca.init();
    expect(await Armazenamento.salvar(branca), false);
    expect((await Armazenamento.carregar())!["ficha"]["pesonagem"]["nome"],
        'Guardada');
  });

  test('limpar remove ficha e imagem', () async {
    personagem.nomePersonagem = 'Apagar';
    await Armazenamento.salvar(personagem, Uint8List.fromList([9]));
    await Armazenamento.limpar();

    expect(await Armazenamento.carregar(), isNull);
    expect(arquivos(), isEmpty);
  });

  test('arquivo corrompido abre em branco, sem derrubar o aplicativo',
      () async {
    await File('${pasta.path}/ficha.json').writeAsString('{nao e json');
    expect(await Armazenamento.carregar(), isNull);
  });
}
