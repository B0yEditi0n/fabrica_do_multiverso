import 'package:flutter/material.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/screens/components/printer.dart';

/// Menu Ofensiva: escolhe o que entra na Ofensiva da ficha (PDF).
class ScreenOfensiva extends StatefulWidget {
  const ScreenOfensiva({super.key});
  @override
  State<ScreenOfensiva> createState() => _ScreenOfensivaState();
}

class _ScreenOfensivaState extends State<ScreenOfensiva> {
  @override
  Widget build(BuildContext context) {
    List ataques = Printer.ataquesOfensiva();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofensiva'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                SwitchListTile(
                  title: const Text('Incluir desarmado na ofensiva'),
                  subtitle: const Text(
                      'Ataque desarmado com Força no PDF e no limite de NP'),
                  value: personagem.incluirDesarmado,
                  onChanged: (valor) =>
                      setState(() => personagem.incluirDesarmado = valor),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Ataques na ficha',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                for (Map ataque in ataques)
                  Card(
                    child: ListTile(
                      title: Text("${ataque["nome"]}"),
                      subtitle: Text(ataque["noPower"] == true
                          ? 'Ataque com Força'
                          : "${ataque["efeito"] ?? ''}"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
