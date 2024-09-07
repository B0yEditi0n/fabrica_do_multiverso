import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';

//# Dialogo Adicionar Poderes

class DynamicDialog extends StatefulWidget {
  bool ea = false;
  bool descNome = true;
  DynamicDialog({super.key, required this.ea, required this.descNome});
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
    String jsonPacotes = await rootBundle.loadString('assets/poderes/pacotes.json');
    List<dynamic> objEfeitos = jsonDecode(jsonEfeitos);
    List<dynamic> objPacotes = jsonDecode(jsonPacotes);
    if(!widget.ea){ // Impede efeitos alternativos sejam adiconados de novo
      objPacotes.removeWhere((obj)=> obj["e_id"] == "E043" || obj["e_id"] == "E044");
    }
    objEfeitos.addAll(objPacotes);

    // Converte o JSON em objetos
    setState(() {
      Map efeito = {};
      for(efeito in objEfeitos){
        efeitos.add(efeito);
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
            objEfeito["nome"] = inputTextPoder.text;
            // Fecha o popup
            Navigator.of(context).pop(objEfeito);
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
