import 'dart:developer';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';

class Defesa{
  String _id = "";
  String nome = "";

  int _valor = 0;
  List bonus = [];
  String idHabi = "";

  String idOpDefesa = "";
  bool imune = false;

  init(obj){
    _id = obj["id"];
    nome = obj["nome"];
    if(obj["valor"] != null){
      _valor = obj["valor"];
    }
    
    idOpDefesa = obj["idOpDefesa"];
    imune = obj["imune"];
    idHabi = obj["idHabi"];
    if(obj["imune"] != null || obj["imune"] != true){
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
    /*
      Soma o valor da habilidade e da defesa para calcular o valor 
      total de defesa
        - returns int | total do valor da defesa
    */
    int indexHab = personagem.habilidades.listHab.indexWhere((hab)=>hab["id"] == idHabi );
    Map habi = personagem.habilidades.listHab[indexHab];

    // Bonus total
    int bonusTotal = 0; 
    for(Map b in bonus){ 
      // a sintaxe não reconhece como int, 
      // e parse int quebra caso caregado com int
      bonusTotal += int.parse("${b["valor"]}");
    }
    
    // Instacia para recuperar valor total da habilidade
    Habilidade currnetHabilidade = Habilidade();
    currnetHabilidade.initObject(habi);
    bonusTotal += currnetHabilidade.valorTotal();

    return _valor + bonusTotal;
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
  int bonusTotal(){
    int total = super.bonusTotal();

    // Inclui a Vantagem Rolamento Defensivo
    List vantagens = personagem.vantagens.listaVantagens;
    int rolamentoDefensivo = 0;
    if(vantagens.isNotEmpty){
      rolamentoDefensivo = vantagens.firstWhere((e) => e["id"] == "V077");
    }
     
    return total + rolamentoDefensivo;
  }
  @override  
  void setValor(valor){
    //; nada fazer pos não pode comprar
    //; resistência direto
  }

}

