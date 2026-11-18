import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Biblioteca de Load files
import 'dart:convert'; // Biblitoeca de conversão de json

// Bibliotecas
import 'package:fabrica_do_multiverso/script/defesas/lib_defesas.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
//import 'package:fabrica_do_multiverso/screens/screenPoderes/controlePoderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';

import 'dart:developer' as dev;

//# Classe de Validação de NP
class ValidaNpPersonagem {
  List logErros = [];

  // Sempre lê o NP atual da ficha (antes ficava preso ao valor da criação)
  int get np => personagem.np;

  List _efeitos() {
    List logEfeitos = [];
    // Filtrar Efeitos Ofensivos
    List poderes = personagem.poderes.poderesLista
        .where((e) => ["EfeitoAflicao", "EfeitoOfensivo", "EfeitoDano"]
            .contains(e["class"]))
        .toList();

    // Desmantela os Pacotes
    extractPacote desmantelaPacote;
    List pacotes = personagem.poderes.poderesLista
        .where((e) => e["class"] == "PacotesEfeitos")
        .toList();

    for (Map p in pacotes) {
      desmantelaPacote = extractPacote();
      // Converte os efeitos de arvore para Linear
      poderes.addAll(desmantelaPacote.getEfeitos(p));
    }

    Vantagem objectVantagem = Vantagem();
    Habilidade objectHabilidade = Habilidade();

    List vantagens = personagem.vantagens.listaVantagens;

    int luta = 0;
    int vantagemCorpoACorpo = 0;

    int destreza = 0;
    int vantagemADistancia = 0;

    // Bonus de Habilidades;
    objectHabilidade.initObject(
        personagem.habilidades.listHab.firstWhere((e) => e["id"] == "LUT"));
    luta = objectHabilidade.valorTotal();

    objectHabilidade.initObject(
        personagem.habilidades.listHab.firstWhere((e) => e["id"] == "DES"));
    destreza = objectHabilidade.valorTotal();

    // Puxa Bonus das Vantagens
    if (vantagens.any((e) => e["id"] == "V013")) {
      // Corpo a Corpo
      objectVantagem.init(vantagens.firstWhere((v) => v["id"] == "V013"));
      vantagemCorpoACorpo = objectVantagem.returnTotalGrad();
    }

    if (vantagens.any((e) => e["id"] == "V011")) {
      // a Distância
      objectVantagem.init(vantagens.firstWhere((v) => v["id"] == "V011"));
      vantagemADistancia = objectVantagem.returnTotalGrad();
    }

    int bonusVantagem = 0;

    EfeitoOfensivo objectEfeito = EfeitoOfensivo();
    for (Map p in poderes) {
      // Encontra a origem do bonus
      switch (p["alcance"]) {
        case 1: // Perto
          // Vantagem corpo a corpo
          bonusVantagem = vantagemCorpoACorpo + luta;
          break;
        case 2: // a Distância
          bonusVantagem = vantagemADistancia + destreza;
          break;
        default: // Apenas o limite de NP
      }

      // Síncrono: o catálogo já foi carregado em Ficha.init
      objectEfeito = EfeitoOfensivo();
      objectEfeito.carregaMapa(p);
      int dano = danoTotal(p, objectEfeito.returnGraduacao());

      // Validação de Erro
      if (bonusVantagem + objectEfeito.totalBonusAcerto() + dano > 2 * np) {
        // Limite Estourado
        logEfeitos.add({
          "tipo": "E",
          "nome": objectEfeito.nome.isNotEmpty
              ? objectEfeito.nome
              : objectEfeito.returnObjDefault()["efeito"],
          "msg":
              "${objectEfeito.nome.isNotEmpty ? objectEfeito.nome : objectEfeito.returnObjDefault()["efeito"]}, se econtram com ${bonusVantagem + objectEfeito.totalBonusAcerto() + dano - (np * 2)} pontos fora do limite",
          "id": [objectEfeito.returnObjDefault()["efeito"]]
        });
      }
      // Considera os limites de 50% de troca
      else if (bonusVantagem + objectEfeito.totalBonusAcerto() > np * 1.5 ||
          dano > np * 1.5) {
        // Limite Estourado
        logEfeitos.add({
          "tipo": "E",
          "nome": objectEfeito.nome,
          "msg": "${objectEfeito.nome}, passa do limite de troca 50% NP",
          "id": [objectEfeito.returnObjDefault()["efeito"]]
        });
      }
    }

    return logEfeitos;
  }

  /// Dano usado no limite de NP (acerto + dano <= 2 x NP).
  /// Mover Objetos (E026): graduação do efeito + graduações do extra
  /// "Arma Improvisada ou Maestria em Arremesso" (ED001) + graduações da
  /// vantagem Armas Improvisadas (V007). Demais efeitos: a graduação.
  static int danoTotal(Map efeito, int graduacao) {
    if (efeito["e_id"] != "E026") return graduacao;
    int dano = graduacao;
    for (Map m in efeito["modificadores"] ?? []) {
      if (m["m_id"] == "ED001") dano += (m["grad"] ?? 1) as int;
    }
    for (Map v in personagem.vantagens.listaVantagens) {
      if (v["id"] == "V007") {
        Vantagem vantagem = Vantagem();
        vantagem.init(v);
        dano += vantagem.returnTotalGrad();
      }
    }
    return dano;
  }

