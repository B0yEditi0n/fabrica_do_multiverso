// Modificadores próprios de Mover Objetos e Teleporte, validação de NP
// ligada a eles e área de cópia (copiar e colar poderes).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_areaCopia.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

final List _catalogo =
    jsonDecode(File('assets/poderes/efeitos.json').readAsStringSync());

Map _modDoEfeito(String eId, String nome, [int grad = 1]) {
  Map efeito = _catalogo.firstWhere((e) => e["e_id"] == eId);
  Map mod = Map.from(
      (efeito["modificadores"] as List).firstWhere((m) => m["nome"] == nome));
  mod["grad"] = grad;
  return mod;
}

Future<Map> _efeito(String classe, String eId, int grad,
    [List<Map> mods = const []]) async {
  Efeito e = Efeito.porClasse(classe);
  await e.instanciarMetodo("Teste $eId", eId);
  e.setGrad(grad);
  for (Map m in mods) {
    e.addModificador(m);
  }
  return e.retornaObj();
}

Map _pacote(String tipo, List efeitos) => {
      "nome": "Pacote $tipo",
      "efeito": "Pacote",
      "tipo": tipo,
      "removivel": 0,
      "class": "PacotesEfeitos",
      "efeitos": efeitos,
      "idCriacao": "A-original-$tipo",
    };

