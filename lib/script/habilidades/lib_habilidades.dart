class Habilidade{
  String _id = "";
  String nome = "";
  int valor = 0;
  List bonus  = []; // Caso venha de alguma pode ou modificador
  

  bool ausente = false;

  init(id, valor, nome){
    _id = id;
    this.valor = valor;
    this.nome = nome;
  }
  
  int initObject(object){
    _id = object["id"];
    nome = object["nome"]; 
    ausente = object["ausente"]; 
    valor = object["valor"]; 
    bonus = object["bonus"];     

    return 1;
  }

  int custoTotal(){
    /* Retorna o custo */
    if(!ausente){
      return valor * 2;
    }else{
      return -10;
    }
  }

  int valorTotal(){
    /* Retorna o bonus total */
    int bonusTotal = 0;
    for(Map b in bonus){
      bonusTotal += int.parse("${b["valor"]}");
    }

    return bonusTotal + valor;
  }

  List<int> valoresTotais(){
    /*
      Retorna uma lista de valores que esse objeto pode assumir 
      caso haja efeitos aternativos do mesmo bonus
    */

    // 1 - Analisa se há mais de um bonus com o mesmo ID de criação
    Map b;
    int index = 0;
    for(int i = 0; i < bonus.length; i++){
      b = bonus[i];

      if(bonus.any((bo) => bo["idCriacao"] == b["idCriacao"])){
        bonus[i]['index'] = index;

        int j = i;
    // 2 - Classificar por indices
        while(bonus.any( (bo) => 
          bo["idCriacao"] == b["idCriacao"] 
          && bo["index"] != null
        )){
          j++;
          if(bonus[j]["idCriacao"] == b["idCriacao"]){
            index++;
            bonus[j]["index"] = index;
          }          
        }
      }
    }

    // 3 - Checar se a herança possui lista de bonus (se Houver);

    // 4 - Retornar uma lista pra cada indice
    //  Somar não indices
    //  Somar Indices   


    return [];
  }

  Map objHabilidade(){
    return{
      "id": _id,
      "nome": nome,
      "valor": valor,
      "bonus": bonus,
      "ausente": ausente,
    };
  }

  

}