  /// Modificadores que dependem de outro no mesmo efeito.
  /// Teleporte (E036): Limitado a Estendido (ED008) exige Estendido (ED002).
  List _dependenciasModificadores([List? lista]) {
    List log = [];
    for (Map p in lista ?? personagem.poderes.poderesLista) {
      if (p["class"] == "PacotesEfeitos") {
        log.addAll(_dependenciasModificadores(p["efeitos"] ?? []));
        continue;
      }
      if (p["e_id"] != "E036") continue;
      List mods = p["modificadores"] ?? [];
      bool tem(String id) => mods.any((m) => m["m_id"] == id);
      if (tem("ED008") && !tem("ED002")) {
        String nome = "${p["nome"] ?? ""}".isNotEmpty ? "${p["nome"]}" : "Teleporte";
        log.add({
          "tipo": "E",
          "nome": nome,
          "msg": "$nome tem a falha Limitado a Estendido sem o extra Estendido",
          "id": ["Teleporte"]
        });
      }
    }
    return log;
  }

  List _defesas() {
    /*
      Valida defesas a Regra
      
      - Args:
        Return: List [{
          tipo: "D"
          nome: nome das Defesas, 
          msg: mensagem de erro, 
          id: Lista com o id das Defesas
        }]
    */
    int np = personagem.np;

    List defesas = personagem.defesas.listaDefesas;
    List logDefesas = [];
    Defesa oDefesas = Defesa();

    // Fortitude & Vontade
    Map mapFortitude = defesas.firstWhere((d) => d["id"] == "D003");
    oDefesas.init(mapFortitude);
    int totalFortitude = oDefesas.bonusTotal();

    Map mapVontade = defesas.firstWhere((d) => d["id"] == "D005");
    oDefesas.init(mapVontade);
    int totalVontade = oDefesas.bonusTotal();

    if ((totalFortitude + totalVontade) > 2 * np) {
      // Ultrapassa os limites do NP
      logDefesas.add({
        "tipo": "D",
        "nome": "Vontade & Fortitude",
        "msg":
            "Vontade e Fortitude, se econtram com ${(totalFortitude + totalVontade) - (np * 2)} pontos fora do limite",
        "id": ["D003", "D005"]
      });
    }

    // Defesas Ativas & Resistência
    Map mapEsquiva = defesas.firstWhere((d) => d["id"] == "D001");
    oDefesas.init(mapEsquiva);
    int totalEsquiva = oDefesas.bonusTotal();

    Map mapAparar = defesas.firstWhere((d) => d["id"] == "D002");
    oDefesas.init(mapAparar);
    int totalAparar = oDefesas.bonusTotal();

    // Resistência deve ser Processado
    Map mapResistencia = defesas.firstWhere((d) => d["id"] == "D004");
    Resistencia oResistencia = Resistencia();
    oResistencia.init(mapResistencia);
    int totalResistencia = oResistencia.bonusTotal();

    if (totalAparar + totalResistencia > 2 * np) {
      logDefesas.add({
        "tipo": "D",
        "nome": "Aparar & Resistência",
        "msg":
            "Aparar e Resistência, se econtram com ${(totalResistencia + totalAparar) - (np * 2)} pontos fora do limite",
        "id": ["D002", "D004"]
      });
    }
    if (totalEsquiva + totalResistencia > 2 * np) {
      logDefesas.add({
        "tipo": "D",
        "nome": "Esquiva & Resistência",
        "msg":
            "Esquiva e Resistência, se econtram com ${(totalResistencia + totalEsquiva) - (np * 2)} pontos fora do limite",
        "id": ["D001", "D004"]
      });
    }

    return logDefesas;
  }

  List _pericias() {
    /*
      Valida Perícias a Regra é simples 
      10 + NP não podem ser superior ao bonus da perícias

      - Args:
        Return: List [{
          tipo: "P"
          nome: nome da Perícia, 
          msg: mensagem de erro, 
          id: List com o id da perícia 
        }]
    */
    int np = personagem.np;

    // Ignorar Pericias ofensiva, isso deve ir apenas para efeito
    List pericias = personagem.pericias.ListaPercias;
    List logPericia = [];

    for (Map p in pericias) {
      // Captura o valor
      Pericia pericia = Pericia();
      pericia.init(p);
      // Recolhe o Antecessor
      Map habilidadeBase = personagem.habilidades.listHab.firstWhere(
        (h) => (h["id"] == p["idHab"])
      );

      int bonusTotal = pericia.bonusTotal();
      //List toais = pericia.valoresTotais();

      // Validação de NP
      if (bonusTotal > np + 10) {
        // o valor se encontra fora dos limites
        // do NP
        logPericia.add({
          "tipo": "P",
          "nome": p["nome"],
          "msg":
              "a perícia ${p["nome"]}, se econtra com ${bonusTotal - (np + 10)} pontos fora do limite",
          "id": [p["id"]],
        });
      }
    }

    return logPericia;
  }

