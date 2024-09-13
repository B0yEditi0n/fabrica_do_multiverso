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
  List<Map> ListaPercias = [];
  Pericia pericia = Pericia();
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
    List classPericias = personagem.pericias.ListaPercias;
    for (Map mapPericias in classPericias) {
      ListaPercias.add(mapPericias);
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
      for (Map p in ListaPercias) {
          listInputs.add(TextEditingController(text: p["valor"].toString()));
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
            child: GridView.builder(
              //; configurações de grid
              //; para deixar mais proximo de uma ficha 2 colunas de pericias
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Define o número de colunas
                //maxCrossAxisExtent: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1

                
              ),

              itemCount: ListaPercias.length,
              itemBuilder: (context, index) {
                Pericia defesa = Pericia();
                defesa.init(ListaPercias[index]);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),

                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ListaPercias[index]["nome"]),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                      
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: listInputs[index],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) =>{
                                if(int.tryParse(value) != null){
                                  personagem.pericias.ListaPercias[index]["valor"] = int.parse(value),
                                },                                
                                // _updateValues(),
                                setState(() {
                                  custoTotal = personagem.pericias.calculaTotal();
                                }),
                              }
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text("Total: ${pericia.bonusTotal()}"),
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
