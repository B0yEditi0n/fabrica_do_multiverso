import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

/*
  Importação de fichas do "Poder Supremo"
  (React-Mutants-Masterminds-Character-Sheet).

  O Poder Supremo salva um PORTFÓLIO em JSON:
    { formatVersion, id, portName, ruleset?, characters: [ ... ] }
  com IDs numéricos (habilidades 1001+, defesas 2001+, perícias 3001+,
  efeitos 5001+, modificadores 10001+).

  Esta classe converte UM personagem do portfólio para o mesmo Map que
  Ficha.returnObjJson() produz, para ser carregado com Ficha.reInit.
  Só M&M 3ª edição é aceito (é a regra da Fábrica).

  Fluxo:
    1. PoderSupremo.reconhece(json)            - é um portfólio?
    2. PoderSupremo.nomesPersonagens(json)     - para escolher o personagem
    3. await PoderSupremo.converter(json, i)   - Map da ficha + avisos
    4. personagem.reInit(resultado.ficha)
    5. PoderSupremo.finalizar()                - aplica bônus de poderes
                                                 e recalcula custos

  O que não tem equivalente direto vira algo que preserve os pontos
  (modificador "Personalizado", efeito "Característica") e gera um aviso.
*/

class ResultadoImportacao {
  final Map ficha;
  final List<String> avisos;
  final Uint8List imagem;

  ResultadoImportacao(this.ficha, this.avisos, this.imagem);
}

class CatalogosFabrica {
  final List efeitos;
  final Map modificadores;
  final List vantagens;
  final List pericias;
  final List habilidades;
  final List defesas;

  CatalogosFabrica({
    required this.efeitos,
    required this.modificadores,
    required this.vantagens,
    required this.pericias,
    required this.habilidades,
    required this.defesas,
  });

  static Future<CatalogosFabrica> carregar() async {
    Future<dynamic> ler(String caminho) async =>
        jsonDecode(await rootBundle.loadString(caminho));

    return CatalogosFabrica(
      efeitos: await ler('assets/poderes/efeitos.json'),
      modificadores: await ler('assets/poderes/modificadores.json'),
      vantagens: await ler('assets/vantagens.json'),
      pericias: await ler('assets/pericias.json'),
      habilidades: await ler('assets/habilidades.json'),
      defesas: await ler('assets/defesas.json'),
    );
  }
}

class PoderSupremo {
  // ---------------------------------------------------------------------
  // Tabelas de equivalência (IDs do Poder Supremo -> Fábrica)
  // ---------------------------------------------------------------------

  static const Map<int, String> _habilidades = {
    1001: "FOR",
    1002: "VIG",
    1003: "AGI",
    1004: "DES",
    1005: "LUT",
    1006: "INT",
    1007: "PRO",
    1008: "PRE",
  };

  // Atenção: no Poder Supremo Resistência é 2003 e Fortitude 2004
  static const Map<int, String> _defesas = {
    2001: "D001", // Esquiva
    2002: "D002", // Aparar
    2003: "D004", // Resistência
    2004: "D003", // Fortitude
    2005: "D005", // Vontade
  };

  static const Map<int, String> _pericias = {
    3001: "P001",
    3002: "P002",
    3003: "P003",
    3004: "P004",
    3005: "P005",
    3006: "P006",
    3007: "P007",
    3008: "P008",
    3009: "P009",
    3010: "P010",
    3011: "P011",
    3012: "P012",
    3013: "P013",
  };

  /// Efeitos simples: effectID -> e_id do efeitos.json
  static const Map<int, String> _efeitos = {
    5001: "E001", // Aflição
    5002: "E002", // Alongamento
    5003: "E003", // Ambiente
    5004: "E004", // Camuflagem
    5005: "E005", // Característica
    5007: "E007", // Compreender
    5008: "E008", // Comunicação
    5009: "E009", // Controle de Sorte
    5010: "PB05", // Crescimento
    5011: "E011", // Criar
    5012: "E012", // Cura
    5013: "E013", // Dano
    5014: "E014", // Deflexão
    5015: "PB06", // Encolhimento
    5016: "E016", // Enfraquecer
    5017: "E017", // Escavação
    5018: "E018", // Ilusão
    5019: "E019", // Imortalidade
    5020: "E020", // Imunidade
    5021: "E021", // Intangibilidade
    5022: "E022", // Invocar
    5023: "E023", // Leitura Mental
    5024: "E024", // Membros Extras
    5025: "E025", // Morfar
    5026: "E026", // Mover Objetos
    5027: "E027", // Movimento
    5028: "E028", // Natação
    5029: "E029", // Nulificar
    5030: "E030", // Proteção
    5031: "E031", // Rapidez
    5032: "E032", // Regeneração
    5033: "E033", // Salto
    5034: "E034", // Sentido Remoto
    5035: "E035", // Sentidos
    5036: "E036", // Teleporte
    5037: "E037", // Transformar
    5038: "E038", // Variável
    5039: "E039", // Velocidade
    5040: "E040", // Voo
    5057: "E035", // Sentidos (formato novo)
  };

  // Contêineres do Poder Supremo
  static const int _arranjo = 5042;
  static const int _dispositivo = 5043;
  static const int _efeitosLigados = 5045;
  static const int _multiplosEfeitos = 5046;
  static const int _formaAlternativa = 5048;
  static const List<int> _multiplosPoderes = [
    _dispositivo,
    _efeitosLigados,
    _multiplosEfeitos,
    _formaAlternativa,
  ];