  List _calculaBonusTotal(mapObj, [ List<int> bonusBase = const [0] ]){
    /*
      TODO: CLASSE NÂO UTILIZADA - FUTURA IMPLMENTAÇÃO
      Retorna uma lista de valores que esse objeto pode assumir 
      caso haja efeitos aternativos do mesmo bonus
    */

    // 1 - Analisa se há mais de um bonus com o mesmo ID de criação
    List bonusAlternativo = [];
    Map b;
    int i = 0;
    List bonusLoop = [];
    List otherBonus = [];

    bonusLoop.addAll(mapObj["bonus"]);

    while (i < bonusLoop.length){
      b = bonusLoop[i];

      // Remove o Elemento atual da busca
      otherBonus = [];
      otherBonus.addAll(bonusLoop);
      otherBonus.removeAt(i);

      List arryBonus = [];
      if(otherBonus.any((bo) => bo["idArranjo"] == b["idArranjo"] && b["idArranjo"] != "")){
        // Adiciona o Atual da Lista e o Separa do Loop
        arryBonus.add(b);
        bonusLoop.removeAt(i);

        // Puxa os Efeitos Alternativos do Mesmo 
        // Grupo de b
        while(bonusLoop.any((bo) => bo["idArranjo"] == b["idArranjo"])) {
          int iFound = bonusLoop.indexWhere(
            (bo) => bo["idArranjo"] == b["idArranjo"]
          );
          Map bonusFound = bonusLoop[iFound];

          arryBonus.add(bonusFound);

          // Remove id encontrado para não duplica consulta
          bonusLoop.removeAt(iFound);
        }
        bonusAlternativo.add(arryBonus);
      }else{
        // Deixo no Else porque caso encotre isso embaralhá 
        // a contagem
        i++;
      }      
    }

    // Em bonusAlternativo todos os Efeitos de arranjo estão separados
    // Em bonusLoop coneterá efeitos não oriundos de EA;

    // Calcula Bonus Fixo
    int bonusFixo = mapObj["valor"];
    for (Map b in bonusLoop){
      bonusFixo += b["valor"] as int;
    }


    // Faz o calculo recursivo de todos o possíveis bonus
    List<int> lenIdx = [];  // contem o indice arry
    // int x = 0; // Posição Atual no Arry
    int idxA = 0; // Idex do Arry Atual

    int inxTmp = 0;

    // inicializa lenIdx
    for(var b in bonusAlternativo){lenIdx.add(0);}

    List<int> bonusAlternativoTotal = [];
    
    // Icremento de bonus
    for (int bonusSumBase in bonusBase) {
      do{
        idxA = 0; // Incia no primeiro arry

        // Calcula o bonus
        int total = bonusFixo + bonusSumBase;
        for(int i=0; i<lenIdx.length; i++){
          total += bonusAlternativo[i][lenIdx[i]]["valor"] as int;          
        }
        bonusAlternativoTotal.add(total);

        // - Lógica de Incremento
        try { // Caso não haja EAs
          lenIdx[idxA]++;  
        } catch (e) {
          continue; 
        }
        
        while( idxA < bonusAlternativo.length
        && lenIdx[idxA] >= bonusAlternativo[idxA].length ){
          // Zerá o indice atual
          lenIdx[idxA] = 0;

          // Incrementa o Próximo se Existir
          idxA++;
          if(idxA < bonusAlternativo.length){ lenIdx[idxA]++; }
        }

      }while(idxA < bonusAlternativo.length);
    }
    
    return bonusAlternativoTotal;
  }

  List _pontos() {
    /*
      Valida o orçamento da ficha: total de pontos de poder
      e pontos de equipamento.

      - Args:
        Return: List [{ tipo: "T" (total) ou "Q" (equipamento), nome, msg, id }]
    */
    List logPontos = [];
    Map<String, int> resumo = personagem.resumoPontos();

    if (resumo["total"]! > resumo["disponivel"]!) {
      logPontos.add({
        "tipo": "T",
        "nome": "Pontos de poder",
        "msg":
            "A ficha gasta ${resumo["total"]} pontos de poder, ${resumo["total"]! - resumo["disponivel"]!} acima dos ${resumo["disponivel"]} disponíveis",
        "id": [],
      });
    }

    if (resumo["equipamentoUsado"]! > resumo["equipamentoDisponivel"]!) {
      logPontos.add({
        "tipo": "Q",
        "nome": "Equipamento",
        "msg":
            "Os equipamentos usam ${resumo["equipamentoUsado"]} pontos de equipamento, mas a vantagem Equipamento fornece ${resumo["equipamentoDisponivel"]} (5 por graduação)",
        "id": ["V041"],
      });
    }

    return logPontos;
  }

  List validacaoGeral() {
    /*
      Valida a ficha com base nas regras,
      dentro de cada metódo as regras
      podem ser melhor descritas

      - Args:
        Return: List [{
          tipo: "P": Pericia, "D": Defesa, "E": Efetios
          nome: nome do objeto, 
          msg: mensagem de erro, 
          id: id do objeto 
        }]
    */

    logErros = []; // Limpa a lista de erros

    logErros.addAll(_pericias());
    logErros.addAll(_defesas());
    logErros.addAll(_efeitos());
    logErros.addAll(_dependenciasModificadores());
    logErros.addAll(_pontos());
    logErros.addAll(_vantagens());

    return logErros;
  }

