import 'package:flutter/material.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';


class powerEdit extends StatefulWidget {
  final int idPoder;
  const powerEdit({super.key, required this.idPoder});

  @override
  State<powerEdit> createState() => _powerEditState();
}

class _powerEditState extends State<powerEdit> {
  // Declaração
  var poder = Efeito();
  var objPoder = {};

  @override

  void initState() {
    super.initState();
    _startPower(); // Carrega os dados ao iniciar o estado
  }

  void _startPower(){
    objPoder = personagem.poderes.poderesLista[widget.idPoder];
    poder.reinstanciarMetodo(objPoder);    
  }

  /*********
  * WIDGETs
  ************/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edição do Poder'),//'${objPoder["nome"]}'),
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Text(
                  '${objPoder["efeito"]}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Impact',
                    fontWeight: FontWeight.bold,
                    //decoration: TextDecoration.lineThrough
                  )
                )
              ]
          )
          
        ],
      ),
    );
  }
}