int _bonusResistencia() =>
    (personagem.defesas.returnId("D004")["bonus"] as List? ?? []).length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
    AreaDeCopia.limpar();
  });

  group('Catálogo', () {
    test('Mover Objetos tem os modificadores da wiki', () {
      Map mo = _catalogo.firstWhere((e) => e["e_id"] == "E026");
      expect((mo["modificadores"] as List).map((m) => m["nome"]), [
        "Arma Improvisada ou Maestria em Arremesso",
        "Dano",
        "Direção Limitada",
        "Limitação Material",
      ]);
    });

    test('Teleporte tem os modificadores da wiki', () {
      Map t = _catalogo.firstWhere((e) => e["e_id"] == "E036");
      expect((t["modificadores"] as List).length, 10);
    });

    test('custo de Mover Objetos com extras e falhas', () async {
      // (2 + 1 Dano - 1 Direção Limitada) x 6 + 2 fixos = 14
      Map mo = await _efeito("EfeitoOfensivo", "E026", 6, [
        _modDoEfeito("E026", "Dano"),
        _modDoEfeito("E026", "Direção Limitada"),
        _modDoEfeito("E026", "Arma Improvisada ou Maestria em Arremesso", 2),
      ]);
      expect(CustoPoderes.custoEfeito(mo), 14);
    });

    test('custo de Teleporte com extras e falhas', () async {
      // (2 + 1 Estendido + 2 Portal - 1 Meio) x 5 + 1 Giro - 2 Tempo = 19
      Map t = await _efeito("Efeito", "E036", 5, [
        _modDoEfeito("E036", "Estendido"),
        _modDoEfeito("E036", "Portal"),
        _modDoEfeito("E036", "Meio"),
        _modDoEfeito("E036", "Giro"),
        _modDoEfeito("E036", "Tempo de Transporte", 2),
      ]);
      expect(CustoPoderes.custoEfeito(t), 19);
    });
  });

  group('Validação de NP', () {
    test('dano de Mover Objetos soma o extra e Armas Improvisadas', () async {
      Map mo = await _efeito("EfeitoOfensivo", "E026", 6, [
        _modDoEfeito("E026", "Arma Improvisada ou Maestria em Arremesso", 2),
      ]);
      expect(ValidaNpPersonagem.danoTotal(mo, 6), 8);

      personagem.vantagens.listaVantagens.add({
        "id": "V007",
        "nome": "ARMAS IMPROVISADAS",
        "graduado": true,
        "desc": false,
        "graduacao": 3,
        "class": "Vantagem",
      });
      expect(ValidaNpPersonagem.danoTotal(mo, 6), 11);

      // Outros efeitos: só a graduação
      Map dano = await _efeito("EfeitoDano", "E013", 6);
      expect(ValidaNpPersonagem.danoTotal(dano, 6), 6);
    });

    test('Mover Objetos acima de 2 x NP pelo dano total', () async {
      personagem.np = 5;
      Map mo = await _efeito("EfeitoOfensivo", "E026", 7, [
        _modDoEfeito("E026", "Arma Improvisada ou Maestria em Arremesso", 4),
      ]);
      personagem.poderes.poderesLista.add(mo);
      List erros = ValidaNpPersonagem().validacaoGeral();
      expect(erros.any((e) => "${e["msg"]}".contains("fora do limite")),
          isTrue);
    });

    test('Limitado a Estendido exige Estendido', () async {
      Map t = await _efeito("Efeito", "E036", 4,
          [_modDoEfeito("E036", "Limitado a Estendido")]);
      personagem.poderes.poderesLista.add(_pacote("R", [t]));
      bool temErro() => ValidaNpPersonagem()
          .validacaoGeral()
          .any((e) => "${e["msg"]}".contains("Limitado a Estendido"));
      expect(temErro(), isTrue);

      (t["modificadores"] as List).add(_modDoEfeito("E036", "Estendido"));
      expect(temErro(), isFalse);
    });
  });

  group('Copiar e colar', () {
    test('colar na lista cria poder novo com id novo', () async {
      Map dano = await _efeito("EfeitoDano", "E013", 8);
      AreaDeCopia.copiar(dano);
      expect(AreaDeCopia.temCopia, isTrue);

      Map colado = AreaDeCopia.colar();
      expect(colado["idCriacao"], isNot(dano["idCriacao"]));
      expect(colado["graduacao"], 8);
      expect(CustoPoderes.custoEfeito(colado), 8);

      // A cópia é independente do original
      dano["graduacao"] = 2;
      expect(AreaDeCopia.colar()["graduacao"], 8);
    });

    test('pacote colado renova os ids internos', () async {
      Map ligados = _pacote("L", [await _efeito("EfeitoDano", "E013", 4)]);
      AreaDeCopia.copiar(ligados);
      Map colado = AreaDeCopia.colar(idPacoteDestino: "A-destino", tipoDestino: "E");
      expect(colado["idCriacao"], isNot("A-original-L"));
      expect(colado["efeitos"][0]["idCriacao"],
          isNot(ligados["efeitos"][0]["idCriacao"]));
    });

    test('destinos respeitam as regras de aninhamento', () async {
      AreaDeCopia.copiar(await _efeito("EfeitoDano", "E013", 4));
      for (String? destino in [null, "E", "D", "R", "L"]) {
        expect(AreaDeCopia.motivoRecusa(destino), isNull);
      }

      AreaDeCopia.copiar(_pacote("E", []));
      expect(AreaDeCopia.motivoRecusa(null), isNull);
      expect(AreaDeCopia.motivoRecusa("R"), isNull);
      expect(AreaDeCopia.motivoRecusa("E"), isNotNull);
      expect(AreaDeCopia.motivoRecusa("L"), isNotNull);

      AreaDeCopia.copiar(_pacote("L", []));
      expect(AreaDeCopia.motivoRecusa("E"), isNull);
      expect(AreaDeCopia.motivoRecusa("L"), isNotNull);

      AreaDeCopia.copiar(_pacote("R", []));
      expect(AreaDeCopia.motivoRecusa("R"), isNotNull);
      expect(() => AreaDeCopia.colar(tipoDestino: "E"), throwsStateError);
    });

    test('sem cópia não há o que colar', () {
      expect(AreaDeCopia.temCopia, isFalse);
      expect(AreaDeCopia.motivoRecusa(null), isNotNull);
    });

    test('Proteção colada aplica o bônus em Resistência', () async {
      EfeitoCrescimento protecao = EfeitoCrescimento();
      await protecao.instanciarMetodo("Pele", "E030");
      protecao.setGrad(4);
      Map original = protecao.retornaObj();
      original["alvoAumento"] = protecao.returnBonusList();
      int antes = _bonusResistencia();

      AreaDeCopia.copiar(original);
      Map colado = AreaDeCopia.colar(idPacoteDestino: "A-arranjo", tipoDestino: "E");
      expect(colado["idArranjo"], "A-arranjo");
      expect(_bonusResistencia(), greaterThan(antes));
      expect((colado["alvoAumento"] as List).first["idOrigem"],
          colado["idCriacao"]);
    });
  });
}
