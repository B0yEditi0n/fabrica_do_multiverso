class Vantagem {
  String id = "";
  String nome = "";
  bool desc = false;  
  bool graduado = false;

  // Especifico
  String txtDec = ""; // texto inputado pelo usuário
  int _graduacao = 0;
  int limite = 0;
  List bonus = [];


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

    if(obj["bonus"] != null){
      //bonus.addAll();
      bonus.addAll(obj["bonus"].map((e) => e.toString() ).toList());
    }
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
      "bonus": bonus,
      "class": "Vantagem",
    };
  }
}