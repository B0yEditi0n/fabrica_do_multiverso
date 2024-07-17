import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart' ;

class Poderes{
  //Classe de Poderes

  List efeitos = []; 

  novoPoder(nome, id) async{    
    // Cria um novo Efeito
    var poder = Efeito();
    await poder.instanciarMetodo(nome, id);
    efeitos.add(poder);
    return 1;
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
  var poder = Poderes();
}
