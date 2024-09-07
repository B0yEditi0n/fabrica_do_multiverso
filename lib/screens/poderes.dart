import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

// Screens de poderes
import 'package:fabrica_do_multiverso/screens/powerEdit.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:flutter/widgets.dart';

class Poderes extends StatefulWidget {
  const Poderes({super.key});

  @override
  State<Poderes> createState() => _PoderesState();
}

class _PoderesState extends State<Poderes> {
  // Declaração de Variáveis
  List poderes = [];
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
                //? Implementar popUp Widget de classes
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
            await showDialog(
              context: context,
              builder: ((BuildContext context) {
                return DynamicDialog();
                
              })),
            
            //! Atualiza a Lista de poderes
            setState(() {
              poderes = personagem.poderes.listaDePoderes();
            })
          },
        ),
    );
  }
}

//# Dialogo Adicionar Poderes


class DynamicDialog extends StatefulWidget {
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  final List<Map> efeitos = [];
  String efeitoSelecionado = '';
  Map objEfeito = {};
  TextEditingController inputTextPoder = TextEditingController();
  
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
  _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    List<dynamic> objEfeitos = jsonDecode(jsonEfeitos);

    // Converte o JSON em objetos
    setState(() {
      Map efeito = {};
      for(efeito in objEfeitos){
        efeitos.add(efeito);
        /*efeitos.add({
          "e_id": efeito["e_id"],
          "efeito": efeito["efeito"],
          "classe_manipulacao": efeito["classe_manipulacao"],
        });*/
      }

      efeitoSelecionado = efeitos.first["e_id"];
      objEfeito = efeitos.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Poderes'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
          
            //* Entrada do Nome
            TextField(
              controller: inputTextPoder,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nome do poder',
              ),
            ),

            const SizedBox(height: 15,),

            DropdownButton<String>(
              value: efeitoSelecionado,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              underline: Container(
                height: 2,
              ),
              onChanged: (value) {
                setState(() {
                  efeitoSelecionado = value!;
                  // Atualiza o selecionado
                  int index = efeitos.indexWhere((mod) => mod["e_id"] == efeitoSelecionado);
                  objEfeito = efeitos[index];
                });
              },
              items: efeitos.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value["e_id"].toString(),
                  child: Text(value["efeito"].toString()),
                );
              }).toList(),
            )
          ]
        )
      ),
      
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            //? Pont de Atenção
            // os efeitos devem já aqui ser
            // instanciados na classe correta

            // Cria a classe 
            if(objEfeito["classe_manipulacao"] != "PacotesEfeitos"){
              await personagem.poderes.novoPoder(inputTextPoder.text.toString(), efeitoSelecionado, objEfeito["classeManipuladora"]);
            }else{
              await personagem.poderes.novoPacote(inputTextPoder.text.toString(), objEfeito["tipo"], objEfeito["efeito"]);
            }
            
            
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),

        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
      ],
      );
  }
}
