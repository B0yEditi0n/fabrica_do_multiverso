import 'package:flutter/material.dart';

/// Lista os problemas de validação da ficha (ValidaNpPersonagem.validacaoGeral).
class LogPopupError extends StatelessWidget {
  final List erros;
  const LogPopupError({super.key, this.erros = const []});

  static const Map<String, String> _secoes = {
    "P": "Perícia",
    "D": "Defesa",
    "E": "Efeito",
    "T": "Pontos",
    "Q": "Equipamento",
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(erros.isEmpty
          ? 'Validação da ficha'
          : 'Validação da ficha (${erros.length})'),
      content: SizedBox(
        width: 400,
        child: erros.isEmpty
            ? const Text('Nenhum problema encontrado.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: erros.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  Map erro = erros[index];
                  return ListTile(
                    leading: const Icon(Icons.warning_amber),
                    title: Text(_secoes[erro["tipo"]] ?? 'Ficha'),
                    subtitle: Text("${erro["msg"]}"),
                  );
                },
              ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        TextButton(
          child: const Text('Fechar'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
