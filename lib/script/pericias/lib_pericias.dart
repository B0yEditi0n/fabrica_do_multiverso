import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';

class Pericia{
  String id = "";
  String nome = "";
  String _idHabilidadeBase = "";
  int _valor = 0;
  bool _apenasTreinado = false;
  List bonus = [];
  
  bool init(obj){
    id    = obj["id"];
    nome  = obj["nome"];
    _idHabilidadeBase = obj["idHab"];
    _apenasTreinado = obj["treinado"];
    if(obj["valor"] != null){
      _valor = obj["valor"];
    }

    if(obj["bonus"] != null){
      bonus = obj["bonus"];
    }
    

    return true;
  }

  setValor(int valor){
    /*
      Define o valor do Bonus da Perícia
      Args: 
        - valor int: Valor a ser subistituido
    */
    _valor = valor;
  }

  int bonusTotal(){
    /*
      Calcula Bonus Total somando o valor
      da perícias e habilidade
      - Parms:
        - Return int: Valor total somado
    */

    // Retorno do Bonus
    int totalBonus = 0;
    for (Map b in bonus){
      int currentValue = b["valor"] as int;
      totalBonus += currentValue;
    }

    // Total Habilidades
    Map mapHabilidade = personagem.habilidades.listHab.firstWhere((h)=>h["id"] == _idHabilidadeBase);
    Habilidade habilidadeObj = Habilidade();
    habilidadeObj.initObject(mapHabilidade);

    return habilidadeObj.valorTotal() + _valor + totalBonus;
  }

  Map returnObj(){
    return({
      "id": id,
      "nome": nome,
      "valor": _valor,
      "idHab": _idHabilidadeBase,
      "treinado": _apenasTreinado,
      "bonus": bonus,
      "classe": "Pericia",
    });
  }

}

//# Especialidade
class PericiaAdiciona extends Pericia{
  String escopo = "";

  @override
  bool init(obj){
    super.init(obj);

    escopo = obj["escopo"];

    return true;
  }

  @override 
  Map returnObj(){
    return({
      "id": id,
      "nome": nome,
      "valor": _valor,
      "idHab": _idHabilidadeBase,
      "treinado": _apenasTreinado,
      "escopo": escopo,
      "classe": "PericiaAdiciona",
    });
  }
}

//# Ataque
class PericiaAddAcerto extends PericiaAdiciona{
  List bonusPoderes = [];
  bool range = false;
  
  @override
  bool init(obj){
    super.init(obj);

    range = obj["range"];
    if(obj["bonusPoderes"] != null){ bonusPoderes = obj["bonusPoderes"]; }    

    return true;
  }
  // esse valor será utilzidado para indetificar onde seu bonus foi addicionado
  int _addId = 0; 
  @override
  PericiaAdiciona(){
    int _addId = DateTime.now().millisecondsSinceEpoch;
  }

  addEfeitosOfensivos(int index){
    /*
      adiciona a lista de bonus um efeito da lista de efeitos
    */
    bonusPoderes.add(index);
    personagem.validador.addBonusPericiaOfensivo(_addId, index, _valor);
  }

  @override 
  Map returnObj(){
    return({
      "id": id,
      "nome": nome,
      "valor": _valor,
      "idHab": _idHabilidadeBase,
      "treinado": _apenasTreinado,
      "bonusPoderes": bonusPoderes,
      "escopo": escopo,
      "range": range,
      "classe": "PericiaAddAcerto",
    });
  }
}