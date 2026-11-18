import 'package:fabrica_do_multiverso/screens/pericias/ScreenPericias.dart';
import 'package:fabrica_do_multiverso/screens/vantagens/ScreenVantagens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

// Import de imagens
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Salvamento de Arquivos
import 'script/download.dart';
import 'package:fabrica_do_multiverso/script/armazenamento.dart';
import 'package:fabrica_do_multiverso/script/importacao/importa_poder_supremo.dart';

// Temas
import 'package:fabrica_do_multiverso/theme/theme.dart';
// Screen de Habilidades
import 'package:fabrica_do_multiverso/screens/habilidades/ScreenHabilidades.dart';
// Screen de Defesas
import 'package:fabrica_do_multiverso/screens/defesas/ScreenDefesas.dart';
// Screens de Poderes
import 'package:fabrica_do_multiverso/screens/poderes/ScreenPoderes.dart';
// Screen de Poderes
import 'package:fabrica_do_multiverso/screens/complicacoes/ScreenComplicacoes.dart';
// Screen de Ofensiva
import 'package:fabrica_do_multiverso/screens/ofensiva/ScreenOfensiva.dart';

// Compnentes
import 'package:fabrica_do_multiverso/screens/components/logErros.dart';
import 'package:fabrica_do_multiverso/screens/components/save_option_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catálogos carregados antes da primeira tela
  await personagem.init();
  runApp(FabricaHerois());
}

class FabricaHerois extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabrica de Heróis',
      theme: temaPadrao(), //(
      //   primarySwatch: Colors.blue,
      // ),
      home: const ScreenInicial(),
      routes: {
        '/home': (context) => const ScreenInicial(),
        '/habilidades': (context) => const ScreenHabilidades(),
        '/defesas': (context) => const ScreenDefesas(),
        '/poderes': (context) => const ScreenPoderes(),
        '/vantagens': (context) => const ScreenVantagens(),
        '/pericias': (context) => const ScreenPericias(),
        '/complicacoes': (context) => const ScreenComplicacoes(),
        '/ofensiva': (context) => const ScreenOfensiva(),
        '/componentLog': (context) => const LogPopupError(),
      },
    );
  }
}

class ScreenInicial extends StatefulWidget {
  const ScreenInicial({super.key});

  @override
  State<ScreenInicial> createState() => _ScreenInicialState();
}

class _ScreenInicialState extends State<ScreenInicial> {
  ValidaNpPersonagem validador = ValidaNpPersonagem(); // objeto de validação
  List logError = [];

  Uint8List fileImg = Uint8List(0); // Imagem do Personagem;

  TextEditingController txtControlName = TextEditingController();
  TextEditingController txtNP = TextEditingController();

  @override
  void initState() {
    super.initState();
    txtControlName.text = personagem.nomePersonagem;
    txtNP.text = personagem.np.toString();
    _abrirUltimaFicha();
  }

  void _validaFicha() {
    // Chamado ao voltar de qualquer seção: redesenha e guarda a ficha
    setState(() {});
    _salvarLocal();
  }

  Future<void> _salvarLocal() async {
    try {
      await Armazenamento.salvar(personagem, fileImg);
    } catch (e) {
      // Falha de disco não deve interromper a edição da ficha
      debugPrint('Falha ao salvar a ficha: $e');
    }
  }

  void _mostrarFicha(Uint8List imagem) {
    // Reflete na tela a ficha que acabou de ser aberta ou criada
    setState(() {
      fileImg = imagem;
      txtControlName.text = personagem.nomePersonagem;
      txtNP.text = personagem.np.toString();
    });
  }

