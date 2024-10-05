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