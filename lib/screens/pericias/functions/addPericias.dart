//# Dialogo de Adição de Perícias

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
  List addOfensivePoderes = [];   // Já adicionados
  List<String> ListIdPoderes = [];  // Indice que volta pra retorno

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
    if(addOfensivePoderes.length != ListIdPoderes.length){
      setState(() {
        // Adiciona os poderes a Lista
        addOfensivePoderes = ofensivePoderes.where((o)=>ListIdPoderes.contains(o["idCriacao"])).toList();
      });
    }
    
  }

  Future<void> _carregarDados() async {
    periciaSelecionada = periciaListAdd.first;

    // Efeitos Ofensivos
    int rangeOfensive = 0;
    if(widget.obj.isEmpty){
      periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
      periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
    }else{ // Caso já esteja instanciado
      widget.obj["id"] == "PA01" ? rangeOfensive = 1 : null;
      widget.obj["id"] == "PA02" ? rangeOfensive = 2 : null;
    }
    ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);

    // caso haja objetos carregados
    if(widget.obj.isNotEmpty){
      periciaSelecionada["id"] = widget.obj["id"];
      periciaSelecionada["nome"] = widget.obj["nome"];
      periciaSelecionada["idHab"] = widget.obj["idHab"];
      periciaSelecionada["treinado"] = widget.obj["treinado"];
      inputDescrPericia.text = widget.obj["escopo"];
      if(widget.obj["bonusPoderes"] != null){
        ListIdPoderes = widget.obj["bonusPoderes"];
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
                  //? Seleciona poder a Ser adicionado
                  MultiSelectDialogField(
                    items: ofensivePoderes.map<MultiSelectItem>((value) {
                      return MultiSelectItem(
                        value["idCriacao"],
                        "${value["nome"]}${value["nome"].isNotEmpty ? ":" : ""} ${value["efeito"]}"
                      );
                    }).toList(),
                    listType: MultiSelectListType.LIST,
                    initialValue: ListIdPoderes,

                    // Pop UP
                    title: const Text("Poderes"),
                    searchable: true,
                    checkColor: const Color.fromARGB(255, 243, 243, 243),
                    selectedColor: Theme.of(context).primaryColorDark,
                    itemsTextStyle: const TextStyle(
                      color: Colors.white
                    ),
                    selectedItemsTextStyle: const TextStyle(
                      color: Colors.white
                    ),



                    decoration: BoxDecoration(
                      //color: PrimaryScrollController.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 8, 0),
                        width: 2,
                      ),
                    ),
                    buttonIcon: const Icon(
                      BootstrapIcons.fire,
                      color: Color.fromARGB(255, 255, 8, 0),
                    ),
                    buttonText: const Text(
                      "Selecionar Poderes",
                      style: TextStyle(
                        //color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),  

                    onConfirm: (results) {
                      setState(() {
                        // Evita Repetições ao adicionar
                        ListIdPoderes = [];
                        ListIdPoderes.addAll(results.cast<String>());
                        _addBonusOfensivo();                        
                      });
                    },
                  )
                ],
              ) : const SizedBox(),
            ]
          ),
        ),
        actions: [
          //? Botões de remover(se tiver) cancelar e adicionar
          TextButton(
            child: const Text('Adicionar'),
            onPressed: () async{
              // Anexa Descrição e Valores a Perícias 
              periciaSelecionada["escopo"] = inputDescrPericia.text;
              periciaSelecionada["valor"] = 0;

              if(widget.obj["valor"] != null){periciaSelecionada["valor"] = widget.obj["valor"];}
              if(widget.obj["idCriacao"] != null){periciaSelecionada["idCriacao"]= widget.obj["idCriacao"];}

              if(["PA01", "PA02"].contains(periciaSelecionada["id"])){
                periciaSelecionada["class"] = "PericiaAddAcerto";
                if(periciaSelecionada["id"] == "PA01"){
                  periciaSelecionada["range"] = false;
                }else if(periciaSelecionada["id"] == "PA02"){
                  periciaSelecionada["range"] = true;
                }
                // Anexa Poderes de Acerto
                periciaSelecionada["bonusPoderes"] = ListIdPoderes;
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
