# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.10)

project(pdfium-download NONE)

include(ExternalProject)

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  cmake_policy(SET CMP0135 NEW)
endif()

ExternalProject_Add(pdfium-download
                    URL;https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/5200/pdfium-linux-x64.tgz
                    SOURCE_DIR          "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-src"
                    BINARY_DIR          "/home/gleice/Documentos/fabrica_do_multiverso/build/linux/x64/debug/pdfium-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