  List _vantagens() {
    /*
      Vantagens acima do teto oficial de graduação
      (fichas antigas não são corrigidas, só sinalizadas).
    */
    List logVantagens = [];
    for (Map v in personagem.vantagens.listaVantagens) {
      Vantagem vantagem = Vantagem().init(v);
      if (vantagem.acimaDoLimite()) {
        logVantagens.add({
          "tipo": "V",
          "nome": vantagem.nome,
          "msg":
              "${vantagem.nome} está com graduação ${vantagem.grad()}, acima do máximo de ${vantagem.graduacaoMaxima()}",
          "id": [vantagem.id],
        });
      }
    }
    for (Map v in personagem.vantagens.repetidas()) {
      logVantagens.add({
        "tipo": "V",
        "nome": v["nome"],
        "msg": "${v["nome"]} não é graduada e só pode ser comprada uma vez",
        "id": [v["id"]],
      });
    }
    return logVantagens;
  }
}

//# Classe de intercambio entre os modulos
class IntercambioModular {
  // Lista de Bonus
  List<Object> bonus = [];

  List ofensive = [];
  // Essa classe fica reponsável por alterações
  // que devem acontecer fora do modulo

  void deletePericiaWhere(String idPericia) {
    /*
      Deleta todos os bonus onde o Id de criação 
      da perícia selecionado foi adicionado
      - Params:
        String idPericia - id de criação da Perícia
    */
    removePericias(List poderes){
      for (Map poder in poderes) {
        if(poder["bonus"] != null){// Evita erros em caso de vazio
          poder["bonus"].removeWhere((p) => p["acerto"]["idCriacao"] == idPericia);
        }else if(poder["class"] == "PacotesEfeitos"){
          removePericias(poder["efeitos"]);
        }
      }
    }

    removePericias(personagem.poderes.poderesLista);
    
  }

  void updatePericiaBonus() {
    /*
      Atualiza os Bonus de Pericia de todos os poderes
    */

    editPodewerList(Map poder, List listaP){
      // Nível Root
      if(listaP.any((p)=> p["idCriacao"] == poder["idCriacao"])){
        int idxP = listaP.indexWhere((p)=> p["idCriacao"] == poder["idCriacao"]);
        listaP[idxP] = poder;
      }

      // Considera os pacotes
      if(listaP.any((p)=> p["class"] == "PacotesEfeitos")){
        for(Map pe in listaP.where((p)=> p["class"] == "PacotesEfeitos").toList()){
          editPodewerList(poder, pe["efeitos"]);
        }    
      }
    }


    List listaOfensivePoderes = personagem.pericias.returnOfensiveEfeitos(0);
    List listPericia = personagem.pericias.ListaPercias
        .where((p) => p["classe"] == "PericiaAddAcerto")
        .toList();

    for (Map pericia in listPericia) {
      // Delete tudo para evitar duplicade
      deletePericiaWhere(pericia["idCriacao"]);

      Pericia currentPericia = Pericia();
      currentPericia.init(pericia);
      for (Map poder in listaOfensivePoderes) {
        if (pericia["bonusPoderes"].contains(poder["idCriacao"])) {
          poder["bonus"].add({
            "acerto": {
              "idCriacao": pericia["idCriacao"],
              "bonus": currentPericia.bonusTotal(),
            }
          });

          // Reflete Alteração
          editPodewerList(poder, personagem.poderes.poderesLista);
          
        }
      }
    }
  }

  ///**********************************************
  //;/* Lógica de Bonus
  ///**********************************************/

  void addHabilidades(mapHab) {
    /* 
      Metodo de Adição de Habilidades
      Args:
        - Params:
          - Map mapHab: obj contendo bonus e origem
    */

    // Pega a Habilidade
    int habIndex = personagem.habilidades.listHab
        .indexWhere((h) => h["id"] == mapHab["id"]);
    List currentBonus = personagem.habilidades.listHab[habIndex]["bonus"];

    // Verifica se o bonus já foi adicionado
    int bonusIndex =
        currentBonus.indexWhere((b) => b["idOrigem"] == mapHab["idOrigem"]);
    if (bonusIndex >= 0) {
      personagem.habilidades.listHab[habIndex]["bonus"][bonusIndex] = mapHab;
    } else {
      personagem.habilidades.listHab[habIndex]["bonus"].add(mapHab);
    }
  }

