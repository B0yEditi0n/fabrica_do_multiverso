import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Biblioteca de Defesas
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/defesas/defesas.dart';

class screenDefesas extends StatefulWidget {
  const screenDefesas({super.key});
  @override
  _screenDefesasState createState() => _screenDefesasState();
}

class _screenDefesasState extends State<screenDefesas> {
  List<Map> listDefesa = [];
  Defesa defesa = Defesa();
  int custoTotal = 0;

  List<TextEditingController> listInputs = [];

  //* Constante de estilo
  TextStyle headDefesas = const TextStyle(fontFamily: "Impact", height: 45);

  @override
  void initState() {
    super.initState();
    _initProg();
    _initialStete();
  }

  _initProg() {
    List classDefesas = personagem.defesas.listaDefesas;
    for (Map mapDefesas in classDefesas) {
      listDefesa.add(mapDefesas);
    }
  }
  
  _updateValues(){
    custoTotal = personagem.defesas.calculaTotal();
  }
  _initialStete() {
    setState(() {
      // define custo total
      custoTotal = personagem.defesas.calculaTotal();

      // Instancia campos de input
      for (Map d in listDefesa) {
        if(!d["imune"]){ // Caso seja imune
          listInputs.add(TextEditingController(text: d["valor"].toString()));
        }else{
          listInputs.add(TextEditingController(text: "imune"));
        }
      }
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Defesas'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                    // Fecha A Aplicação & passando alterações
                    Navigator.of(context).pop()
                  }),
        ),
        body: Column(
          children: [
          // Grid de Defesas
          Expanded(
            child: ListView.builder(
              itemCount: listDefesa.length,
              itemBuilder: (context, index) {
                Defesa defesa = Defesa();
                defesa.init(listDefesa[index]);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),

                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listDefesa[index]["nome"]),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                      
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: listInputs[index],
                              enabled: !listDefesa[index]["imune"],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) =>{
                                if(int.tryParse(value) != null){
                                  personagem.defesas.listaDefesas[index]["valor"] = int.parse(value),
                                },                                
                                // _updateValues(),
                                setState(() {
                                  custoTotal = personagem.defesas.calculaTotal();
                                }),
                              }
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text("Total: ${defesa.bonusTotal()}"),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            child: Text('Total: ${custoTotal.toString()}')
          )
        ]
      )
    );
  }
}
