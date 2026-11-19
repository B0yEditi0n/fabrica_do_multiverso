// Menu de Ofensiva: desarmado e arremesso opcionais na ficha, no PDF e no
// limite de NP; margem de crítico (Perigoso) nas linhas da Ofensiva.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/screens/components/printer.dart';
import 'package:fabrica_do_multiverso/screens/ofensiva/ScreenOfensiva.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/ofensiva/lib_ofensiva.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

List<String> nomesNaOfensiva() =>
    Printer.ataquesOfensiva().map((a) => "${a["nome"]}").toList();

Map perigoso(int grad) {
  Map catalogo =
      jsonDecode(File('assets/poderes/modificadores.json').readAsStringSync());
  Map m = (catalogo["ofensivos"] as List).firstWhere((m) => m["m_id"] == "E065");
  return {...m, "grad": grad};
}

/// Poder "Garras": Dano (perto) com Perigoso opcional
Future<Map> garras(int grad, {int perigosoGrad = 0}) async {
  EfeitoDano e = EfeitoDano();
  await e.instanciarMetodo("Garras", "E013");
  e.nome = "Garras";
  e.setGrad(grad);
  if (perigosoGrad > 0) e.addModificador(perigoso(perigosoGrad));
  return e.retornaObj();
}

Map linha(String nome) =>
    Ofensiva.linhas().firstWhere((l) => l["nome"] == nome);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  test('desarmado entra na ofensiva do PDF só quando incluído', () {
    personagem.incluirDesarmado = true;
    expect(nomesNaOfensiva(), contains('Desarmado'));

    personagem.incluirDesarmado = false;
    expect(nomesNaOfensiva(), isNot(contains('Desarmado')));
  });

  test('desarmado incluído respeita acerto + dano <= 2 x NP', () {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 12; // dano 12
    personagem.habilidades.getItem("LUT")["valor"] = 9; // acerto 9
    bool desarmadoForaDoLimite() => ValidaNpPersonagem()
        .validacaoGeral()
        .any((e) => e["nome"] == "Desarmado");

    personagem.incluirDesarmado = true;
    expect(desarmadoForaDoLimite(), isTrue);

    personagem.incluirDesarmado = false;
    expect(desarmadoForaDoLimite(), isFalse);
  });

  test('desarmado dentro do limite não gera alerta', () {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 10;
    personagem.habilidades.getItem("LUT")["valor"] = 10;
    expect(
        ValidaNpPersonagem()
            .validacaoGeral()
            .any((e) => e["nome"] == "Desarmado"),
        isFalse);
  });

  test('a escolha é salva na ficha; ficha antiga inclui o desarmado', () async {
    personagem.incluirDesarmado = false;
    Map json = personagem.returnObjJson();

    Ficha recarregada = Ficha();
    await recarregada.reInit(json);
    expect(recarregada.incluirDesarmado, isFalse);

    json.remove("ofensiva"); // versões anteriores não tinham o campo
    Ficha antiga = Ficha();
    await antiga.reInit(json);
    expect(antiga.incluirDesarmado, isTrue);
  });

  // Arremesso opcional (spec 2a, 17a–17d): acerto Destreza + Ataque à
  // Distância, dano Força; independente do desarmado.
  test('arremesso entra na ofensiva do PDF só quando incluído (o desarmado não muda)', () {
    personagem.incluirArremesso = true;
    expect(nomesNaOfensiva(), contains('Arremesso'));
    expect(nomesNaOfensiva(), contains('Desarmado'));

    personagem.incluirArremesso = false;
    expect(nomesNaOfensiva(), isNot(contains('Arremesso')));
    expect(nomesNaOfensiva(), contains('Desarmado'));
  });

  test('arremesso incluído respeita acerto + dano <= 2 x NP', () {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 12; // dano 12
    personagem.habilidades.getItem("DES")["valor"] = 9; // acerto 9
    bool arremessoForaDoLimite() => ValidaNpPersonagem()
        .validacaoGeral()
        .any((e) => e["nome"] == "Arremesso");

    personagem.incluirArremesso = true;
    expect(arremessoForaDoLimite(), isTrue);

    personagem.incluirArremesso = false;
    expect(arremessoForaDoLimite(), isFalse);
  });

  test('arremesso dentro do limite não gera alerta', () {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 10;
    personagem.habilidades.getItem("DES")["valor"] = 10;
    expect(
        ValidaNpPersonagem()
            .validacaoGeral()
            .any((e) => e["nome"] == "Arremesso"),
        isFalse);
  });

  test('a escolha do arremesso é salva; ficha antiga e ficha só com ofensiva.desarmado incluem o arremesso', () async {
    personagem.incluirArremesso = false;
    Map json = personagem.returnObjJson();

    Ficha recarregada = Ficha();
    await recarregada.reInit(json);
    expect(recarregada.incluirArremesso, isFalse);
    expect(recarregada.incluirDesarmado, isTrue);

    json["ofensiva"] = {"desarmado": false}; // salva antes da opção de arremesso
    Ficha soDesarmado = Ficha();
    await soDesarmado.reInit(json);
    expect(soDesarmado.incluirDesarmado, isFalse);
    expect(soDesarmado.incluirArremesso, isTrue);

    json.remove("ofensiva");
    Ficha antiga = Ficha();
    await antiga.reInit(json);
    expect(antiga.incluirArremesso, isTrue);
  });

  // Margem de crítico (ticket 2): ameaça = 20 − (Perigoso + Crítico
  // Aprimorado ligado ao ataque); a soma passa de 4 → erro de validação.
  group('margem de crítico', () {
    test('Perigoso 1→4 gera Crítico 19-20 até 16-20 na linha da Ofensiva',
        () async {
      for (int n = 1; n <= 4; n++) {
        personagem.poderes.poderesLista
          ..clear()
          ..add(await garras(8, perigosoGrad: n));
        expect(linha("Garras")["critico"], 'Crítico ${20 - n}-20');
      }
    });

    test('ataque sem melhoria não exibe margem (poder, desarmado e arremesso)',
        () async {
      // ficha antiga com a chave legada "critico" continua sem margem
      personagem.poderes.poderesLista.add({...await garras(8), "critico": 3});
      for (String nome in ["Garras", "Desarmado", "Arremesso"]) {
        expect(linha(nome)["critico"], '', reason: nome);
        expect(Ofensiva.resumo(linha(nome)), isNot(contains('Crítico')),
            reason: nome);
      }
    });

    test('Perigoso e Crítico Aprimorado somam: Perigoso 1 + CA 2 → 17-20',
        () async {
      Map poder = await garras(8, perigosoGrad: 1);
      expect(EfeitoOfensivo.ameacaCritico(poder, graduacoesVantagem: 2), 17);
      expect(EfeitoOfensivo.textoCritico(17), 'Crítico 17-20');
      expect(EfeitoOfensivo.melhoriaCritico(poder, graduacoesVantagem: 2), 3);
    });

    test('melhoria acima de 4 gera erro de validação', () async {
      personagem.np = 20; // isola o alerta de crítico do limite de NP
      Map poder = await garras(8, perigosoGrad: 3);
      expect(EfeitoOfensivo.melhoriaCritico(poder, graduacoesVantagem: 2), 5);

      bool erroCritico() => ValidaNpPersonagem().validacaoGeral().any(
          (e) => e["nome"] == "Garras" && "${e["msg"]}".contains("crítico"));

      personagem.poderes.poderesLista.add(poder);
      expect(erroCritico(), isFalse);

      // Perigoso 5 (ficha editada/importada) passa do teto 16-20
      personagem.poderes.poderesLista
        ..clear()
        ..add(await garras(8, perigosoGrad: 5));
      expect(erroCritico(), isTrue);
    });

    test('resumo da Ofensiva: Garras +12 (Dano 8, CD 23, Crítico 18-20)',
        () async {
      personagem.habilidades.getItem("LUT")["valor"] = 12;
      personagem.poderes.poderesLista.add(await garras(8, perigosoGrad: 2));
      expect(Ofensiva.resumo(linha("Garras")),
          'Garras +12 (Dano 8, CD 23, Crítico 18-20)');
      expect(Ofensiva.resumo(linha("Desarmado")), 'Desarmado +12 (Dano 0, CD 15)');
      // O PDF consome a mesma linha
      expect(Printer.textoAtaque(linha("Garras")),
          'Acerto +12 | Dano 8 | Crítico 18-20');
      expect(linha("Garras")["cdTexto"], '23 Resistência');
    });

    test('o poder salvo não grava mais a chave legada "critico"', () async {
      expect((await garras(8)).containsKey("critico"), isFalse);
    });
  });

  group('tela do menu Ofensiva', () {
    testWidgets(
        'desligar o arremesso tira a linha da lista e não mexe no desarmado',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScreenOfensiva()));
      expect(find.textContaining('Arremesso +'), findsOneWidget);
      expect(find.textContaining('Desarmado +'), findsOneWidget);

      await tester.tap(find.text('Incluir arremesso na ofensiva'));
      await tester.pump();

      expect(personagem.incluirArremesso, isFalse);
      expect(personagem.incluirDesarmado, isTrue);
      expect(find.textContaining('Arremesso +'), findsNothing);
      expect(find.textContaining('Desarmado +'), findsOneWidget);
    });

    testWidgets('mostra o resumo com a margem de crítico', (tester) async {
      personagem.habilidades.getItem("LUT")["valor"] = 12;
      personagem.poderes.poderesLista.add(await garras(8, perigosoGrad: 2));

      await tester.pumpWidget(const MaterialApp(home: ScreenOfensiva()));
      expect(find.text('Garras +12 (Dano 8, CD 23, Crítico 18-20)'),
          findsOneWidget);
      expect(find.textContaining('Desarmado +12 (Dano 0, CD 15)'),
          findsOneWidget);
    });
  });
}