  void addBonus(bonusList) {
    /* 
      metódo para passagem de bonus adicionados em qualquer
      outro bonus
      Args:
        - Params:
          - List bonusList: Maps contendo o alvo e a origem
    */

    for (Map b in bonusList) {
      //; Verifica ID peculiar Habilidades
      switch (b["id"]) {
        case "FOR" ||
              "VIG" ||
              "AGI" ||
              "DES" ||
              "LUT" ||
              "INT" ||
              "PRO" ||
              "PRE":
          addHabilidades(b);
          break;
        default:
          // outros
          var listRef = [];
          int idxPedacoFicha = 0;
          switch (b["id"].substring(0, 1)) {
            case "D":
              listRef = personagem.defesas.listaDefesas;
              break;
            case "P":
              listRef = personagem.pericias.ListaPercias;
              break;
            case "V":
              listRef = personagem.vantagens.listaVantagens;
          }

          // Separa a lógica de Vantagens de Defesas e Perícias
          // Adição de Pericias e Defesas
          if (["P", "D"].contains(b["id"].substring(0, 1))) {
            idxPedacoFicha = listRef.indexWhere((r) => r["id"] == b["id"]);
            List bonus = listRef[idxPedacoFicha]["bonus"];
            int idxBonus =
                bonus.indexWhere((bi) => bi["idOrigem"] == b["idOrigem"]);
            if (idxBonus >= 0) {
              bonus[idxBonus] = b;
            } else {
              bonus.add(b);
            }
          }
          // Adiçãode Vantagens
          else if (b["id"].substring(0, 1) == "V") {
            // Checa se existe algum bonus já
            int index = listRef.indexWhere((v) => v["id"] == b["id"]);

            // Caso tenha
            if (index >= 0) {
              // Sobreescreve como add power
              listRef[index]["bonus"]
                  .add({"idOrigem": b["idOrigem"], "valor": b["valor"]});
            }
            // Caso não tenha
            else {
              b["addByPower"] = true;
              // Inicialização das Variáveis
              b["graduacao"] = 0;
              b["txtDec"] = "";
              b["bonus"] = [];
              b["bonus"].add({"idOrigem": b["idOrigem"], "valor": b["valor"]});

              listRef.add(b);
            }
          }
      }
    }
  }

  void removeBonusId(String id) {
    /*
        Passando id o classe irá remover o atributo
        busancando aonde ele foi adicionado
        Args:
          - Params:
            - int id : id de origem do bonus
      */

    List listRef;

    List removeBonusIdInRange(List getList) {
      for (int i = 0; i < getList.length; i++) {
        //Map r in getList){
        Map r = getList[i];
        // Fichas antigas podem ter itens sem a lista de bonus
        r["bonus"] ??= [];
        if (r["bonus"].isNotEmpty) {
          int idx = r["bonus"].indexWhere((b) => b["idOrigem"] == id);
          if (idx > -1) {
            getList[i]["bonus"].removeAt(idx);
          }
        }
      }
      return getList;
    }

    // Habilidades
    listRef = personagem.habilidades.listHab;
    personagem.habilidades.listHab = removeBonusIdInRange(listRef);

    // Defesas
    listRef = personagem.defesas.listaDefesas;
    personagem.defesas.listaDefesas = removeBonusIdInRange(listRef);

    // Pericias
    listRef = personagem.pericias.ListaPercias;
    personagem.pericias.ListaPercias = removeBonusIdInRange(listRef) as List<Map<dynamic, dynamic>>;

    // Vantagens
    listRef = personagem.vantagens.listaVantagens;
    listRef.removeWhere((r) =>
        r["addByPower"] == true &&
        id == r["idOrigem"]); // Remove vantagens adicioadas por poderes
    personagem.vantagens.listaVantagens = removeBonusIdInRange(listRef) as List<Map<dynamic, dynamic>>;
  }
}

//# Classe de Manipulação de Habilidades
class ManipulaHabilidades {
  List listHab = [];

  ManipulaHabilidades() {
    Habilidade forHabilidade = Habilidade();
    forHabilidade.init("FOR", 0, "Força");
    listHab.add(forHabilidade.objHabilidade());

    Habilidade vigHabilidade = Habilidade();
    vigHabilidade.init("VIG", 0, "Vigor");
    listHab.add(vigHabilidade.objHabilidade());

    Habilidade agiHabilidade = Habilidade();
    agiHabilidade.init("AGI", 0, "Agilidade");
    listHab.add(agiHabilidade.objHabilidade());

    Habilidade desHabilidade = Habilidade();
    desHabilidade.init("DES", 0, "Destreza");
    listHab.add(desHabilidade.objHabilidade());

    Habilidade lutHabilidade = Habilidade();
    lutHabilidade.init("LUT", 0, "Luta");
    listHab.add(lutHabilidade.objHabilidade());

    Habilidade intHabilidade = Habilidade();
    intHabilidade.init("INT", 0, "Intelecto");
    listHab.add(intHabilidade.objHabilidade());

    Habilidade proHabilidade = Habilidade();
    proHabilidade.init("PRO", 0, "Prontidão");
    listHab.add(proHabilidade.objHabilidade());

    Habilidade preHabilidade = Habilidade();
    preHabilidade.init("PRE", 0, "Presença");
    listHab.add(preHabilidade.objHabilidade());
  }
  void reInit(jsonHabilidades) {
    listHab = jsonHabilidades;
  }

  Habilidade getIndex(int index) {
    Map obj = listHab[index];
    Habilidade habilidade = Habilidade();
    habilidade.initObject(obj);
    return habilidade;
  }

  Map getItem(String id){
    /*
      Esse metodo uma das mapas de habilidade com base
      no seu ID chamado, o objetivo é facilitar a chamada direta
    */
    return listHab.firstWhere((h) => h["id"] == id);
    
  }

