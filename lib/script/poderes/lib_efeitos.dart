
import 'package:flutter/services.dart'; 
import 'dart:convert';

class Efeito{
  String nome = '' ;
  String _nomeEfeito = '';
  String _idEfeito = '';
  int graduacao = 0;

  int _acao = -1;    // 0 - Nenhuma | 1 - Padrao | 2 - Movimento | 3 - Livre | 4 - Reação
  int _alcance = -1; // 0 - Pessoal | 1 - Perto | 2 - A Distância | 3 - Percepção | 4 - Graduação
  int _duracao = -1; // 0 - Permente | 1 - Instantanêo | 2 - Concentração | 3 - Sustentado | 4 - Contínuo 

  var _padraoEfeito = {};
  var _modificador = [];
  
  // ###########################
  // Methodos de Inicialização #
  // ###########################
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
    graduacao   = 1;

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
    graduacao = objPoder["graduacao"];
    _acao = objPoder["acao"];
    _alcance = objPoder["alcance"];
    _duracao = objPoder["duracao"];

    List efeitos = await carregaJson();
    Map efeitoAtual = efeitos[efeitos.indexWhere((efeito) => efeito["e_id"] == objPoder["e_id"])];

    _nomeEfeito = efeitoAtual["efeito"];

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

  // ####################################
  // # Modificações de atributos Classe #
  // ####################################
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
        // Permanente Sustentado Continuo 
        if([0, 2, 3, 4].contains(novaDuracao)){
          _duracao = novaDuracao;
        }        
        break;
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
      case 3:
        // Livre
        if([1, 2, 3, 4].contains(novaAcao)){
          _acao = novaAcao;
        }        
        break;
      case 4:
        // Reação
        if([1, 2, 3, 4].contains(novaAcao)){
          _acao = novaAcao;
        }        
    }
  }

  aleteraAlcance(novoAlcance){
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

  addModificador(objModificador){
    _modificador.add(objModificador);
  }

  int CustearAlteracoes(){
    /*
      Processa o custo de alterações feitas em (Ação, Duração e Alcance)  
      Returns: Valor do Custo total calculado
    */

    // contabilizando alterações do efeitos
    // - Ação 
    int dfAcao = _padraoEfeito["acao"];
    int custoAcao = _acao - dfAcao;

    // - Alcance
    int dfAlcance = _padraoEfeito["alcance"];
    int custoAlcance = 0;
    if([1, 2, 3].contains(dfAlcance)){
      custoAlcance = _alcance - dfAlcance;
    }

    // - Duração
    int dfDurcao = _padraoEfeito["duracao"];
    int custoDurcao = 0;
    switch (dfDurcao) {
      case 0 || 3: // Permanente ou Sustentado
        if(_duracao == 4){
          custoDurcao = 1;
        }
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
        custoModfixo = mod["grad"] * mod["custo"];
      }else{
        // Custo por graduação
        custoModGrad = mod["grad"] * mod["custo"];
      }
    }

    // Finalizar custeio
    int custoBase = _padraoEfeito["custo_base"];
    int custoPorG = custoBase + custoAcao + custoDurcao + custoAlcance + custoModGrad;

    int custoFinal = 0;

    // custo por graduação
    if(custoPorG > 1){
      custoFinal = graduacao * custoPorG;
    }else{
      // 1 para varios
      custoFinal = ( graduacao / ( custoPorG.abs() + 1 ) ).ceil();
    }

    // Calculo de fixos
    custoFinal += custoModfixo;

    // Não pode ser 0
    if(custoFinal < 1){
      custoFinal = 1;
    }

    return custoFinal;
  }

  // ################################
  // # Methodos de Retorno do objto #
  // ################################

  Map<String, dynamic> retornaObj(){
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    print(nome);
    return{
      "nome":      nome,
      "e_id":      _idEfeito,
      "efeito":    _nomeEfeito,
      "graduacao": graduacao,
      "acao":      _acao,
      "alcance":   _alcance,
      "duracao":   _duracao,
      "custo":     CustearAlteracoes(),
      
    };
  }

    
}