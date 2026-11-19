import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'dart:developer' as dev;

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

  String _idCriacao = "";
  String _idArranjo = "";
  
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
    const uuid = Uuid();
    _idCriacao = "P${uuid.v4()}";
    
    this.nome = nome;
    _idEfeito = idEfeito;

    // carrega json Base e preenche atributos do objeto
    List efeitos = await carregaJson();

    int index = efeitos.indexWhere((efeito) => efeito["e_id"] == idEfeito);
    Map efeitoAtual = efeitos[index];
    
    // Cópia: algumas classes alteram o custo-base e o catálogo é compartilhado
    _padraoEfeito = Map.from(efeitoAtual);
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
    await carregarCatalogo();
    carregaMapa(objPoder);
    return true;
  }

  void carregaMapa(Map objPoder){
    /*
      Preenche o objeto a partir do mapa salvo na ficha, sem efeitos
      colaterais. É síncrono: exige o catálogo já carregado
      (Efeito.carregarCatalogo), o que permite calcular custos sem await.
      As classes filhas sobrescrevem este método para seus campos próprios.
    */
    _idCriacao = objPoder["idCriacao"];
    nome = objPoder["nome"];
    _idEfeito = objPoder["e_id"];
    _graduacao = objPoder["graduacao"];
    _acao = objPoder["acao"];
    _alcance = objPoder["alcance"];
    _duracao = objPoder["duracao"];
    _modificador = objPoder["modificadores"] ?? [];
    defAtaque = objPoder["defAtaque"] ?? false;
    desc = objPoder["descricao"] ?? '';

    Map efeitoAtual = _catalogo!.firstWhere((efeito) => efeito["e_id"] == objPoder["e_id"]);

    _nomeEfeito = efeitoAtual["efeito"];
    // Cópia: algumas classes alteram o custo-base e o catálogo é compartilhado
    _padraoEfeito = Map.from(efeitoAtual);
  }

  static Efeito porClasse(String? classe){
    /*
      Único ponto que relaciona o nome da classe salvo na ficha
      com a classe de manipulação do efeito.
    */
    switch (classe) {
      case "EfeitoCrescimento":
        return EfeitoCrescimento();
      case "EfeitoBonus":
        return EfeitoBonus();
      case "EfeitoAflicao":
        return EfeitoAflicao();
      case "EfeitoDano":
        return EfeitoDano();
      case "EfeitoCompra":
        return EfeitoCompra();
      case "EfeitoCustoVaria":
        return EfeitoCustoVaria();
      case "EfeitoOfensivo":
        return EfeitoOfensivo();
      case "Efeito":
      default:
        return Efeito();
    }
  }

  static Future<Efeito> init(Map objPoder) async{
    Efeito poder = porClasse(objPoder["class"]);
    await poder.reinstanciarMetodo(objPoder);
    return poder;
  }

  static Efeito doMapa(Map objPoder){
    /*
      Versão síncrona e sem efeitos colaterais de init,
      usada pelos cálculos de custo. Exige o catálogo carregado.
    */
    Efeito poder = porClasse(objPoder["class"]);
    poder.carregaMapa(objPoder);
    return poder;
  }

  // Catálogo de efeitos, lido do JSON uma única vez
  static List? _catalogo;
  static bool get catalogoCarregado => _catalogo != null;

  static Future<List> carregarCatalogo() async{
    if(_catalogo == null){
      String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
      _catalogo = jsonDecode(jsonEfeitos);
    }
    return _catalogo!;
  }

  Future<List> carregaJson() async{
    /*
      Retorna o catálogo de efeitos (assets/poderes/efeitos.json)
    */
    return carregarCatalogo();
  }

  
  //? Modificações de atributos Classe 
  
  void alteraDuracao(novaDuracao){
    /* 
      o metodo apenas avaiará qual alterações mecanicamente são permitidas
      ele não calculará custo isso fica a cargo do CustearAlteracoes

      Args:
        int novaDuracao - um valor a ser definido em duração

    */ 
    int duracaoPadrao = _padraoEfeito["duracao"];
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
  void alteraAcao(novaAcao){
    /* 
      avalia alterações de ação disponiveis do efeito

      Args:
        int novaAcao - um valor a ser definido em duração

    */ 
    int acaoPadrao = _padraoEfeito["acao"];
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

  void alteraAlcance(novoAlcance){
    /* 
      avalia alterações de Alcance disponiveis do efeito

      Args:
        int novaDuracao - um valor a ser definido em duração

    */ 
    int alcancePadrao = _padraoEfeito["alcance"];
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
  static List<String> gruposModificadores(Efeito efeito){
    /*
      Grupos do modificadores.json que podem ser oferecidos ao efeito:
        gerais    - sempre
        ofensivos - efeitos que agem sobre um alvo (ou pessoais usados como ataque)
        pessoais  - efeitos cujo alcance padrão é pessoal
      Ação, alcance, duração e Baseado em Força não entram aqui:
      são opções do próprio efeito, não itens do catálogo.
    */
    List<String> grupos = ["gerais"];
    if(efeito is EfeitoOfensivo || efeito.defAtaque){
      grupos.add("ofensivos");
    }
    if(efeito._padraoEfeito["alcance"] == 0){
      grupos.add("pessoais");
    }
    return grupos;
  }

  static int limiteModificador(Map modificador, int graduacaoEfeito){
    /*
      Quantas graduações o modificador aceita.
        limite ausente ou 1 - compra única
        limite -1           - até a graduação do efeito (Penetrante, Dividido, Impenetrável)
        limite N            - até N
    */
    int limite = modificador["limite"] ?? 1;
    if(limite == -1){
      return graduacaoEfeito < 1 ? 1 : graduacaoEfeito;
    }
    return limite < 1 ? 1 : limite;
  }

  void addModificador(objModificador){
    if(objModificador["grad"] == null){
      objModificador["grad"] = 1;
    }
    int index = -1;
    index = _modificador.indexWhere((mod) => mod["m_id"] == objModificador["m_id"]);    

    if(index < 0){
      _modificador.add(objModificador);
    }    
  }
  
  void delModificador(m_id){
    int index = _modificador.indexWhere((mod) => mod["m_id"] == m_id);
    _modificador.removeAt(index);
  }

  void setDescMod(m_id, text){
    int index = _modificador.indexWhere((mod) => mod["m_id"] == m_id);
    _modificador[index]["text_desc"] = text;
  }

  void definirComoAtaque(bool eAtaque){
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

  String idCriacao() => _idCriacao;

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
    int custoModGrad = 0;
    int custoModfixo = 0;
    for(Map mod in _modificador){
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
      custoBase = _padraoEfeito["custo_base"];
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

  int returnGraduacao(){ return _graduacao; }

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
      "idCriacao":        _idCriacao,
      "efeito":           _nomeEfeito,
      "graduacao":        _graduacao,
      "acao":             _acao,
      "alcance":          _alcance,
      "duracao":          _duracao,
      "modificadores":    _modificador,
      "descricao":        desc,
      "defAtaque":        defAtaque,
      "class":            _padraoEfeito["class"],
      "custo":            custearAlteracoes(),
    };
  }

  void destrutor(){
    /*
      para ações no fim da fida de poderes
      interface de metodo para sofrer override
    */
  }
}

class EfeitoEscolha extends Efeito{
  EfeitoEscolha(): super();

  bool _compraUnica = false;
  List opt = [];
  
  // Implementação dos Construtores para os atributos adicionais
  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    if(objPoder["opt"] != null){
      opt = objPoder["opt"];
    }
    if(_padraoEfeito["unico"] != null){
      _compraUnica = _padraoEfeito["unico"];
    }
  }

  @override
  Future<bool> instanciarMetodo(String nome , String idEfeito)  async{
    await super.instanciarMetodo(nome, idEfeito);
    
    if(_padraoEfeito["unico"] != null){
      _compraUnica = _padraoEfeito["unico"];
    }
    return true;
  }

  // Metodos de tratamento do atributo OPT de escolha do efeito
  void addOpt(Map option){
    if(_padraoEfeito["unico"]){ // apenas um unico efeito
      if(opt.isNotEmpty){
        opt = [];
      }
    }

    opt.add(option);
    // Atualiza Grad
      optsetCusto();
    
  }

  void optsetCusto(){
    // Implementado para ser utilizado com @override

    // Efeitos de compra implementam a graduação 
    // Efeitos de alteração de custo o custo base
  }

  void setOptDesc(m_id, text){
    int index = opt.indexWhere((option) => option["ID"] == m_id);
    opt[index]["text_desc"] = text;
  }

  void rmOpt(id){
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
    Map<String, dynamic> objReturn = super.retornaObj();

    objReturn["opt"] = opt;
    objReturn["custo"] = custearAlteracoes();

    return objReturn;
  }
}

class EfeitoCompra extends EfeitoEscolha{
  /* Efeito de Escolha Define a Graduação e o custo é fixo */
  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    // A graduação é a soma das opções escolhidas (Imunidade, Movimento...).
    // Sem opções (ex.: Intangibilidade) vale a graduação salva na ficha.
    if(opt.isNotEmpty){ optsetCusto(); }
  }

  @override
  void optsetCusto(){
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
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    // O custo-base não é salvo na ficha: é refeito a partir das opções
    if(opt.isNotEmpty){ optsetCusto(); }
  }

  @override 
  void optsetCusto(){
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
  // Bonus de Efeito vindo de outros lugares
  List bonus = [];
  // Implementação dos Construtores para os atributos adicionais
  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    if(objPoder["acerto"] != null){
      _bonusAcerto = objPoder["acerto"];
    }

    if(objPoder["bonus"] != null){
      bonus = objPoder["bonus"];
    }
  }

  void addBonus(bonus){
    if(_alcance != 3){ // Alacance a Percepão
      _bonusAcerto = bonus;
    }    
  }

  int bonusAcerto(){return _bonusAcerto;}
  int totalBonusAcerto(){
    int bonusTotal = 0;
    for(Map b in bonus){
      if(b["acerto"] != null){
        bonusTotal += b["acerto"]["bonus"] as int;
      }
    }
    return _bonusAcerto + bonusTotal;
  }

  //; Margem de crítico — cálculo único usado pela Ofensiva, pelo PDF e
  //; pelo validador. Perigoso (E065) e Crítico Aprimorado ligado ao ataque
  //; somam +1 de ameaça por graduação; a soma vai até 4 (16-20) e acima
  //; disso é erro de validação (wiki Poderes/Armas.md e Vantagens.md).
  static const String idPerigoso = "E065";
  static const int limiteMelhoriaCritico = 4;

  /// Graduações de melhoria de crítico do ataque: Perigoso do poder +
  /// Crítico Aprimorado ligado a ele (ticket 3; hoje sempre 0).
  static int melhoriaCritico(Map poder, {int graduacoesVantagem = 0}){
    int total = graduacoesVantagem;
    for(Map m in poder["modificadores"] ?? []){
      if(m["m_id"] == idPerigoso) total += (m["grad"] ?? 1) as int;
    }
    return total;
  }

  /// Menor resultado do d20 que ameaça crítico (20 = sem melhoria).
  static int ameacaCritico(Map poder, {int graduacoesVantagem = 0}){
    return 20 - melhoriaCritico(poder, graduacoesVantagem: graduacoesVantagem);
  }

  /// "Crítico 18-20"; vazio quando não há melhoria.
  static String textoCritico(int ameaca){
    return ameaca < 20 ? "Crítico $ameaca-20" : "";
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

  void processaBonus(){
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
    Map<String, dynamic> objReturn = super.retornaObj();

    objReturn["bonus"] = bonus;
    objReturn["acerto"] = _bonusAcerto;
    objReturn["cd"] = (_graduacao + 10);
    objReturn["custo"] = custearAlteracoes();

    return objReturn;
  }

}

//# classe Dano

class EfeitoDano extends EfeitoOfensivo{
  bool baseadoForca = false;

  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    baseadoForca = objPoder["baseadoForca"] == true;
  }

  @override
  int custearAlteracoes(){
    int custoFinal = super.custearAlteracoes();

    if(baseadoForca){ // Subtrai o valor de força
      Habilidade objectHabilidade = Habilidade();
      objectHabilidade.initObject(
        personagem.habilidades.listHab.firstWhere((h)=>h["id"] == "FOR")
      );

      custoFinal -= objectHabilidade.valorTotal();

      // Cuidado pro valor não ser inferior a 1
      if(custoFinal < 1){
        custoFinal = 1;
      }
    }
    
    return custoFinal;
  }

  @override
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    
    Map<String, dynamic> objReturn = super.retornaObj();

    objReturn["baseadoForca"] = baseadoForca;
    objReturn["cd"] = (_graduacao + 15);
    objReturn["custo"] = custearAlteracoes();

    return objReturn;
  }
}

