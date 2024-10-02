import 'package:flutter/material.dart';

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

  int bonusAtaque = 0;
  
  // Inputs de controle
  TextEditingController inputTextNomePoder = TextEditingController();
  TextEditingController inputTextDesc = TextEditingController(); // Descrição de Poder (se houver)
  List<TextEditingController> listInputModText = []; // Descrição de Modificador (se houver)
  List<TextEditingController> listInputOption = []; // Descrição de para Efeitos de compra de Opções (se houver)

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
    etiquetasModificadores = ["gerais"];
    switch (objPoder["class"]) {
      case "EfeitoCrescimento":
        poder = EfeitoCrescimento();
        break;
      case "EfeitoBonus":
        poder = EfeitoBonus();
        break;
      case "EfeitoAflicao":
        poder = EfeitoAflicao();
        break;
      case "EfeitoDano":
        poder = EfeitoDano();
        etiquetasModificadores += ["ofensivos"];
        break;
      case "EfeitoCompra":
        poder = EfeitoCompra();
        break;
      case "EfeitoCustoVaria":
        poder = EfeitoCustoVaria();
        break;
      case "EfeitoOfensivo":
        poder = EfeitoOfensivo();
        break;
      case "Efeito":
      default:
        poder = Efeito();
        break;
    }
    poder.reinstanciarMetodo(objPoder).then((valor)=>_updateData());
    //_updateData();
    return true;
  }
  _updateData(){
    // Atualiza o estado da interface após a operação assíncrona
    
    setState(() {
      // com a reinstancia é refazer o obj
      objPoder = poder.retornaObj();

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
        bonusAtaque = poderOfensivo.bonusAcerto();        
      }
      // Exclusivo de Aflição
      if(poder is EfeitoAflicao && objPoder["condicoes"] != null){
        priCondica.text = objPoder["condicoes"][1];
        segCondica.text = objPoder["condicoes"][2];
        terCondica.text = objPoder["condicoes"][3];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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


      body: SingleChildScrollView(
        child: Padding(
          
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          if(objPoder["graduacao"] == 0){
                            objPoder["graduacao"] = 1
                          },
                          poder.setGrad( await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PoupInputIntValue(
                              intValue: objPoder["graduacao"], 
                              titulo: 'Valor de Graduação',
                              iniValor: 1,
                            )),
                          ) ),
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
                        icon: const Icon(Icons.arrow_circle_left),
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
                        icon: const Icon(Icons.arrow_circle_right),
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
                        icon: const Icon(Icons.arrow_circle_left),
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
                        icon: const Icon(Icons.arrow_circle_right),
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
                        icon: const Icon(Icons.arrow_circle_left),
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
                        icon: const Icon(Icons.arrow_circle_right),
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
                        onPressed: () async => {
                          
                          if(poder is EfeitoOfensivo){
                            // chama um popupItem
                            bonusAtaque = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PoupInputIntValue(intValue: bonusAtaque, titulo: 'Valor de Acerto')),
                            ),
                            setState(() {
                              EfeitoOfensivo poderOfensivo = poder as EfeitoOfensivo;
                              poderOfensivo.addBonus(bonusAtaque);
                              objPoder = poderOfensivo.retornaObj();
                            })
                          }
                      }
                    ) : const SizedBox(),
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
                alignment: WrapAlignment.spaceBetween,
                direction: Axis.horizontal,
                spacing: 10.0, // Espaço horizontal entre os itens
                runSpacing: 15.0, // Espaço vertical entre as linhas                  
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: priCondica,
                      onChanged: (String value){
                        // Força o cast
                        EfeitoAflicao poderCompra = poder as EfeitoAflicao;
                        poderCompra.addCondicao(1, value);
                      },
                      decoration: const InputDecoration(hintText: 'Primeira Condição'),
                    ),
                  ),
              
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: segCondica,
                      onChanged: (String value){
                        // Força o cast
                        EfeitoAflicao poderCompra = poder as EfeitoAflicao;
                        poderCompra.addCondicao(2, value);                        
                      },
                      decoration: const InputDecoration(hintText: 'Segunda Condição',),
                    ),
                  ),
              
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: terCondica,
                      onChanged: (String value){
                        // Força o cast
                        EfeitoAflicao poderCompra = poder as EfeitoAflicao;
                        poderCompra.addCondicao(3, value);
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
                                Text('${compra[index]["desc"]} ${compra[index]["valor"]}'),

                                // Input de Descrição *se tiver   
                                compra[index]["espec"] != null && compra[index]["espec"] ? Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.20,
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
                                ) : const SizedBox(),
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
                          await showDialog(
                            context: context,
                            builder: ((BuildContext context) {
                              return AddOptCompra();
                            })
                          ).then((result)=>{
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
              poder is EfeitoBonus ? Container(
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
                                      await showDialog(
                                        context: context,
                                        builder: ((BuildContext context) {
                                          return PoupInputIntValue(
                                            iniValor: 0, 
                                            intValue: caractAumentada[index]["valor"],
                                            titulo: "Valor de ${caractAumentada[index]["nome"]}"
                                          );
                                        })
                                      ).then((result){
                                        // Atualizar a Lista do Que Saiu
                                        if (poder is! EfeitoCrescimento){
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

                          await showDialog(
                            context: context,
                            builder: ((BuildContext context) {
                              return AddCaractAumet(caracteristica:{});
                            })
                          ).then((result){
                            // Atualizar a Lista do Que Saiu
                            if(result.isNotEmpty){
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
                                Text('${modificadores[index]["nome"]} ${modificadores[index]["grad"] > 1 ? modificadores[index]["grad"] : ''}'),

                                // Input de Descrição *se tiver   
                                Row(
                                  children: modificadores[index]["desc"] ? [
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.20,
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
                                  ]: [], 
                                ),
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
                          await showDialog(
                            context: context,
                            builder: ((BuildContext context) {
                              return AddModificadorSelecionador(etiquetas: etiquetasModificadores);
                            })
                          ).then((result)=>{
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
      ),
    );
  }
}