  // Características aumentadas
  static const int _caracteristicaAumentada = 5006;
  static const int _forcaAumentada = 5051;
  static const int _vantagemAumentada = 5053;
  static const int _periciaAumentada = 5054;

  // Modificadores tratados à parte (não viram item de modificador)
  static const int _modAcurado = 10001;
  static const int _modAfetaApenasOutros = 10006;
  static const int _modAfetaOutros = 10007;
  static const int _modAtaque = 10011;
  static const int _modDistanciaAumentada = 10017;
  static const int _modDuracaoAumentada = 10018;
  static const int _modSustentado = 10034;
  static const int _modReacao = 10088;
  static const int _modAcaoAumentada = 11000;
  static const int _modDistanciaReduzida = 11007;
  static const int _modImpreciso = 11013;
  static const int _modPermanente = 11018;
  static const int _modRemovivel = 11021;
  static const int _modConcentracao = 11052;
  static const int _modAcao = 501201;
  static const int _modAcaoVariavel = 503801;

  static const List<int> _modsDeAlcance = [
    _modDistanciaAumentada,
    _modDistanciaReduzida,
  ];
  static const List<int> _modsDeDuracao = [
    _modDuracaoAumentada,
    _modSustentado,
    _modConcentracao,
    _modPermanente,
  ];
  static const List<int> _modsDeAcao = [
    _modAcaoAumentada,
    _modAcao,
    _modAcaoVariavel,
    _modReacao,
  ];

  /// Nomes do Poder Supremo que diferem do nome usado na Fábrica
  static const Map<String, String> _apelidosModificador = {
    "engatilhado (variavel)": "gatilho variavel",
    "distrativo": "distracao",
    "inconstante (chance)": "inconstante",
    "afeta apenas objetos": "afeta objetos apenas",
    "area (linha)": "area",
    "massa aumentada": "aumentar massa", // Teleporte
  };

  /// Sentidos (formato novo, 5057): o arquivo guarda só o ID da opção
  static const Map<int, String> _opcoesSentidos = {
    503501: "Acurado",
    503502: "Acurado (Tipo)",
    503503: "À Distância",
    503504: "Aguçado",
    503505: "Aguçado (Tipo)",
    503506: "Analítico",
    503507: "Analítico (Tipo)",
    503508: "Contra-ataca Camuflagem",
    503532: "Contra-ataca Todas Camuflagens",
    503509: "Contra-ataca Ilusão",
    503510: "Detecção",
    503511: "Elo de Comunicação",
    503512: "Estendido",
    503513: "Infravisão",
    503514: "Penetra Cobertura",
    503515: "Percepção",
    503516: "Póscognição",
    503517: "Precognição",
    503518: "Rádio",
    503519: "Radial",
    503520: "Radial (Tipo)",
    503521: "Rápido",
    503522: "Rastrear",
    503523: "Sentido de Direção",
    503524: "Sentido de Distância",
    503525: "Sentido de Perigo",
    503526: "Sentido de Tempo",
    503527: "Ultra-Audição",
    503528: "Ultravisão",
    503529: "Visão Microscópica",
    503530: "Visão na Penumbra",
    503531: "Visão no Escuro",
  };

  // ---------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------

  /// O JSON é um portfólio do Poder Supremo?
  static bool reconhece(dynamic json) =>
      json is Map && json["characters"] is List && json["pesonagem"] == null;

  static List<String> nomesPersonagens(Map portfolio) {
    List personagens = portfolio["characters"] ?? [];
    return [
      for (int i = 0; i < personagens.length; i++)
        _texto(personagens[i]["name"]).isNotEmpty
            ? _texto(personagens[i]["name"])
            : "Personagem ${i + 1}"
    ];
  }

  /// Motivo para recusar o portfólio (null = pode importar)
  static String? motivoRecusa(Map portfolio) {
    var ruleset = portfolio["ruleset"];
    if ((ruleset != null && ruleset != "mm3") ||
        (portfolio["formatVersion"] is num && portfolio["formatVersion"] > 3)) {
      return "A ficha é de Mutantes & Malfeitores 4ª edição; "
          "a Fábrica do Multiverso só trabalha com a 3ª edição.";
    }
    if ((portfolio["characters"] as List?)?.isEmpty ?? true) {
      return "O portfólio não tem personagens.";
    }
    return null;
  }

  static Future<ResultadoImportacao> converter(Map portfolio,
      [int indice = 0]) async {
    CatalogosFabrica catalogos = await CatalogosFabrica.carregar();
    return PoderSupremo(catalogos)._converter(portfolio, indice);
  }

  /// Versão síncrona, com os catálogos já lidos (usada nos testes)
  static ResultadoImportacao converterComCatalogos(
          Map portfolio, int indice, CatalogosFabrica catalogos) =>
      PoderSupremo(catalogos)._converter(portfolio, indice);

  static void finalizar() {
    /*
      Depois de personagem.reInit(ficha importada):
        - reflete os bônus de Característica Aumentada, Crescimento e
          Proteção nas habilidades, defesas, perícias e vantagens;
        - aplica as perícias de combate aos poderes escolhidos;
        - recalcula o campo "custo" gravado em cada poder.
      Usa o personagem global (é o que o restante da Fábrica usa).
    */
    _aplicaBonus(personagem.poderes.poderesLista, true);
    personagem.validador.updatePericiaBonus();
    _recalculaCustos(personagem.poderes.poderesLista);
  }

  // ---------------------------------------------------------------------
  // Conversão
  // ---------------------------------------------------------------------

  final CatalogosFabrica cat;
  final List<String> _avisos = [];
  final Uuid _uuid = const Uuid();