  int calculaTotal() {
    Habilidade instanciaHab = Habilidade();
    int totalHabi = 0;
    for (Map hab in listHab) {
      instanciaHab.initObject(hab);
      totalHabi += instanciaHab.custoTotal();
    }
    return totalHabi;
  }
}

//# Classe de Manipulação de Habilidades
class ManipulaDefesas {
  List listaDefesas = [];

  ManipulaDefesas() {
    // Anexa as Defesas
    Defesa esquiva = Defesa();
    esquiva.init({
      "id": "D001",
      "nome": "Esquiva",
      "valor": 0,
      "bonus": [],
      "idHabi": "AGI",
      "idOpDefesa": "D004",
      "imune": false
    });
    listaDefesas.add(esquiva.returnObj());

    Defesa aparar = Defesa();
    aparar.init({
      "id": "D002",
      "nome": "Aparar",
      "valor": 0,
      "bonus": [],
      "idHabi": "LUT",
      "idOpDefesa": "D004",
      "imune": false
    });
    listaDefesas.add(aparar.returnObj());

    Defesa fortitude = Defesa();
    fortitude.init({
      "id": "D003",
      "nome": "Fortitude",
      "valor": 0,
      "bonus": [],
      "idHabi": "VIG",
      "idOpDefesa": "D005",
      "imune": false
    });
    listaDefesas.add(fortitude.returnObj());

    Resistencia resistencia = Resistencia();
    resistencia.init({
      "id": "D004",
      "nome": "Resistência",
      "valor": 0,
      "bonus": [],
      "idHabi": "VIG",
      "idOpDefesa": "",
      "imune": false
    });
    listaDefesas.add(resistencia.returnObj());

    Defesa vontade = Defesa();
    vontade.init({
      "id": "D005",
      "nome": "Vontade",
      "valor": 0,
      "bonus": [],
      "idHabi": "PRO",
      "idOpDefesa": "D003",
      "imune": false
    });
    listaDefesas.add(vontade.returnObj());
  }
  init() {}

  Map returnId(String id) => listaDefesas.firstWhere((d)=> d["id"] == id);
  String returnForPrint(String id){
    Defesa defesa;

    id == 'D004' 
    ? defesa = Resistencia().init(returnId(id)) 
    : defesa = Defesa().init(returnId(id));

    if(defesa.imune){ return '-'; }

    if (defesa.bonus.isNotEmpty){
      return '${defesa.bonusTotal(false) } / ${defesa.bonusTotal()}';
    }else{
      return defesa.bonusTotal().toString();
    }
    
  }

  void reInit(jsonDefeas) {
    listaDefesas = jsonDefeas;
  }

  int calculaTotal() {
    int total = 0;
    for (Map mapDefesa in listaDefesas) {
      Defesa defesa = Defesa();
      defesa.init(mapDefesa);
      total += defesa.custoTotal();
    }
    return total;
  }
}

//# Classe de Manipulação de Poderes
class ManipulaPoderes {
  //Classe de Poderes

  List poderesLista = [];

  void reInit(jsonPoderes) {
    poderesLista = jsonPoderes as List;
  }

  /// Todos os efeitos são sempre ativos. Fichas salvas quando ainda havia
  /// a opção "Efeito Ativo" podem ter efeitos de bônus desligados
  /// ("active": false) em arranjos; aqui eles são ligados e o bônus aplicado.
  /// Retorna true se algum bônus foi aplicado.
  bool ativarBonusInativos([List? lista]) {
    bool alterou = false;
    for (Map p in lista ?? poderesLista) {
      if (["PacotesEfeitos", "EfeitosAlternativos"].contains(p["class"])) {
        alterou = ativarBonusInativos(p["efeitos"] ?? []) || alterou;
        continue;
      }
      if (!["EfeitoBonus", "EfeitoCrescimento"].contains(p["class"])) continue;
      if (p["active"] != false) continue;

      p["active"] = true;
      EfeitoBonus efeito = Efeito.doMapa(p) as EfeitoBonus;
      personagem.validador.removeBonusId("${p["idCriacao"]}");
      if (efeito is EfeitoCrescimento) {
        p["alvoAumento"] = efeito.returnBonusList();
      } else {
        efeito.configBonus();
      }
      alterou = true;
    }
    return alterou;
  }

  novoPoder(nome, id, classe) async {
    /*
      inicialização das classes de efeito
      selecionadas pela primeira vez (Provavelmente no add poder)
      
      Arg:
        String nome   | nome escolhido para a classe
        String id     | id de identificação do efeito
        String classe | indicador de Classe de manipulação
    */

    // Cria um novo Efeito
    Efeito poder = Efeito.porClasse(classe);
    await poder.instanciarMetodo(nome, id);
    Map objPoder = poder.retornaObj();
    poderesLista.add(objPoder);
  }

