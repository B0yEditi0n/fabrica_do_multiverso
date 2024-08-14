import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

import 'package:fabrica_do_multiverso/script/ficha.dart' ;

//
// Dialogo Adicionar Poderes
//

class AddModificadorSelecionador extends StatefulWidget {
  List etiquetas = [];
  AddModificadorSelecionador({super.key, required this.etiquetas});
  @override
  _AddModificadorSelecionadorState createState() => _AddModificadorSelecionadorState();
}

class _AddModificadorSelecionadorState extends State<AddModificadorSelecionador> {
  //String _title;A
  // Declaração de Variáveis
  //List poderes = [];
  var modificadores = [];

  TextEditingController inputTextPoder = TextEditingController();
  String modificadorSelecionado = '';
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
    
  }
  Future<void> _carregarDados() async {
    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    String jsonMod = await rootBundle.loadString('assets/poderes/modificadores.json');
    List objEfeitos = jsonDecode(jsonEfeitos);
    Map objMod = jsonDecode(jsonMod);
    

    Future<List> pegaEfeito() async{
      String idEfeito = poder.retornaObj()["e_id"];
      int index = objEfeitos.indexWhere((efeito) => efeito["e_id"] == idEfeito);
      Map efeito = objEfeitos[index];
      List efeitosMod = [];

      if (efeito["modificadores"] != null){
        efeitosMod = efeito["modificadores"];
      }

      return efeitosMod;
      
    }

    Future<List> pegaModificadores() async{
      String etiqueta = '';
      List listMods = [];

      // Lista de Efeitos Genéricos
      List modGerais = objMod["gerais"];
      listMods += modGerais;

      // Seleciona Gerais

      

      for(etiqueta in widget.etiquetas){
        var currentMod = objMod[etiqueta];
        listMods += currentMod;
      }
      return listMods;
    }

    List efeitosMod = await pegaEfeito();
    List modsGerais = await pegaModificadores();
    
    setState(() {
      // Converte o JSON em objetos
      
      // Apenda todos em um só
      modificadores = efeitosMod;
      modificadores += modsGerais;
      //print(modificadores);
      // Define o primeiro
      modificadorSelecionado = modificadores.first["m_id"];
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
            /*TextField(
              controller: inputTextPoder,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nome do poder',
              ),
            ),

            const SizedBox(height: 15,),*/

            DropdownButton<String>(
              value: modificadorSelecionado,
              //icon: const Icon(Icons.arrow_downward),
              //elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              /*underline: Container(
                height: 2,
              ),*/
              onChanged: (String? value) {
                setState(() {
                  //modificadorSelecionado = value!;
                });
              },
              items: modificadores.map<DropdownMenuItem<String>>((value) {
                print('Variável item valor');
                print(value);
                return DropdownMenuItem<String>(
                  value: value["m_id"],
                  child: Text(value["nome"].toString()),
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
