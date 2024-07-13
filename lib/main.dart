import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: Poderes(),
  ));

}

class Poderes extends StatefulWidget {
  const Poderes({super.key});

  @override
  State<Poderes> createState() => _PoderesState();
}

class _PoderesState extends State<Poderes> {
  List _poderes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    // Carrega o arquivo JSON
    String jsonString = await rootBundle.loadString('assets/poderes.json');
    List<dynamic> jsonPoderes = jsonDecode(jsonString);

    // Converte o JSON em objetos Poder e atualiza o estado
    setState(() {
      Map poder = {};
      for(poder in jsonPoderes){
        _poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: const Text("Modificadores"),
        ),

        body: ListView.builder(
          itemCount: _poderes.length,
          itemBuilder: (BuildContext context, int index){
            return InkWell(
            onTap: () {
              // Ação a ser realizada quando o Card for clicado
              print('Card $index clicado');
            },
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(_poderes[index]['nome']),
                  Text(_poderes[index]['efeito'])
                ],
              ),
            )
            );
          },
          
        ),

        //
        // add Icone
        //

        floatingActionButton: FloatingActionButton(

          // Ação e PopUP
          onPressed: ()=> showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('AlertDialog Title'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('This is a demo alert dialog.'),
                        Text('Would you like to approve of this message?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Approve'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
    );
  }
}