  Future<int?> _escolherPersonagem(List<String> nomes) {
    // Portfólio do Poder Supremo com vários personagens
    return showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Qual personagem importar?'),
        children: [
          for (int i = 0; i < nomes.length; i++)
            SimpleDialogOption(
              child: Text(nomes[i]),
              onPressed: () => Navigator.pop(context, i),
            ),
        ],
      ),
    );
  }

  void _mostrarMensagens(String titulo, List<String> mensagens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: 400,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (String m in mensagens)
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(m),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fechar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirUltimaFicha() async {
    // Ao abrir o aplicativo continua da ficha guardada (só existe uma)
    try {
      Map? dados = await Armazenamento.carregar();
      if (dados == null) return;
      personagem = Ficha();
      await personagem.init();
      await personagem.reInit(dados["ficha"]);
      if (mounted) _mostrarFicha(dados["imagem"]);
    } catch (e) {
      debugPrint('Falha ao abrir a ficha guardada: $e');
    }
  }

  Future<void> _novaFicha() async {
    // O aplicativo gerencia uma ficha por vez: começar outra descarta a atual
    bool confirmou = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nova ficha'),
            content: const Text(
                'A ficha atual será apagada deste aparelho. Use "Baixar Ficha" antes se quiser guardá-la.'),
            actionsAlignment: MainAxisAlignment.center,
            actionsOverflowAlignment: OverflowBarAlignment.center,
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Apagar e começar'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmou) return;

    try {
      await Armazenamento.limpar();
    } catch (e) {
      debugPrint('Falha ao apagar a ficha guardada: $e');
    }
    personagem = Ficha();
    await personagem.init();
    if (mounted) _mostrarFicha(Uint8List(0));
  }

  Widget _linhaPontos(String rotulo, int? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(rotulo), Text('$valor')],
      ),
    );
  }

  Widget _resumoPontos() {
    Map<String, int> r = personagem.resumoPontos();
    bool estourou = r["restante"]! < 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              'Pontos de poder: ${r["total"]} / ${r["disponivel"]}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: estourou ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            Text(estourou
                ? '${-r["restante"]!} acima do disponível'
                : '${r["restante"]} restantes'),
            const Divider(),
            _linhaPontos('Habilidades', r["habilidades"]),
            _linhaPontos('Defesas', r["defesas"]),
            _linhaPontos('Perícias', r["pericias"]),
            _linhaPontos('Vantagens', r["vantagens"]),
            _linhaPontos('Poderes', r["poderes"]),
            if (r["equipamentoUsado"]! > 0 || r["equipamentoDisponivel"]! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                    'Pontos de equipamento: ${r["equipamentoUsado"]} / ${r["equipamentoDisponivel"]}'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    logError = validador.validacaoGeral();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral do Pesonagem'),

      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.zero,
          // ListView: o menu rola em telas baixas em vez de estourar
          child: ListView(children: [
            const DrawerHeader(
              child: Text(
                'Menu',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(BootstrapIcons.yin_yang),
              title: const Text('Habilidades'),
              onTap: () {
                Navigator.pushNamed(context, '/habilidades')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Defesas'),
              onTap: () {
                Navigator.pushNamed(context, '/defesas')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(
                  BootstrapIcons.battery_charging /*(BootstrapIcons.fire*/),
              title: const Text('Poderes'),
              onTap: () {
                Navigator.pushNamed(context, '/poderes')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(BootstrapIcons.lightning),
              title: const Text('Ofensiva'),
              onTap: () {
                Navigator.pushNamed(context, '/ofensiva')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(Icons.paid),
              title: const Text('Vantagens'),
              onTap: () {
                Navigator.pushNamed(context, '/vantagens')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(BootstrapIcons.tools),
              title: const Text('Perícias'),
              onTap: () {
                Navigator.pushNamed(context, '/pericias')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(Icons.personal_injury),
              title: const Text('Complicações'),
              onTap: () {
                Navigator.pushNamed(context, '/complicacoes')
                    .then((value) => _validaFicha());
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Nova ficha'),
              onTap: () {
                Navigator.pop(context);
                _novaFicha();
              },
            ),
            ListTile(
              leading: const Icon(BootstrapIcons.upload),
              title: const Text('Upload'),
              onTap: () async {
                Download upload = Download();
                var ficha = await upload.uploadFicha(
                    escolherPersonagem: _escolherPersonagem);
                // Upload cancelado ou inválido: mantém ficha e imagem atuais
                if (ficha.isNotEmpty) {
                  personagem = Ficha();
                  await personagem.init();
                  await personagem.reInit(ficha);
                  if (upload.importadoPoderSupremo) PoderSupremo.finalizar();
                  _mostrarFicha(upload.img);
                  await _salvarLocal();
                }
                if (!mounted) return;
                if (upload.erro.isNotEmpty) {
                  _mostrarMensagens('Não foi possível importar', [upload.erro]);
                } else if (upload.avisos.isNotEmpty) {
                  _mostrarMensagens('Ficha importada do Poder Supremo', upload.avisos);
                }
              },
            ),

            //logError.isNotEmpty ?
              ListTile(
                leading: const Icon(BootstrapIcons.exclamation_triangle_fill),
                title: Text('Erros ${logError.length}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => LogPopupError(erros: logError),
                  );
                },
              ), // : const SizedBox(),
            const Divider(),
          ]),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
          //; descomentar quando for colcoar titulo
          // const Text(
          //   'Fabrica de Heróis',
          //   style: TextStyle(
          //     fontFamily: 'Impact',
          //     fontSize: 20,
          //   ),
          // ),

          IconButton(
            icon: fileImg.isNotEmpty
                ? Image.memory(
                    fileImg,
                    height: 300,
                  )
                : const Icon(BootstrapIcons.image, size: 50),
            onPressed: () async {
              try {
                FilePickerResult respostaPath =
                    await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                  dialogTitle: "Imagem de Herói",
                  initialDirectory: "",
                  lockParentWindow: false,
                ) as FilePickerResult;

                final Uint8List imgUploaded;
                if(kIsWeb){
                  imgUploaded = respostaPath.files.first.bytes!;
                }else{
                  String pathFile = respostaPath.files.first.path as String;
                  imgUploaded = File(pathFile).readAsBytesSync();
                }
                  

                setState(() {
                  fileImg = imgUploaded;
                });
                _salvarLocal();
              } catch (e) {
                // typeError
                print(e.toString());
              }
            },
          ),

          const SizedBox(height: 50),

          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      //? Nome
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.6),
                        child: TextField(
                          controller: txtControlName,
                          decoration: const InputDecoration(
                              hintText: "Nome do Personagem"),
                          onChanged: (value) {
                            personagem.nomePersonagem = value;
                            _salvarLocal();
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      //? NP
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.3),
                        child: TextField(
                          controller: txtNP,
                          decoration:
                              const InputDecoration(hintText: "Nível de Poder"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            if (int.tryParse(value) != null) {
                              // Recalcula pontos disponíveis e validação
                              setState(() => personagem.np = int.parse(value));
                              _salvarLocal();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ]),

          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _resumoPontos(),
          ),
          const SizedBox(height: 80),

          //# Lista de notificações
          // logError.isNotEmpty ?
          // ListView.builder(
          //   itemCount: logError.length,
          //   itemBuilder: (BuildContext context, int index){
          //     InkWell(
          //       child: Column(
          //         children: [
          //           //Card(child: Text(logError[index]["msg"]))
          //         ]
          //       )
          //     );
          //   }
          // ) : const SizedBox(),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Salvar / exportar ficha',
        child: const Icon(BootstrapIcons.floppy2_fill),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) => SavePopUp(fileImg: fileImg)
          );
        },
      ),
    );
  }
}
