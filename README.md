# CalliVox

Application d'accessibilité permettant aux personnes souffrant de troubles de la parole de communiquer grâce à la synthèse vocale alimentée par l'IA.

## Description

CalliVox transforme le texte saisi (clavier ou écriture manuscrite via Apple Pencil) en voix synthétisée de haute qualité. L'application intègre des suggestions IA intelligentes et contextuelles pour faciliter la communication rapide et naturelle.

## Fonctionnalités principales

- **Synthèse vocale haute qualité** : Voix Gradium TTS personnalisée ou voix iOS native (AVFoundation)
- **Suggestions IA intelligentes** : Génération de réponses contextuelles via Cerebras LLM
- **Personnalisation avancée** : Ajustement du ton, de la longueur et du style des suggestions
- **Mode hors-ligne** : Détection automatique du réseau avec fallback vers la synthèse iOS native
- **Accessibilité complète** : Support VoiceOver, interface adaptée aux besoins des utilisateurs
- **Sécurité** : Stockage des clés API dans le Keychain iOS, aucune donnée transmise sans consentement

## Structure du projet

```
CalliVox/
├── HandwritingToSpeechSwiftUI/   # Application iOS (SwiftUI)
├── calli-vox-backend/            # API Backend (NestJS) - optionnel
└── CalliVox-Site/                # Site web promotionnel
```

## Documentation

| Composant | Documentation |
|-----------|---------------|
| **Application iOS** | [HandwritingToSpeechSwiftUI/README.md](HandwritingToSpeechSwiftUI/README.md) |
| **Backend API** | [calli-vox-backend/README.md](calli-vox-backend/README.md) |
| **Site web** | [CalliVox-Site/README.md](CalliVox-Site/README.md) |

## Démarrage rapide

### Application iOS

```bash
# Cloner le dépôt
git clone https://github.com/votre-utilisateur/callivox.git
cd callivox/HandwritingToSpeechSwiftUI

# Ouvrir dans Xcode
open HandwritingToSpeechSwiftUI.xcodeproj

# Builder et exécuter (Cmd + R)
```

### Configuration des services externes

L'application fonctionne immédiatement avec la synthèse vocale iOS native. Pour des fonctionnalités avancées :

| Service | Usage | Obtenir une clé |
|---------|-------|-----------------|
| **Gradium TTS** | Voix française haute qualité | [gradium.ai](https://gradium.ai) |
| **Cerebras LLM** | Suggestions IA intelligentes | [cerebras.ai](https://cerebras.ai) |

Les clés API se configurent directement dans l'application via les boutons "Service TTS" et "Service IA".

> **Note** : Sans ces clés, l'application reste pleinement fonctionnelle avec la synthèse vocale iOS native (AVFoundation). Les suggestions IA seront simplement désactivées.

## Stack technique

### Application iOS

- **Framework** : SwiftUI
- **Version iOS minimale** : 17.0
- **Synthèse vocale** : Gradium TTS API + AVFoundation (fallback)
- **IA** : Cerebras LLM (API compatible OpenAI)
- **Stockage sécurisé** : Keychain iOS
- **Réseau** : Network.framework (détection connectivité)

### Backend (optionnel)

- **Framework** : NestJS (Node.js)
- **Base de données** : PostgreSQL
- **ORM** : Prisma
- **Authentification** : Passport.js (Apple Sign In, JWT)

> **Note** : Le backend est actuellement bypassé (`AppConfig.bypassServerAPI = true`). L'application fonctionne de manière autonome.

## État du projet

### Épiques complétées

- [x] **Epic 1** : High-Quality Voice Communication (Gradium TTS)
- [x] **Epic 2** : Reliable Communication (Mode hors-ligne, fallback)
- [x] **Epic 3** : AI-Assisted Responses (Suggestions LLM)
- [x] **Epic 4** : Personalized AI Experience (Personnalisation, guidage)

### Prochaines étapes potentielles

- [ ] Intégration du backend pour statistiques d'utilisation
- [ ] Ajout de voix supplémentaires
- [ ] Synchronisation des phrases rapides via iCloud
- [ ] Widget iOS pour accès rapide

## Contributions

Les contributions sont les bienvenues ! Si vous souhaitez apporter des améliorations ou corriger des bugs :

1. Forkez le dépôt
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/ma-fonctionnalite`)
3. Committez vos changements (`git commit -m 'Ajout de ma fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/ma-fonctionnalite`)
5. Ouvrez une Pull Request

## Auteurs

- **Développeur** : Fabrice CROISEAUX
- **Projet développé pour** : Odile Noel

## Licence

Propriétaire - Tous droits réservés
