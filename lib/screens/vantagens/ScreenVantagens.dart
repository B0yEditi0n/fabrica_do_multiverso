import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';
// Bibliotecas
import 'package:fabrica_do_multiverso/script/ficha.dart';
// pop up
import 'package:fabrica_do_multiverso/screens/vantagens/functions/addVantagens.dart';

class ScreenVantagens extends StatefulWidget {
  const ScreenVantagens({super.key});
  @override
  State<ScreenVantagens> createState() => _ScreenVantagensState();
}

class _ScreenVantagensState extends State<ScreenVantagens> {
  List repertorioVantagens = [];
  List vantagensDisponiveis = [];
  List addVantagens = [];
  
  Map objVantagems = {};

  // Carrega dados do JSON
  @override
  void initState() {
    // TODO: implement initState
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
    });

    // remove já adicionados
    updateAvaliableAdvantage();    
  }

  void _addNewAdvantage(Map obj){
    setState((){
      addVantagens.add(obj);
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
    print(vantagensDisponiveis);
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

      body: ListView.builder(
        itemCount: addVantagens.length,
        itemBuilder: (BuildContext context, int index){
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
                          addVantagens[index]["graduacao"] == 1 
                          ? Text(addVantagens[index]["nome"], textAlign: TextAlign.center,)
                          : Text("${addVantagens[index]["nome"]}[${addVantagens[index]["graduacao"]}]"  , textAlign: TextAlign.center,)
                        ),
                        IconButton(
                        icon: const  Icon(Icons.delete),
                        onPressed: () =>{  
                            setState(() {
                              addVantagens.removeAt(index);
                              updateAvaliableAdvantage();
                            })
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
                });
              }

            }
          );
        }

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