  /// ID do poder no Poder Supremo -> idCriacao na Fábrica
  final Map<String, String> _idsPoderes = {};
  int _forca = 0;
  int _seqModificador = 0;

  PoderSupremo(this.cat);

  ResultadoImportacao _converter(Map portfolio, int indice) {
    String? recusa = motivoRecusa(portfolio);
    if (recusa != null) throw FormatException(recusa);

    List personagens = portfolio["characters"];
    if (indice < 0 || indice >= personagens.length) indice = 0;
    Map c = personagens[indice];

    if (personagens.length > 1) {
      _avisos.add(
          "O portfólio tem ${personagens.length} personagens; foi importado \"${nomesPersonagens(portfolio)[indice]}\".");
    }
    if (c["pointsPerLevel"] is num && c["pointsPerLevel"] != Ficha.pontosPorNp) {
      _avisos.add(
          "A ficha usa ${c["pointsPerLevel"]} pontos por NP; a Fábrica usa ${Ficha.pontosPorNp}.");
    }

    List habilidades = _converteHabilidades(c["abilities"]);
    _forca = habilidades.firstWhere((h) => h["id"] == "FOR")["valor"];

    List poderes = [];
    for (var p in _lista(c["powers"])) {
      poderes.addAll(_convertePoder(p));
    }
    Map? equipamento = _converteEquipamentos(_lista(c["equipment"]));
    if (equipamento != null) poderes.add(equipamento);

    Map ficha = {
      "pesonagem": {
        "nome": _texto(c["name"]),
        "np": _inteiro(c["powerLevel"], 10),
      },
      "habilidades": habilidades,
      "defesas": _converteDefesas(c["defenses"]),
      "poderes": poderes,
      "pericias": _convertePericias(c["skills"], c["extraSkills"]),
      "vantagens": _converteVantagens(c["advantages"], c["languages"]),
      "complicacoes": [
        for (var comp in _lista(c["complications"]))
          {"titulo": _texto(comp["title"]), "desc": _texto(comp["description"])}
      ],
    };

    return ResultadoImportacao(ficha, _avisos, _imagem(c["gallery"]));
  }

  // --- Habilidades, defesas, perícias ----------------------------------

  List _converteHabilidades(dynamic abilities) {
    List lista = [
      for (Map h in cat.habilidades)
        {
          "id": h["id"],
          "nome": h["nome"],
          "valor": 0,
          "bonus": [],
          "ausente": false
        }
    ];
    for (var a in _lista(abilities)) {
      String? id = _habilidades[a["id"]];
      if (id == null) continue;
      Map h = lista.firstWhere((e) => e["id"] == id);
      h["valor"] = _inteiro(a["rank"]);
      h["ausente"] = a["isNull"] == true;
    }
    return lista;
  }

  List _converteDefesas(dynamic defenses) {
    // Mesma estrutura do construtor de ManipulaDefesas
    List lista = ManipulaDefesas().listaDefesas;
    for (var d in _lista(defenses)) {
      String? id = _defesas[d["id"]];
      if (id == null) continue;
      Map defesa = lista.firstWhere((e) => e["id"] == id);
      defesa["valor"] = _inteiro(d["rank"]);
    }
    return lista;
  }

  List _convertePericias(dynamic skills, dynamic extraSkills) {
    List lista = [
      for (Map p in cat.pericias)
        {
          "id": p["id"],
          "nome": p["nome"],
          "valor": 0,
          "idHab": p["idHab"],
          "treinado": p["treinado"],
          "bonus": [],
          "classe": "Pericia",
        }
    ];
    for (var s in _lista(skills)) {
      String? id = _pericias[s["id"]];
      if (id == null) continue;
      lista.firstWhere((e) => e["id"] == id)["valor"] = _inteiro(s["rank"]);
    }

    for (var s in _lista(extraSkills)) {
      String nome = _texto(s["name"]);
      if (s["isRanged"] != null) {
        // Perícia de combate (Ataque a Corpo-a-Corpo / à Distância)
        bool distancia = s["isRanged"] == true;
        Map escolhidos = s["chosenAttacks"] is Map ? s["chosenAttacks"] : {};
        lista.add({
          "id": distancia ? "PA02" : "PA01",
          "nome": distancia ? "Ataque a Distância" : "Ataque a Corpo-a-Corpo",
          "valor": _inteiro(s["rank"]),
          "idHab": distancia ? "DES" : "LUT",
          "treinado": false,
          "bonus": [],
          "escopo": _texto(escolhidos["descriptor"]).isNotEmpty
              ? _texto(escolhidos["descriptor"])
              : nome,
          "bonusPoderes": [
            for (var id in _lista(escolhidos["list"]))
              if (_idsPoderes["$id"] != null) _idsPoderes["$id"]
          ],
          "range": distancia,
          "idCriacao": "S${_uuid.v4()}",
          "classe": "PericiaAddAcerto",
        });
      } else {
        // Especialidade
        String idHab = _habilidades[s["abilityID"]] ?? "INT";
        String id = {"PRO": "PA04", "PRE": "PA05"}[idHab] ?? "PA03";
        lista.add({
          "id": id,
          "nome": id == "PA04"
              ? "Especialidade de Prontidão"
              : id == "PA05"
                  ? "Especialidade de Presença"
                  : "Especialidade de Intelecto",
          "valor": _inteiro(s["rank"]),
          "idHab": idHab,
          "treinado": true,
          "bonus": [],
          "escopo": _texto(s["trait"]).isNotEmpty ? _texto(s["trait"]) : nome,
          "classe": "PericiaAdiciona",
        });
      }
    }
    return lista;
  }

