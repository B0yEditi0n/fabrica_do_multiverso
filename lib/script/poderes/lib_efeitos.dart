import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

// intercambio
import 'package:fabrica_do_multiverso/script/intercambio/intercambio.dart'; 
class Efeito{
  String nome = '' ;
  String _nomeEfeito = '';
  String _idEfeito = '';
  int _graduacao = 0;

  int _acao = -1;    // 0 - Nenhuma | 1 - Padrao | 2 - Movimento | 3 - Livre | 4 - Reação
  int _alcance = -1; // 0 - Pessoal | 1 - Perto | 2 - A Distância | 3 - Percepção | 4 - Graduação
  int _duracao = -1; // 0 - Permente | 1 - Instantanêo | 2 - Concentração | 3 - Sustentado | 4 - Contínuo 

  bool defAtaque = false;
  String desc = '';

  Map _padraoEfeito = {};
  //Map get padraoEfeito => _padraoEfeito;
  var _modificador = [];
  
  //*************************** */
  // Methodos de Inicialização 
  //*************************** */
  Future<bool> instanciarMetodo(String nome , String idEfeito) async{
    /*
      Carrega os atributos básicos do efeito 
      o algoritimo que o chamar precisa usar await
      para carregar o json

      Args:
        nome     - nome do poder a ser dados
        idEfeito - id do efeito a ser inserido
      Return:
        Map Json - o Arquivo json
    */
    
    this.nome = nome;
    _idEfeito = idEfeito;

    // carrega json Base e preenche atributos do objeto
    var efeitos = await carregaJson();

    int index = efeitos.indexWhere((efeito) => efeito["e_id"] == idEfeito);
    Map efeitoAtual = efeitos[index];
    
    
    _padraoEfeito = efeitoAtual;
    _nomeEfeito = efeitoAtual["efeito"];
    _acao       = efeitoAtual["acao"];
    _alcance    = efeitoAtual["alcance"];
    _duracao    = efeitoAtual["duracao"];
    _graduacao   = 1;

    return true;
  }
  Future<bool> reinstanciarMetodo(Map objPoder) async{
    /*
      Carrega os atributos básicos do efeito 
      o algoritimo que o chamar precisa usar await
      para carregar o json

      Args:
        objPoder - Map json de para instanciar atributos
        
      Return:
        Map Json - o Arquivo json
    */

    nome = objPoder["nome"];
    _idEfeito = objPoder["e_id"];
    _graduacao = objPoder["graduacao"];
    _acao = objPoder["acao"];
    _alcance = objPoder["alcance"];
    _duracao = objPoder["duracao"];
    _modificador = objPoder["modificadores"];
    defAtaque = objPoder["defAtaque"];
    desc = objPoder["descricao"];

    List efeitos = await carregaJson();
    Map efeitoAtual = efeitos[efeitos.indexWhere((efeito) => efeito["e_id"] == objPoder["e_id"])];

    _nomeEfeito = efeitoAtual["efeito"];
    _padraoEfeito = efeitoAtual;

    return true;
  }

  Future carregaJson() async{
    /*
      carrega qualquer arquivo json necessário dentro do projeto

      Args:
        String json - nome do arquivo sem extensão
      Return:
        Map Json - o Arquivo json
    */
    
    var jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    var objetoJson = jsonDecode(jsonEfeitos);
    return(objetoJson);

  }

  
  //? Modificações de atributos Classe 
  
  alteraDuracao(novaDuracao){
    /* 
      o metodo apenas avaiará qual alterações mecanicamente são permitidas
      ele não calculará custo isso fica a cargo do CustearAlteracoes

      Args:
        int novaDuracao - um valor a ser definido em duração

    */ 
    var duracaoPadrao = _padraoEfeito["duracao"];
    switch (duracaoPadrao) {
      case 1 || 2: 
        // Instantaneo ou Concentração
        if([1, 2].contains(novaDuracao)){
          _duracao = novaDuracao;
        }          
        break;
      
      case 0 || 3 || 4:
        // Permanente Sustentado Continuo Reação
        if([0, 2, 3, 4].contains(novaDuracao)){
          _duracao = novaDuracao;
          // Alerar de Sustentado pra continuo implica na alteração da ação
          switch (novaDuracao) {
            case 3 || 4:
              _acao = 3;  
              break;
            case 0:
              _acao = 0;
              break;
            case 2:
              _acao = 1;
              break;
          }
        }        
    }

  }
  alteraAcao(novaAcao){
    /* 
      avalia alterações de ação disponiveis do efeito

      Args:
        int novaAcao - um valor a ser definido em duração

    */ 
    var acaoPadrao = _padraoEfeito["acao"];
    switch (acaoPadrao){
      //case 0:
      /* não pode pode case 0 pois isso é alterdação
       * de sustentado para permanente e vice-versa */
      case 1: 
        // Padrão
        if([1, 4].contains(novaAcao)){
          _acao = novaAcao;
        }          
        break;
      case 2:
        // Movimento
        if([1, 2].contains(novaAcao)){
          _acao = novaAcao;
        }        
        break;
      case 3 || 4:
        // Livre ou Reação
        if([1, 2, 3, 4].contains(novaAcao)){
          _acao = novaAcao;
        }        
        break;     
    }
  }

