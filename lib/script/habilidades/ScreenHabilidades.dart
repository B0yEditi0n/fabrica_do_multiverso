class Habilidade{
  String _id = "";
  String nome = "";
  int valor = 0;
  int bonus  = 0; // Caso venha de alguma pode ou modificador
  

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

  int total(){
    if(!ausente){
      return valor * 2;
    }else{
      return -10;
    }
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