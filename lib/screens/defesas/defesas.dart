import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Biblioteca de Defesas
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/defesas/defesas.dart';

class screenDefesas extends StatefulWidget {
  @override
  _screenDefesasState createState() => _screenDefesasState();
}

class _screenDefesasState extends State<screenDefesas> {
  List<Map> listHabilidade = [];
  Defesa defesa = Defesa();
  int custoTotal = 0;

  List<TextEditingController> listInputs = [];

  //* Constante de estilo
  TextStyle headHabilidade = const TextStyle(fontFamily: "Impact", height: 45);
  @override
  void initState() {
    super.initState();
    _initProg();
    _initialStete();
  }

  _initProg() {
    // List classDefesas = personagem.Defesas.listHab;
    // for (Map mapDefesas in classDefesas) {
    //   listHabilidade.add(mapDefesas);
    // }
  }

  _initialStete() {
    setState(() {
      // // define custo total
      // custoTotal = personagem.Defesas.calculaTotal();

      // // Instancia campos de input
      // for (Map l in listHabilidade) {
      //   if(l["ausente"] != true){ // Caso seja ausente o valor
      //     listInputs.add(TextEditingController(text: l["valor"].toString()));
      //   }else{
      //     listInputs.add(TextEditingController(text: '-'));
      //   }
        
      // }
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a largura da tela
    double screenWidth = MediaQuery.of(context).size.width; // print(screenWidth); // deixar guardado para futuros debug
    // Define o número de colunas com base na largura da tela
    int crossAxisCount = 4;

    if (screenWidth < 1000) {
      // 2 colunas para telas maiores, 1 para menores
      crossAxisCount = screenWidth > 600 ? 2 : 1;
    }

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
            child: GridView.builder(
              padding: const EdgeInsets.all(2.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Define o número de colunas
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 2.0,
                childAspectRatio: 2.5, // Controla o tamanho das células
              ),
              itemCount: listHabilidade.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      listHabilidade[index]["nome"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: listInputs[index],
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                      ],
                      onChanged: ((value) => {
                        currentHabi = personagem.Defesas.getIndex(index),
                        if (int.tryParse(value) != null){
                          currentHabi.valor = int.parse(value),
                          currentHabi.ausente = false,
                        }else if (value == '-'){
                          currentHabi.valor = 0,
                          currentHabi.ausente = true,
                        },

                        personagem.Defesas.listHab[index] = currentHabi.objHabilidade(),

                        setState(() {
                          custoTotal = personagem.Defesas.calculaTotal();
                        }),

                      }),
                    ),
                  ],
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
