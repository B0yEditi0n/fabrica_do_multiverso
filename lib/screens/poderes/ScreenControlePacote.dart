import 'package:flutter/material.dart';

//Screens
import 'package:fabrica_do_multiverso/screens/poderes/ScreenEditorPoderes.dart';
// popups
import 'package:fabrica_do_multiverso/screens/poderes/poderes/popup_addPoderes.dart';

// Lib de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';

class ControladorDePacotes extends StatefulWidget {
  final Map objPacote;

  const ControladorDePacotes({super.key, required this.objPacote});

  @override
  State<ControladorDePacotes> createState() => _ControladorDePacotesState();
}

class _ControladorDePacotesState extends State<ControladorDePacotes> {
  //# Declarações
  PacotesEfeitos pacote = PacotesEfeitos();
  int indexPoder = -1;
  bool retornoDePacote = true;
  Map objPacote = {};
  Map objPoder = {}; // Retorno objtido de chamadas
  List poderes = [];
  bool nomearEfeitos = true;

  // Controle de texto
  TextEditingController nomePoder = TextEditingController();
  @override
  void initState() {
    super.initState();
    //objPacote = personagem.poderes.poderesLista[widget.indexPacote];
    _inicializarVariaveis();
  }

  _updateAfterCreate(Efeito efeito){
    pacote.efeitos.add(efeito.retornaObj());
    setState(() {
      objPacote = pacote.retornaObj();
      poderes = pacote.efeitos;
    });
  }

  Future _addPoderes(Map objEfeito) async{
    
    if(objEfeito["classe_manipulacao"] != "PacotesEfeitos"){
      Efeito efeito = Efeito();
      await efeito.instanciarMetodo(objEfeito["nome"], objEfeito["e_id"])
      .then((resulte)=>{
        _updateAfterCreate(efeito)
      });
    }else{
      PacotesEfeitos enpacotado = PacotesEfeitos();
      await enpacotado.instanciarMetodo(objEfeito)
      .then((resulte)=>{
        // Apos a chamada atualiza a lista
        pacote.efeitos.add(enpacotado.retornaObj()),
        setState(() {
          objPacote = pacote.retornaObj();
          poderes = pacote.efeitos;
        })
      });
    }
    
    
    
    
    
  }

  _inicializarVariaveis(){
    // inicialização do objeto
    objPacote = widget.objPacote;
    pacote.instanciarMetodo(objPacote);
    poderes.addAll(objPacote["efeitos"]);

    // define se os efeitos adionados devem ter nome
    if(["R", "E" "D"].contains(pacote.getType())){ nomearEfeitos = true; }
    if(["L"].contains(pacote.getType())){ nomearEfeitos = true; }

    nomePoder.text = pacote.nomePacote;
    
  }

  //# Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: objPacote["nome"] != "" 
          ? Text("${objPacote["nome"]}")
          : Text("Poderes de (${objPacote["efeito"]})"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                // Fecha A Aplicação & passando alterações
                Navigator.of(context).pop(pacote.retornaObj())
              }
          ), 
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: nomePoder,
                style: const TextStyle(
                  
                ),
                onChanged: (valor) =>{
                  pacote.nomePacote = nomePoder.text,
                  objPacote = pacote.retornaObj(),
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
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
                          pacote.efeitos.removeAt(index),
                          setState(() {
                            poderes = pacote.efeitos;
                          })
                        }
                      )
              
                    ],)
                  ),
                  onTap: () async {
                    atualizarValores(){
                      setState(() {
                        poderes = pacote.efeitos;
                      });
                    }

                    Map returnObjPoder = {};
                    Map inputObjEfeito = poderes[index];

                    if(poderes[index]["classe_manipulacao"] != "PacotesEfeitos"){
                      
                      returnObjPoder = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => powerEdit(objEfeito: inputObjEfeito)),
                      );
                    }else{
                      returnObjPoder = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ControladorDePacotes(objPacote: inputObjEfeito)),
                      );
                    }
                    pacote.efeitos[index] = returnObjPoder;
                    atualizarValores();                      
                  },
                  );
                },
                
              ),
            ),
          ],
        ),

        // add Icone

        floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            objPoder = {},            
            objPoder = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DynamicDialog(tipo: objPacote["tipo"], descNome: nomearEfeitos))
            ),
            //! Atualiza a Lista de poderes
            if(objPoder.isNotEmpty){
              _addPoderes(objPoder)
            }            
          },
        ),
    );
  }
}