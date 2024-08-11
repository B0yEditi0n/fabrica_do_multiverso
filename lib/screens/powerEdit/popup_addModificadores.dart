import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

import 'package:fabrica_do_multiverso/script/ficha.dart' ;

//
// Dialogo Adicionar Poderes
//

class AddmodificadorSelecionador extends StatefulWidget {
  List etiquetas = [];
  AddmodificadorSelecionador({super.key, required this.etiquetas});
  @override
  _AddmodificadorSelecionadorState createState() => _AddmodificadorSelecionadorState();
}

class _AddmodificadorSelecionadorState extends State<AddmodificadorSelecionador> {
  //String _title;A
  // Declaração de Variáveis
  //List poderes = [];
  final modificadores = [];

  TextEditingController inputTextPoder = TextEditingController();
  String modificadorSelecionado = '';
  @override
  
  void initState() async {
    // _title = widget.title;
    super.initState();
    await _carregarDados(); // Carrega os dados ao iniciar o estado
    
  }
  Future<void> _carregarDados() async {
    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    String jsonMod = await rootBundle.loadString('assets/poderes/modificadores.json');
    List objEfeitos = jsonDecode(jsonEfeitos);
    List objMod = jsonDecode(jsonMod);

    List <Map> pegaEfeito(){
      String idEfeito = poder.retornaObj()["e_id"];
      int index = objEfeitos.indexWhere((efeito) => efeito["e_id"] == idEfeito);
      Map efeito = objEfeitos[index];
      
      return efeito["modificadores"];

    }

    List <Map> pegaModificadores(){
      String etiqueta = '';
      int index = -1;
      List <Map> mods = objMod["gerais"];

      // Seleciona Gerais
      objEfeitos.indexWhere((mod) => mod  == "E010");

      for(etiqueta in widget.etiquetas){
        objMod[etiqueta]
      }
      return mods;
    }

    // Converte o JSON em objetos
    List modificadores = [];
    List efeitosMod = pegaEfeito();
    List modsGerais = pegaModificadores() ;

    setState(() {
      
      
      // Apenda todos em um só
      modificadores = [efeitosMod];


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
              value: modificadorSelecionado,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              underline: Container(
                height: 2,
              ),
              onChanged: (String? value) {
                setState(() {
                  modificadorSelecionado = value!;
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
            await personagem.poderes.novoPoder(inputTextPoder.text.toString(), modificadorSelecionado);
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