  alteraAlcance(novoAlcance){
    /* 
      avalia alterações de Alcance disponiveis do efeito

      Args:
        int novaDuracao - um valor a ser definido em duração

    */ 
    var alcancePadrao = _padraoEfeito["alcance"];
    switch (alcancePadrao){
      case 0:
        // Pessoal
        if([0, 1, 2, 3].contains(novoAlcance)){
          _alcance = novoAlcance;
        }
        break;
      case 1 || 2 || 3:
        // Perto, a Distânca, Percepção
        if([1, 2, 3].contains(novoAlcance)){
          _alcance = novoAlcance;
        }
        break;
    }

  }

  void setGrad(valor){
    _graduacao = valor;
  }
  addModificador(objModificador){
    if(objModificador["grad"] == null){
      objModificador["grad"] = 1;
    }
    int index = -1;
    index = _modificador.indexWhere((mod) => mod["m_id"] == objModificador["m_id"]);    

    if(index < 0){
      _modificador.add(objModificador);
    }    
  }
  
  delModificador(m_id){
    int index = _modificador.indexWhere((mod) => mod["m_id"] == m_id);
    _modificador.removeAt(index);
  }

  setDescMod(m_id, text){
    int index = _modificador.indexWhere((mod) => mod["m_id"] == m_id);
    _modificador[index]["text_desc"] = text;
  }

  definirComoAtaque(bool eAtaque){
    if(_padraoEfeito["alcance"] == 0 && eAtaque){
      _acao = 1;
      _alcance = 1;
      defAtaque = true;
    }else{
      _acao = _padraoEfeito["acao"];
      _alcance = _padraoEfeito["alcance"];
      defAtaque = false;

    }
  }

  // ********************************
  // * Methodos de Retorno do objto *
  // ********************************

  int custearAlteracoes(){
    /*
      Processa o custo de alterações feitas em (Ação, Duração e Alcance)  
      Returns: Valor do Custo total calculado
    */

    // contabilizando alterações do efeitos
    int dfAcao = _padraoEfeito["acao"];
    int dfAlcance = _padraoEfeito["alcance"];
    int dfDurcao = _padraoEfeito["duracao"];
    
    
    
    // - Ação    
    int custoAcao = 0;
    if(!defAtaque){ 
      // Pra maioria das vezes funciona
      if([1, 2, 3, 4].contains(dfAcao) && _duracao != 2){
        custoAcao = _acao - dfAcao;
      }else if(dfAcao == 0 && _duracao != 2){ // Ação Permamente tem o mesmo custo de livre
        
        if(_acao != 0){
          custoAcao = _acao - 3;
        }        
      }else{ // Caso permanente
        custoAcao = _acao - 1; // Presupoem que o custo vem apartir de concentração
      }
      
    }else{
      // Caso setado como ataque ignora o custo da ação default
      custoAcao = _acao - 1; 
    }
    
    // - Alcance
    int custoAlcance = 0;
    if([0, 1, 2, 3].contains(dfAlcance) && !defAtaque){
      custoAlcance = _alcance - dfAlcance;
    }else{
      // Caso setado como ataque ignora o custo do alcance default
      custoAlcance = _alcance - 1;
    }

    // - Duração
    int custoDurcao = 0;
    switch (dfDurcao) {
      case 0 || 3: // Permanente ou Sustentado
        if(_duracao == 4){
          custoDurcao = 1;
        }else if(_duracao == 2){
          custoDurcao = -1;
        };  
        break;
      case 1: // Instaneo
        if(_duracao == 2){
          custoDurcao = 1;
        }
        break;
    }

    // - Soma dos Modificadores
    var custoModGrad = 0;
    var custoModfixo = 0;
    for(var mod in _modificador){
      if(mod["fixo"]){
        // Custo fixo
        custoModfixo = (mod["grad"] * mod["custo_base"]) + custoModfixo;
      }else{
        // Custo por graduação
        custoModGrad = (mod["grad"] * mod["custo_base"]) + custoModGrad;
      }
    }

    // Finalizar custeio
    int custoBase = 0;
    if(_padraoEfeito["custo_base"] != null){ // Caso algum filho com custo variado
      int custoBase = _padraoEfeito["custo_base"];
    }    
    int custoPorG = custoBase + custoAcao + custoDurcao + custoAlcance + custoModGrad;

    int custoFinal = 0;

    // custo por graduação
    if(custoPorG >= 1){
      custoFinal = _graduacao * custoPorG;
    }else{
      // 1 para varios
      custoFinal = ( _graduacao / ( custoPorG.abs() + 2 ) ).ceil();
    }

    // Calculo de fixos
    custoFinal += custoModfixo;

    // Não pode ser 0
    if(custoFinal < 1){
      custoFinal = 1;
    }

    return custoFinal;
  }

