import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: Poderes(),
  ));

}

enum EfeitoSelect {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const EfeitoSelect(this.label, this.color);
  final String label;
  final Color color;
}


class Poderes extends StatefulWidget {
  const Poderes({super.key});

  @override
  State<Poderes> createState() => _PoderesState();
}

class _PoderesState extends State<Poderes> {
  // Declaração de Variáveis
  List _poderes = [];
  List _efeitos = [];

  // Controles de input 
  TextEditingController inputTextPoder = TextEditingController();
  String EfeitoSelecionado = '';
  @override
  
  final TextEditingController colorController = TextEditingController();
  EfeitoSelect? selectedColor;

  void initState() {
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    // Carrega o Poderes text
    String jsonPoderes = await rootBundle.loadString('assets/poderes.json');
    List<dynamic> objPoderes = jsonDecode(jsonPoderes);

    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    List<dynamic> objEfeitos = jsonDecode(jsonEfeitos);

    // Converte o JSON em objetos
    setState(() {
      //? Texte Poder
      Map poder = {};
      for(poder in objPoderes){
        _poderes.add({
          "nome": poder["nome"],
          "efeito": poder["efeito"],
          "graduacao": poder["graduacao"],
        });
      }

      Map efeito = {};
      for(efeito in objEfeitos){
        _efeitos.add({
          "e_id": efeito["e_id"],
          "efeito": efeito["efeito"] 
        });
      }

      EfeitoSelecionado = _poderes.first["efeito"];
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
                  ListTile(
                    title: Text(_poderes[index]['nome']),
                    subtitle: Text("${_poderes[index]['efeito']} ${_poderes[index]['graduacao']}"),
                  ),                  
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
                  title: const Text('Adicionar Poder'),
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
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              EfeitoSelecionado = value!;
                            });
                          },
                          items: _efeitos.map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value["efeito"],
                              child: Text(value["efeito"].toString()),
                            );
                          }).toList(),
                        )
                      ],
                    )
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Adicionar'),
                      onPressed: () {                        
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Cancelar'),
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

