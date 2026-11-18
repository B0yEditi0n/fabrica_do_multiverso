// Teste de fumaça da tela inicial: resumo de pontos e validação visíveis.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/main.dart';
import 'package:fabrica_do_multiverso/script/armazenamento.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory pasta;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('fabrica_tela_');
    Armazenamento.pastaTeste = pasta;
    personagem = Ficha();
    await personagem.init();
  });

  tearDown(() async {
    Armazenamento.pastaTeste = null;
    if (await pasta.exists()) await pasta.delete(recursive: true);
  });

  testWidgets('mostra o orçamento de pontos da ficha', (tester) async {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 5;

    await tester.pumpWidget(FabricaHerois());
    await tester.pump();

    expect(find.text('Pontos de poder: 10 / 150'), findsOneWidget);
    expect(find.text('140 restantes'), findsOneWidget);
  });

  testWidgets('lista de erros mostra as mensagens de validação',
      (tester) async {
    personagem.np = 1;
    personagem.habilidades.getItem("FOR")["valor"] = 10; // 20 > 15
    personagem.incluirDesarmado = false; // só o alerta de pontos

    await tester.pumpWidget(FabricaHerois());
    await tester.pump();

    expect(find.text('5 acima do disponível'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Erros 1'), 100,
        scrollable: find.descendant(
            of: find.byType(Drawer), matching: find.byType(Scrollable)));
    expect(find.text('Erros 1'), findsOneWidget);

    await tester.tap(find.text('Erros 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 acima dos 15 disponíveis'), findsOneWidget);
  });

  testWidgets('uma ficha por vez: "Nova ficha" confirma e apaga a atual',
      (tester) async {
    personagem.nomePersonagem = 'Antigo';
    personagem.habilidades.getItem("FOR")["valor"] = 3;

    await tester.pumpWidget(FabricaHerois());
    await tester.pump();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Personagens'), findsNothing);

    Finder rolagem = find.descendant(
        of: find.byType(Drawer), matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(find.text('Nova ficha'), 100,
        scrollable: rolagem);
    await tester.ensureVisible(find.text('Nova ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova ficha'));
    await tester.pumpAndSettle();

    // Cancelar mantém a ficha
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(personagem.nomePersonagem, 'Antigo');

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Nova ficha'), 100,
        scrollable: rolagem);
    await tester.ensureVisible(find.text('Nova ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova ficha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar e começar'));
    // A limpeza usa disco de verdade: alterna tempo real e quadros
    for (int i = 0; i < 10 && personagem.nomePersonagem.isNotEmpty; i++) {
      await tester.pump();
      await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)));
    }
    await tester.pumpAndSettle();

    expect(personagem.nomePersonagem, '');
    expect(find.text('Pontos de poder: 0 / 150'), findsOneWidget);
  });
}
