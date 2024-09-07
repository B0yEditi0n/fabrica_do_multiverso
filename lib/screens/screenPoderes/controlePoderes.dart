import 'package:flutter/material.dart';

// Screens de poderes
import 'package:fabrica_do_multiverso/screens/screenPoderes/editorPoderes.dart';
import 'package:fabrica_do_multiverso/screens/screenPoderes/poderes/popup_addPoderes.dart';
import 'package:fabrica_do_multiverso/screens/screenPoderes/poderes/popup_controlePacote.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:flutter/widgets.dart';

class Poderes extends StatefulWidget {
  const Poderes({super.key});

  @override
  State<Poderes> createState() => _PoderesState();
}

class _PoderesState extends State<Poderes> {
  // Declaração de Variáveis
  List poderes = [];
  Map objEfeito = {};
  @override

  void initState() {
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    // Carrega poderes já instanciados
    setState(() {
      //List poderes = [];
      poderes = personagem.poderes.listaDePoderes();  
    });
  }
  Future _addPoderes(Map objPoder) async{
    if(objEfeito["classe_manipulacao"] != "PacotesEfeitos"){
      await personagem.poderes.novoPoder(objEfeito["nome"], objEfeito["e_id"], objEfeito["classeManipuladora"]);
    }else{
      await personagem.poderes.novoPacote(objEfeito["nome"], objEfeito["tipo"], objEfeito["efeito"]);
    }
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: const Text("Poderes"),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => powerEdit(idPoder: index)),
                ).then((result)=>{
                  atualizarValores()
                });
              }else{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ControladorDePacotes(indexPacote: index)),
                ).then((result)=>{
                  atualizarValores()
                });
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
            objEfeito = {},
            objEfeito = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DynamicDialog(ea: false, descNome: true),
              )
            ),
            //! Atualiza a Lista de poderes
            if(objEfeito.isNotEmpty){
              _addPoderes(objEfeito)
            }            
          },
        ),
    );
  }
}