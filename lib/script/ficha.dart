import 'package:fabrica_do_multiverso/screens/poderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

class controlPoderes{
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
      "removivel": 0,
    });

    Map objPackge = pacote.retornaObj();
    poderesLista.add(objPackge);

    
  }

  List<dynamic> listaDePoderes(){
      Map poder = {};
      List poderes = [];
      
      for(poder in poderesLista){
        if(poder["classe_manipulacao"] != "classe_manipulacao"){
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
          //"graduacao": poder["graduacao"],
          "classe_manipulacao": poder["classe_manipulacao"]
          
        });
      }
    }
    return poderes;
  }
}

class Ficha{
  String nomePersonagem = '';

  // Habilidades
  List<Object> Habilidades = [
    {"FOR": 0},
    {"VIG": 0},
    {"AGI": 0},
    {"DES": 0},
    {"LUT": 0},
    {"INT": 0},
    {"PRO": 0},
    {"PRE": 0}
  ];

  List<Object> Defesas =[
    {"Esquiva": 0},
    {"Aparar": 0},
    {"Fortitude": 0},
    {"Vontade": 0},
  ];

  List<String> complicacoes = [];

  // Instancia Poderes
  var poderes = controlPoderes();
}

var personagem = Ficha();