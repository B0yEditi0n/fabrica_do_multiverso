import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

// Funções e Pops adicionais
import 'package:fabrica_do_multiverso/screens/poderes/powerEdit/functions_controlEdition.dart';

import 'package:fabrica_do_multiverso/screens/poderes/powerEdit/popup_addModificadores.dart';
import 'package:fabrica_do_multiverso/screens/poderes/powerEdit/popup_OptPoderes.dart';
import 'package:fabrica_do_multiverso/screens/poderes/powerEdit/popup_inputValue.dart';
import 'package:fabrica_do_multiverso/screens/poderes/powerEdit/popup_CaracteristicaAumentada.dart';

class powerEdit extends StatefulWidget {
  final Map objEfeito;
  const powerEdit({super.key, required this.objEfeito});

  @override
  State<powerEdit> createState() => _powerEditState();
}

class _powerEditState extends State<powerEdit> {
  // Declaração
  Map objPoder = {};
  String txtAcao = "";
  String txtAlcance = "";
  String txtDuracao = "";
  
  List modificadores = [];
  List compra = [];
  List caractAumentada = [];

  bool efeitoPessoal = false;
  bool efeitoOfensivo = false;
  bool descricao = false;

  List etiquetasModificadores = [];

  int acurado = 0;
  int bonusAtaque = 0;
  
  // Inputs de controle
  TextEditingController inputTextNomePoder = TextEditingController();
  TextEditingController inputTextDesc = TextEditingController(); // Descrição de Poder (se houver)
  List<TextEditingController> listInputModText = []; // Descrição de Modificador (se houver)
  List<TextEditingController> listInputOption = []; // Descrição de para Efeitos de compra de Opções (se houver)

  // Exclusivo de Força
  bool baseadoEmForca = false;

