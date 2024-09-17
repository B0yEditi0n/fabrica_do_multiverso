//# Dialogo de Adição de Perícias

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

// Biblioteca de Pericias
import 'package:fabrica_do_multiverso/script/ficha.dart';

class PopUpAddSkill extends StatefulWidget {
  Map obj = {};
  PopUpAddSkill({super.key, required this.obj});

  @override
  _PopUpAddSkillState createState() => _PopUpAddSkillState();
}

class _PopUpAddSkillState extends State<PopUpAddSkill> {
  // Controla qual perícia foi selecionada para Adição
  Map periciaSelecionada ={};

  // Repetório de Efeitos Adicionados
  List ofensivePoderes = [];      // Repetório
  List avaliableOfenPoderes = []; // Disponíveis para adição
  List addOfensivePoderes = [];   // Já adicionados
  List<int> ListIdxPoderes = [];  // Indice que volta pra retorno

  // Qual efeito em seleção para receber bonus
  Map poderBonusEmSelec   = {}; // Poderes Selecionado para dar bonus de acerto


  // Pericias Adicionaveis no Popup
  final List<Map<String, dynamic>> periciaListAdd = [
    {"id": "PA01", "nome": "Ataque a Corpo-a-Corpo", "idHab": "LUT", "treinado": false},
    {"id": "PA02", "nome": "Ataque a Distância", "idHab": "DES", "treinado": false},
    {"id": "PA03", "nome": "Especialidade de Intelecto", "idHab": "INT", "treinado": true},
    {"id": "PA04", "nome": "Especialidade de Prontidão", "idHab": "PRO", "treinado": true},
    {"id": "PA05", "nome": "Especialidade de Presença", "idHab": "PRE", "treinado": true}
  ];

  TextEditingController inputDescrPericia = TextEditingController();
  
