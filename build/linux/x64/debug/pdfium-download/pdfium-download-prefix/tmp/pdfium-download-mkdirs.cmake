# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-src"
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-build"
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix"
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix/tmp"
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp"
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix/src"
  "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
