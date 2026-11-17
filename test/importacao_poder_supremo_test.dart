// Importação de portfólios do Poder Supremo
// (React-Mutants-Masterminds-Character-Sheet) para o formato da Fábrica.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/importacao/importa_poder_supremo.dart';

Map _mod(int id, String nome, int rank,
        {bool extra = true, bool flat = false, String trait = ""}) =>
    {
      "id": id,
      "name": nome,
      "description": "",
      "rank": rank,
      "extra": extra,
      "flat": flat,
      "ranked": false,
      "maxRank": 1,
      "hasTrait": trait.isNotEmpty,
      "parcial": 0,
      "traitText": trait,
      "senseText": "",
      "instanceID": -1,
    };

Map _poder(int id, String nome, int effectID, int rank,
        {int baseCost = 1,
        int action = 1,
        int range = 1,
        int duration = 1,
        List extras = const [],
        List flaws = const [],
        List flats = const [],
        List alternates = const [],
        int removable = 0,
        Map extra = const {}}) =>
    {
      "id": id,
      "name": nome,
      "description": "",
      "rank": rank,
      "effectID": effectID,
      "baseCost": baseCost,
      "typeID": 1,
      "actionID": action,
      "rangeID": range,
      "durationID": duration,
      "maxRank": -1,
      "resistedBy": "Resistência",
      "affectedTrait": "Nenhum",
      "extras": extras,
      "flaws": flaws,
      "flats": flats,
      "alternateEffects": alternates,
      "extraEfforts": [],
      "enhancedAdvantages": [],
      "isAlternateEffect": false,
      "isDynamicEffect": false,
      "removable": removable,
      "isActive": true,
      "descriptors": [],
      ...extra,
    };