  novoPacote(nome, tipo, efeito, [int removivel = 0]) {
    /*
      inicialização de um pacote de efeitos
      selecionadas pela primeira vez (Provavelmente no add poder)
      
      Arg:
        String nome   | nome escolhido para a classe
        String id     | id de identificação do efeito
        String efeito | Nome do tipo do pacote 
    */
    PacotesEfeitos pacote = PacotesEfeitos();

    pacote.instanciarMetodo({
      "nome": nome,
      "tipo": tipo,
      "efeito": efeito,
      "efeitos": [],
      "removivel": removivel,
    });

    Map objPackge = pacote.retornaObj();
    poderesLista.add(objPackge);
  }

  /// Total em pontos de poder (equipamentos ficam de fora)
  int calculaTotal() => CustoPoderes.totalPoderes(poderesLista);

  /// Pontos de equipamento usados pelos pacotes de equipamento
  int pontosEquipamento() => CustoPoderes.pontosEquipamento(poderesLista);

  List<dynamic> listaDePoderes() {
    Map poder = {};
    List poderes = [];

    for (poder in poderesLista) {
      if (poder["class"] != "PacotesEfeitos") {
        poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "graduacao": poder["graduacao"],
          "class": poder["class"]
        });
      } else {
        poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "efeitos": poder["efeitos"],
          "class": poder["class"]
        });
      }
    }
    return poderes;
  }

  Future<Efeito> instanciaPoder(Map mapPoder) async {
    /*
      Efetua a Instancia do poder e retorna com o 
      respectiva classe alvo
      
      Arg:
        Map mapPoder |  o objeto de inicialização do poder
      Return:
        Objeto Efeito ou qualquer filho de acordo com o objeto
    */

    Efeito poder = Efeito.porClasse(mapPoder["class"]);

    await poder.instanciarMetodo(mapPoder["nome"], mapPoder["e_id"]);

    return poder;
  }
}

//# Classe de manipulação de Perícias
class ManipulaVantagens {
  List<Map> listaVantagens = [];

  void reInit(jsonVantagens) {
    listaVantagens = [];
    for (Map v in jsonVantagens) {
      listaVantagens.add(v);
    }
  }

  int cutoTotal() {
    // calcula o custo total das vantagens
    int totalCusto = 0;
    List<Map> repetidasLista = repetidas();
    for (Map v in listaVantagens) {
      if (repetidasLista.contains(v)) continue; // só a primeira compra custa
      Vantagem currentVantagem = Vantagem();
      currentVantagem.init(v);

      totalCusto += currentVantagem.returnTotalCusto();
    }

    return totalCusto;
  }

  List<Map> repetidas() {
    // Vantagens não graduadas compradas de novo (a partir da segunda)
    Set ids = {};
    return listaVantagens
        .where((v) => v["graduado"] != true && !ids.add(v["id"]))
        .toList();
  }
}

//# Classe de manipulação de Perícias
class ManipulaPericias {
  List<Map> ListaPercias = [];

  //Armazena Pericias Ofensivas
  List ListOfensive = [];

  Future<int> init() async {
    /*
      instancia a lista de pericias armazenadas
    */
    String jsonEfeitos = await rootBundle.loadString('assets/pericias.json');
    List objetoJson = jsonDecode(jsonEfeitos);

    if (ListaPercias.isEmpty) {
      // Em caso de reinicio rápido
      for (Map oPericia in objetoJson) {
        Pericia pericia = Pericia();
        pericia.init(oPericia);

        ListaPercias.add(pericia.returnObj());
      }
    }
    return 1;
  }

  void reInit(jsonPericias) {
    ListaPercias = [];

    if (ListaPercias.isEmpty) {
      // Em caso de reinicio rápido
      for (Map oPericia in jsonPericias) {
        Pericia pericia;

        // Mantém a classe original para não perder escopo de especialidades
        switch (oPericia["classe"]) {
          case "PericiaAddAcerto":
            pericia = PericiaAddAcerto();
            break;
          case "PericiaAdiciona":
            pericia = PericiaAdiciona();
            break;
          default:
            pericia = Pericia();
        }

        pericia.init(oPericia);

        ListaPercias.add(pericia.returnObj());
      }
    }
  }

  int calculaTotal() {
    int total = 0;
    for (Map p in ListaPercias) {
      total += int.parse("${p["valor"]}");
    }

    return (total / 2).ceil();
  }

