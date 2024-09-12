class Pericias{
  String id = "";
  String nome = "";
  String idHabilidadeBase = "";
  int valor = 0;
  
  init(obj){
    id    = obj["id"];
    nome  = obj["nome"];
    idHabilidadeBase = obj["idHab"];
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
      "idHab": idHabilidadeBase
    });
  }

}