# CalliVox

Application d'accessibilité permettant aux personnes souffrant de troubles de la parole de communiquer grâce à la synthèse vocale alimentée par l'IA.

## Description

CalliVox transforme le texte saisi (clavier ou écriture manuscrite via Apple Pencil) en voix synthétisée personnalisée, offrant ainsi une aide à la communication pour les personnes ayant des difficultés d'élocution.

## Structure du projet

```
CalliVox/
├── HandwritingToSpeechSwiftUI/   # Application iOS (SwiftUI)
├── calli-vox-backend/            # API Backend (NestJS)
└── CalliVox-Site/                # Site web promotionnel
```

## Stack technique

### Application iOS
- **Framework** : SwiftUI
- **Authentification** : Apple Sign In
- **Synthèse vocale** : AVSpeechSynthesizer (natif) + ElevenLabs API (voix personnalisées)
- **Stockage sécurisé** : Keychain

### Backend
- **Framework** : NestJS (Node.js)
- **Base de données** : PostgreSQL
- **ORM** : Prisma
- **Authentification** : Passport.js (Apple Sign In, JWT)
- **Documentation API** : Swagger/OpenAPI

### Site web
- HTML/CSS/JavaScript statique

## Fonctionnalités principales

- Saisie de texte par clavier ou écriture manuscrite (Apple Pencil)
- Synthèse vocale avec voix natives Apple ou voix personnalisées ElevenLabs
- Authentification sécurisée via Apple Sign In
- Statistiques d'utilisation anonymisées
- Répétition automatique du dernier texte prononcé

## Installation

### Backend

```bash
cd calli-vox-backend
npm install
cp .env.example .env
# Configurer les variables d'environnement
npm run start:dev
```

### Application iOS

1. Ouvrir `HandwritingToSpeechSwiftUI/HandwritingToSpeech.xcodeproj` dans Xcode
2. Configurer les capacités "Sign in with Apple"
3. Builder et exécuter sur un appareil iOS

## Documentation

- [Intégration de l'authentification](README_AUTH_INTEGRATION.md)

## Licence

Propriétaire - Tous droits réservés
