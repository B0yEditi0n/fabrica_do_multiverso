class Pericia{
  String id = "";
  String nome = "";
  String _idHabilidadeBase = "";
  int valor = 0;
  bool _apenasTreinado = false;
  
  init(obj){
    id    = obj["id"];
    nome  = obj["nome"];
    _idHabilidadeBase = obj["idHab"];
    _apenasTreinado = obj["treinado"];
    if(obj["valor"] != null){
      valor = obj["valor"];
    }
  }

  int setValor(){
    return ( valor / 2 ).ceil();
  }
  int calculaBonusTotal(){
    /*
      Calcula Bonus Total somando o valor
      da perícias e habilidade
      - Parms:
        - Return int // Valor total somado
    
    */
    return 0;
  }

  Map returnObj(){
    return({
      "id": id,
      "nome": nome,
      "valor": valor,
      "idHab": _idHabilidadeBase,
      "treinado": _apenasTreinado,
    });
  }

}

class PericiaAdiciona extends Pericia{
  List listEfeitos = [];
  bool range = false;
  String escopo = "";

  addEfeitosOfensivos(int index){
    /*
      adiciona a lista de bonus um efeito da lista de efeitos
    */
  }

  Map returnEfeitos(){
    /*
      retorna uma lista de efeitos compativeis com a 
      perícias
    */

    return {};
  }

  @override 
  Map returnObj(){
    return({
      "id": id,
      "nome": nome,
      "idHab": _idHabilidadeBase,
      "treinado": _apenasTreinado,
      "list": listEfeitos,
      "escopo": escopo,
      "range": range,
    });
  }
}