Map _portfolio() => {
      "formatVersion": 3,
      "id": 1,
      "portName": "Teste",
      "ruleset": "mm3",
      "characters": [
        {
          "id": 10,
          "name": "Capitão Importado",
          "powerLevel": 8,
          "pointsPerLevel": 15,
          "abilities": [
            {"id": 1001, "name": "Força", "abrev": "FOR", "rank": 4, "isNull": false},
            {"id": 1003, "name": "Agilidade", "abrev": "AGI", "rank": 2, "isNull": false},
            {"id": 1006, "name": "Intelecto", "abrev": "INT", "rank": 0, "isNull": true},
          ],
          "defenses": [
            {"id": 2001, "name": "Esquiva", "rank": 5},
            {"id": 2004, "name": "Fortitude", "rank": 3},
          ],
          "skills": [
            {"id": 3001, "name": "Acrobacias", "rank": 6},
            {"id": 3008, "name": "Percepção", "rank": 4},
          ],
          "extraSkills": [
            {
              "id": 31001,
              "name": "Especialidade",
              "rank": 4,
              "trait": "Ciências",
              "abilityID": 1006
            },
            {
              "id": 31002,
              "name": "Combate à Distância",
              "rank": 6,
              "isRanged": true,
              "chosenAttacks": {"id": 31002, "descriptor": "Rajadas", "list": [101]}
            },
          ],
          "advantages": [
            {"id": 4001, "name": "Ação em Movimento", "rank": 1, "traitText": ""},
            {"id": 4041, "name": "Equipamento", "rank": 2, "traitText": "", "ranked": true},
            {"id": 4052, "name": "Idiomas", "rank": 1, "traitText": "", "ranked": true},
            {"id": 4999, "name": "Vantagem Inventada", "rank": 1, "traitText": "x"},
          ],
          "languages": [
            {"id": 1, "text": "Português"},
            {"id": 2, "text": "Inglês"}
          ],
          "powers": [
            // Dano 8 à distância (Distância Aumentada 1), Área 1 e Acurado 2
            _poder(101, "Rajada", 5013, 8,
                range: 2,
                extras: [
                  _mod(10017, "Distância Aumentada", 1),
                  _mod(10010, "Área", 1, trait: "Explosão")
                ],
                flats: [_mod(10001, "Acurado", 2, flat: true)]),
            // Proteção 4, Sustentado
            _poder(102, "Campo de Força", 5030, 4,
                action: 3,
                range: 0,
                duration: 3,
                baseCost: 1,
                extras: [_mod(10034, "Sustentado", 0)]),
            // Voo 6 com alternativo Teleporte 3 (removível)
            _poder(103, "Mobilidade", 5040, 6,
                baseCost: 2,
                action: 3,
                range: 0,
                duration: 3,
                removable: 1,
                alternates: [
                  _poder(104, "Salto Dimensional", 5036, 3,
                      baseCost: 2, action: 2, range: 0, duration: 1)
                ]),
            // Imunidade com opções
            _poder(105, "Corpo Resistente", 5020, 3,
                action: 0, range: 0, duration: 5, extra: {
              "powerOptions": [
                {"id": 1, "name": "Doença", "rank": 1, "traitText": ""},
                {"id": 2, "name": "Veneno", "rank": 1, "traitText": ""},
                {"id": 3, "name": "Frio", "rank": 1, "traitText": ""},
              ]
            }),
            // Característica Aumentada: Força +2 e Ataque Acurado
            _poder(106, "Super Força", 5006, 0,
                baseCost: 1, action: 3, range: 0, duration: 3, extra: {
              "enhancedTraits": [
                {"id": 1, "traitName": "Força", "affectedTraitID": 1001, "rank": 2}
              ],
              "enhancedAdvantages": [
                {"id": 4012, "name": "Ataque Acurado", "rank": 1, "traitText": ""}
              ],
            }),
            // Efeito sem equivalente (Feitos de Força)
            _poder(107, "Proeza", 5047, 2,
                baseCost: 0, flats: [_mod(10029, "Personalizado", 3, flat: true)]),
            // Efeitos ligados
            _poder(108, "Toque Gélido", 5045, 0, extra: {
              "powers": [
                _poder(109, "Gelo", 5013, 3),
                _poder(110, "Congelar", 5001, 3, extra: {
                  "conditions": {
                    "firstDegree": "Prejudicado",
                    "secondDegree": "Imóvel",
                    "thirdDegree": "Paralisado"
                  }
                }),
              ]
            }),
          ],
          "equipment": [
            {"id": 7001, "name": "Celular", "cost": 1, "description": ""},
          ],
          "complications": [
            {"id": 1, "title": "Motivação", "description": "Justiça"}
          ],
          "gallery": [""],
        },
        {"id": 11, "name": "Parceiro", "powerLevel": 6, "powers": []},
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogosFabrica catalogos;

  setUpAll(() async {
    catalogos = await CatalogosFabrica.carregar();
  });

  Future<List<String>> importa(Map portfolio, [int indice = 0]) async {
    ResultadoImportacao r =
        PoderSupremo.converterComCatalogos(portfolio, indice, catalogos);
    // Ida e volta por JSON, como acontece com o arquivo salvo
    Map ficha = jsonDecode(json.encode(r.ficha));
    personagem = Ficha();
    await personagem.init();
    await personagem.reInit(ficha);
    PoderSupremo.finalizar();
    return r.avisos;
  }

  Map poder(String nome) => personagem.poderes.poderesLista
      .firstWhere((p) => p["nome"] == nome);

  test('reconhece portfólio e recusa M&M4', () {
    expect(PoderSupremo.reconhece(_portfolio()), true);
    expect(PoderSupremo.reconhece(personagem.returnObjJson()), false);
    expect(PoderSupremo.nomesPersonagens(_portfolio()),
        ["Capitão Importado", "Parceiro"]);
    expect(PoderSupremo.motivoRecusa({"ruleset": "mm4", "characters": [{}]}),
        isNotNull);
    expect(PoderSupremo.motivoRecusa(_portfolio()), isNull);
  });

  test('características básicas', () async {
    List<String> avisos = await importa(_portfolio());

    expect(personagem.nomePersonagem, "Capitão Importado");
    expect(personagem.np, 8);
    // Força 4 + 2 da Característica Aumentada
    expect(personagem.habilidades.getItem("FOR")["valor"], 4);
    expect(personagem.habilidades.getItem("INT")["ausente"], true);
    expect(personagem.defesas.returnId("D001")["valor"], 5);
    expect(personagem.defesas.returnId("D003")["valor"], 3);

    List pericias = personagem.pericias.ListaPercias;
    expect(pericias.firstWhere((p) => p["id"] == "P001")["valor"], 6);
    Map especialidade = pericias.firstWhere((p) => p["id"] == "PA03");
    expect(especialidade["escopo"], "Ciências");
    expect(especialidade["valor"], 4);
    Map combate = pericias.firstWhere((p) => p["id"] == "PA02");
    expect(combate["bonusPoderes"], [poder("Rajada")["idCriacao"]]);

    List vantagens = personagem.vantagens.listaVantagens;
    expect(vantagens.any((v) => v["id"] == "V001"), true);
    expect(vantagens.firstWhere((v) => v["id"] == "V041")["graduacao"], 2);
    expect(vantagens.firstWhere((v) => v["id"] == "V052")["txtDec"],
        "Português, Inglês");
    expect(vantagens.any((v) => v["nome"] == "VANTAGEM INVENTADA"), true);

    expect(personagem.complicacoes, [
      {"titulo": "Motivação", "desc": "Justiça"}
    ]);
    expect(avisos.any((a) => a.contains("2 personagens")), true);
    expect(avisos.any((a) => a.contains("Vantagem Inventada")), true);
  });

  test('poderes e custos', () async {
    await importa(_portfolio());

    // Dano 8, distância (+1), Área (+1), Acurado 2 (+2 fixo) = 8*3 + 2 = 26
    Map rajada = poder("Rajada");
    expect(rajada["e_id"], "E013");
    expect(rajada["alcance"], 2);
    expect(rajada["acerto"], 4);
    expect(rajada["custo"], 26);
    // Bônus da perícia de combate aplicado ao poder
    expect(rajada["bonus"].length, 1);

    // Proteção 4 soma em Resistência
    expect(poder("Campo de Força")["custo"], 4);
    Map resistencia = personagem.defesas.returnId("D004");
    expect(resistencia["bonus"].any((b) => b["valor"] == 4), true);

    // Voo 6 (12) com alternativo (+1) e removível (-1 a cada 5): 13 - 2 = 11
    Map mobilidade = poder("Mobilidade");
    expect(mobilidade["tipo"], "R");
    expect(mobilidade["removivel"], 1);
    expect(mobilidade["efeitos"].first["tipo"], "E");
    expect(mobilidade["custo"], 11);

    // Imunidade 3
    Map imunidade = poder("Corpo Resistente");
    expect(imunidade["graduacao"], 3);
    expect(imunidade["opt"].length, 3);
    expect(imunidade["custo"], 3);

    // Força +2 (4 PP) e Ataque Acurado (1 PP), ligados
    Map superForca = poder("Super Força");
    expect(superForca["tipo"], "L");
    expect(superForca["custo"], 5);
    Map forca = personagem.habilidades.getItem("FOR");
    expect(forca["bonus"].any((b) => b["valor"] == 2), true);
    expect(personagem.vantagens.listaVantagens
        .any((v) => v["id"] == "V012" && v["addByPower"] == true), true);

    // Sem equivalente: Característica com o custo estimado (2 grad. a custo 0 = 1, + 3 fixos)
    Map proeza = poder("Proeza");
    expect(proeza["e_id"], "E005");
    expect(proeza["custo"], 4);

    // Efeitos ligados: Dano 3 + Aflição 3
    Map ligado = poder("Toque Gélido");
    expect(ligado["tipo"], "L");
    expect(ligado["custo"], 6);
    expect(ligado["efeitos"][1]["condicoes"],
        ["Prejudicado", "Imóvel", "Paralisado"]);

    // Equipamento vai para o pacote de equipamentos
    Map equipamento = poder("Equipamentos");
    expect(equipamento["removivel"], 4);
    expect(personagem.resumoPontos()["equipamentoUsado"], 1);

    // A ficha inteira continua calculável e validável
    expect(personagem.resumoPontos()["total"], greaterThan(0));
    expect(() => ValidaNpPersonagem().validacaoGeral(), returnsNormally);
  });

  test('importa o segundo personagem do portfólio', () async {
    await importa(_portfolio(), 1);
    expect(personagem.nomePersonagem, "Parceiro");
    expect(personagem.np, 6);
  });

  test('ficha Lenan: custos iguais ao app React', () async {
    Map portfolio = jsonDecode(
        File('test/fixtures/poder_supremo_lenan.json').readAsStringSync());
    await importa(portfolio);

    // Imunidade: no React o "rank" vem 0 e a graduação está na opção
    Map imunidade = poder("nao sufoca");
    expect(imunidade["graduacao"], 2);
    expect(imunidade["custo"], 2);

    // Arranjo dinâmico com só "mundo liquido" dinâmico:
    // 9 + 1 (base dinâmico) + 1 (Aquaporte comum) = 11
    Map movimento = poder("movimento");
    Map mundoLiquido = (movimento["efeitos"] as List)
        .firstWhere((e) => e["nome"] == "mundo liquido");
    expect(mundoLiquido["graduacao"], 3);
    expect(mundoLiquido["custo"], 9);
    expect(movimento["custo"], 11);

    expect(poder("ofensivos")["custo"], 21);
    expect(poder("Defensivos")["custo"], 6);
    expect(personagem.resumoPontos()["poderes"], 40);

    // Todos os efeitos são ativos: Proteção alternativa soma em Resistência
    expect(personagem.defesas.returnId("D004")["bonus"], isNotEmpty);
  });

  for (String arquivo in [
    'poder_supremo_lenan.json',
    'poder_supremo_sentinela.json',
    'poder_supremo_legado.json',
  ]) {
    test('arquivo de exemplo do Poder Supremo: $arquivo', () async {
      Map portfolio =
          jsonDecode(File('test/fixtures/$arquivo').readAsStringSync());
      await importa(portfolio);
      expect(personagem.nomePersonagem, isNotEmpty);
      expect(personagem.poderes.poderesLista, isNotEmpty);
      expect(() => personagem.resumoPontos(), returnsNormally);
      expect(() => ValidaNpPersonagem().validacaoGeral(), returnsNormally);
    });
  }
}