//# classe Aflição
class EfeitoAflicao extends EfeitoOfensivo{
  List _condicoes = [
    "",
    "",
    ""
  ];

  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    if(objPoder["condicoes"] != null){
      _condicoes = objPoder["condicoes"];
    }
  }

  void addCondicao(grau, txtCond){
    if([0, 1, 2].contains(grau)){
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

    Map<String, dynamic> objReturn = super.retornaObj();
    objReturn["condicoes"] = _condicoes;
    objReturn["custo"] = custearAlteracoes();

    return objReturn;
  }
}

class EfeitoBonus extends Efeito{
  /* 
    Apesar de semelhante a escolha a tratativa é bem
    mais estritiva em EfeitoBonus
  */

  List _alvoAumento = [];
  List grupoOpt = [];
  List opt = [];

  // Todos os efeitos são considerados sempre ativos, inclusive os
  // efeitos alternativos de um arranjo: o bônus sempre é aplicado.
  // O campo continua gravado na ficha só por compatibilidade.
  bool active = true;

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
    
    await super.instanciarMetodo(nome, idEfeito);

    return true;
  }

  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    if(objPoder["alvoAumento"] != null){
      _alvoAumento = objPoder["alvoAumento"];
    }
    if(objPoder["idArranjo"] != null){
      _idArranjo = objPoder["idArranjo"];
    }

    // Fichas antigas podem ter "active": false; o valor é ignorado
    active = true;
  }

  @override
  Future<bool> reinstanciarMetodo(Map objPoder) async{
    await super.reinstanciarMetodo(objPoder);

    // Aplica o bonus
    configBonus();
    // personagem.validador.removeBonusId(_idCriacao);
    // if(active){
    //   personagem.validador.addBonus(_alvoAumento);  
    // }
    
    
    return true;
  }

  void addBonus(Map bonus){
    int idx = _alvoAumento.indexWhere((e) => e["id"] == bonus["id"]);

    // Afim de evitar erros checa se mapa tem valor 
    if(bonus["valor"] == null){
      bonus["valor"] = 1;
    }

    bonus["idOrigem"] = _idCriacao;
    bonus["idArranjo"] = _idArranjo;
    if(idx > -1){
      _alvoAumento[idx] = bonus;
    }else{
      _alvoAumento.add(bonus);
    }
  }

  void removeIndexBonus(int index){_alvoAumento.removeAt(index);}
  List returnBonusList(){
    // Chama o incrementador 
    // Atualzia Valor do bonus
    _graduacao = 0;
    for(Map a in _alvoAumento){
      int currentValor = a["valor"];
      _graduacao += currentValor;
    }
    configBonus();    
    return _alvoAumento;
  }

  void configBonus(){
    /*
      reflete o bonus da classe para outras partes da ficha
    */

    // Limpa os bonus encontrados
    // Limpa a Saida do Bonus
    personagem.validador.removeBonusId(_idCriacao);
    // Adicioa bonus se tiver 
    if(active){
      personagem.validador.addBonus(_alvoAumento);
    }
    
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

    Map<String, dynamic> objReturn = super.retornaObj();

    objReturn["idArranjo"] = _idArranjo;
    objReturn["alvoAumento"] = _alvoAumento;
    objReturn["opt"] = opt;
    objReturn["active"] = active;
    objReturn["custo"] = custearAlteracoes();

    return objReturn;
  }

  @override
  void destrutor(){
    /*
      a função destrutor é para remover bonus incrementados
    */
    personagem.validador.removeBonusId(_idCriacao);
  }

}