  Map returnObjDefault() {
    return _padraoEfeito;
  }

  String returnStrAcao(){
    String txtAcao = '';
    switch(_acao){
      
      case 0:
        txtAcao    = 'Nenhuma';
        break;
      case 1:
        txtAcao    = 'Padrão'; 
        break;
      case 2:
        txtAcao    = 'Movimento'; 
        break;
      case 3:
        txtAcao    = 'Livre'; 
        break;
      case 4:
        txtAcao    = 'Reação';
        break;
    }
    return txtAcao;
  }

  String returnStrAlcance(){
    String txtAlcance = '';
    
    switch(_alcance){
      case 0:
        txtAlcance  = "Pessoal";
        break;
      case 1:
        txtAlcance  = "Perto";
        break;
      case 2:
        txtAlcance  = "A Distância";
        break;
      case 3:
        txtAlcance  = "Percepção";
        break;
      case 4:
        txtAlcance  = "Graduação";
        break;
    }

    return txtAlcance;
  }

  String returnStrDuracao(){
    String txtDuracao = '';
    
    switch(_duracao){
      case 0:
        txtDuracao = "Permanente";
        break;
      case 1:
        txtDuracao = "Instantanêo";
        break;
      case 2:
        txtDuracao = "Concentração";
        break;
      case 3:
        txtDuracao = "Sustentado";
        break;
      case 4:
        txtDuracao = "Contínuo";
        break;
    }

    return txtDuracao;
  }

  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return{
      "nome":             nome,
      "e_id":             _idEfeito,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "class":            _padraoEfeito["classe_manipulacao"],
      "custo":            custearAlteracoes(),
    };
  }

}

class EfeitoEscolha extends Efeito{
  EfeitoEscolha(): super();

  bool _compraUnica = false;
  List opt = [];
  
  // Implementação dos Construtores para os atributos adicionais
  @override
  Future<bool> reinstanciarMetodo(Map objPoder) async{
    super.reinstanciarMetodo(objPoder);
    if(objPoder["opt"] != null){
      opt = objPoder["opt"];
    }
    if(_padraoEfeito["unico"] != null){
      _compraUnica = _padraoEfeito["unico"];
    }
    return true;
  }

  @override
  Future<bool> instanciarMetodo(String nome , String idEfeito)  async{
    super.instanciarMetodo(nome, idEfeito);
    
    if(_padraoEfeito["unico"] != null){
      _compraUnica = _padraoEfeito["unico"];
    }
    return true;
  }

  // Metodos de tratamento do atributo OPT de escolha do efeito
  addOpt(Map option){
    if(_padraoEfeito["unico"]){ // apenas um unico efeito
      if(opt.length > 0){
        opt = [];
      }
    }

    opt.add(option);
    // Atualiza Grad
      optsetCusto();
    
  }

  optsetCusto(){
    // Implementado para ser utilizado com @override

    // Efeitos de compra implementam a graduação 
    // Efeitos de alteração de custo o custo base
  }

  setOptDesc(m_id, text){
    int index = opt.indexWhere((option) => option["ID"] == m_id);
    opt[index]["text_desc"] = text;
  }

