import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Biblioteca de Load files
import 'dart:convert';                  // Biblitoeca de conversão de json

// Bibliotecas
import 'package:fabrica_do_multiverso/script/defesas/lib_defesas.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
//import 'package:fabrica_do_multiverso/screens/screenPoderes/controlePoderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

//# Classe de Validação de NP
class validaNpPersonagem{
  List logErros = [];

  int np = personagem.np;

  List _efeitos(){
    List logEfeitos = [];
    // Filtrar Efeitos Ofensivos
    List poderes = personagem.poderes.poderesLista.where(
      (e) => ["EfeitoAflicao", "EfeitoOfensivo", "EfeitoDano"].contains(e["class"])
    ).toList();

    // Desmantela os Pacotes
    extractPacote desmantelaPacote;
    List pacotes = personagem.poderes.poderesLista.where(
      (e) => e["class"] == "PacotesEfeitos"
    ).toList();

     
    for(Map p in pacotes){
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
    objectHabilidade.initObject(personagem.habilidades.listHab.firstWhere((e)=>e["id"] == "LUT"));
    luta = objectHabilidade.valorTotal();

    objectHabilidade.initObject(personagem.habilidades.listHab.firstWhere((e)=>e["id"] == "DES"));
    destreza = objectHabilidade.valorTotal();

    // Puxa Bonus das Vantagens
    if(vantagens.any((e) => e["id"] == "V013")){
      // Corpo a Corpo
      objectVantagem.init(vantagens.firstWhere(
        (v)=>v["id"] == "V013"
      ));
      vantagemCorpoACorpo = objectVantagem.returnTotalGrad();
    }
    
    if(vantagens.any((e) => e["id"] == "V011")){
      // a Distância
      objectVantagem.init(vantagens.firstWhere(
        (v)=>v["id"] == "V011"
      ));
      vantagemADistancia = objectVantagem.returnTotalGrad();
    }
    

    int bonusVantagem = 0;
    
    EfeitoOfensivo objectEfeito = EfeitoOfensivo(); 
    for(Map p in poderes){
      // Encontra a origem do bonus
      switch (p["alcance"]){
        case 1: // Perto
          // Vantagem corpo a corpo
          bonusVantagem = vantagemCorpoACorpo + luta;
          break;
        case 2: // a Distância
          bonusVantagem = vantagemADistancia + destreza;
          break; 
        default: // Apenas o limite de NP


      }

      objectEfeito.reinstanciarMetodo(p);

      // Validação de Erro
      if ( bonusVantagem + objectEfeito.totalBonusAcerto() + objectEfeito.returnGraduacao() > 2 * np){
        // Limite Estourado
        logEfeitos.add({
          "tipo": "E",
          "nome": objectEfeito.nome.isNotEmpty ? objectEfeito.nome : objectEfeito.returnObjDefault()["efeito"],
          "msg": "${objectEfeito.nome.isNotEmpty ? objectEfeito.nome : objectEfeito.returnObjDefault()["efeito"]}, se econtram com ${bonusVantagem + objectEfeito.totalBonusAcerto() + objectEfeito.returnGraduacao() - ( np * 2)} pontos fora do limite",
          "id": [objectEfeito.returnObjDefault()["efeito"]]
        });
      }
      // Considera os limites de 50% de troca
      else if( bonusVantagem + objectEfeito.totalBonusAcerto() > np * 1.5
        || objectEfeito.returnGraduacao() > np * 1.5){
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

  List _defesas(){
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
    

    if( (totalFortitude + totalVontade) > 2*np ){
      // Ultrapassa os limites do NP
      logDefesas.add({
        "tipo": "D",
        "nome": "Vontade & Fortitude",
        "msg": "Vontade e Fortitude, se econtram com ${(totalFortitude + totalVontade) - ( np * 2)} pontos fora do limite",
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

    if( totalAparar + totalResistencia > 2 * np){
      logDefesas.add({
        "tipo": "D",
        "nome": "Aparar & Resistência",
        "msg": "Aparar e Resistência, se econtram com ${(totalResistencia + totalAparar) - ( np * 2)} pontos fora do limite",
        "id": ["D002", "D004"]
      });

    }
    if ( totalEsquiva + totalResistencia > 2 * np){
      logDefesas.add({
        "tipo": "D",
        "nome": "Esquiva & Resistência",
        "msg": "Esquiva e Resistência, se econtram com ${(totalResistencia + totalEsquiva) - ( np * 2)} pontos fora do limite",
        "id": ["D001", "D004"]
      });
    }

    return logDefesas;
  }

  List _pericias(){
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
    
    for(Map p in pericias){
      // Captura o valor
      Pericia pericia = Pericia();
      pericia.init(p);
      int bonusTotal = pericia.bonusTotal();

      // Validação de NP
      if(bonusTotal > np + 10){
        // o valor se encontra fora dos limites
        // do NP
        logPericia.add({
          "tipo": "P",
          "nome": p["nome"],
          "msg": "a perícia ${p["nome"]}, se econtra com ${bonusTotal - ( np + 10)} pontos fora do limite",
          "id": [p["id"]],
        });
      }
    }

    return logPericia;
  }

  List validacaoGeral(){
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

    return logErros;
  }
}

//# Classe de intercambio entre os modulos
class IntercambioModular{
  // Lista de Bonus
  List<Object> bonus = [];

  List ofensive = [];
  // Essa classe fica reponsável por alterações
  // que devem acontecer fora do modulo

  void deletePericiaWhere(String idPericia){
    /*
      Deleta todos os bonus onde o Id de criação 
      da perícia selecionado foi adicionado
      - Params:
        String idPericia - id de criação da Perícia
    */

    List poderes = personagem.poderes.poderesLista;
    for(Map poder in poderes){
      poder["bonus"].removeWhere((p) => p["acerto"]["idCriacao"] == idPericia);
    }
  }

  void updatePericiaBonus(){
    /*
      Atualiza os Bonus de Pericia de todos os poderes
    */
    List listaOfensivePoderes = personagem.pericias.returnOfensiveEfeitos(0);
    List listPericia = personagem.pericias.ListaPercias.where((p) => p["classe"] == "PericiaAddAcerto").toList();

    for(Map pericia in listPericia){
      // Delete tudo para evitar duplicade
      deletePericiaWhere(pericia["idCriacao"]);

      Pericia currentPericia = Pericia();
      currentPericia.init(pericia);
      for(Map poder in listaOfensivePoderes){
        if(pericia["bonusPoderes"].contains(poder["idCriacao"])){

          poder["bonus"].add({
            "acerto": {
              "idCriacao": pericia["idCriacao"],
              "bonus": currentPericia.bonusTotal(),
            }
          });
        };
      }
    }
  }

  ///**********************************************
  //;/* Lógica de Bonus
  ///**********************************************/

  void addHabilidades(mapHab){
    /* 
      Metodo de Adição de Habilidades
      Args:
        - Params:
          - Map mapHab: obj contendo bonus e origem
    */

    // Pega a Habilidade
    int habIndex = personagem.habilidades.listHab.indexWhere((h)=>h["id"] == mapHab["id"]);
    List currentBonus = personagem.habilidades.listHab[habIndex]["bonus"];
    
    // Verifica se o bonus já foi adicionado
    int bonusIndex = currentBonus.indexWhere((b)=>b["idOrigem"] == mapHab["idOrigem"]);
    if(bonusIndex >= 0){
      personagem.habilidades.listHab[habIndex]["bonus"][bonusIndex] = mapHab;
    }else{
      personagem.habilidades.listHab[habIndex]["bonus"].add(mapHab);
    }
  }
  void addBonus(bonusList){
    /* 
      metódo para passagem de bonus adicionados em qualquer
      outro bonus
      Args:
        - Params:
          - List bonusList: Maps contendo o alvo e a origem
    */   

    for (Map b in bonusList){
      //; Verifica ID peculiar Habilidades
      switch (b["id"]) {
        case "FOR" || "VIG" || "AGI" 
          || "DES" || "LUT" || "INT"
          || "PRO" || "PRE":
            addHabilidades(b);
          break;
        default:
          // outros
          var listRef = [];
          int idxPedacoFicha = 0;
          switch (b["id"].substring(0, 1)){            
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
          if (["P", "D"].contains(b["id"].substring(0, 1))){
            idxPedacoFicha = listRef.indexWhere((r)=> r["id"] == b["id"]);
            List bonus = listRef[idxPedacoFicha]["bonus"];
            int idxBonus = bonus.indexWhere((bi)=>bi["idOrigem"] == b["idOrigem"]);
            if(idxBonus >= 0){
              bonus[idxBonus] = b;
            }else{
              bonus.add(b);
            }
          }
          // Adiçãode Vantagens
          else if(b["id"].substring(0, 1) == "V"){
            // Checa se existe algum bonus já
            int index = listRef.indexWhere((v) => v["id"] == b["id"] );

            // Caso tenha
            if(index >= 0){
              // Sobreescreve como add power
              listRef[index]["bonus"].add({
                "idOrigem": b["idOrigem"],
                "valor" : b["valor"]
              });
            }
            // Caso não tenha
            else{
              b["addByPower"] = true;
              // Inicialização das Variáveis
              b["graduacao"] = 0;
              b["txtDec"] = "";
              b["bonus"] = [];
              b["bonus"].add({
                "idOrigem": b["idOrigem"],
                "valor" : b["valor"]
              });

              listRef.add(b);
            }
          }
      }
    }
  }

  void removeBonusId(String id){
      /*
        Passando id o classe irá remover o atributo
        busancando aonde ele foi adicionado
        Args:
          - Params:
            - int id : id de origem do bonus
      */

      List listRef;

      List removeBonusIdInRange(List getList){
        for(int i=0; i < getList.length; i++){
          //Map r in getList){
          Map r = getList[i];
          if(r["bonus"].isNotEmpty){
            int idx = r["bonus"].indexWhere((b)=>b["idOrigem"] == id);
            if(idx > -1){
              getList[i]["bonus"].removeAt(idx);
            }
          }
          
        }
        return getList;
      }

      // Habilidades
      listRef = personagem.habilidades.listHab;
      listRef = removeBonusIdInRange(listRef);

      // Defesas 
      listRef = personagem.defesas.listaDefesas;
      listRef = removeBonusIdInRange(listRef);

      // Pericias
      listRef = personagem.pericias.ListaPercias;
      listRef = removeBonusIdInRange(listRef);

      // Vantagens
      listRef = personagem.vantagens.listaVantagens;
      listRef.removeWhere((r) => r["addByPower"] && id == r["idOrigem"]); // Remove vantagens adicioadas por poderes
      listRef = removeBonusIdInRange(listRef);

  }

}

//# Classe de Manipulação de Habilidades
class ManipulaHabilidades{
  List listHab = [];
  
  ManipulaHabilidades(){
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
  void reInit(jsonHabilidades){
    listHab = jsonHabilidades;
  }

  Habilidade getIndex(int index){
    Map obj = listHab[index];
    Habilidade habilidade = Habilidade();
    habilidade.initObject(obj);
    return habilidade;
  }

  int calculaTotal(){
    Habilidade instanciaHab = Habilidade();
    int totalHabi = 0;
    for(Map hab in listHab){
      instanciaHab.initObject(hab);
      totalHabi += instanciaHab.custoTotal();
    }
    return totalHabi;
  }
}

//# Classe de Manipulação de Habilidades
class ManipulaDefesas{
  List listaDefesas = [];

  ManipulaDefesas(){
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
  init(){

  }

  void reInit(jsonDefeas){
    listaDefesas = jsonDefeas;
  }

  int calculaTotal(){
    int total = 0;
    for(Map mapDefesa in listaDefesas){
      Defesa defesa = Defesa();
      defesa.init(mapDefesa);
      total += defesa.custoTotal();
    }
    return total;
  }
}

//# Classe de Manipulação de Poderes
class ManipulaPoderes{
  //Classe de Poderes

  List poderesLista = []; 

  void reInit(jsonPoderes){
    poderesLista = jsonPoderes as List;
  }

  novoPoder(nome, id, classe) async{    
    /*
      inicialização das classes de efeito
      selecionadas pela primeira vez (Provavelmente no add poder)
      
      Arg:
        String nome   | nome escolhido para a classe
        String id     | id de identificação do efeito
        String classe | indicador de Classe de manipulação
    */

    // Cria um novo Efeito
    Efeito poder;
    switch (classe) {
      case "EfeitoCrescimento":
        poder = EfeitoCrescimento();
        break;
      case "EfeitoBonus":
        poder = EfeitoBonus();
        break;
      case "EfeitoAflicao":
        poder = EfeitoAflicao();
        break;
      case "EfeitoDano":
        poder = EfeitoDano();
        break;
      case "EfeitoCompra":
        poder = EfeitoCompra();
        break;
      case "EfeitoCustoVaria":
        poder = EfeitoCustoVaria();
        break;
      case "EfeitoOfensivo":
        poder = EfeitoOfensivo();
        break;
      case "Efeito":
      default:
        poder = Efeito();
        break;
    }
    await poder.instanciarMetodo(nome, id);
    Map objPoder = poder.retornaObj();
    poderesLista.add(objPoder);
  }

  novoPacote(nome, tipo, efeito){
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
      "removivel": 0,
    });

    Map objPackge = pacote.retornaObj();
    poderesLista.add(objPackge);

    
  }

  List<dynamic> listaDePoderes(){
      Map poder = {};
      List poderes = [];
      
      for(poder in poderesLista){
        if(poder["class"] != "PacotesEfeitos"){
        poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "graduacao": poder["graduacao"],
          "class": poder["class"]
          
        });
        }else{
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

  Future<Efeito> instanciaPoder(Map mapPoder) async{
    /*
      Efetua a Instancia do poder e retorna com o 
      respectiva classe alvo
      
      Arg:
        Map mapPoder |  o objeto de inicialização do poder
      Return:
        Objeto Efeito ou qualquer filho de acordo com o objeto
    */

    Efeito poder;
    switch (mapPoder["class"]) {
      case "EfeitoCrescimento":
        poder = EfeitoCrescimento();
        break;
      case "EfeitoBonus":
        poder = EfeitoBonus();
        break;
      case "EfeitoAflicao":
        poder = EfeitoAflicao();
        break;
      case "EfeitoDano":
        poder = EfeitoDano();
        break;
      case "EfeitoCompra":
        poder = EfeitoCompra();
        break;
      case "EfeitoCustoVaria":
        poder = EfeitoCustoVaria();
        break;
      case "EfeitoOfensivo":
        poder = EfeitoOfensivo();
        break;
      case "Efeito":
      default:
        poder = Efeito();
        break;
    }

    poder.instanciarMetodo(mapPoder["nome"], mapPoder["e_id"]);

    return poder;
  }
}

//# Classe de manipulação de Perícias
class ManipulaVantagens{
  List<Map> listaVantagens = [];

  void reInit(jsonVantagens){
    listaVantagens = [];
    for(Map v in jsonVantagens){ listaVantagens.add(v); }
  }

  int cutoTotal(){
    // calcula o custo total das vantagens
    int totalCusto = 0;
    for (Map v in listaVantagens){
      Vantagem currentVantagem = Vantagem();
      currentVantagem.init(v);

      totalCusto += currentVantagem.returnTotalCusto();
    }

    return totalCusto;
  }
}
//# Classe de manipulação de Perícias
class ManipulaPericias{
  List<Map> ListaPercias = [];

  //Armazena Pericias Ofensivas
  List ListOfensive = [];

  Future<int> init() async{
    /*
      instancia a lista de pericias armazenadas
    */
    String jsonEfeitos = await rootBundle.loadString('assets/pericias.json');
    List objetoJson = jsonDecode(jsonEfeitos);

    if(ListaPercias.isEmpty){ // Em caso de reinicio rápido
      for(Map oPericia in objetoJson){
        Pericia pericia = Pericia();
        pericia.init(oPericia);

        ListaPercias.add(pericia.returnObj());
      }
    } 
    return 1;
  }

  void reInit(jsonPericias){
    ListaPercias = [];


    if(ListaPercias.isEmpty){ // Em caso de reinicio rápido
      for(Map oPericia in jsonPericias){
        Pericia pericia; 

        oPericia["classe"] == "PericiaAddAcerto"
          ? pericia = PericiaAddAcerto()
          : pericia = Pericia();

        pericia.init(oPericia);

        ListaPercias.add(pericia.returnObj());
      }
    } 
  }

  int calculaTotal(){
    int total = 0;
    for(Map p in ListaPercias){
      total += int.parse("${p["valor"]}");
    }

    return ( total / 2 ).ceil();
  }
  
  List returnOfensiveEfeitos(int distancia){
    /*
      retorna uma lista de poderes compativeis com a 
      perícias, e realoca a lista de poderes se alterados

      - Args;
        - int distancia : 0 retornar tudo, 1 para perto, 2 para distância
        - Return: List<Map>: Retorna a Lista de poderes compativeis com acerto
    */
    List poderes = personagem.poderes.poderesLista;
    List poderesFilter = [];
    //; Poderes ofensivos e Sendo perto ou a distância
    List mapPoderes = poderes.where((p)=>
      // Efeitos Ofensivos nativos
      (["EfeitoAflicao", "EfeitoOfensivo", "EfeitoDano"].contains(p["class"])
      
      // OU: Efeitos Convetidos em Ofensivo
      || p["defAtaque"] == true)
      
      // E: Alance sendo pero ou a ditância
      && [1, 2].contains(p["alcance"])
    ).toList();

    for(int i=0; i < mapPoderes.length; i++){
      // Apenda de acordo com o Range
      if(distancia == 0 || distancia == mapPoderes[i]["alcance"]){
        poderesFilter.add(mapPoderes[i]);
      }
      
    }

    // Adiciona Desarmado (Perto)
    if(distancia == 1){
      poderesFilter.add({
        "nome": "Desarmado",
        "noPower": true,
        "efeito": "Força",
        "idCriacao": "F1"
      });
    }
    
    // Adicona Aremeço (a Distância)
    if(distancia == 2){
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
class Ficha{
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

  Future<int> init() async{
    await pericias.init();

    return 1;
  }

  Future<int> reInit(Map jsonReInit) async{
    nomePersonagem = jsonReInit["pesonagem"]["nome"];
    np = jsonReInit["pesonagem"]["np"];

    habilidades.reInit(jsonReInit["habilidades"]);
    defesas.reInit(jsonReInit["defesas"]);
    poderes.reInit(jsonReInit["poderes"]);
    pericias.reInit(jsonReInit["pericias"]);
    vantagens.reInit(jsonReInit["vantagens"]);

    complicacoes = jsonReInit["complicacoes"].toList();

    return 1;
  }


  Map returnObjJson(){

    return {
      "pesonagem":{
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