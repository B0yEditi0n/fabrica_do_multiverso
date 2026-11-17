#!/bin/bash
# Envia as alterações para o GitHub.
# O build web e o APK são feitos pelo GitHub Actions (.github/workflows/deploy.yml);
# a pasta build/ fica fora do Git (.gitignore).

# Roda os testes antes de enviar (o Actions também roda)
flutter test || { echo "Testes falharam: nada foi enviado."; exit 1; }

# -A inclui arquivos que começam com ponto (.github, .gitignore)
git add -A

echo "----------------------------------------"
echo ""
echo "Comentario do push:"
read _comentario;
git commit -m "$_comentario"

git push