class EfeitoCrescimento extends EfeitoBonus{
  List _bonusTamanho = [];

  @override
  Future<bool> instanciarMetodo(String nome , String idEfeito) async{
    await super.instanciarMetodo(nome, idEfeito);   
    _bonusTamanho = _padraoEfeito["bonusTamanho"];
    return true;
  }
  
  @override
  void carregaMapa(Map objPoder){
    super.carregaMapa(objPoder);
    _bonusTamanho = _padraoEfeito["bonusTamanho"];
  }

  @override
  List returnBonusList(){
    _alvoAumento = [];
    int valorBonus = 0;
    for(Map bonusT in _bonusTamanho){
      // Atenção para valores negativos ou positivos
      if(bonusT["multiplicador"] > 0){
        valorBonus = (_graduacao * bonusT["multiplicador"]).floor();
      }else{
        valorBonus = (_graduacao * bonusT["multiplicador"]).ceil();
      }
      
      _alvoAumento.add({
        "idOrigem": _idCriacao,
        "idArranjo": _idArranjo,
        "id": bonusT["alvo"],
        "valor": valorBonus,
        "nome": bonusT["nome"],
      });
    }

    // Chama o incrementador 
    if(active){
      personagem.validador.addBonus(_alvoAumento);  
    }   
    
    return _alvoAumento;
  }

  @override
  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */

    Map<String, dynamic> objReturn = super.retornaObj();
    objReturn["custo"] = custearAlteracoes();
    
    return objReturn;
  }
}

// Variável de Manipulação de Poderes
Efeito poder = Efeito();