  rmOpt(id){
    int index = opt.indexWhere((option) => option["ID"] == id);
    opt.removeAt(index);
    // Atualiza Grad
    optsetCusto();
  }

  
  List returnListOpt(){
    // Evitas retornos duplicadoss
    List optionList = [];
    for (Map option in _padraoEfeito["opt"]){
      int i = opt.indexWhere((optio) => optio["ID"] == option["ID"]);
      if(i == -1){ 
        // evita que adicione opoções já adicionadas
        optionList.add(option);
      }      
    }
    return optionList;
  }

  @override 
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return{
      "nome":             nome,
      "e_id":             _idEfeito,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "opt":              opt,
      "class":            "EfeitoEscolha",
      "custo":            custearAlteracoes(),
    };
  }
}

class EfeitoCompra extends EfeitoEscolha{
  /* Efeito de Escolha Define a Graduação e o custo é fixo */
  @override 
  optsetCusto(){
    _graduacao = 0;
    for(Map option in opt){
      int valor = option["valor"];
      _graduacao += valor;
    }
    
  }
}

class EfeitoCustoVaria extends EfeitoEscolha{
  /* Efeito de Escolha Define a o custo base e a graduação é definida*/
  @override 
  optsetCusto(){
    int custoBase = 0;
    _padraoEfeito["custo_base"] = 0;
    
    for(Map option in opt){
      int valor = option["valor"];
      custoBase += valor;
    }

    _padraoEfeito["custo_base"] = custoBase;
  }
}

//# classe Ofensiva
class EfeitoOfensivo extends Efeito{
  int _bonusAcerto = 0;
  int _critico = 0;
  // Bonus de Efeito vindo de outros lugares
  List bonus = [];
  // Implementação dos Construtores para os atributos adicionais
  @override
  Future<bool> reinstanciarMetodo(Map objPoder) async{
    super.reinstanciarMetodo(objPoder);    
    if(objPoder["acerto"] != null){
      _bonusAcerto = objPoder["acerto"];
    }

    if(objPoder["bonus"] != null){
      bonus = objPoder["bonus"];
    }
    
    return true;
  }

  void addBonus(bonus){
    if(_alcance != 3){ // Alacance a Percepão
      _bonusAcerto = bonus;
    }    
  }

  int bonusAcerto(){return _bonusAcerto;}

  int getCritico(){
    /*
      contabiliza o critico total 
    */
    int bCritico = int.parse("${bonus.where((b) => b["alvo"] == "critico")}");
    return bCritico + _critico;
  }
  
  void defineCritic(int crit){ 
    // checa se ah bonus na lista
    if(getCritico() + crit <= 4){
      _critico = crit;
    }    
  }

  @override
  int custearAlteracoes(){
    /*
      Processa o custo de alterações feitas em (Ação, Duração e Alcance)  
      Returns: Valor do Custo total calculado
    */

    // contabilizando alterações do efeitos
    int dfAcao = _padraoEfeito["acao"];
    int dfAlcance = _padraoEfeito["alcance"];
    int dfDurcao = _padraoEfeito["duracao"];
    
    // - Ação    
    int custoAcao = _acao - dfAcao;
    
    // - Alcance
    int custoAlcance = _alcance - dfAlcance;
  
    // - Duração
    int custoDurcao = _duracao - dfDurcao;

    // - Soma dos Modificadores
    var custoModGrad = 0;
    var custoModfixo = 0;
    for(var mod in _modificador){
      if(mod["fixo"]){
        // Custo fixo
        custoModfixo = (mod["grad"] * mod["custo_base"]) + custoModfixo;
      }else{
        // Custo por graduação
        custoModGrad = (mod["grad"] * mod["custo_base"]) + custoModGrad;
      }
    }

    // Incrementa valores de acurado e impreciso
    custoModfixo += ( _bonusAcerto / 2 ).ceil();

    // Finalizar custeio
    int custoBase = _padraoEfeito["custo_base"];
    int custoPorG = custoBase + custoAcao + custoDurcao + custoAlcance + custoModGrad;

    int custoFinal = 0;

    // custo por graduação
    if(custoPorG >= 1){
      custoFinal = _graduacao * custoPorG;
    }else{
      // 1 para varios
      custoFinal = ( _graduacao / ( custoPorG.abs() + 2 ) ).ceil();
    }

    // Calculo de fixos
    custoFinal += custoModfixo;

    // Não pode ser 0
    if(custoFinal < 1){
      custoFinal = 1;
    }

    return custoFinal;
  }

