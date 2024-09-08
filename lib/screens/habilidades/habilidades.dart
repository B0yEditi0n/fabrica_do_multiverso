import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Habilidades extends StatefulWidget {
  @override
  //Habilidades({super.key});
  _HabilidadesState createState() => _HabilidadesState();
}

class _HabilidadesState extends State<Habilidades> {
  final List<String> labels = [
    'FORÇA', 'VIGOR', 'AGILIDADE', 'DESTREZA',
    'LUTA', 'INTELECTO', 'PRONTIDÃO', 'PRESENÇA'
  ];
  List<TextEditingController> listInputs = [];
  
  // TextEditingController txtForca     = TextEditingController();
  // TextEditingController txtVigor     = TextEditingController(); 
  // TextEditingController txtAgilidade = TextEditingController();
  // TextEditingController txtDestreza  = TextEditingController();
  // TextEditingController txtLuta      = TextEditingController();
  // TextEditingController txtIntelecto = TextEditingController();
  // TextEditingController txtProntidao = TextEditingController();
  // TextEditingController txtPresenca  = TextEditingController();
  
  //* Constante de estilo
  TextStyle headHabilidade = const TextStyle(
    fontFamily: "Impact",
    height: 45
  );
  @override
  void initState() {
    super.initState();
    _initialStete();
  }


  _initialStete(){
    setState(() {
      for(String l in labels){
        listInputs.add(TextEditingController(
        ));
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a largura da tela
    double screenWidth = MediaQuery.of(context).size.width;
    // Define o número de colunas com base na largura da tela
    int crossAxisCount = 4;
    print(screenWidth);
    if(screenWidth < 1000){
      
      // 2 colunas para telas maiores, 1 para menores
      crossAxisCount = screenWidth > 600 ? 2 : 1;
    }    

    return Scaffold(
      appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: const Text('Habilidades'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                // Fecha A Aplicação & passando alterações
                Navigator.of(context).pop()
              }
          ), 
      ),
      body: GridView.builder(
        
        padding: const EdgeInsets.all(2.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Define o número de colunas
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 2.5, // Controla o tamanho das células
        ),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labels[index],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], 
                ),
              ],
          );
        },
      ),
    );
  }
}
