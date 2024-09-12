import 'package:flutter/services.dart'; 
import 'dart:convert';

// Bibliotecas
import 'package:fabrica_do_multiverso/script/defesas/defesas.dart';
import 'package:fabrica_do_multiverso/script/habilidades/habilidades.dart';
import 'package:fabrica_do_multiverso/screens/defesas/defesas.dart';
//import 'package:fabrica_do_multiverso/screens/screenPoderes/controlePoderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

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
      totalHabi += instanciaHab.total();
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
      "bonus": 0,
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
      "bonus": 0,
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
      "bonus": 0,
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
      "bonus": 0,
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
      "bonus": 0,
      "idHabi": "PRO",
      "idOpDefesa": "D003",
      "imune": false
    });
    listaDefesas.add(vontade.returnObj());
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
          "efeitos": poder["efeitos"],
          "classe_manipulacao": poder["classe_manipulacao"]
          
        });
      }
    }
    return poderes;
  }
}


//# Classe de Manipulação de Ficha
// esse metodo será acessível para todos
// para manipulação
class Ficha{
  String nomePersonagem = '';
  int np = 10;

  // Instancia da Ficha
  ManipulaPoderes poderes = ManipulaPoderes();
  ManipulaHabilidades habilidades = ManipulaHabilidades();
  ManipulaDefesas defesas = ManipulaDefesas();

  List<String> complicacoes = [];
}

Ficha personagem = Ficha();