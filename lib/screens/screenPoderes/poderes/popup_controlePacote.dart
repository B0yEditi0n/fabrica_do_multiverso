import 'package:flutter/material.dart';

//Screens
import 'package:fabrica_do_multiverso/screens/screenPoderes/editorPoderes.dart';
// popups
import 'package:fabrica_do_multiverso/screens/screenPoderes/poderes/popup_addPoderes.dart';

// Lib de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

class ControladorDePacotes extends StatefulWidget {
  final int indexPacote;
  const ControladorDePacotes({required this.indexPacote});

  @override
  State<ControladorDePacotes> createState() => _ControladorDePacotesState();
}

class _ControladorDePacotesState extends State<ControladorDePacotes> {
  //# Declarações
  PacotesEfeitos pacote = PacotesEfeitos();
  Map objPacote = {};
  List poderes = [];
  bool nomearEfeitos = true;

  @override
  void initState() {
    super.initState();
    //objPacote = personagem.poderes.poderesLista[widget.indexPacote];
    _inicializarVariaveis();
  }

  Future _addPoderes(Map objEfeito) async{
    pacote.efeitos.add(objEfeito);
  }

  _inicializarVariaveis(){
    objPacote = personagem.poderes.poderesLista[widget.indexPacote];
    pacote.instanciarMetodo(objPacote);
    poderes.addAll(objPacote["efeitos"]);

    if(["R", "E" "D"].contains(pacote.getType())){ nomearEfeitos = true; }
    if(["L"].contains(pacote.getType())){ nomearEfeitos = true; }
    
  }


  //# Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: const Text("Poderes"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                // Salva Alterações
                setState(() {
                  personagem.poderes.poderesLista[widget.indexPacote] = pacote.retornaObj();
                }),
                
                // Fecha A Aplicação
                Navigator.of(context).pop()
              }
          ), 
        ),

        body: ListView.builder(
          itemCount: poderes.length,
          itemBuilder: (BuildContext context, int index){
            return InkWell(
            child: Card(
              child: 
              Row( children: <Widget> [
                Expanded(
                  child:
                    //# Card de Exibição
                    // Exibe os poderes ativos
                    poderes[index]["classe_manipulacao"] != "PacotesEfeitos" 
                    ? ListTile(
                      title: Text(poderes[index]['nome']),
                      subtitle: Text("${poderes[index]['efeito']} ${poderes[index]['graduacao']}"),
                    ) 
                    : ListTile(
                      title: Text('${poderes[index]["efeito"]}: ${poderes[index]['nome']}'),
                      //subtitle: Text("${poderes[index]['nome']} ${poderes[index]['custo']}"),
                    ),
                ),

                IconButton(
                  icon: const  Icon(Icons.delete),
                  onPressed: () =>{
                    personagem.poderes.poderesLista.removeAt(index),
                    setState(() {
                      poderes = personagem.poderes.listaDePoderes();  
                    })
                  }
                )

              ],)
            ),
            onTap: () {
              atualizarValores(){
                setState(() {
                  poderes = personagem.poderes.listaDePoderes();
                });
              }

              if(poderes[index]["classe_manipulacao"] != "PacotesEfeitos"){ 
                // Navigator.push()
                //   MaterialPageRoute(builder: (context) => ControladorDePacotes(indexPacote: index,)),
                // ).then((result)=>{expression
                //   atualizarValores()
                // });
              };

              
              // Atualiza os Poderes
              
            },
            );
          },
          
        ),

        // add Icone

        floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            objPacote = {},            
            objPacote = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DynamicDialog(ea: false, descNome: nomearEfeitos),
              )
            ),
            //! Atualiza a Lista de poderes
            if(objPacote.isNotEmpty){
              _addPoderes(objPacote)
            }            
          },
        ),
    );
  }
}