// Testes do custo de poderes compostos e do orçamento da ficha.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

/// Efeito de Dano (1/grad.) com a graduação pedida: custa `grad` pontos.
Future<Map> dano(int grad) async {
  EfeitoDano e = EfeitoDano();
  await e.instanciarMetodo("Dano $grad", "E013");
  e.setGrad(grad);
  return e.retornaObj();
}

Map pacote(String tipo, List efeitos,
        {int removivel = 0, String efeito = "Pacote"}) =>
    {
      "nome": "Teste",
      "efeito": efeito,
      "tipo": tipo,
      "removivel": removivel,
      "class": "PacotesEfeitos",
      "efeitos": efeitos,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  group('Custo de pacotes', () {
    test('pacote vazio custa 0', () {
      expect(CustoPoderes.custoItem(pacote("E", [])), 0);
    });

    test('efeitos ligados somam', () async {
      expect(
          CustoPoderes.custoItem(pacote("L", [await dano(10), await dano(6)])),
          16);
    });

    test('efeito alternativo: primário + 1 ponto por alternativo', () async {
      Map arranjo =
          pacote("E", [await dano(8), await dano(10), await dano(4)]);
      expect(CustoPoderes.custoItem(arranjo), 12);
    });

    test('arranjo com um único efeito custa só o efeito', () async {
      expect(CustoPoderes.custoItem(pacote("E", [await dano(10)])), 10);
      expect(CustoPoderes.custoItem(pacote("D", [await dano(10)])), 10);
    });

    test('alternativo dinâmico: primário + 1 + 2 por alternativo', () async {
      Map arranjo =
          pacote("D", [await dano(10), await dano(10), await dano(5)]);
      expect(CustoPoderes.custoItem(arranjo), 15);
    });

    test('alternativo formado por efeitos ligados', () async {
      Map ligados = pacote("L", [await dano(4), await dano(5)]);
      Map arranjo = pacote("E", [await dano(10), ligados]);
      expect(CustoPoderes.custoItem(arranjo), 11);
    });

    test('removível: -1 a cada 5 pontos', () async {
      expect(
          CustoPoderes.custoItem(
              pacote("R", [await dano(12)], removivel: 1)),
          10);
      expect(
          CustoPoderes.custoItem(pacote("R", [await dano(4)], removivel: 1)),
          4);
    });

    test('facilmente removível: -2 a cada 5 pontos', () async {
      expect(
          CustoPoderes.custoItem(
              pacote("R", [await dano(10)], removivel: 2)),
          6);
    });

    test('equipamento não custa pontos de poder', () async {
      Map equip =
          pacote("R", [await dano(7)], removivel: 4, efeito: "Equipamentos");
      expect(CustoPoderes.custoItem(equip), 0);
      expect(CustoPoderes.pontosEquipamento([equip]), 7);
    });

    test('custo é recalculado, não lido do campo gravado', () async {
      Map efeito = await dano(10);
      efeito["custo"] = 999;
      expect(CustoPoderes.custoItem(efeito), 10);
    });

    test('PacotesEfeitos devolve o mesmo custo', () async {
      PacotesEfeitos p = PacotesEfeitos();
      await p.instanciarMetodo(pacote("E", [await dano(10), await dano(3)]));
      expect(p.retornaObj()["custo"], 11);
    });
  });

  group('Efeitos de custo variável', () {
    test('custo-base das opções é refeito ao recarregar', () async {
      EfeitoCustoVaria e = EfeitoCustoVaria();
      await e.instanciarMetodo("Ilusão", "E018");
      e.setGrad(4);
      Map opcao = Map.from(e.returnListOpt().first);
      e.addOpt(opcao);
      int custo = e.custearAlteracoes();
      expect(custo, greaterThan(0));

      Map salvo = jsonDecode(jsonEncode(e.retornaObj()));
      expect(CustoPoderes.custoItem(salvo), custo);
    });

    test('alterar um efeito não muda o catálogo compartilhado', () async {
      EfeitoCustoVaria a = EfeitoCustoVaria();
      await a.instanciarMetodo("A", "E018");
      a.addOpt(Map.from(a.returnListOpt().last));

      EfeitoCustoVaria b = EfeitoCustoVaria();
      await b.instanciarMetodo("B", "E018");
      expect(b.returnObjDefault()["custo_base"],
          isNot(a.returnObjDefault()["custo_base"]));
    });
  });

  group('Orçamento da ficha', () {
    test('disponível é 15 por nível de poder', () {
      personagem.np = 8;
      expect(personagem.resumoPontos()["disponivel"], 120);
    });

    test('total soma todos os módulos', () async {
      personagem.np = 10;
      personagem.habilidades.getItem("FOR")["valor"] = 5; // 10
      personagem.defesas.returnId("D001")["valor"] = 3; // 3
      personagem.pericias.ListaPercias[0]["valor"] = 4; // 2
      personagem.vantagens.listaVantagens.add({
        "id": "V001",
        "nome": "X",
        "graduado": false,
        "desc": false,
        "graduacao": 1,
      }); // 1
      personagem.poderes.poderesLista
          .add(pacote("E", [await dano(10), await dano(2)])); // 11

      Map<String, int> r = personagem.resumoPontos();
      expect(r["poderes"], 11);
      expect(r["total"], 27);
      expect(r["restante"], 123);
    });

    test('estourar o total gera erro de validação', () async {
      personagem.np = 1;
      personagem.poderes.poderesLista.add(await dano(16));
      List erros = ValidaNpPersonagem().validacaoGeral();
      expect(erros.where((e) => e["tipo"] == "T").length, 1);
    });

    test('equipamento além da vantagem gera erro', () async {
      personagem.poderes.poderesLista.add(pacote("R", [await dano(7)],
          removivel: 4, efeito: "Equipamentos"));
      expect(
          ValidaNpPersonagem()
              .validacaoGeral()
              .where((e) => e["tipo"] == "Q")
              .length,
          1);

      personagem.vantagens.listaVantagens.add({
        "id": "V041",
        "nome": "EQUIPAMENTO",
        "graduado": true,
        "desc": false,
        "graduacao": 2,
      });
      expect(
          ValidaNpPersonagem()
              .validacaoGeral()
              .where((e) => e["tipo"] == "Q"),
          isEmpty);
    });
  });
}
