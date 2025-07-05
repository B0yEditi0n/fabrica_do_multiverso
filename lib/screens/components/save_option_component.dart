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
        return Align(
            alignment: Alignment.center,
            child: Container(
              width: 450,
              height: 300,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(10), // M
              
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // color: ThemeData(),
                boxShadow: const [
                  
                  BoxShadow(
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ]
              ),

              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 50,
                  children: [
                      ElevatedButton(
                        child: const Row(
                          children: [
                            Icon(BootstrapIcons.file_pdf, size: 30),
                            SizedBox(width: 10),
                            Text('PDF Para impressão', style: TextStyle(fontSize: 30)),
                          ]
                        ),
                        onPressed: () => Printer.generatePDF(),
                      ),
              
                      ElevatedButton(
                          child: const Row(
                              children: [
                                  Icon(BootstrapIcons.download, size: 30),
                                  SizedBox(width: 10),
                                  Text('Baixar Ficha', style: TextStyle(fontSize: 30))
                              ],
                          ),
                          onPressed:  () async {
                            // Download baixar = Download();
                            Download.genericDownload(fileImg);
                          }
                      ),
                  ],
              ),

              
            ),
        );
    }
}