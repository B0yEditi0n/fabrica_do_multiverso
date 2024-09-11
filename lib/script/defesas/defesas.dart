class Defesa{
  String _id = "";
  String nome = "";

  int valor = 0;
  int bonus = 0;
  String idHabi = "";

  String idOpDefesa = "";

  init(obj){
    _id = obj["id"];
  }

  int custoTotal(){
    return 0;
  }
  
  returnObj(){
    return{
      "id": _id,
      "nome": nome,
      "valor": valor,
      "bonus": bonus,
      "idHabi": idHabi,
      "idOpDefesa": idOpDefesa,
    };
  }
}