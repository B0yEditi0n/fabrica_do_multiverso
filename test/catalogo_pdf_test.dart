// Catálogos (modificadores e vantagens), iniciativa e PDF no formato do modelo.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/screens/components/printer.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/printer/poderes.dart';

Map catalogoMods() =>
    jsonDecode(File('assets/poderes/modificadores.json').readAsStringSync());

List catalogoVantagens() =>
    jsonDecode(File('assets/vantagens.json').readAsStringSync());

Map mod(String nome, [int grad = 1]) {
  for (List grupo in catalogoMods().values) {
    for (Map m in grupo) {
      if (m["nome"] == nome) return {...m, "grad": grad};
    }
  }
  throw StateError('Modificador "$nome" não está no catálogo');
}

Map vantagem(String id, {int grad = 1, String txt = ''}) {
  Map v = Map.from(catalogoVantagens().firstWhere((v) => v["id"] == id));
  v["graduacao"] = grad;
  v["txtDec"] = txt;
  return v;
}

Future<EfeitoDano> dano(int grad) async {
  EfeitoDano e = EfeitoDano();
  await e.instanciarMetodo("Raio", "E013");
  e.setGrad(grad);
  return e;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  group('Catálogo de modificadores', () {
    test('arquivo válido, sem id repetido e com os campos que o motor lê', () {
      List ids = [];
      catalogoMods().forEach((grupo, lista) {
        for (Map m in lista) {
          ids.add(m["m_id"]);
          expect(m["nome"], isA<String>(), reason: '${m["m_id"]}');
          expect(m["fixo"], isA<bool>(), reason: '${m["nome"]}');
          expect(m["custo_base"], isA<int>(), reason: '${m["nome"]}');
          expect(m["desc"], isA<bool>(), reason: '${m["nome"]}');
        }
      });
      expect(ids.toSet().length, ids.length);
    });

    test('genéricos que faltavam estão presentes', () {
      for (String nome in [
        'Área',
        'Afeta Outros',
        'Afeta Apenas Outros',
        'Alcance Estendido',
        'Incurável',
        'Resistência Alternativa',
        'Sonífero',
        'Baseado em Agarrar',
        'Dependente de Sentido',
        'Impreciso',
        'Resistível',
        'Personalizado (extra fixo)',
        'Personalizado (falha por graduação)',
      ]) {
        expect(mod(nome)["nome"], nome);
      }
    });

    test('extra por graduação, extra fixo e falha fixa entram no custo',
        () async {
      EfeitoDano e = await dano(10);
      expect(e.custearAlteracoes(), 10);

      e.addModificador(mod('Área')); // +1 por graduação
      expect(e.custearAlteracoes(), 20);

      e.addModificador(mod('Incurável')); // +1 fixo
      expect(e.custearAlteracoes(), 21);

      e.addModificador(mod('Impreciso', 2)); // -1 fixo por graduação
      expect(e.custearAlteracoes(), 19);

      e.addModificador(mod('Sonífero')); // +0
      expect(e.custearAlteracoes(), 19);
    });

    test('modificadores corrigidos: custo fixo conforme a regra', () async {
      EfeitoDano e = await dano(10);
      e.addModificador(mod('Inato')); // +1 fixo, não por graduação
      expect(e.custearAlteracoes(), 11);

      e.addModificador(mod('Afeta Corpóreo', 3)); // +1 fixo por graduação
      expect(e.custearAlteracoes(), 14);

      e.addModificador(mod('Dimensional', 2));
      expect(e.custearAlteracoes(), 16);

      e.addModificador(mod('Aumentar Massa', 2));
      expect(e.custearAlteracoes(), 18);

      expect(mod('Afeta Corpóreo')["limite"], -1);
      expect(mod('Dimensional')["limite"], 3);
      // Alcance é opção do efeito, não entra no catálogo
      expect(() => mod('Alcance'), throwsStateError);
    });

    test('grupos oferecidos dependem do tipo do efeito', () async {
      EfeitoDano ataque = await dano(5);
      expect(Efeito.gruposModificadores(ataque), contains('ofensivos'));
      expect(Efeito.gruposModificadores(ataque), contains('gerais'));

      Efeito voo = Efeito();
      await voo.instanciarMetodo("Voo", "E040");
      expect(Efeito.gruposModificadores(voo).contains('pessoais'),
          voo.returnObjDefault()["alcance"] == 0);
      expect(Efeito.gruposModificadores(voo), isNot(contains('ofensivos')));
    });

    test('limite de graduação do modificador', () {
      expect(Efeito.limiteModificador({"limite": 3}, 10), 3);
      expect(Efeito.limiteModificador({}, 10), 1);
      // -1: até a graduação do efeito
      expect(Efeito.limiteModificador({"limite": -1}, 7), 7);
      expect(Efeito.limiteModificador({"limite": -1}, 0), 1);
    });

    // Perigoso: +1 de margem de crítico por graduação, 1 PP cada, até 4
    // (wiki Poderes/Armas.md; teto 16-20 em Vantagens.md, Crítico Aprimorado)
    test('Perigoso: extra fixo de 1 PP por graduação, até 4, só para ofensivos',
        () async {
      EfeitoDano e = await dano(10);
      e.addModificador(mod('Perigoso', 3));
      expect(e.custearAlteracoes(), 13);

      expect(mod('Perigoso')["m_id"], 'E065');
      expect(Efeito.limiteModificador(mod('Perigoso'), 10), 4);
      expect((catalogoMods()["ofensivos"] as List)
          .any((m) => m["nome"] == 'Perigoso'), isTrue);
      for (String grupo in ['gerais', 'pessoais']) {
        expect((catalogoMods()[grupo] as List)
            .any((m) => m["nome"] == 'Perigoso'), isFalse);
      }
    });
  });

  group('Catálogo de vantagens', () {
    test('sem nome nem id repetido', () {
      List lista = catalogoVantagens();
      expect(lista.map((v) => v["id"]).toSet().length, lista.length);
      expect(lista.map((v) => v["nome"]).toSet().length, lista.length);
    });

    test('Velocidade do Pensamento existe', () {
      expect(vantagem("V090")["nome"], 'VELOCIDADE DO PENSAMENTO');
    });
  });

  group('Iniciativa', () {
    test('Agilidade + 4 por graduação de Iniciativa Aprimorada', () {
      personagem.habilidades.getItem("AGI")["valor"] = 3;
      expect(personagem.iniciativa(), 3);

      personagem.vantagens.listaVantagens.add(vantagem("V054", grad: 2));
      expect(personagem.iniciativa(), 11);
    });

    test('Velocidade do Pensamento troca Agilidade por Intelecto', () {
      personagem.habilidades.getItem("AGI")["valor"] = 1;
      personagem.habilidades.getItem("INT")["valor"] = 6;
      personagem.vantagens.listaVantagens.add(vantagem("V090"));
      expect(personagem.iniciativa(), 6);
    });
  });

  group('PDF no formato do modelo', () {
    test('linhas de NP e de totais', () {
      personagem.np = 11;
      personagem.habilidades.getItem("FOR")["valor"] = 5; // 10 pontos
      expect(Printer.linhaNp(), 'NP 11 (10 / 165 pontos)');
      expect(
          Printer.linhaTotais(),
          'Habilidades 10 + Defesas 0 + Vantagens 0 + Poderes 0 + '
          'Perícias 0 : 10 pontos');
    });

    test('nomes das vantagens saem como no modelo', () {
      expect(Printer.nomeProprio('ATAQUE À DISTÂNCIA'), 'Ataque à Distância');
      expect(Printer.nomeProprio('ESCONDER-SE A PLENA VISTA'),
          'Esconder-Se a Plena Vista');
      expect(Printer.textoVantagem(vantagem("V021")), 'Ataque Poderoso');
      expect(
          Printer.textoVantagem(
              vantagem("V022", grad: 2, txt: 'Camuflagem, a Distância')),
          'Ataque Preciso (Camuflagem, a Distância) [2]');
      expect(Printer.textoVantagem(vantagem("V077", grad: 4)),
          'Rolamento Defensivo [4]');
    });

    test('perícia: só as com graduação, no formato "Nome [grad] +total"', () {
      expect(Printer.periciasImpressas(), isEmpty);

      Map pericia = personagem.pericias.ListaPercias.first;
      pericia["valor"] = 4;
      List<Map> impressas = Printer.periciasImpressas();
      expect(impressas.length, 1);
      expect(Printer.textoPericia(impressas.first),
          matches(RegExp(r'^.+ \[4\] [+-]\d+$')));
    });

    test('rótulos e total dos pacotes', () async {
      expect(WidPdgPoderes.prefixoDoTipo("E"), 'EA: ');
      expect(WidPdgPoderes.prefixoDoTipo("D"), 'EAD: ');
      expect(WidPdgPoderes.prefixoDoTipo("R"), '');

      Map a = (await dano(10)).retornaObj();
      Map b = (await dano(4)).retornaObj();
      Map arranjo = {
        "nome": "Controle de Energia",
        "efeito": "Pacote",
        "tipo": "E",
        "removivel": 0,
        "class": "PacotesEfeitos",
        "efeitos": [a, b],
      };
      expect(WidPdgPoderes.totalPacote(arranjo), 'Total: 11 pontos');

      Map equipamento = {...arranjo, "tipo": "R", "efeito": "Equipamentos"};
      expect(WidPdgPoderes.totalPacote(equipamento),
          'Total: 14 pontos de equipamento');
    });

    test('gera o documento de uma ficha completa sem erro', () async {
      personagem.nomePersonagem = 'Prodígio';
      personagem.np = 11;
      personagem.habilidades.getItem("FOR")["valor"] = 11;
      personagem.pericias.ListaPercias.first["valor"] = 6;
      personagem.vantagens.listaVantagens
        ..add(vantagem("V021"))
        ..add(vantagem("V077", grad: 4));
      personagem.complicacoes
          .add({"titulo": "Motivação", "desc": "Ser o melhor."});

      EfeitoDano raio = await dano(10);
      raio.addModificador(mod('Área')..["text_desc"] = 'Explosão');
      Map a = raio.retornaObj();
      Map b = (await dano(4)).retornaObj();
      EfeitoDano perigoso = await dano(8);
      perigoso.addModificador(mod('Perigoso', 2));
      personagem.poderes.poderesLista
        ..add(perigoso.retornaObj())
        ..add({
          "nome": "Controle de Energia",
          "efeito": "Pacote",
          "tipo": "E",
          "removivel": 0,
          "class": "PacotesEfeitos",
          "efeitos": [a, b],
        })
        ..add({
          "nome": "Cinto",
          "efeito": "Equipamentos",
          "tipo": "R",
          "removivel": 0,
          "class": "PacotesEfeitos",
          "efeitos": [(await dano(3)).retornaObj()],
        });

      Uint8List bytes = await (await Printer.montar(Uint8List(0))).save();
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });
  });
}