  @override  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }

  void _addBonusOfensivo(){
    // Evita que o mesmo efeito seja add 2 vezes
    if(addOfensivePoderes.length != ListIdxPoderes.length){
      setState(() {
        // Adiciona os poderes a Lista
        addOfensivePoderes = ofensivePoderes.where((o)=>ListIdxPoderes.contains(o["index"])).toList();
        // Remove do disponíveis
        avaliableOfenPoderes.removeWhere((a)=>ListIdxPoderes.contains(a["index"]));
        if(avaliableOfenPoderes.isNotEmpty){
          poderBonusEmSelec = avaliableOfenPoderes.first;
        }        

      });
    }
    
  }

  Future<void> _carregarDados() async {
    periciaSelecionada = periciaListAdd.first;

    // Efeitos Ofensivos
    int rangeOfensive = 0; 
    periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
    periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
    ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);
    avaliableOfenPoderes.addAll(ofensivePoderes);
    if(avaliableOfenPoderes.isNotEmpty){poderBonusEmSelec = avaliableOfenPoderes.first;}

    // caso haja objetos carregados
    if(widget.obj.isNotEmpty){
      periciaSelecionada["id"] = widget.obj["id"];
      periciaSelecionada["nome"] = widget.obj["nome"];
      periciaSelecionada["idHab"] = widget.obj["idHab"];
      periciaSelecionada["treinado"] = widget.obj["treinado"];
      inputDescrPericia.text = widget.obj["escopo"];
      if(widget.obj["bonusPoderes"] != null){
        ListIdxPoderes = widget.obj["bonusPoderes"];
        _addBonusOfensivo();
      }
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.obj.isNotEmpty ? Text(widget.obj["nome"]) : const Text('Perícia Adicional'),


      content: SingleChildScrollView(
        child: 
          Column(
            children: <Widget>[
              //? Input nome da perícia ou descrição do grupo de acerto            
              periciaSelecionada.isNotEmpty && ["PA03", "PA04", "PA05"].contains(periciaSelecionada["id"]) 
              ? TextField(
                controller: inputDescrPericia,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Especialização',
                ),
              )
              : TextField(
                controller: inputDescrPericia,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Grupo de Acerto',
                ),
              ),
          
              const SizedBox(height: 15,),
              
              //? Input de Perícia
              widget.obj.isEmpty ?
              DropdownButton<Map>(
                value: periciaSelecionada,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                underline: Container(
                  height: 2,
                ),
                onChanged: (value) {
                  // caso seja um retorno atualiza a lista de Poderes
                  // Atualiza o estado das variáveis
                  setState(() {
                    periciaSelecionada = value!;     
                    if(["PA01", "PA02"].contains(periciaSelecionada["id"])){ // Em caso de ofensivo estruturar lista
                      int rangeOfensive = 0;
                      periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
                      periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
                      ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);
                    }
                    
                  });
                },
                items: periciaListAdd.map<DropdownMenuItem<Map>>((value) {
                  return DropdownMenuItem<Map>(
                    value: value,
                    child: Text(value["nome"].toString()),
                  );
                }).toList(),
              ): const SizedBox(),
          
              //? Perícia baseada ou Poderes selecionado
              ofensivePoderes.isNotEmpty && ["PA01", "PA02"].contains(periciaSelecionada["id"]) ?
              Column(
                children: [
                  //? Poderes alvo de bonus
                  SizedBox(
                    height: 150,
                    width: 300,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: addOfensivePoderes.length,
                      itemBuilder: (BuildContext context, int idxPoder) {

                        return InkWell(
                          child: Column(children: [
                            //; Efeitos Adiconados a Perícia
                            ListTile(
                              title: Text(addOfensivePoderes[idxPoder]['nome']),
                              subtitle: Text(addOfensivePoderes[idxPoder]['efeito']),
                            ) 
                          ],)
                        );
                      }
                    ),
                  ),
                  //? Seleciona poder a Ser adicionado
                  avaliableOfenPoderes.isNotEmpty ?
                  DropdownButton<Map>(
                    value: poderBonusEmSelec,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    underline: Container(
                      height: 2,
                    ),
                    onChanged: (value) {
                      setState(() {
                        poderBonusEmSelec = value!;                  
                      });
                    },
                    items: avaliableOfenPoderes.map<DropdownMenuItem<Map>>((value) {
                      return DropdownMenuItem<Map>(
                        value: value,
                        child: Text("${value["nome"]}: ${value["efeito"]}"),
                      );
                    }).toList(),
                  ) : const SizedBox(),

                  avaliableOfenPoderes.isNotEmpty ?
                  IconButton(
                    //? Botão de Adição de Poder
                    //? ao acerto
                    icon: const Icon(BootstrapIcons.plus_circle),
                    onPressed: (){
                      setState(() {
                        // Evita Repetições ao adicionar
                        if(!ListIdxPoderes.contains(poderBonusEmSelec["index"])){
                          ListIdxPoderes.add(poderBonusEmSelec["index"]);
                          _addBonusOfensivo();
                        }
                        
                      });                    
                    },
                  ) : const SizedBox(),
                ],
              ) : const SizedBox(),
            ]
          ),
        ),
        actions: [
          //? Botões de remover(se tiver) cancelar e adicionar

          widget.obj.isNotEmpty ?
          TextButton(
            child: const Text('Remover'),
            onPressed: () {
              // Fecha o popup
              Navigator.of(context).pop({"remove": true});
            },
          ) : const SizedBox(),

          TextButton(
            child: const Text('Adicionar'),
            onPressed: () async{
              // Anexa Descrição e Valores a Perícias 
              periciaSelecionada["escopo"] = inputDescrPericia.text;
              periciaSelecionada["valor"] = 0;
              if(["PA01", "PA02"].contains(periciaSelecionada["id"])){
                periciaSelecionada["class"] = "PericiaAddAcerto";
                if(periciaSelecionada["id"] == "PA01"){
                  periciaSelecionada["range"] = false;
                }else if(periciaSelecionada["id"] == "PA02"){
                  periciaSelecionada["range"] = true;
                }
                // Anexa Poderes de Acerto
                periciaSelecionada["bonusPoderes"] = ListIdxPoderes;
              }else{
                periciaSelecionada["class"] = "PericiaAdiciona";
              }
              // E o Poderes se Tiver
              //"PA03" != periciaSelecionada["id"] ?? efeitoBonusSelec
              // Fecha o popup
              Navigator.of(context).pop(periciaSelecionada);
            },
          ),
                
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              // Fecha o popup
              Navigator.of(context).pop({});
            },
          ),
        ],
      );
  }
}
