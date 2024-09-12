import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Biblioteca de Pericias
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/pericias/pericias.dart';

class screenPericias extends StatefulWidget {
  const screenPericias({super.key});
  @override
  _screenPericiasState createState() => _screenPericiasState();
}

class _screenPericiasState extends State<screenPericias> {
  List<Map> listDefesa = [];
  Defesa defesa = Defesa();
  int custoTotal = 0;

  List<TextEditingController> listInputs = [];

  //* Constante de estilo
  TextStyle headPericias = const TextStyle(fontFamily: "Impact", height: 45);

  @override
  void initState() {
    super.initState();
    _initProg();
    _initialStete();
  }

  _initProg() {
    List classPericias = personagem.pericias.listaPericias;
    for (Map mapPericias in classPericias) {
      listDefesa.add(mapPericias);
    }
  }
  
  _updateValues(){
    custoTotal = personagem.pericias.calculaTotal();
  }
  _initialStete() {
    setState(() {
      // define custo total
      custoTotal = personagem.pericias.calculaTotal();

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
          title: const Text('Pericias'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                    // Fecha A Aplicação & passando alterações
                    Navigator.of(context).pop()
                  }),
        ),
        body: Column(
          children: [
          // Grid de Pericias
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
                                  personagem.pericias.listaPericias[index]["valor"] = int.parse(value),
                                },                                
                                // _updateValues(),
                                setState(() {
                                  custoTotal = personagem.pericias.calculaTotal();
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