  // --- Vantagens --------------------------------------------------------

  Map? _vantagemCatalogo(String nome) {
    String chave = _normaliza(nome);
    for (Map v in cat.vantagens) {
      if (_normaliza(v["nome"]) == chave) return v;
    }
    return null;
  }

  List _converteVantagens(dynamic advantages, dynamic languages) {
    List lista = [];
    String idiomas = [
      for (var l in _lista(languages))
        if (_texto(l["text"]).isNotEmpty) _texto(l["text"])
    ].join(", ");

    for (var a in _lista(advantages)) {
      String nome = _texto(a["name"]);
      Map? v = _vantagemCatalogo(nome);
      String txt = _texto(a["traitText"]);
      if (v != null && v["id"] == "V052" && txt.isEmpty) txt = idiomas;

      if (v == null) {
        _avisos.add(
            "Vantagem \"$nome\" não existe no catálogo da Fábrica; foi importada como vantagem livre.");
      }
      bool graduado = v != null ? v["graduado"] == true : a["ranked"] == true;
      lista.add({
        "id": v?["id"] ?? "VPS${a["id"]}",
        "nome": v?["nome"] ?? nome.toUpperCase(),
        "desc": v != null ? v["desc"] == true || txt.isNotEmpty : true,
        "txtDec": txt,
        "graduado": graduado,
        "graduacao": graduado ? math.max(1, _inteiro(a["rank"], 1)) : 1,
        "limite": v?["limite"] ?? 0,
        "idOrigem": "",
        "bonus": [],
        "addByPower": false,
        "alvo_bonus": v?["alvo_bonus"] ?? [],
        "class": "Vantagem",
      });
    }
    return lista;
  }

  // --- Poderes ----------------------------------------------------------

  Map _efeitoCatalogo(String eId) =>
      cat.efeitos.firstWhere((e) => e["e_id"] == eId);

  /// Converte um poder do Poder Supremo em um ou mais itens da Fábrica
  List<Map> _convertePoder(Map p) {
    int efeito = _inteiro(p["effectID"]);
    List alternativos = _lista(p["alternateEffects"]);
    String nome = _texto(p["name"]);
    Map item;

    if (efeito == _arranjo) {
      List<Map> efeitos = [
        for (var a in alternativos) ..._marcaDinamico(_convertePoder(a), a)
      ];
      if (efeitos.isEmpty) return [];
      bool dinamico = p["isDynamicEffect"] == true ||
          alternativos.any((a) => a["isDynamicEffect"] == true);
      item = _pacote(nome, dinamico ? "D" : "E", efeitos);
      return [_aplicaRemovivel(item, p)];
    }

    if (_multiplosPoderes.contains(efeito)) {
      List<Map> efeitos = [
        for (var sub in _lista(p["powers"])) ..._convertePoder(sub)
      ];
      if (efeitos.isEmpty) return [];
      item = _pacote(nome, efeito == _efeitosLigados ? "L" : "R", efeitos);
      if (efeito == _dispositivo && _removivel(p) == 0) item["removivel"] = 1;
    } else {
      List<Map> convertidos = _converteEfeito(p);
      if (convertidos.isEmpty) return [];
      item = convertidos.length == 1
          ? convertidos.first
          : _pacote(nome, "L", convertidos);
    }

    if (alternativos.isNotEmpty) {
      List<Map> efeitos = [..._marcaDinamico([item], p)];
      for (var a in alternativos) {
        efeitos.addAll(_marcaDinamico(_convertePoder(a), a));
      }
      bool dinamico = p["isDynamicEffect"] == true ||
          alternativos.any((a) => a["isDynamicEffect"] == true);
      item = _pacote(nome, dinamico ? "D" : "E", efeitos);
    }

    return [_aplicaRemovivel(item, p)];
  }

  /// Guarda em cada efeito de um arranjo se ele é dinâmico.
  /// O Poder Supremo marca o Dinâmico efeito a efeito; a Fábrica usa a
  /// marca para cobrar o arranjo como o app de origem (ver CustoPoderes).
  List<Map> _marcaDinamico(List<Map> itens, Map origem) {
    for (Map i in itens) {
      i["dinamico"] = origem["isDynamicEffect"] == true;
    }
    return itens;
  }

  int _removivel(Map p) {
    int r = _inteiro(p["removable"]);
    for (var f in _lista(p["flats"])) {
      if (f["id"] == _modRemovivel) r = math.max(r, _inteiro(f["rank"], 1));
    }
    return r.clamp(0, 2);
  }

  Map _aplicaRemovivel(Map item, Map p) {
    int removivel = _removivel(p);
    if (removivel == 0) return item;
    if (item["class"] == "PacotesEfeitos" && item["tipo"] == "R") {
      item["removivel"] = removivel;
      return item;
    }
    Map pacote = _pacote(_texto(p["name"]), "R", [item]);
    pacote["removivel"] = removivel;
    return pacote;
  }

  Map _pacote(String nome, String tipo, List<Map> efeitos) {
    const Map<String, String> nomes = {
      "R": "Pacotes de Efeitos",
      "E": "Efeitos Alternativos",
      "D": "Efeitos Alternativos Dinamicos",
      "L": "Efeitos Ligados",
    };
    String idPacote = "A${_uuid.v4()}";
    for (Map e in efeitos) {
      // Mesmo tratamento de PacotesEfeitos.addPoder
      if (["L", "D", "E"].contains(tipo) &&
          ["EfeitoBonus", "EfeitoCrescimento"].contains(e["class"])) {
        e["idArranjo"] = idPacote;
      }
    }
    return {
      "nome": nome,
      "efeito": nomes[tipo],
      "tipo": tipo,
      "removivel": 0,
      "custo": 0,
      "class": "PacotesEfeitos",
      "efeitos": efeitos,
      "idCriacao": idPacote,
    };
  }

