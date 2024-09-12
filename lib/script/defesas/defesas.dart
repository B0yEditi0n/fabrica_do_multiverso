import 'package:fabrica_do_multiverso/script/ficha.dart';

class Defesa{
  String _id = "";
  String nome = "";

  int _valor = 0;
  int bonus = 0;
  String idHabi = "";

  String idOpDefesa = "";
  bool imune = false;

  init(obj){
    _id = obj["id"];
    nome = obj["nome"];
    _valor = obj["valor"];
    idOpDefesa = obj["idOpDefesa"];
    imune = obj["imune"];
    idHabi = obj["idHabi"];
    if(obj["imune"] != null && obj["imune"]){
      bonus = obj["bonus"];
    }
  }

  int custoTotal(){
    if(!imune){
      return _valor;
    }else{
      return 0;
    }    
  }
  int bonusTotal(){
    int indexHab = personagem.habilidades.listHab.indexWhere((hab)=>hab["id"] == idHabi );
    Map habi = personagem.habilidades.listHab[indexHab];
    // a sintaxe não reconhece como int, 
    // e parse int quebra caso caregado com int
    return _valor + int.parse("${habi["valor"]}") + int.parse("${habi["bonus"]}");
  }
  void setValor(valor){
    if(!imune){
      _valor = valor;
    }
  }

  setImune(bool imune){
    this.imune = imune;
    if(imune){
      _valor = 0;
    }
  }
  
  returnObj(){
    return{
      "id": _id,
      "nome": nome,
      "valor": _valor,
      "bonus": bonus,
      "idHabi": idHabi,
      "idOpDefesa": idOpDefesa,
      "imune": imune,
    };
  }
}

class Resistencia extends Defesa{
  @override
  void setValor(valor){
    //; nada fazer pos não pode comprar
    //; resistência direto
  }

}

