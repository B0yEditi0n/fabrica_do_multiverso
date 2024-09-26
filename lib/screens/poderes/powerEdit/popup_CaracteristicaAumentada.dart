import 'dart:developer';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenPoderes.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';
//
// Dialogo Adicionar Poderes
//

class AddCaractAumet extends StatefulWidget {
  @override
  _AddCaractAumetState createState() => _AddCaractAumetState();
}

class _AddCaractAumetState extends State<AddCaractAumet> {
  List caractCompra = [];
  Map caractSel = {};
  int gradValue = 1;

  EfeitoBonus poderCompra = EfeitoBonus();

  TextEditingController inputValue = TextEditingController( text: '1' );

  @override  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
    
  }
  Future<bool> _carregarDados() async {
    
    // força um cast na classe para acessar os metodos sem problemas
    // de sintaxe
    poderCompra = poder as EfeitoBonus;

    List listTemp = await poderCompra.returnListOpt();  
    setState(() {   
      caractCompra = listTemp;
      caractSel = caractCompra.first;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Caracteristica Selecionada'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[             
            // Valor da Caracteristica (Atenção para Vantagens)
            SizedBox(
              width: 50,
              child: TextField(
                controller: inputValue,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  // Validar a entrada para evitar texto
                  // E Evita o máximo
                  setState((){
                    gradValue = int.parse(value);
                  });  
                }
              )
            ),

            const SizedBox(height: 30),

            // Escolha da Caracteristica 
            DropdownButton(
              value: caractSel,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              items: caractCompra.map<DropdownMenuItem<Map>>((value) {
                return DropdownMenuItem(
                  value: value, 
                  child: Text(value["nome"].toString()),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  caractSel = value!;
                });
              },

            ),
            
          ]
        )
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Atualiza a Classe
            
            //poderCompra.addOpt(optSelecionado); 

            // Fecha o Popup
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
