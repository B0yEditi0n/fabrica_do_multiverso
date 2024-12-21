#!/bin/bash
# Limpa o flutter para um post reduzido
flutter clean

git add *

# Armazenmento do Comentario
echo "----------------------------------------"
echo ""
echo "Comentario do push:"
read _comentario;
git commit -m "$_comentario"

# Post 
git push