  // Exclusivo de Aflição
  TextEditingController priCondica = TextEditingController();
  TextEditingController segCondica = TextEditingController();
  TextEditingController terCondica = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _startPower();
  }

  Future<bool> _startPower() async{
    objPoder = widget.objEfeito;
    // Reinstancia para zerar Objeto
    poder = await Efeito.init(objPoder);
    etiquetasModificadores = Efeito.gruposModificadores(poder);
    _updateData();
    //_updateData();
    return true;
  }
  _updateData(){
    // Atualiza o estado da interface após a operação assíncrona
    
    // com a reinstancia é refazer o obj
    objPoder = poder.retornaObj();

    setState(() {
      inputTextNomePoder.text = objPoder["nome"];

      // Converte as Variáveis para texto
      txtAcao    = poder.returnStrAcao();
      txtAlcance = poder.returnStrAlcance();
      txtDuracao = poder.returnStrDuracao();

      // Define os Widgets que irão aparecer
      efeitoPessoal = (objPoder["alcance"] == 0) || objPoder["defAtaque"] == true;
      if( objPoder["defAtaque"] != null ) {efeitoOfensivo = objPoder["defAtaque"];}
      descricao = poder.returnObjDefault()["desc"];
      if(descricao){
        inputTextDesc.text = poder.desc;
      }

      // Extras e Falhas
      modificadores = objPoder["modificadores"];
      for(Map mod in modificadores){
        listInputModText.add(TextEditingController(text: mod["text_desc"] != null ? mod["text_desc"] : ''));
      }

      //
      // Inputs de Tipos Especificos
      //

      // Cria Inputs de Texto para Opções (Se tiver)
      if(poder is EfeitoEscolha){
        if(objPoder["opt"] != null && objPoder["opt"].length > 0){
          compra = objPoder["opt"];

          for(Map option in objPoder["opt"]){
            listInputOption.add(TextEditingController(text: option["text_desc"] != null ? option["text_desc"] : ''));
          }
        }        
      }

      // Bonus de Acerto & CD se tiver
      if(poder is EfeitoOfensivo){
        EfeitoOfensivo poderOfensivo = poder as EfeitoOfensivo;
        bonusAtaque = poderOfensivo.totalBonusAcerto();
        acurado = poderOfensivo.bonusAcerto();
      }

      // Exclusivo de Dano
      if(poder is EfeitoDano){
        baseadoEmForca = objPoder["baseadoForca"];
      }

      // Exclusivo de Aflição
      if(poder is EfeitoAflicao && objPoder["condicoes"] != null){
        priCondica.text = objPoder["condicoes"][0];
        segCondica.text = objPoder["condicoes"][1];
        terCondica.text = objPoder["condicoes"][2];
      }

      // Opções de Caracteristica aumentada ou Crescimento
      if(poder is EfeitoBonus){
        EfeitoBonus poderBonus = poder as EfeitoBonus;
        caractAumentada = poderBonus.returnBonusList();
      }

    });
  }

  @override
  void dispose() {
    //! adição do Chat GPT ao código
    // Certifica-se de descartar todos os controladores ao finalizar
    for (var controller in listInputModText) {
      controller.dispose();
    }
    for (var controller in listInputOption) {
      controller.dispose();
    }
    super.dispose();
  }

  //# ************
  //# * WIDGETs  *
  //# ************

  // Checkbox de limitação de grau da Aflição. As opções são exclusivas:
  // marcar uma troca a anterior; desmarcar remove a falha.
  Widget _checkLimiteGrau(int opcao, String titulo, String regra){
    EfeitoAflicao aflicao = poder as EfeitoAflicao;
    // Largura fixa: dentro do Wrap o tile precisa de limite, e 300 cabe
    // num celular (uma por linha) e põe as três lado a lado no desktop.
    return SizedBox(
      width: 300,
      child: CheckboxListTile(
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(titulo),
      subtitle: Text(regra),
      value: aflicao.limiteGrau() == opcao,
      onChanged: (bool? marcado){
        setState(() {
          aflicao.setLimiteGrau(marcado == true ? opcao : EfeitoAflicao.semLimite);
          _sincronizaModificadores();
          priCondica.text = objPoder["condicoes"][0];
          segCondica.text = objPoder["condicoes"][1];
          terCondica.text = objPoder["condicoes"][2];
        });
      },
      ),
    );
  }

  // Refaz a lista de modificadores e seus campos de descrição depois de
  // uma alteração feita fora do popup (os índices podem ter mudado).
  void _sincronizaModificadores(){
    objPoder = poder.retornaObj();
    modificadores = objPoder["modificadores"];
    List<TextEditingController> antigos = listInputModText;
    listInputModText = [
      for(Map mod in modificadores)
        TextEditingController(text: mod["text_desc"] ?? '')
    ];
    WidgetsBinding.instance.addPostFrameCallback((_){
      for(var c in antigos){ c.dispose(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Voltar pelo botão do sistema também devolve o poder editado
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){ Navigator.of(context).pop(poder.retornaObj()); }
      },
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edição do Poder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () async => {
              // Salva Alterações
              setState(() {
                //personagem.poderes.poderesLista[widget.idPoder] = poder.retornaObj();
              }),
              
              // Fecha A Aplicação
              Navigator.of(context).pop(poder.retornaObj())
            }
        ), 
      ),


      body: SafeArea(child: SingleChildScrollView(
        child: Padding(

          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            
            children: [
              //******************************** */
              //# Nome Efeito e Graduação         *
              //******************************** */
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 10.0, // Espaço horizontal entre os itens
                  runSpacing: 15.0, // Espaço vertical entre as linhas
                  children: [

                    //
                    //# Nome do Poder
                    //

                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: inputTextNomePoder,
                        decoration: const InputDecoration(hintText: 'Nome do Poder'),
                        onChanged: (String value) async{
                          poder.nome = value;
                          objPoder["nome"] = value;
                        },
                      )
                    ),
                     
                    TextButton(
                      onPressed: () async => {
                        // Garante que jogador não escolha graduações de efeitos de compra ou bonus
                        if(poder is! EfeitoCompra 
                        && poder.retornaObj()["class"] != "EfeitoBonus"){ 
                          // Voltar do sistema devolve null: mantém a graduação
                          poder.setGrad( await abrirPopup<int>(
                            context,
                            PoupInputIntValue(
                              // Graduação 0 abre em 1 (sem gravar: o voltar mantém 0)
                              intValue: objPoder["graduacao"] == 0 ? 1 : objPoder["graduacao"],
                              titulo: 'Valor de Graduação',
                              iniValor: 1,
                            ),
                          ) ?? objPoder["graduacao"] ),
                          //! Atualiza a Lista de poderes
                          setState(() {
                            objPoder = poder.retornaObj();
                            // ataualização de efeito crescimento
                            if(poder is EfeitoCrescimento){
                              EfeitoCrescimento efeitoCrescimento = poder as EfeitoCrescimento;
                              setState(() {
                                caractAumentada = efeitoCrescimento.returnBonusList();
                              });
                              
                            }
                          }) 
                        }
                      },

                      //
                      //# Efeito & Graduação
                      //

                      child: Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
                        children: [
                          Text('${objPoder["efeito"]} ${objPoder["graduacao"]}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                         

                          // Check Box de Ataque
                          Visibility(
                            visible: efeitoPessoal, 
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              
                              children: [
                                const Text('Ofensivo: '),
                                Checkbox(
                                  value: efeitoOfensivo,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      efeitoOfensivo = value!;
                                      poder.definirComoAtaque(efeitoOfensivo);
                                      // atualiza marcas de texto
                                        txtAcao    = poder.returnStrAcao();
                                        txtAlcance = poder.returnStrAlcance();
                                        txtDuracao = poder.returnStrDuracao();
                                    });
                                  },
                                ),
                              ],
                            )                        
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              //****************************
              //# Ação, Alcance e Duração
              //****************************
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 8.0, // Espaço horizontal entre os itens
                  runSpacing: 5.0, // Espaço vertical entre as linhas
                  direction: Axis.horizontal,
                  children: [
                  // *****************
                  //      Ação
                  // *****************
                  Wrap(                  
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left, size: 38),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraAcao(objPoder["acao"], -1);
                          setState(() {
                            poder.alteraAcao(novoValor);
                            txtAcao = poder.returnStrAcao();

                            // Atualiza o objeto e os custos
                            objPoder = poder.retornaObj();
                          });
                        }
                      ),
                
                      SizedBox(
                        width: 80,
                        child: Text(
                          txtAcao, // Atual ação
                          textAlign: TextAlign.center,
                        ),
                      ),                      
                
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right, size: 38),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraAcao(objPoder["acao"], 1);
                          setState(() {
                            poder.alteraAcao(novoValor);
                            txtAcao = poder.returnStrAcao();

                            // Atualiza o objeto e os custos
                            objPoder = poder.retornaObj();
                          });
                        }
                      ),
                    ],
                  ),
                
                  // *****************
                  //     Alcance
                  // *****************
                
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left, size: 38),
                        onPressed: (){
                          int novoValor = alteraAlcance(objPoder["alcance"], -1);
                          setState(() {
                            poder.alteraAlcance(novoValor);
                            txtAlcance = poder.returnStrAlcance();

                            // Atualiza o objeto e os custos
                            objPoder = poder.retornaObj();
                          });
                        }
                      ),
                
                      SizedBox(
                        width: 80,
                        child: Text(
                          txtAlcance, // Atual Alcance
                          textAlign: TextAlign.center,
                        ),
                      ),                      
                
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right, size: 38),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraAlcance(objPoder["alcance"], 1);
                          setState(() {
                            poder.alteraAlcance(novoValor);
                            txtAlcance = poder.returnStrAlcance();

                            // Atualiza o objeto e os custos
                            objPoder = poder.retornaObj();
                          });
                        }
                      ),
                    ],
                  ),
                  
                  // *****************
                  //     Duração
                  // *****************
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left, size: 38),
                        onPressed: (){
                          int novoValor = alteraDuracao(objPoder["duracao"], -1);
                          setState(() {
                            poder.alteraDuracao(novoValor);
                            txtDuracao = poder.returnStrDuracao();
                            // Talvez altere a ação
                            txtAcao = poder.returnStrAcao();

                            // Atualiza o objeto e os custos
                            objPoder = poder.retornaObj();
                          });
                        }
                      ),
                
                      SizedBox(
                        width: 100,
                        child: Text(
                          txtDuracao, // Atual Duracao
                          textAlign: TextAlign.center,
                        ),
                      ),                      
                
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right, size: 38),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraDuracao(objPoder["duracao"], 1);
                          setState(() {
                            poder.alteraDuracao(novoValor);
                            txtDuracao = poder.returnStrDuracao();
                            // Talvez altere a ação
                            txtAcao = poder.returnStrAcao();

                            // Atualiza o objeto e os custos
                            objPoder = poder.retornaObj();
                          });
                        }
                      ),
                    ],
                  )],
                ),
              ),

              const SizedBox(height: 30),

              //***************************************************
              //# Widgets Ofensivos CD, Acerto
              //***************************************************

              poder is EfeitoOfensivo ? 
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  direction: Axis.horizontal,
                  children: [

                    // CD

                    SizedBox(
                      child: Text('CD: ${objPoder["cd"]}',
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          
                        )
                      ),
                    ),

                    // ACERTO

                    objPoder["alcance"]!= null && objPoder["alcance"] != 3 ? TextButton(
                        child: Text('Acerto $bonusAtaque',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.normal,
                        ),),
                        onPressed: () async{
                          
                          if(poder is EfeitoOfensivo){
                            // chama um popupItem
                            int? valor = await abrirPopup<int>(
                                context,
                                PoupInputIntValue(intValue: acurado, titulo: 'Valor de Acerto'),
                            );
                            // Voltar do sistema devolve null: mantém o acerto
                            if(valor == null) return;
                            acurado = valor;
                            setState(() {
                              EfeitoOfensivo poderOfensivo = poder as EfeitoOfensivo;
                              poderOfensivo.addBonus(acurado);
                              bonusAtaque = poderOfensivo.totalBonusAcerto();
                            });
                          }
                      }
                    ) : const SizedBox(),

                    // BASEADO EM FORÇA (apenas para dano) 

                    poder is EfeitoDano ?
                      Column(
                        children: [
                          const Text("Baseado em Força"),
                          Checkbox(
                            value: baseadoEmForca,
                            onChanged: (value) => setState((){
                              baseadoEmForca = value!;
                              EfeitoDano objectDano = poder as EfeitoDano;
                              objectDano.baseadoForca = baseadoEmForca;
                            }),
                          )
                        ],
                      ): const SizedBox(),
                  ],
                ),
              ) : const SizedBox(),

              // Checa se o efeito exige descrição
              descricao ? 
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //inputTextDesc
                    TextField(
                        controller: inputTextDesc,
                        decoration: const InputDecoration(hintText: 'Descrição'),
                        onChanged: (String value) {
                          poder.desc = value;
                          objPoder["descricao"] = value;
                        },
                    ),
                  ],
                )
              : const SizedBox(),

              const SizedBox(height: 30),

              //***************************************************
              //# Campos de Condições pra Aflições
              //***************************************************

              poder is EfeitoAflicao ? Wrap(
                alignment: WrapAlignment.spaceEvenly,
                direction: Axis.horizontal,
                spacing: 10.0, // Espaço horizontal entre os itens
                runSpacing: 15.0, // Espaço vertical entre as linhas                  
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: priCondica,
                      enabled: (poder as EfeitoAflicao).condicaoAtiva(0),
                      onChanged: (String value){
                        // Força o cast
                        EfeitoAflicao poderCompra = poder as EfeitoAflicao;
                        poderCompra.addCondicao(0, value);
                      },
                      decoration: const InputDecoration(hintText: 'Primeira Condição'),
                    ),
                  ),
              
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: segCondica,
                      enabled: (poder as EfeitoAflicao).condicaoAtiva(1),
                      onChanged: (String value){
                        // Força o cast
                        EfeitoAflicao poderCompra = poder as EfeitoAflicao;
                        poderCompra.addCondicao(1, value);                        
                      },
                      decoration: const InputDecoration(hintText: 'Segunda Condição',),
                    ),
                  ),
              
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: terCondica,
                      enabled: (poder as EfeitoAflicao).condicaoAtiva(2),
                      onChanged: (String value){
                        // Força o cast
                        EfeitoAflicao poderCompra = poder as EfeitoAflicao;
                        poderCompra.addCondicao(2, value);
                      },
                      decoration: const InputDecoration(hintText: 'Terceira Condição',),
                    ),
                  )
                ],
              ) : const SizedBox(),

              const SizedBox(height: 30),

              //***************************************************
              //# Campos de Compra (Especifico pra alguns efeitos)
              //***************************************************
              
              poder is EfeitoEscolha ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: compra.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Row(
                              children: [
                                // Identifica a opção comprada
                                Flexible(child: Text('${compra[index]["desc"]} ${compra[index]["valor"]}')),

                                // Input de Descrição *se tiver
                                // (divide a linha com o nome em vez de 20% da tela)
                                if(compra[index]["espec"] != null && compra[index]["espec"]) ...[
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        controller: listInputOption[index],
                                        onChanged: (String value){
                                          // Força o cast
                                          EfeitoEscolha poderCompra = poder as EfeitoEscolha;
                                          poderCompra.setOptDesc(compra[index]["ID"], value);
                                          poder.reinstanciarMetodo(poderCompra.retornaObj());
                                        },
                                        decoration: const InputDecoration(
                                          hintText: '',
                                        ),
                                      
                                      ),
                                    ),
                                ],
                              ]
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>{
                                setState(() {
                                  // força um cast para acessar metodos de compra
                                  EfeitoEscolha poderCompra = poder as EfeitoEscolha;
                                  
                                  poderCompra.rmOpt(compra[index]["ID"]);
                                  listInputOption.removeAt(index);
                                  compra = poder.retornaObj()["opt"];
                                  
                                  
                                  // Atualiza o objeto inteiro
                                  objPoder = poder.retornaObj();
                                })
                              },
                              ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: Text('Adicionar Compra de ${objPoder["efeito"]}'),
                        onPressed: () async => {
                          await abrirPopup(context, AddOptCompra()).then((result)=>{
                            // Atualizar a Lista do Que Saiu
                            setState(() {
                              compra = poder.retornaObj()["opt"];
                              while(compra.length > listInputOption.length){
                                listInputOption.add(TextEditingController());
                              }
                              // Atualiza o objeto inteiro
                              objPoder = poder.retornaObj();
                            })
                          })
                        },
                      ),
                    ),
                  ],
                ),
              ) : const SizedBox(),

              //# Caracteristica Aumentada ou Habilidade Aumentada
              poder is EfeitoBonus && poder is! EfeitoCrescimento ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: caractAumentada.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Row(
                              children: [
                                // Identifica a opção comprada
                                TextButton(
                                  child: Text('${caractAumentada[index]["nome"]} ${caractAumentada[index]["valor"]}'),
                                  onPressed: () async{
                                      EfeitoBonus poderBonus = poder as EfeitoBonus;
                                      await abrirPopup<int>(
                                        context,
                                        PoupInputIntValue(
                                          iniValor: 0,
                                          intValue: caractAumentada[index]["valor"],
                                          titulo: "Valor de ${caractAumentada[index]["nome"]}"
                                        ),
                                      ).then((result){
                                        // Atualizar a Lista do Que Saiu (voltar do sistema: null, nada muda)
                                        if (result != null && poder is! EfeitoCrescimento){
                                          caractAumentada[index]["valor"] = result;
                                          poderBonus.addBonus(caractAumentada[index]);
                                          setState(() {                                            
                                            caractAumentada = [];
                                            caractAumentada.addAll(poderBonus.returnBonusList());
                                            objPoder = poder.retornaObj();
                                          });
                                        }
                                      });
                                  },
                                ),
                              ]
                            ),
                            
                            trailing:
                              poder is! EfeitoCrescimento ?
                                IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>{
                                  setState(() {
                                    EfeitoBonus poderBonus = poder as EfeitoBonus;
                                    poderBonus.removeIndexBonus(index);
                                    caractAumentada = [];
                                    caractAumentada.addAll(poderBonus.returnBonusList());
                                    objPoder = poder.retornaObj();
                                  })
                                },
                                ) : const SizedBox(),
                          );
                        },
                      ),
                    ),
                    poder is! EfeitoCrescimento ? 
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: Text('Adicionar Compra de ${objPoder["efeito"]}'),
                        onPressed: () async {

                          EfeitoBonus poderBonus = poder as EfeitoBonus;

                          await abrirPopup<Map>(context, AddCaractAumet(caracteristica:{})).then((result){
                            // Atualizar a Lista do Que Saiu (voltar do sistema: null, nada muda)
                            if(result != null && result.isNotEmpty ){
                              // Verifica se já foi adicionado
                              poderBonus.addBonus(result);
                              setState(() {
                                caractAumentada = [];
                                caractAumentada.addAll(poderBonus.returnBonusList());
                                objPoder = poder.retornaObj();
                              });
                            }
                            
                          });
                        },
                      ),
                    ) : const SizedBox(),
                  ],
                ),
              ) : const SizedBox(),

              const SizedBox(height: 30),

              //********************************
              //# Campos de Extra e Falha
              //********************************
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.40, // 40% da altura da tela,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: modificadores.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Row(
                              children: [
                                // Identifica o Modificador
                                Flexible(child: Text('${modificadores[index]["nome"]} ${modificadores[index]["grad"] > 1 ? modificadores[index]["grad"] : ''}')),

                                // Input de Descrição *se tiver
                                // (divide a linha com o nome em vez de 20% da tela)
                                if(modificadores[index]["desc"]) ...[
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        controller: listInputModText[index],
                                        onChanged: (value){
                                         
                                          poder.setDescMod(modificadores[index]["m_id"], value);
                                          
                                        },
                                        decoration: const InputDecoration(  
                                          hintText: '',
                                        ),
                                      
                                      ),
                                    ),
                                ],
                              ]
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>{
                                setState(() {
                                  poder.delModificador(modificadores[index]["m_id"]);
                                  listInputModText.removeAt(index);
                                  modificadores = poder.retornaObj()["modificadores"];
                                  
                                  // Atualiza o objeto inteiro
                                  objPoder = poder.retornaObj();
                                })
                              },
                              ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: const Text('Adicionar Modificador'),
                        onPressed: () async => {
                          await abrirPopup(context, AddModificadorSelecionador(etiquetas: Efeito.gruposModificadores(poder))).then((result)=>{
                            // Atualizar a Lista do Que Saiu
                            setState(() {
                              modificadores = objPoder["modificadores"];

                              while(modificadores.length > listInputModText.length){
                                listInputModText.add(TextEditingController());
                              }
                              // Atualiza o objeto inteiro
                              objPoder = poder.retornaObj();

                            })
                          })
                        },
                      ),
                    ),
                  ],
                ),
              ),

              //********************************
              //# Limitação de Grau (Aflição)
              //********************************
              if(poder is EfeitoAflicao) ...[
                // Uma linha só em telas largas; quebra em lista no celular
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 10.0,
                  children: [
                    _checkLimiteGrau(EfeitoAflicao.semTerceira,
                      'Remover 3ª condição', 'Grau Limitado (-1 por graduação)'),
                    _checkLimiteGrau(EfeitoAflicao.semSegundaTerceira,
                      'Remover 2ª e 3ª condição', 'Grau Limitado 2 (-2 por graduação)'),
                    _checkLimiteGrau(EfeitoAflicao.apenasTerceira,
                      'Remover 1ª e 2ª condição', 'Limitado a Terceiro Grau (-1 por graduação)'),
                  ],
                )
              ],

              const SizedBox(height: 30),

              //# Pontos Gastos */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${objPoder["custo"]} pontos de poder',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)
                  )
                ],
              )

            ],
          ),
        ),
      )),
      ),
    );
  }
}