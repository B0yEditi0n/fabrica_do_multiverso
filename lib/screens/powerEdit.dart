import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_switchEfeito.dart';

// Funções e Pops adicionais
import 'package:fabrica_do_multiverso/screens/powerEdit/functions_controlEdition.dart';

import 'package:fabrica_do_multiverso/screens/powerEdit/popup_GradPicker.dart';
import 'package:fabrica_do_multiverso/screens/powerEdit/popup_addModificadores.dart';

class powerEdit extends StatefulWidget {
  final int idPoder;
  const powerEdit({super.key, required this.idPoder});

  @override
  State<powerEdit> createState() => _powerEditState();
}

class _powerEditState extends State<powerEdit> {
  // Declaração
  var objPoder = {};
  String txtAcao = "";
  String txtAlcance = "";
  String txtDuracao = "";
  List modficadores = [];

  bool EsconderText = false;
  bool efeitoPessoal = false;
  bool efeitoOfensivo = false;
  bool descricao = false;

  List etiquetasModificadores = [];
  
  // Inputs de controle
  TextEditingController inputTextNomePoder = TextEditingController();
  TextEditingController inputTextDesc = TextEditingController();
  List<TextEditingController> listInputModText = [];

  @override

  void initState() {
    super.initState();
    _startPower(); // Carrega os dados ao iniciar o estado
    //_updateData();
  }

  Future<bool> _startPower() async{
    // Lista de Modificadores Disponiveis;
    etiquetasModificadores = ["gerais"];
    switch (objPoder["classe_manipulacao"]) {
      case "Aflicao":
      case "Dano":
        etiquetasModificadores += ["ofensivos"];
        break;
    }

    // Reinstancia para zerar Objeto
    poder = Efeito();
    objPoder = personagem.poderes.poderesLista[widget.idPoder];
    poder.reinstanciarMetodo(objPoder).then((valor)=>_updateData());
    //_updateData();
    return true;
  }
  _updateData(){
    // Atualiza o estado da interface após a operação assíncrona
    
    setState(() {
      inputTextNomePoder.text = objPoder["nome"];

      // Converte as Variáveis para texto
      txtAcao    = poder.returnStrAcao();
      txtAlcance = poder.returnStrAlcance();
      txtDuracao = poder.returnStrDuracao();

      // Define os Widgets que irão aparecer
      efeitoPessoal = (objPoder["alcance"] == 0);
      descricao = poder.returnObjDefault()["desc"];
      if(descricao){
        inputTextDesc.text = poder.desc;
      }

      // Extras e Falhas
      modficadores = objPoder["modificadores"];

      // Criar Inputs de Textos de modificadores com texto
      for(Map mod in modficadores){
        if(mod["text_desc"] != null){
          listInputModText.add(TextEditingController(text: mod["text_desc"]));
        }else{
          listInputModText.add(TextEditingController());
        }
        
      }
      
    });

  }

  //************
  //* WIDGETs
  //************

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
              personagem.poderes.poderesLista[widget.idPoder] = poder.retornaObj();
            }),
            
            // Fecha A Aplicação
            Navigator.of(context).pop()
          }
        ), 
      ),


      body: SingleChildScrollView(
        child: Padding(
          
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Nome Efeito e Graduação
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 8.0, // Espaço horizontal entre os itens
                  runSpacing: 5.0, // Espaço vertical entre as linhas
                  children: [
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
                        
                        await showDialog(
                          context: context,
                          builder: ((BuildContext context) {
                            return GradPowerDialog(gradValue: objPoder["graduacao"], titulo: 'Valor de Graduação',);
                          })
                        ),
                        //! Atualiza a Lista de poderes
                        setState(() {
                          objPoder = poder.retornaObj();
                        })
                      },
        
                      child: Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
              // Ação, Alcance e Duração
              
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
                      )
                  ],
                )
              : const SizedBox(),

              const SizedBox(height: 30),

              //***************************************************
              //* Campos de Compra (Especifico pra alguns efeitos)
              //***************************************************
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    objPoder["classe_manipulacao"] == 'EfeitoCompra' ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.40, // 40% da altura da tela,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: modficadores.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            /*title: Row(
                              children: [
                                // Identifica o Modificador
                                //Text('${modficadores[index]["nome"]} ${modficadores[index]["grad"] > 1 ? modficadores[index]["grad"] : ''}'),

                                // Input de Descrição *se tiver   
                                Row(
                                  children: modficadores[index]["desc"] ? [
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.20,
                                      child: TextField(
                                        controller: listInputModText[index],
                                        onChanged: (String value){
                                          poder.setDescMod(modficadores[index]["m_id"], value);
                                        },
                                        decoration: const InputDecoration(
                                          hintText: '',
                                        ),
                                      
                                      ),
                                    ),
                                  ]: [], 
                                ),
                              ]
                            ),*/
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>{
                                setState(() {
                                })
                              },
                              ),
                          );
                        },
                      ),
                    ) : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: Text('Adicionar Compra de ${objPoder["efeito"]}'),
                        onPressed: () async => {
                          await showDialog(
                            context: context,
                            builder: ((BuildContext context) {
                              return AddModificadorSelecionador(etiquetas: etiquetasModificadores);
                            })
                          ).then((result)=>{
                            // Atualizar a Lista do Que Saiu
                            setState(() {
                              modficadores = objPoder["modificadores"];
                              while(modficadores.length > listInputModText.length){
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

              //********************************
              //* Campos de Extra e Falha
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
                        itemCount: modficadores.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Row(
                              children: [
                                // Identifica o Modificador
                                Text('${modficadores[index]["nome"]} ${modficadores[index]["grad"] > 1 ? modficadores[index]["grad"] : ''}'),

                                // Input de Descrição *se tiver   
                                Row(
                                  children: modficadores[index]["desc"] ? [
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.20,
                                      child: TextField(
                                        controller: listInputModText[index],
                                        onChanged: (String value){
                                          poder.setDescMod(modficadores[index]["m_id"], value);
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
                                  poder.delModificador(modficadores[index]["m_id"]);
                                  listInputModText.removeAt(index);
                                  modficadores = poder.retornaObj()["modificadores"];
                                  
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
                              modficadores = objPoder["modificadores"];
                              while(modficadores.length > listInputModText.length){
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

              //* Pontos Gastos */
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