  processaBonus(){
    /*
      Contabiliza o Bonus Inserido dentro do efeito
    */
  }

  @override
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return{
      "nome":             nome,
      "e_id":             _idEfeito,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "class":            "EfeitoOfensivo",
      "bonus":            bonus,
      "critico":          _critico,
      "acerto":           _bonusAcerto,
      "cd":               (_graduacao + 10),
      "custo":            custearAlteracoes(),
      
    };
  }

}

//# classe Dano

class EfeitoDano extends EfeitoOfensivo{
  @override
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return{
      "nome":             nome,
      "e_id":             _idEfeito,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "class":            _padraoEfeito["classe_manipulacao"],
      "bonus":            bonus,      
      "critico":          _critico,
      "acerto":           _bonusAcerto,
      "cd":               (_graduacao + 15),
      "custo":            custearAlteracoes(),
      
    };
  }
}

//# classe Aflição
class EfeitoAflicao extends EfeitoOfensivo{
  Map<int, String> _condicoes = {
    1: "",
    2: "",
    3: ""
  };

  @override
  Future<bool> reinstanciarMetodo(Map objPoder) async{
    super.reinstanciarMetodo(objPoder);    
    if(objPoder["acerto"] != null){
      _condicoes = objPoder["condicoes"];
    }
    
    return true;
  }

  addCondicao(grau, txtCond){
    if([1, 2, 3].contains(grau)){
      _condicoes[grau] = txtCond;
    }
  }

  @override
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return{
      "nome":             nome,
      "e_id":             _idEfeito,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "class":            "EfeitoAflicao",
      "acerto":           _bonusAcerto,
      "bonus":            bonus,
      "critico":          _critico,
      "cd":               (_graduacao + 10),
      "condicoes":        _condicoes,
      "custo":            custearAlteracoes(),
      
    };
  }
}

class EfeitoBonus extends Efeito{
  /* 
    Apesar de semelhante a escolha a tratativa é bem
    mais estritiva em EfeitoBonus
  */

  List alvoAumento = [];
  List grupoOpt = [];
  String idCriacao = '';
  List opt = [];

  Intercambio bonusObj = Intercambio(); // objeto de inicialização

  @override
  Future<bool> instanciarMetodo(String nome , String idEfeito) async{
    /*
      Carrega os atributos básicos do efeito 
      o algoritimo que o chamar precisa usar await
      para carregar o json

      Args:
        nome     - nome do poder a ser dados
        idEfeito - id do efeito a ser inserido
      Return:
        Map Json - o Arquivo json
    */
    
    super.instanciarMetodo(nome, idEfeito);
    // P indica poder + o seu timestump
    idCriacao = "P${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}";
    bonusObj.init(idCriacao, alvoAumento);

    return true;
  }

  @override
  Future<bool> reinstanciarMetodo(Map objPoder) async{
    super.reinstanciarMetodo(objPoder);    
    if(objPoder["alvoAumento"] != null){
      alvoAumento = objPoder["alvoAumento"];
    }

    if(objPoder["idCriacao"] != null){
      idCriacao = objPoder["idCriacao"];
    }
    
    return true;
  }


  @override
  void setGrad(valor){
    /*
      ao alterar graduação de habilidade
      tamList returnListOpt(){bém irá aumentar o bonus em intercambio 
    */
    
    super.setGrad(valor);
  }

  Future<List> returnListOpt() async{
    /*
      Busca os valores de compra baseados na classe

      Param:
        String alvo: tras o nome do arquivo dentro do repósitório json
      Returns: 
        bool:  indica sucesso e fim da execução do metodo
    */

    String jsonString = await rootBundle.loadString('assets/${_padraoEfeito["grupoOpt"]}.json');    
    List objetoJson = jsonDecode(jsonString);
    return objetoJson;
  }

  
  @override
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return{
      "nome":             nome,
      "e_id":             _idEfeito,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "class":            "EfeitoBonus",
      "idCriacao":        idCriacao,
      "alvoAumento":      alvoAumento,
      "opt":              opt,
      "custo":            custearAlteracoes(),
    };
  }

}

// Variável de Manipulação de Poderes
var poder = Efeito();
