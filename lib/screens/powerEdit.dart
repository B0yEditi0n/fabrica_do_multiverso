import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

// Funções e Pops adicionais
import 'package:fabrica_do_multiverso/screens/powerEdit/popup_GradPicker.dart';
import 'package:fabrica_do_multiverso/screens/powerEdit/functions_controlEdition.dart';


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
  List modficadores = [{
    "nome": "Critico Aprimorado",
    "grad": 4
  }];

  bool EsconderText = false;
  bool efeitoPessoal = false;
  bool efeitoOfensivo = false;
  
  // Inputs de controle
  TextEditingController inputTextNomePoder = TextEditingController();

  @override

  void initState() {
    super.initState();
    _startPower(); // Carrega os dados ao iniciar o estado
  }

  void _startPower(){
    setState(() {
      // Reinstancia para zerar Objeto
      poder = Efeito();

      objPoder = personagem.poderes.poderesLista[widget.idPoder];
      poder.reinstanciarMetodo(objPoder);  
      inputTextNomePoder.text = objPoder["nome"];

      // Converte as Variáveis para texto
      txtAcao    = poder.returnStrAcao();
      txtAlcance = poder.returnStrAlcance();
      txtDuracao = poder.returnStrDuracao();

      // Define os Widgets que irão aparecer
      efeitoPessoal = (objPoder["alcance"] == 0);
      print(efeitoPessoal);
      print(objPoder["alcance"]);

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
                            return GradPowerDialog(gradValue: objPoder["graduacao"], titulo: 'Valor de Graduação  ',);
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
                                  //checkColor: Colors.white,
                                  //fillColor: MaterialStateProperty.resolveWith(getColor),
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
                            objPoder = poder.retornaObj();
                            txtAcao = poder.returnStrAcao();
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
                            objPoder = poder.retornaObj();
                            txtAcao = poder.returnStrAcao();
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
                            objPoder = poder.retornaObj();
                            txtAlcance = poder.returnStrAlcance();
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
                            objPoder = poder.retornaObj();
                            txtAlcance = poder.returnStrAlcance();
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
                            objPoder = poder.retornaObj();
                            txtDuracao = poder.returnStrDuracao();
                            // Talvez altere a ação
                            txtAcao = poder.returnStrAcao();
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
                            objPoder = poder.retornaObj();
                            txtDuracao = poder.returnStrDuracao();
                            // Talvez altere a ação
                            txtAcao = poder.returnStrAcao();
                          });
                        }
                      ),
                    ],
                  )],
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
                            title: Text('${modficadores[index]["nome"]} ${modficadores[index]["grad"]}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>{
                                print(index)
                              },
                              ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Adiciona um novo item à lista de modificadores
                            modficadores.add({"nome": "Novo Modificador", "grad": 1});
                          });
                        },
                        child: TextButton(
                          child: const Text('Adicionar Modificador'),
                          onPressed: () => {
                            
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        
              // Parametrizar Widgets Visiveis e Invisiveis
              SizedBox(
                child: Visibility(
                  visible: EsconderText, 
                  child: const Text("Invisible"),
                  
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
