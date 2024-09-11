import 'package:fabrica_do_multiverso/script/defesas/defesas.dart';
import 'package:fabrica_do_multiverso/script/habilidades/habilidades.dart';
import 'package:fabrica_do_multiverso/screens/defesas/defesas.dart';
//import 'package:fabrica_do_multiverso/screens/screenPoderes/controlePoderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

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
      print(hab);
      instanciaHab.initObject(hab);
      totalHabi += instanciaHab.total();
    }
    return totalHabi;
  }
}

class ManipulaDefesas{
  List listaDefesas = [];

  ManipulaDefesas(){
    Defesa esquiva = Defesa();
  }
}

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

class Ficha{
  String nomePersonagem = '';

  // Instancia da Ficha
  ManipulaPoderes poderes = ManipulaPoderes();
  ManipulaHabilidades habilidades = ManipulaHabilidades();
  ManipulaDefesas defesas = ManipulaDefesas();

  List<String> complicacoes = [];
}

Ficha personagem = Ficha();