  /// Converte um efeito (não contêiner). Pode gerar mais de um item
  /// (Característica Aumentada que mistura habilidades e vantagens).
  List<Map> _converteEfeito(Map p) {
    int efeito = _inteiro(p["effectID"]);

    if ([_caracteristicaAumentada, _vantagemAumentada, _periciaAumentada]
        .contains(efeito)) {
      return _converteCaracteristicaAumentada(p);
    }
    if (efeito == _forcaAumentada) {
      Map item = _novoEfeito(p, "PB01");
      item["alvoAumento"] = [
        _bonusHabilidade("FOR", math.max(1, _inteiro(p["rank"], 1)))
      ];
      item["graduacao"] = math.max(1, _inteiro(p["rank"], 1));
      _aplicaModificadores(item, p);
      return [item];
    }

    String? eId = _efeitos[efeito];
    if (eId == null) {
      return [_genericoPorCusto(p, "efeito sem equivalente na Fábrica")];
    }

    Map item = _novoEfeito(p, eId);
    String classe = item["class"];
    int rank = _inteiro(p["rank"]);
    item["graduacao"] = rank;

    switch (classe) {
      case "EfeitoDano":
        if (p["strengthBased"] == true) {
          int forca = _inteiro(p["strengthRanks"]);
          item["baseadoForca"] = true;
          item["graduacao"] = rank + (forca > 0 ? forca : _forca);
        }
        break;
      case "EfeitoAflicao":
        Map cond = p["conditions"] is Map ? p["conditions"] : {};
        item["condicoes"] = [
          _texto(cond["firstDegree"]),
          _texto(cond["secondDegree"]),
          _texto(cond["thirdDegree"]),
        ];
        break;
      case "EfeitoCompra":
        // No Poder Supremo a graduação de Imunidade/Movimento/Sentidos fica
        // nas opções (o "rank" do poder vem 0): a graduação é a soma delas.
        List opcoes = _opcoes(p);
        item["opt"] = opcoes;
        if (opcoes.isNotEmpty) {
          item["graduacao"] =
              opcoes.fold<int>(0, (soma, o) => soma + (o["valor"] as int));
        }
        break;
      case "EfeitoCustoVaria":
        List opt = _opcoes(p);
        if (opt.isEmpty) {
          // Ilusão, Sentido Remoto, Transformar: o custo-base já vem pronto
          opt = [
            {
              "ID": "PSBASE",
              "desc": "Custo-base importado",
              "valor": math.max(1, _inteiro(p["baseCost"], 1)),
              "espec": false,
            }
          ];
        }
        item["opt"] = opt;
        break;
      case "EfeitoCrescimento":
        // Crescimento, Encolhimento e Proteção: bônus calculado pela graduação
        item["alvoAumento"] = [];
        break;
    }

    _aplicaModificadores(item, p);
    return [item];
  }

  Map _novoEfeito(Map p, String eId) {
    Map base = _efeitoCatalogo(eId);
    String idCriacao = "P${_uuid.v4()}";
    _idsPoderes["${p["id"]}"] = idCriacao;

    Map item = {
      "nome": _texto(p["name"]),
      "e_id": eId,
      "idCriacao": idCriacao,
      "efeito": base["efeito"],
      "graduacao": 1,
      "acao": base["acao"],
      "alcance": base["alcance"],
      "duracao": base["duracao"],
      "modificadores": [],
      "descricao": _descricao(p),
      "defAtaque": false,
      "class": base["class"],
      "custo": 0,
    };

    switch (base["class"]) {
      case "EfeitoCompra":
      case "EfeitoCustoVaria":
        item["opt"] = [];
        break;
      case "EfeitoOfensivo":
      case "EfeitoDano":
      case "EfeitoAflicao":
        item["bonus"] = [];
        item["critico"] = 0;
        item["acerto"] = 0;
        if (base["class"] == "EfeitoDano") item["baseadoForca"] = false;
        if (base["class"] == "EfeitoAflicao") item["condicoes"] = ["", "", ""];
        break;
      case "EfeitoBonus":
      case "EfeitoCrescimento":
        item["idArranjo"] = "";
        item["alvoAumento"] = [];
        item["opt"] = [];
        item["active"] = true;
        break;
    }
    return item;
  }

  String _descricao(Map p) {
    List<String> partes = [];
    String desc = _semHtml(_texto(p["description"]));
    if (desc.isNotEmpty) partes.add(desc);

    List descritores = [
      for (var d in _lista(p["descriptors"]))
        if (_texto(d["name"] ?? d["text"]).isNotEmpty) _texto(d["name"] ?? d["text"])
    ];
    if (descritores.isNotEmpty) partes.add("Descritores: ${descritores.join(", ")}");

    String resistido = _texto(p["resistedBy"]);
    if (resistido.isNotEmpty && resistido != "Nenhum") {
      partes.add("Resistido por: $resistido");
    }
    String superado = _texto(p["overcomedBy"]);
    if (superado.isNotEmpty && superado != resistido) {
      partes.add("Superado por: $superado");
    }
    String afetado = _texto(p["affectedTrait"]);
    if (afetado.isNotEmpty && afetado != "Nenhum") {
      partes.add("Característica afetada: $afetado");
    }
    String sentido = _texto(p["sense"]);
    if (sentido.isNotEmpty) partes.add("Sentido: $sentido");
    return partes.join("\n");
  }

