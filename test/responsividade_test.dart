// Layout em celular: as telas não podem estourar a largura e os botões
// precisam ter área de toque confortável. Um estouro de layout (overflow)
// gera exceção e derruba o teste.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/main.dart';
import 'package:fabrica_do_multiverso/script/armazenamento.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/theme/theme.dart';
import 'package:fabrica_do_multiverso/screens/components/save_option_component.dart';
import 'package:fabrica_do_multiverso/screens/complicacoes/ScreenComplicacoes.dart';
import 'package:fabrica_do_multiverso/screens/pericias/functions/addPericias.dart';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenEditorPoderes.dart';
import 'package:fabrica_do_multiverso/screens/poderes/poderes/popup_addPoderes.dart';
import 'package:fabrica_do_multiverso/screens/vantagens/functions/addVantagens.dart';

// Celulares estreitos (iPhone SE 1ª geração) e comuns (Android 360dp)
const List<Size> telas = [Size(320, 568), Size(360, 740)];

Future<void> usarTela(WidgetTester tester, Size tamanho) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = tamanho;
  addTearDown(tester.view.reset);
}

/// Deixa terminar as leituras de catálogo (disco real) e redesenha.
Future<void> assentar(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Widget embrulhar(Widget tela) => MaterialApp(theme: temaPadrao(), home: tela);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory pasta;

  // A fonte padrão dos testes (Ahem) tem letras quadradas, o dobro da largura
  // real. Mede com a Roboto que acompanha o Flutter, como no aparelho.
  setUpAll(() async {
    final String? raiz = Platform.environment['FLUTTER_ROOT'];
    if (raiz == null) return;
    final FontLoader roboto = FontLoader('Roboto');
    for (final String peso in ['regular', 'medium', 'bold']) {
      final File arq = File(
          '$raiz/bin/cache/artifacts/material_fonts/roboto-$peso.ttf');
      if (!arq.existsSync()) return;
      roboto.addFont(arq
          .readAsBytes()
          .then((b) => ByteData.sublistView(Uint8List.fromList(b))));
    }
    await roboto.load();
  });

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('fabrica_resp_');
    Armazenamento.pastaTeste = pasta;
    personagem = Ficha();
    await personagem.init();
  });

  tearDown(() async {
    Armazenamento.pastaTeste = null;
    if (await pasta.exists()) await pasta.delete(recursive: true);
  });

  for (final Size tamanho in telas) {
    final String rotulo = '${tamanho.width.toInt()}x${tamanho.height.toInt()}';

    for (final String rota in [
      '/habilidades',
      '/defesas',
      '/poderes',
      '/vantagens',
      '/pericias',
      '/complicacoes',
    ]) {
      testWidgets('$rota cabe em $rotulo', (tester) async {
        await usarTela(tester, tamanho);
        personagem.complicacoes.add({
          "titulo": "Motivação: responsabilidade com a cidade inteira",
          "desc": "Texto longo para forçar quebra de linha no cartão da lista."
        });

        await tester.pumpWidget(FabricaHerois());
        await tester.pump();
        expect(tester.takeException(), isNull); // tela inicial
        tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(rota);
        await assentar(tester);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('diálogo de salvar cabe em $rotulo',
        (tester) async {
      await usarTela(tester, tamanho);
      await tester.pumpWidget(embrulhar(Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              child: const Text('abrir'),
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SavePopUp(fileImg: Uint8List(0))),
            ),
          ),
        ),
      )));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Botões ocupam a largura do diálogo e têm altura de toque generosa
      for (final String texto in ['PDF Para impressão', 'Baixar Ficha']) {
        final Size botao = tester.getSize(
            find.ancestor(of: find.text(texto), matching: find.bySubtype<ElevatedButton>()));
        expect(botao.height, greaterThanOrEqualTo(56));
        expect(botao.width, greaterThan(tamanho.width * 0.6));
      }
    });

    testWidgets('popups de inclusão cabem em $rotulo', (tester) async {
      await usarTela(tester, tamanho);

      await tester.pumpWidget(
          embrulhar(DynamicDialog(tipo: "", descNome: true)));
      await assentar(tester);
      expect(tester.takeException(), isNull);
      // Ações do diálogo centralizadas: par simétrico em relação ao meio
      final double esquerda = tester.getRect(find.text('Adicionar')).left;
      final double direita = tester.getRect(find.text('Cancelar')).right;
      expect((esquerda + direita) / 2, closeTo(tamanho.width / 2, 12));
      expect(
          tester
              .getSize(find.ancestor(
                  of: find.text('Adicionar'),
                  matching: find.byType(TextButton)))
              .height,
          greaterThanOrEqualTo(48));

      await tester.pumpWidget(embrulhar(PopUpAddSkill(obj: const {})));
      await assentar(tester);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
          embrulhar(PopUpAddComplicacao(title: "", desc: "")));
      await assentar(tester);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(embrulhar(PopUpAddVantagem(
        repertorioVantagens: [
          {
            "id": "V999",
            "nome": "Vantagem com um nome bem comprido para testar a largura",
            "desc": true,
            "graduado": true,
            "limite": 0
          }
        ],
        obj: const {},
      )));
      await assentar(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('editor de poder cabe em $rotulo', (tester) async {
      await usarTela(tester, tamanho);
      await tester.runAsync(
          () => personagem.poderes.novoPoder("Rajada", "E001", "EfeitoAflicao"));
      expect(personagem.poderes.poderesLista, isNotEmpty);

      await tester.pumpWidget(embrulhar(
          powerEdit(objEfeito: personagem.poderes.poderesLista.first)));
      await assentar(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Adicionar Modificador'), findsOneWidget);
    });
  }
}
