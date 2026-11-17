import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:fabrica_do_multiverso/script/download.dart';
import 'printer.dart';

class SavePopUp extends StatelessWidget{
    final Uint8List fileImg;
    const SavePopUp({super.key, required this.fileImg});

    @override
    Widget build(BuildContext context) {
        // Dialog: respeita as margens da tela e encolhe em celulares
        return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 24,
                    children: [
                        ElevatedButton.icon(
                          icon: const Icon(BootstrapIcons.file_pdf, size: 28),
                          label: const Text('PDF Para impressão', textAlign: TextAlign.center),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(64),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => Printer.generatePDF(fileImg),
                        ),

                        ElevatedButton.icon(
                            icon: const Icon(BootstrapIcons.download, size: 28),
                            label: const Text('Baixar Ficha', textAlign: TextAlign.center),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(64),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            onPressed:  () async {
                              Download.genericDownload(fileImg);
                            }
                        ),
                    ],
                ),
              ),
            ),
        );
    }
}
