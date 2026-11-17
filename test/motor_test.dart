// Testes de caracterização do motor de regras (lib/script).
// Fixam o comportamento atual para que as próximas etapas não o quebrem.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/defesas/lib_defesas.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';

Map _mod(String id, int custo, {bool fixo = false, int grad = 1}) =>
    {"m_id": id, "nome": id, "fixo": fixo, "custo_base": custo, "grad": grad};

void _setHabilidade(String id, int valor) {
  personagem.habilidades.getItem(id)["valor"] = valor;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  group('Habilidades', () {
    test('custam 2 pontos por graduação', () {
      _setHabilidade("FOR", 3);
      _setHabilidade("AGI", 2);
      expect(personagem.habilidades.calculaTotal(), 10);
    });

    test('habilidade ausente devolve 10 pontos', () {
      personagem.habilidades.getItem("INT")["ausente"] = true;
      expect(personagem.habilidades.calculaTotal(), -10);
    });

    test('bônus de poderes entram no total mas não no custo', () {
      Map forca = personagem.habilidades.getItem("FOR");
      forca["valor"] = 2;
      forca["bonus"].add({"idOrigem": "P1", "valor": 4});
      Habilidade hab = Habilidade().reInit(forca);
      expect(hab.valorTotal(), 6);
      expect(hab.custoTotal(), 4);
    });
  });

  group('Defesas', () {
    test('custam 1 ponto por graduação e somam a habilidade', () {
      _setHabilidade("AGI", 3);
      Map esquiva = personagem.defesas.returnId("D001");
      esquiva["valor"] = 4;
      expect(personagem.defesas.calculaTotal(), 4);
      expect(Defesa().init(esquiva).bonusTotal(), 7);
    });

    test('Resistência soma Vigor e Rolamento Defensivo', () {
      _setHabilidade("VIG", 5);
      personagem.vantagens.listaVantagens.add({
        "id": "V077",
        "nome": "ROLAMENTO DEFENSIVO",
        "graduado": true,
        "desc": false,
        "graduacao": 2,
      });
      Resistencia res = Resistencia();
      res.init(personagem.defesas.returnId("D004"));
      expect(res.bonusTotal(), 7);
    });
  });

  group('Perícias', () {
    test('duas graduações custam 1 ponto, arredondando para cima', () {
      personagem.pericias.ListaPercias[0]["valor"] = 3;
      expect(personagem.pericias.calculaTotal(), 2);
      personagem.pericias.ListaPercias[1]["valor"] = 2;
      expect(personagem.pericias.calculaTotal(), 3);
    });

    test('total soma a habilidade base', () {
      _setHabilidade("AGI", 4);
      Map acrobacias = personagem.pericias.ListaPercias
          .firstWhere((p) => p["id"] == "P001");
      acrobacias["valor"] = 6;
      Pericia pericia = Pericia();
      pericia.init(acrobacias);
      expect(pericia.bonusTotal(), 10);
    });
  });

  group('Vantagens', () {
    test('custo é a graduação comprada; bônus de poder não custa', () {
      personagem.vantagens.listaVantagens.add({
        "id": "V013",
        "nome": "ATAQUE CORPO-A-CORPO",
        "graduado": true,
        "desc": false,
        "graduacao": 3,
        "bonus": [
          {"idOrigem": "P1", "valor": 2}
        ],
      });
      expect(personagem.vantagens.cutoTotal(), 3);
      Vantagem v = Vantagem();
      v.init(personagem.vantagens.listaVantagens.first);
      expect(v.returnTotalGrad(), 5);
    });

    test('addByPower falso continua falso depois de recarregar', () {
      Vantagem v = Vantagem();
      v.init({
        "id": "V001",
        "nome": "X",
        "graduado": false,
        "desc": false,
        "addByPower": false,
      });
      expect(v.returnObj()["addByPower"], false);
    });
  });

  group('Custo de efeito', () {
    Future<Efeito> dano(int grad) async {
      EfeitoDano e = EfeitoDano();
      await e.instanciarMetodo("Teste", "E013");
      e.setGrad(grad);
      return e;
    }

    test('sem modificadores: custo-base × graduação', () async {
      expect((await dano(10)).custearAlteracoes(), 10);
      expect((await dano(1)).custearAlteracoes(), 1);
    });

    test('extra por graduação', () async {
      Efeito e = await dano(10);
      e.addModificador(_mod("X1", 1));
      expect(e.custearAlteracoes(), 20);
    });

    test('alcance à distância custa +1 por graduação', () async {
      Efeito e = await dano(10);
      e.alteraAlcance(2);
      expect(e.custearAlteracoes(), 20);
    });

    test('modificador fixo soma depois da multiplicação', () async {
      Efeito e = await dano(10);
      e.addModificador(_mod("X1", 1, fixo: true, grad: 2));
      expect(e.custearAlteracoes(), 12);
    });

    test('extras e falhas simultâneos', () async {
      Efeito e = await dano(10);
      e.addModificador(_mod("X1", 1));
      e.addModificador(_mod("F1", -1));
      expect(e.custearAlteracoes(), 10);
    });

    test('custo fracionário: 1 ponto para 2 e para 3 graduações', () async {
      Efeito e = await dano(10);
      e.addModificador(_mod("F1", -1));
      expect(e.custearAlteracoes(), 5);
      e.addModificador(_mod("F2", -1));
      expect(e.custearAlteracoes(), 4);
    });

    test('custo nunca fica abaixo de 1', () async {
      Efeito e = await dano(1);
      e.addModificador(_mod("F1", -1, fixo: true, grad: 3));
      expect(e.custearAlteracoes(), 1);
    });

    test('bônus de acerto custa 1 ponto a cada +2', () async {
      EfeitoDano e = EfeitoDano();
      await e.instanciarMetodo("Teste", "E013");
      e.setGrad(10);
      e.addBonus(4);
      expect(e.custearAlteracoes(), 12);
    });

    test('efeito de custo-base 2 (Voo)', () async {
      Efeito e = Efeito();
      await e.instanciarMetodo("Teste", "E040");
      e.setGrad(5);
      expect(e.custearAlteracoes(), 10);
    });
  });

  group('Validação de NP', () {
    test('perícia acima de NP + 10 gera erro', () {
      personagem.np = 10;
      personagem.pericias.ListaPercias[0]["valor"] = 21;
      List erros = ValidaNpPersonagem().validacaoGeral();
      expect(erros.where((e) => e["tipo"] == "P").length, 1);
    });

    test('Fortitude + Vontade acima de 2 × NP gera erro', () {
      personagem.np = 10;
      personagem.defesas.returnId("D003")["valor"] = 11;
      personagem.defesas.returnId("D005")["valor"] = 10;
      List erros = ValidaNpPersonagem().validacaoGeral();
      expect(erros.where((e) => e["tipo"] == "D").length, 1);
    });

    test('acompanha mudanças de NP feitas depois da criação', () {
      ValidaNpPersonagem validador = ValidaNpPersonagem();
      personagem.np = 10;
      personagem.pericias.ListaPercias[0]["valor"] = 21;
      expect(validador.validacaoGeral(), isNotEmpty);
      personagem.np = 11;
      expect(validador.validacaoGeral(), isEmpty);
    });
  });

  group('Salvar e carregar', () {
    test('texto com aspas sobrevive ao JSON', () async {
      personagem.nomePersonagem = 'O "Grande" Herói';
      personagem.complicacoes.add({"titulo": 'Diz "não"', "desc": 'a\\b'});
      String txt = json.encode(personagem.returnObjJson());

      Ficha outra = Ficha();
      await outra.reInit(jsonDecode(txt));
      expect(outra.nomePersonagem, 'O "Grande" Herói');
      expect(outra.complicacoes.first["titulo"], 'Diz "não"');
    });

    test('especialidade mantém classe e escopo ao recarregar', () async {
      PericiaAdiciona esp = PericiaAdiciona();
      esp.init({
        "id": "PA03",
        "nome": "Especialidade",
        "idHab": "INT",
        "treinado": true,
        "valor": 4,
        "escopo": "Magia",
      });
      personagem.pericias.ListaPercias.add(esp.returnObj());
      String txt = json.encode(personagem.returnObjJson());

      Ficha outra = Ficha();
      await outra.reInit(jsonDecode(txt));
      Map recarregada =
          outra.pericias.ListaPercias.firstWhere((p) => p["id"] == "PA03");
      expect(recarregada["classe"], "PericiaAdiciona");
      expect(recarregada["escopo"], "Magia");
      expect(recarregada["valor"], 4);
    });

    test('remover bônus não falha em itens sem lista de bônus', () {
      personagem.pericias.ListaPercias.add({
        "id": "PA03",
        "nome": "Especialidade",
        "idHab": "INT",
        "treinado": true,
        "valor": 1,
        "escopo": "Antiga",
        "classe": "PericiaAdiciona",
      });
      personagem.vantagens.listaVantagens.add({
        "id": "V001",
        "nome": "X",
        "graduado": false,
        "desc": false,
        "bonus": [],
      });
      expect(() => personagem.validador.removeBonusId("P-inexistente"),
          returnsNormally);
    });
  });
}
