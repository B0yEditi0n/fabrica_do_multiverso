import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart' ;

class controlPoderes{
  //Classe de Poderes

  List poderesLista = []; 

  novoPoder(nome, id) async{    
    // Cria um novo Efeito
    var poder = Efeito();    
    await poder.instanciarMetodo(nome, id);
    Map objPoder = poder.retornaObj();
    poderesLista.add(objPoder);
    return 1;
  }

  List<dynamic> listaDePoderes(){
    //? Texte Poder
      //? Chamada de da classe de poderes
      Map poder = {};
      List poderes = [];
      
      for(poder in poderesLista){

        poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "graduacao": poder["graduacao"],
        });
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