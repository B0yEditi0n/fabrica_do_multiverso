import 'package:fabrica_do_multiverso/script/ficha.dart';

class Pericia{
  String id = "";
  String nome = "";
  String _idHabilidadeBase = "";
  int _valor = 0;
  bool _apenasTreinado = false;
  
  bool init(obj){
    id    = obj["id"];
    nome  = obj["nome"];
    _idHabilidadeBase = obj["idHab"];
    _apenasTreinado = obj["treinado"];
    if(obj["valor"] != null){
      _valor = obj["valor"];
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
    Map mapHabilidade = personagem.habilidades.listHab.firstWhere((h)=>h["id"] == _idHabilidadeBase);
    return mapHabilidade["valor"] + _valor;
  }

  Map returnObj(){
    return({
      "id": id,
      "nome": nome,
      "valor": _valor,
      "idHab": _idHabilidadeBase,
      "treinado": _apenasTreinado,
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