  List returnOfensiveEfeitos(int distancia) {
    /*
      retorna uma lista de poderes compativeis com a 
      perícias, e realoca a lista de poderes se alterados

      - Args;
        - int distancia : 0 retornar tudo, 1 para perto, 2 para distância
        - Return: List<Map>: Retorna a Lista de poderes compativeis com acerto
    */

    List buscaListaPoderes(List listPoderes){
      List efeitosReturn = [];

      // Busca por Lista
      List pacotes = listPoderes.where((p) =>
        p["class"] == 'PacotesEfeitos'
      ).toList();
      
      // Busca efeito empacotados também
      for(final pacote in pacotes){
        efeitosReturn.addAll(buscaListaPoderes(pacote["efeitos"]));
      }

      // Efeitos que estão a nível "Raiz"
      efeitosReturn.addAll(
        listPoderes.where((p) =>
          // Efeitos Ofensivos nativos
          (["EfeitoAflicao", "EfeitoOfensivo", "EfeitoDano"]
          .contains(p["class"])

          // OU: Efeitos Convetidos em Ofensivo
          || p["defAtaque"] == true)

          // E: Alance sendo pero ou a ditância
          && [1, 2].contains(p["alcance"]))
        .toList()
      );

      return efeitosReturn;
    }
    
    List poderes = personagem.poderes.poderesLista;
    List poderesFilter = [];
    //; Poderes ofensivos e Sendo perto ou a distância
    List mapPoderes = buscaListaPoderes(poderes);

    for (int i = 0; i < mapPoderes.length; i++) {
      // Apenda de acordo com o Range
      if (distancia == 0 || distancia == mapPoderes[i]["alcance"]) {
        poderesFilter.add(mapPoderes[i]);
      }
    }

    // Adiciona Desarmado (Perto)
    if (distancia == 1) {
      poderesFilter.add({
        "nome": "Desarmado",
        "noPower": true,
        "efeito": "Força",
        "idCriacao": "F1"
      });
    }

    // Adicona Aremeço (a Distância)
    if (distancia == 2) {
      poderesFilter.add({
        "nome": "Arremeço",
        "noPower": true,
        "efeito": "Força",
        "idCriacao": "F2"
      });
    }

    return poderesFilter;
  }
}

//# Classe de Manipulação de Ficha
// esse metodo será acessível para todos
// para manipulação
class Ficha {
  String nomePersonagem = '';
  int np = 10;

  int acertoDis = 0;
  int acertoPer = 0;

  // Instancia da Ficha
  ManipulaHabilidades habilidades = ManipulaHabilidades();
  ManipulaDefesas defesas = ManipulaDefesas();
  ManipulaPoderes poderes = ManipulaPoderes();
  ManipulaPericias pericias = ManipulaPericias();
  ManipulaVantagens vantagens = ManipulaVantagens();
  List complicacoes = [];

  IntercambioModular validador = IntercambioModular();

  // Pontos de poder recebidos por nível de poder
  static const int pontosPorNp = 15;

  Future<int> init() async {
    await pericias.init();
    await Efeito.carregarCatalogo();
    await Vantagem.carregarCatalogo();

    return 1;
  }

  int iniciativa() {
    /*
      Bônus de iniciativa: Agilidade + 4 por graduação de Iniciativa
      Aprimorada (V054). Com Velocidade do Pensamento (V090) usa Intelecto
      no lugar de Agilidade.
    */
    List lista = vantagens.listaVantagens;
    String idHabilidade = lista.any((v) => v["id"] == "V090") ? "INT" : "AGI";

    Habilidade objHabilidade = Habilidade();
    objHabilidade.initObject(habilidades.getItem(idHabilidade));
    int total = objHabilidade.valorTotal();

    for (Map v in lista.where((v) => v["id"] == "V054")) {
      total += 4 * (Vantagem().init(v).returnTotalGrad() as int);
    }
    return total;
  }

  Map<String, int> resumoPontos() {
    /*
      Orçamento da ficha: quanto cada módulo gasta, o total
      e o disponível pelo nível de poder.
    */
    int hab = habilidades.calculaTotal();
    int def = defesas.calculaTotal();
    int per = pericias.calculaTotal();
    int van = vantagens.cutoTotal();
    int pod = poderes.calculaTotal();

    // Graduações de Equipamento compradas ou concedidas por poder
    int gradEquipamento = 0;
    for (Map v in vantagens.listaVantagens.where((v) => v["id"] == "V041")) {
      gradEquipamento += Vantagem().init(v).returnTotalGrad() as int;
    }

    int total = hab + def + per + van + pod;
    int disponivel = np * pontosPorNp;
    return {
      "habilidades": hab,
      "defesas": def,
      "pericias": per,
      "vantagens": van,
      "poderes": pod,
      "total": total,
      "disponivel": disponivel,
      "restante": disponivel - total,
      "equipamentoUsado": poderes.pontosEquipamento(),
      "equipamentoDisponivel": gradEquipamento * 5,
    };
  }

  Future<int> reInit(Map jsonReInit) async {
    await Efeito.carregarCatalogo();
    await Vantagem.carregarCatalogo();
    nomePersonagem = jsonReInit["pesonagem"]["nome"];
    np = jsonReInit["pesonagem"]["np"];

    habilidades.reInit(jsonReInit["habilidades"]);
    defesas.reInit(jsonReInit["defesas"]);
    poderes.reInit(jsonReInit["poderes"]);
    pericias.reInit(jsonReInit["pericias"]);
    vantagens.reInit(jsonReInit["vantagens"]);

    complicacoes = jsonReInit["complicacoes"].toList();

    // Bônus de efeitos que estavam desligados passam a valer
    if (identical(personagem, this) && poderes.ativarBonusInativos()) {
      validador.updatePericiaBonus();
    }

    return 1;
  }

  Map returnObjJson() {
    return {
      "pesonagem": {
        "nome": nomePersonagem,
        "np": np,
      },
      "habilidades": habilidades.listHab,
      "defesas": defesas.listaDefesas,
      "poderes": poderes.poderesLista,
      "pericias": pericias.ListaPercias,
      "vantagens": vantagens.listaVantagens,
      "complicacoes": complicacoes,
    };
  }
}

Ficha personagem = Ficha();
