class Vantagem {
  String id = "";
  String nome = "";
  bool desc = false;  
  bool graduado = false;

  // Especifico
  String txtDec = ""; // texto inputado pelo usuário
  int _graduacao = 0;
  int limite = 0;

  String idOrigem = ''; // ID do Poder criador
  bool addByPower = false; // Adicionado por poder?
  List bonus = []; // vantagem adicionada por bonus

  List alvoBonus = []; // alvo de bonus da vantagem


  init(obj){
    id = obj["id"];
    nome = obj["nome"];
    graduado = obj["graduado"];
    desc = obj["desc"];

    //; Atributos Especificos
    if(obj["graduacao"] != null){
      _graduacao = obj["graduacao"];
    }
    if(obj["limite"] != null){
      limite = obj["limite"];
    }
    if(obj["txtDec"] != null){
      txtDec = obj["txtDec"];
    }

    if(obj["alvo_bonus"] != null){
      //bonus.addAll();
      alvoBonus.addAll(obj["alvo_bonus"].map((e) => e.toString() ).toList());
    }

    if(obj["idOrigem"] != null){idOrigem = obj["idOrigem"];}
    if(obj["addByPower"] != null){ addByPower = true; }
    if(obj["bonus"] != null){bonus.addAll(obj["bonus"]);}
  }

  int returnTotalGrad(){
    int totalBonus = 0;
    for (Map b in bonus){
      totalBonus += b["valor"] as int;
    }

    return _graduacao + totalBonus;
  }

  int returnTotalCusto(){
    // Bonus abatem o custo.
    return _graduacao;

  }

  Map returnObj(){
    return{
      "id": id,
      "nome": nome,
      "desc": desc,
      "txtDec": txtDec,
      "graduado": graduado,
      "graduacao": _graduacao,
      "limite": limite,
      "idOrigem": idOrigem,
      "bonus": bonus,      
      "addByPower" : addByPower,
      "alvo_bonus": alvoBonus,
      "class": "Vantagem",
    };
  }
}