  List _opcoes(Map p) {
    List opt = [];
    int seq = 0;

    void adiciona(String nome, int valor, String texto) {
      seq++;
      opt.add({
        "ID": "PS${seq.toString().padLeft(2, "0")}",
        "desc": nome,
        "valor": valor,
        "espec": texto.isNotEmpty,
        if (texto.isNotEmpty) "text_desc": texto,
      });
    }

    for (var o in _lista(p["powerOptions"])) {
      adiciona(_texto(o["name"]), _inteiro(o["rank"], 1), _texto(o["traitText"]));
    }

    // Sentidos (formato novo)
    String nomeOpcao(dynamic id) => _opcoesSentidos[id] ?? "Opção $id";
    for (var s in _lista(p["senses"])) {
      String tipo = _texto(s["type"]);
      List feitos = [
        if (s["mainSense"] is Map) s["mainSense"],
        ..._lista(s["improvements"]),
      ];
      for (var f in feitos) {
        String texto = [tipo, _texto(f["traitText"])]
            .where((t) => t.isNotEmpty)
            .join(": ");
        adiciona(nomeOpcao(f["optionID"]), _inteiro(f["rank"], 1), texto);
      }
    }
    for (var m in _lista(p["senseTypeImprovements"])) {
      adiciona(nomeOpcao(m["optionID"]), 1, _texto(m["type"]));
    }
    return opt;
  }

  // --- Ação, alcance, duração e modificadores --------------------------

  void _aplicaModificadores(Map item, Map p, {bool comFixos = true}) {
    Map base = _efeitoCatalogo(item["e_id"]);
    List extras = _lista(p["extras"]);
    List falhas = _lista(p["flaws"]);
    List fixos = comFixos ? _lista(p["flats"]) : [];
    List todos = [...extras, ...falhas, ...fixos];

    bool tem(List<int> ids) => todos.any((m) => ids.contains(m["id"]));
    bool ofensivo =
        ["EfeitoOfensivo", "EfeitoDano", "EfeitoAflicao"].contains(item["class"]);

    // A Fábrica cobra a mudança de ação/alcance/duração pela diferença
    // com o padrão do efeito; os modificadores que fazem essa mudança no
    // Poder Supremo não viram itens (senão o custo seria contado 2 vezes).
    if (tem(_modsDeDuracao)) {
      int duracao = _inteiro(p["durationID"]);
      duracao = duracao == 5 ? 0 : duracao;
      item["duracao"] = duracao;
      // Mesmo efeito colateral de Efeito.alteraDuracao
      if (duracao == 2) item["acao"] = 1;
      if ([3, 4].contains(duracao) && [0, 3, 4].contains(base["duracao"])) {
        item["acao"] = 3;
      }
    }
    if (tem(_modsDeAcao)) {
      int acao = _inteiro(p["actionID"], item["acao"]);
      if (todos.any((m) => m["id"] == _modReacao)) acao = 4;
      item["acao"] = acao;
    }
    if (tem(_modsDeAlcance)) {
      item["alcance"] = _inteiro(p["rangeID"], item["alcance"]);
    }
    if (todos.any((m) => m["id"] == _modAtaque)) {
      if (base["alcance"] == 0) {
        item["defAtaque"] = true;
        item["acao"] = 1;
        int alcance = _inteiro(p["rangeID"], 1);
        item["alcance"] = alcance < 1 ? 1 : alcance;
      }
    }

    List mods = [];
    for (var m in extras) {
      _converteModificador(m, true, false, item, base, ofensivo, mods);
    }
    for (var m in falhas) {
      _converteModificador(m, false, false, item, base, ofensivo, mods);
    }
    for (var m in fixos) {
      _converteModificador(m, m["extra"] == true, true, item, base, ofensivo, mods);
    }
    item["modificadores"] = mods;
  }

  void _converteModificador(Map m, bool extra, bool fixo, Map item, Map base,
      bool ofensivo, List mods) {
    int id = _inteiro(m["id"]);
    int rank = _inteiro(m["rank"]);
    String nome = _texto(m["name"]);
    String texto = _texto(m["traitText"]);

    if ([
      ..._modsDeAcao,
      ..._modsDeAlcance,
      ..._modsDeDuracao,
      _modAtaque,
      _modRemovivel
    ].contains(id)) {
      return;
    }
    if (id == _modAcurado && ofensivo) {
      item["acerto"] = (item["acerto"] ?? 0) + 2 * math.max(1, rank);
      return;
    }
    if (id == _modImpreciso && ofensivo) {
      item["acerto"] = (item["acerto"] ?? 0) - 2 * math.max(1, rank);
      return;
    }

    Map? fabrica = _modificadorCatalogo(nome, base, extra, id);
    // Fixo x por graduação diferente mudaria o custo: usa Personalizado
    if (fabrica != null && (fabrica["fixo"] == true) == fixo) {
      Map mod = Map.from(fabrica);
      mod["grad"] = math.max(1, rank);
      if (rank == 0 && (mod["custo_base"] ?? 0) != 0) {
        // Modificador gratuito no Poder Supremo (ex.: graduação 0)
        mod = _personalizado(nome, extra, fixo, 0, texto);
      } else if (texto.isNotEmpty) {
        mod["text_desc"] = texto;
      }
      mods.add(_idUnico(mod));
      return;
    }

    mods.add(_idUnico(_personalizado(nome, extra, fixo, rank, texto)));
  }

