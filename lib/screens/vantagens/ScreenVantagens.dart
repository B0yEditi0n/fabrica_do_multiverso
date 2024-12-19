import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';
// Bibliotecas
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
// pop up
import 'package:fabrica_do_multiverso/screens/vantagens/functions/addVantagens.dart';

class ScreenVantagens extends StatefulWidget {
  const ScreenVantagens({super.key});
  @override
  State<ScreenVantagens> createState() => _ScreenVantagensState();
}

class _ScreenVantagensState extends State<ScreenVantagens> {
  int cutoTotal = 0;

  List repertorioVantagens = [];
  List vantagensDisponiveis = [];
  List addVantagens = [];
  
  Map objVantagems = {};

  // Carrega dados do JSON
  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    _carregaDados();
  }
  void _carregaDados() async {
    // Puxa dados json
    String jsonEfeitos = await rootBundle.loadString('assets/vantagens.json');
    repertorioVantagens = jsonDecode(jsonEfeitos).toList();
    
    // Checa o que já foi adicionado
    setState(() {
      addVantagens.addAll(personagem.vantagens.listaVantagens);
      cutoTotal = personagem.vantagens.cutoTotal();
    });

    // remove já adicionados
    updateAvaliableAdvantage();    
  }

  void _addNewAdvantage(Map obj){
    setState((){
      addVantagens.add(obj);
      cutoTotal = personagem.vantagens.cutoTotal();
      // Remove dos Disponíveis
      vantagensDisponiveis.removeWhere((v) => v["id"] == obj["id"]);
    });
  }
  void updateAvaliableAdvantage(){
    // refaz a list de vantagens disponíveis
    vantagensDisponiveis = [];
    vantagensDisponiveis.addAll(repertorioVantagens);
    for(Map addedVantage in addVantagens){
      vantagensDisponiveis.removeWhere((e) => addedVantage["id"] == e["id"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Vantagens'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async => {
              // Fecha A Aplicação & passando alterações
              personagem.vantagens.listaVantagens = [],
              personagem.vantagens.listaVantagens.addAll(addVantagens.map((e) => e)),
              Navigator.of(context).pop()
            }),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: addVantagens.length,
              itemBuilder: (BuildContext context, int index){

                Vantagem currentVatagem = Vantagem();
                currentVatagem.init(addVantagens[index]);
                
                return InkWell(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(children:[
                              Expanded(
                                child: 
                                currentVatagem.returnTotalGrad() == 1 
                                ? Text(
                                  "${addVantagens[index]["nome"]} ${addVantagens[index]["txtDec"].isNotEmpty
                                    ? '(${addVantagens[index]["txtDec"]})' 
                                    : ""
                                  }", 
                                textAlign: TextAlign.center,
                                )
                                : Text(
                                  "${addVantagens[index]["nome"]}[${currentVatagem.returnTotalGrad()}] ${addVantagens[index]["txtDec"].isNotEmpty 
                                    ? '(${addVantagens[index]["txtDec"]})' 
                                    : ""
                                  }", 
                                  textAlign: TextAlign.center,
                                )
                              ),
                              IconButton(
                              icon: const  Icon(Icons.delete),
                              onPressed: () =>{  
                                  if(!addVantagens[index]["addByPower"]){
                                    setState(() {
                                    addVantagens.removeAt(index);
                                    updateAvaliableAdvantage();
                                    cutoTotal = personagem.vantagens.cutoTotal();
                                  })
                                  } 
                                  
                                }
                              ),
                            ]),
                          ),
                        ),
                      )
                    ]
                  ),
                  onTap: () async{
                    // Ao selecionar uma vantagem já adicionada
                    objVantagems = {};
                    objVantagems = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PopUpAddVantagem(repertorioVantagens: vantagensDisponiveis, obj: addVantagens[index]),
                      )
                    );
                    
                    if(objVantagems.isNotEmpty){ 
                      setState(() {
                        addVantagens[index] = objVantagems;
                        cutoTotal = personagem.vantagens.cutoTotal();
                      });
                    }
                
                  },
                
                );
              },
              
            
            ),
          ),


          Text("Total $cutoTotal")
        ],
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar Vantagem',
        child: const Icon(Icons.add),
        onPressed: () async => {
          objVantagems = {},
          objVantagems = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PopUpAddVantagem(repertorioVantagens: vantagensDisponiveis, obj: {}),
            )
          ),
          if(objVantagems.isNotEmpty){ _addNewAdvantage(objVantagems) }
        },
      ),
    );
  }
}