# Emplake

Trabalho de engenharia reversa do jogo **Emplake**, feito em Flutter/Dart para a web.

Você recebe 4 dígitos fixos e coloca sinais entre eles (`+ - * / ( ) √ ∛ ! ** | ⌊ ⌋ ⌈ ⌉`) para formar uma igualdade verdadeira. A fórmula é mostrada logo abaixo renderizada em LaTeX.

Visual inspirado nos desenhos animados dos anos 1930: papel pontilhado, raios de sol, lâmpadas de marquise e contornos grossos.

## Como funciona o jogo

- Os 4 números ficam fixos. Toque numa **casa** (entre os números) e escolha os sinais no teclado.
- Casa vazia entre dois números junta os dois (1 e 2 viram 12).
- O sinal `=` só pode ser usado uma vez.
- Toque num sinal já colocado para removê-lo.
- Níveis: **Fácil** (todos os operadores, aceita divisão não inteira), **Intermediário**, **Avançado** e **Difícil**.
- Nos níveis Intermediário, Avançado e Difícil, qualquer divisão com resultado não inteiro gera erro.
- Dá para **pular** um número difícil. Números já resolvidos ou pulados não voltam.

## Tecnologias

| Recurso | Pacote |
| --- | --- |
| Estado | `flutter_riverpod` |
| Rotas | `go_router` |
| Login (e-mail e Google) | `firebase_ui_auth`, `firebase_ui_oauth_google` |
| Banco de dados | `cloud_firestore` (plano Spark) |
| Tradução (pt/en) | `flutter_localizations` + `gen-l10n` |
| Barra inferior | `curved_navigation_bar` |
| Fórmula em LaTeX | `flutter_math_fork` |
| Indicador de progresso | `flutter_spinkit` |
| Última página aberta e som | `shared_preferences` |
| Bandeirinhas | `country_flags` |

## Como rodar

```bash
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

## Publicar na web

```bash
flutter build web --release
```

A pasta `build/web` pode ser hospedada no Firebase Hosting, Netlify, Vercel ou GitHub Pages.

## Regras do Firestore

O arquivo `firestore.rules` deve ser colado em **Firestore Database → Regras** no console do Firebase (ou publicado com `firebase deploy --only firestore:rules`).

## Autoria

Desenvolvido por Bia.
