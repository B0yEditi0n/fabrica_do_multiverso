# fabrica_do_multiverso

Aplicativo Flutter de fichas de Mutantes & Malfeitores 3ª edição.

**Versão web:** https://b0yediti0n.github.io/fabrica_do_multiverso/ (o endereço antigo `.../build/web/index.html` redireciona para cá)

## Desenvolvimento

Versão do Flutter usada no projeto e no deploy: **3.47.1** (stable, Dart 3.13).

```bash
flutter pub get
flutter test
flutter run
```

## Deploy automático (GitHub Actions)

O fluxo fica em `.github/workflows/deploy.yml` e roda a cada push em `desenvolvimento` ou `main`. Também pode ser disparado à mão na aba Actions.

| Etapa | O que faz |
|---|---|
| Testes | `flutter analyze` (só erros bloqueiam) e `flutter test`. Se falhar, nada é publicado. |
| Web | `flutter build web --base-href /fabrica_do_multiverso/` e publicação no GitHub Pages. |
| Android | APK de release, disponível em Actions > execução > Artifacts (guardado por 30 dias). |
| Release | Numa tag `v*`, o APK (e o AAB, se houver assinatura) é anexado a um GitHub Release. |

Para publicar uma versão:

```bash
git tag v1.1.0
git push origin v1.1.0
```

### Configuração única no GitHub

1. **Settings > Pages > Build and deployment > Source: GitHub Actions.** Sem isso, a etapa de publicação web falha.
2. (Opcional) Assinatura Android em **Settings > Secrets and variables > Actions**:

| Secret | Conteúdo |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | o arquivo `.jks` em base64 (`base64 -w0 upload-keystore.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | senha do keystore |
| `ANDROID_KEY_ALIAS` | alias da chave |
| `ANDROID_KEY_PASSWORD` | senha da chave |

Sem esses secrets, o APK é assinado com a chave de debug. Ele instala normalmente, mas não serve para a Play Store, e um APK assinado com outra chave não atualiza por cima dele (é preciso desinstalar antes).

Para gerar uma chave: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`. Guarde o arquivo e as senhas fora do repositório.

### Envio manual

`updateGithub.sh` roda os testes, faz `git add -A`, pede a mensagem do commit e faz o push. Não é mais preciso gerar nem commitar a pasta `build/`.
