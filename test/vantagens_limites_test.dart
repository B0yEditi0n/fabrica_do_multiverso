// Limites oficiais de graduação das vantagens (seam: cálculo da ficha).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';

Map vantagem(String id, {int grad = 1}) {
  List catalogo =
      jsonDecode(File('assets/vantagens.json').readAsStringSync());
  Map v = Map.from(catalogo.firstWhere((v) => v["id"] == id));
  v["graduacao"] = grad;
  v["txtDec"] = '';
  return v;
}

List alertasVantagem() => ValidaNpPersonagem()
    .validacaoGeral()
    .where((e) => e["tipo"] == "V")
    .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  test('vantagem graduada acima do teto oficial gera alerta', () {
    // Atraente: teto 2
    personagem.vantagens.listaVantagens.add(vantagem("V023", grad: 3));

    List alertas = alertasVantagem();
    expect(alertas, hasLength(1));
    expect(alertas.first["id"], ["V023"]);
  });

  test('não graduada com graduação 2 custa 1 PP e gera alerta', () {
    // Ataque Poderoso: não graduada
    personagem.vantagens.listaVantagens.add(vantagem("V021", grad: 2));

    expect(personagem.resumoPontos()["vantagens"], 1);
    expect(alertasVantagem().single["id"], ["V021"]);
  });

  test('catálogo traz os tetos oficiais da 3ª edição', () {
    // Fonte: livro básico de M&M 3ª edição
    const tetos = {
      "V022": 4, // Ataque Preciso
      "V023": 2, // Atraente
      "V032": 4, // Crítico Aprimorado
      "V047": 2, // Evasão
      "V048": 3, // Fascinar (Enganação, Intimidação, Persuasão)
      "V055": 5, // Inspirar
      "V083": 2, // Tontear (Enganação, Intimidação)
    };
    tetos.forEach((id, teto) {
      personagem.vantagens.listaVantagens = [vantagem(id, grad: teto)];
      expect(alertasVantagem(), isEmpty, reason: id);
      personagem.vantagens.listaVantagens = [vantagem(id, grad: teto + 1)];
      expect(alertasVantagem(), hasLength(1), reason: id);
    });
  });

  test('Sorte é limitada à metade do NP', () {
    personagem.np = 11;
    personagem.vantagens.listaVantagens = [vantagem("V080", grad: 5)];
    expect(alertasVantagem(), isEmpty);

    personagem.vantagens.listaVantagens = [vantagem("V080", grad: 6)];
    expect(alertasVantagem().single["id"], ["V080"]);
    expect(personagem.resumoPontos()["vantagens"], 5);
  });

  test('não graduada comprada duas vezes gera alerta e custa 1 PP', () {
    personagem.vantagens.listaVantagens = [vantagem("V021"), vantagem("V021")];

    expect(alertasVantagem().single["id"], ["V021"]);
    expect(personagem.resumoPontos()["vantagens"], 1);
  });

  test('graduada sem teto oficial não gera alerta', () {
    // Ataque Corpo-a-Corpo: limitada só pelo NP
    personagem.vantagens.listaVantagens.add(vantagem("V013", grad: 12));

    expect(alertasVantagem(), isEmpty);
    expect(personagem.resumoPontos()["vantagens"], 12);
  });

  test('ficha antiga acima do teto abre sem correção silenciosa', () async {
    Map json = personagem.returnObjJson();
    // Salva com "limite" 0, como as versões anteriores gravavam
    json["vantagens"] = [
      {...vantagem("V023", grad: 5), "limite": 0}
    ];

    Ficha antiga = Ficha();
    await antiga.reInit(json);
    personagem = antiga;

    expect(personagem.vantagens.listaVantagens.single["graduacao"], 5);
    expect(alertasVantagem().single["id"], ["V023"]);
    expect(personagem.resumoPontos()["vantagens"], 2);
  });
}