  Map? _modificadorCatalogo(String nome, Map base, bool extra, int id) {
    if ([_modAfetaOutros, _modAfetaApenasOutros].contains(id) &&
        base["alcance"] != 0) {
      return null; // Na Fábrica só existem para efeitos pessoais
    }
    String chave = _normaliza(nome).toLowerCase();
    chave = _apelidosModificador[chave] ?? chave;
    if (chave == "resistencia alternativa" && extra) {
      chave = "resistencia alternativa (mais vantajosa)";
    }

    List candidatos = [
      ..._lista(base["modificadores"]),
      for (var grupo in cat.modificadores.values) ..._lista(grupo),
    ];
    for (Map c in candidatos) {
      if (_normaliza(c["nome"]).toLowerCase() == chave) {
        // Extra e falha com o mesmo nome não se misturam
        num custo = c["custo_base"] ?? 0;
        if ((extra && custo < 0) || (!extra && custo > 0)) continue;
        return c;
      }
    }
    return null;
  }

  Map _personalizado(
      String nome, bool extra, bool fixo, int rank, String texto) {
    String mId = extra ? (fixo ? "E052" : "E051") : (fixo ? "E054" : "E053");
    Map base = _lista(cat.modificadores["gerais"])
        .firstWhere((m) => m["m_id"] == mId);
    Map mod = Map.from(base);
    mod["grad"] = rank;
    mod["text_desc"] = texto.isNotEmpty ? "$nome: $texto" : nome;
    return mod;
  }

  Map _idUnico(Map mod) {
    // A Fábrica localiza o modificador pelo m_id (editar/remover)
    _seqModificador++;
    String chave = mod["m_id"] != null ? "m_id" : "e_id";
    mod[chave] = "${mod[chave]}#PS$_seqModificador";
    if (mod["m_id"] == null) mod["m_id"] = mod["e_id"];
    return mod;
  }

  // --- Característica Aumentada ----------------------------------------

  Map _bonusHabilidade(String id, int valor) {
    Map h = cat.habilidades.firstWhere((e) => e["id"] == id);
    return {"id": id, "nome": h["nome"], "valor": valor};
  }

  List<Map> _converteCaracteristicaAumentada(Map p) {
    List habilidades = [];
    List defesas = [];
    List vantagens = [];
    List<String> naoAplicadas = [];
    int custoNaoAplicado = 0;

    for (var t in _lista(p["enhancedTraits"])) {
      int alvo = _inteiro(t["affectedTraitID"]);
      int rank = _inteiro(t["rank"]);
      if (rank == 0) continue;
      if (_habilidades[alvo] != null) {
        habilidades.add(_bonusHabilidade(_habilidades[alvo]!, rank));
      } else if (_defesas[alvo] != null) {
        String id = _defesas[alvo]!;
        Map d = ManipulaDefesas().returnId(id);
        defesas.add({...d, "bonus": 0, "valor": rank});
      } else {
        // Perícias: a "Perícia Aumentada" da Fábrica (custo 0,5) ainda não
        // é calculável; o custo é mantido como Característica.
        naoAplicadas.add("${_texto(t["traitName"])} +$rank");
        custoNaoAplicado += (alvo >= 3001 && alvo <= 3016) || alvo >= 31000
            ? (rank / 2).ceil()
            : rank;
      }
    }
    for (var a in _lista(p["enhancedAdvantages"])) {
      Map? v = _vantagemCatalogo(_texto(a["name"]));
      int rank = math.max(1, _inteiro(a["rank"], 1));
      if (v == null) {
        naoAplicadas.add("${_texto(a["name"])} $rank");
        custoNaoAplicado += rank;
        continue;
      }
      vantagens.add({...v, "valor": rank, "txtDec": _texto(a["traitText"])});
    }

    List<Map> itens = [];
    bool primeiro = true;
    void cria(String eId, List alvos) {
      if (alvos.isEmpty) return;
      Map item = _novoEfeito(p, eId);
      item["alvoAumento"] = alvos;
      item["graduacao"] =
          alvos.fold<int>(0, (s, a) => s + (a["valor"] as int));
      _aplicaModificadores(item, p, comFixos: primeiro);
      primeiro = false;
      itens.add(item);
    }

    cria("PB01", habilidades);
    cria("PB02", defesas);
    cria("PB03", vantagens);

    if (naoAplicadas.isNotEmpty) {
      Map item = _novoEfeito(p, "E005");
      item["graduacao"] = math.max(1, custoNaoAplicado);
      item["descricao"] = [
        "Aumentos importados do Poder Supremo (bônus não aplicado automaticamente): ${naoAplicadas.join(", ")}",
        item["descricao"]
      ].where((t) => t.isNotEmpty).join("\n");
      itens.add(item);
      _avisos.add(
          "\"${_texto(p["name"])}\": aumento de ${naoAplicadas.join(", ")} foi importado como Característica; ajuste o bônus manualmente.");
    }
    return itens;
  }

  // --- Sem equivalente --------------------------------------------------

  Map _genericoPorCusto(Map p, String motivo) {
    /*
      Efeitos sem equivalente (Feitos de Força, Extra Aumentado,
      Invocar Veículo...) viram "Característica" com graduação igual ao
      custo calculado pelas regras do Poder Supremo, preservando os pontos.
    */
    int custo = _custoEstimado(p);
    Map item = _novoEfeito(p, "E005");
    item["graduacao"] = math.max(1, custo);
    item["descricao"] = [
      "Importado do Poder Supremo ($motivo, efeito ${p["effectID"]}): custo $custo PP.",
      item["descricao"]
    ].where((t) => t.isNotEmpty).join("\n");
    _avisos.add(
        "\"${_texto(p["name"])}\": $motivo; importado como Característica de $custo PP.");
    return item;
  }

