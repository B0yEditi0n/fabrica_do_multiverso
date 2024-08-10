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
            onTap: () {
              atualizarValores(){
                setState(() {
                  poderes = personagem.poderes.listaDePoderes();
                });
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => powerEdit(idPoder: index)),
              ).then((result)=>{
                atualizarValores()
              });

              
              // Atualiza os Poderes
              
            },
            child: Card(
              child: 
              Row( children: <Widget> [
                Expanded(
                  child: 
                    ListTile(
                      title: Text(poderes[index]['nome']),
                      subtitle: Text("${poderes[index]['efeito']} ${poderes[index]['graduacao']}"),
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
            )
            );
          },
          
        ),

        //
        // add Icone
        //

        floatingActionButton: FloatingActionButton(

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
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
    );
  }
}

//
// Dialogo Adicionar Poderes
//

class DynamicDialog extends StatefulWidget {
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  //String _title;A
  // Declaração de Variáveis
  //List poderes = [];
  final efeitos = [];

  TextEditingController inputTextPoder = TextEditingController();
  String EfeitoSelecionado = '';
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
        efeitos.add({
          "e_id": efeito["e_id"],
          "efeito": efeito["efeito"] 
        });
      }

      EfeitoSelecionado = efeitos.first["e_id"];
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
              value: EfeitoSelecionado,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              underline: Container(
                height: 2,
              ),
              onChanged: (String? value) {
                setState(() {
                  EfeitoSelecionado = value!;
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
            // Atualiza a Classe
            await personagem.poderes.novoPoder(inputTextPoder.text.toString(), EfeitoSelecionado);
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
