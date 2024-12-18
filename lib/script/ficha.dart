import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Biblioteca de Load files
import 'dart:convert';                  // Biblitoeca de conversão de json

// Bibliotecas
import 'package:fabrica_do_multiverso/script/defesas/lib_defesas.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
import 'package:fabrica_do_multiverso/screens/defesas/ScreenDefesas.dart';
//import 'package:fabrica_do_multiverso/screens/screenPoderes/controlePoderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

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
      // if(!["F1", "F2"].contains(ofensivo["idCriacao"])){
      //   print(ofensivo);

      // }
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
        for(Map r in getList){
          r["bonus"].removeWhere((b)=>b["idOrigem"] == id);
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
        if(poder["classe_manipulacao"] != "PacotesEfeitos"){
        poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "graduacao": poder["graduacao"],
          "classe_manipulacao": poder["classe_manipulacao"]
          
        });
        }else{
        poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "classe_manipulacao": poder["classe_manipulacao"]
          
        });
      }
    }
    return poderes;
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