  int _custoEstimado(Map p) {
    int rank = _inteiro(p["rank"]);
    num base = _inteiro(p["baseCost"]);
    num extras = _lista(p["extras"]).fold<num>(0, (s, m) => s + _inteiro(m["rank"]));
    num falhas = _lista(p["flaws"]).fold<num>(0, (s, m) => s + _inteiro(m["rank"]));
    num porGrad = base + extras - falhas;
    double total =
        porGrad > 0 ? (porGrad * rank).toDouble() : rank / (2 - porGrad);
    for (var f in _lista(p["flats"])) {
      if (f["id"] == _modRemovivel) continue;
      total += f["extra"] == true ? _inteiro(f["rank"]) : -_inteiro(f["rank"]);
    }
    return total.ceil();
  }

  // --- Equipamentos -----------------------------------------------------

  Map? _converteEquipamentos(List equipamentos) {
    List<Map> itens = [];
    for (var e in equipamentos) {
      itens.addAll(_converteEquipamento(e));
    }
    if (itens.isEmpty) return null;
    Map pacote = _pacote("Equipamentos", "R", itens);
    pacote["efeito"] = "Equipamentos";
    pacote["removivel"] = 4;
    return pacote;
  }

  List<Map> _converteEquipamento(dynamic e) {
    if (e is! Map) return [];
    String nome = _texto(e["name"]);

    if (e["power"] is Map) {
      List<Map> poder = _convertePoder(e["power"]);
      if (poder.length == 1 && nome.isNotEmpty) poder.first["nome"] = nome;
      return poder;
    }
    if (e["equipments"] is List) {
      List<Map> itens = [
        for (var sub in e["equipments"]) ..._converteEquipamento(sub)
      ];
      if (itens.isEmpty) return [];
      return [_pacote(nome, "E", itens)];
    }

    int custo = _inteiro(e["cost"]);
    Map item = _novoEfeito({"name": nome, "id": e["instanceID"] ?? e["id"]}, "E005");
    item["graduacao"] = math.max(1, custo);
    item["descricao"] = _semHtml(_texto(e["description"]));
    if (e["powers"] is List && (e["powers"] as List).isNotEmpty) {
      _avisos.add(
          "Equipamento \"$nome\": poderes internos (veículo/quartel-general) não foram importados; mantido o custo de $custo pontos.");
    }
    return [item];
  }

  // --- Utilitários -----------------------------------------------------

  Uint8List _imagem(dynamic galeria) {
    for (var g in _lista(galeria)) {
      String s = _texto(g);
      int virgula = s.indexOf(',');
      if (s.startsWith('data:image') && virgula > 0) {
        try {
          return base64Decode(s.substring(virgula + 1));
        } catch (e) {
          // imagem corrompida: segue sem imagem
        }
      }
    }
    return Uint8List(0);
  }

  static List _lista(dynamic v) => v is List ? v : [];

  static String _texto(dynamic v) => v == null ? "" : "$v".trim();

  static int _inteiro(dynamic v, [int padrao = 0]) {
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse("$v") ?? padrao;
  }

  static String _semHtml(String s) => s
      .replaceAll(RegExp(r'<br\s*/?>|</p>', caseSensitive: false), "\n")
      .replaceAll(RegExp(r'<[^>]+>'), "")
      .trim();

  static String _normaliza(dynamic s) {
    const de = 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc';
    String r = "$s".trim();
    StringBuffer b = StringBuffer();
    for (int i = 0; i < r.length; i++) {
      int idx = de.indexOf(r[i]);
      b.write(idx >= 0 ? para[idx] : r[i]);
    }
    return b
        .toString()
        .toUpperCase()
        .replaceAll(RegExp(r'[-–]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // --- Pós-carregamento ------------------------------------------------

  // Todos os efeitos são sempre ativos, inclusive os alternativos.
  static void _aplicaBonus(List poderes, bool ativo) {
    for (Map p in poderes) {
      if (p["class"] == "PacotesEfeitos") {
        _aplicaBonus(p["efeitos"] ?? [], ativo);
        continue;
      }
      if (!["EfeitoBonus", "EfeitoCrescimento"].contains(p["class"])) continue;

      p["active"] = ativo;
      for (Map alvo in p["alvoAumento"] ?? []) {
        alvo["idOrigem"] = p["idCriacao"];
        alvo["idArranjo"] = p["idArranjo"] ?? "";
      }
      EfeitoBonus efeito = Efeito.doMapa(p) as EfeitoBonus;
      if (!ativo) continue;
      // Evita bônus em dobro se a ficha já os tiver aplicado ao carregar
      personagem.validador.removeBonusId("${p["idCriacao"]}");
      if (efeito is EfeitoCrescimento) {
        p["alvoAumento"] = efeito.returnBonusList();
      } else {
        efeito.configBonus();
      }
    }
  }

  static void _recalculaCustos(List poderes) {
    for (Map p in poderes) {
      if (p["class"] == "PacotesEfeitos") {
        _recalculaCustos(p["efeitos"] ?? []);
        p["custo"] = CustoPoderes.custoItem(p);
      } else {
        p["custo"] = CustoPoderes.custoEfeito(p);
      }
    }
  }
}
