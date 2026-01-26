# CalliVox - Application iOS

Application d'accessibilité permettant aux personnes souffrant de troubles de la parole de communiquer grâce à la synthèse vocale alimentée par l'IA.

## Description

CalliVox transforme le texte saisi (clavier ou écriture manuscrite via Apple Pencil) en voix synthétisée personnalisée. L'application intègre des suggestions IA intelligentes pour faciliter la communication rapide.

## Fonctionnalités

- **Saisie et correction du texte** : Saisie via clavier ou Apple Pencil Scribble avec correction automatique
- **Synthèse vocale haute qualité** : Voix Gradium TTS ou fallback AVFoundation (iOS natif)
- **Suggestions IA intelligentes** : Génération de réponses contextuelles via Cerebras LLM
- **Personnalisation IA** : Ajustement du ton, de la longueur et du style des suggestions
- **Mode hors-ligne** : Détection automatique du réseau avec fallback vers la synthèse iOS native
- **Phrases rapides** : Raccourcis pour les phrases fréquemment utilisées
- **Répétition** : Bouton pour relire le dernier texte prononcé

## Prérequis

- **Xcode** : Version 15 ou ultérieure
- **iOS** : Version 17.0 ou ultérieure
- **Swift** : 5.9+

## Installation

1. **Cloner le dépôt :**

   ```bash
   git clone https://github.com/votre-utilisateur/callivox.git
   cd callivox/HandwritingToSpeechSwiftUI
   ```

2. **Ouvrir le projet dans Xcode :**

   ```bash
   open HandwritingToSpeechSwiftUI.xcodeproj
   ```

3. **Sélectionner la cible** : Choisissez un simulateur iOS ou votre iPhone connecté

4. **Builder et exécuter** : `Cmd + R`

## Configuration des Services

L'application utilise deux services externes optionnels qui nécessitent des clés API :

### 1. Gradium TTS (Synthèse Vocale)

Gradium fournit une voix française de haute qualité pour la synthèse vocale.

**Obtenir une clé API :**

1. Rendez-vous sur [gradium.ai](https://gradium.ai)
2. Créez un compte et obtenez votre clé API

**Configurer dans l'application :**

1. Lancez l'application CalliVox
2. Appuyez sur le bouton **"Service TTS"** (icône waveform, couleur menthe)
3. Entrez votre clé API dans le champ sécurisé
4. Appuyez sur **"Enregistrer"**
5. Optionnel : Appuyez sur **"Tester la connexion"** pour vérifier

> **Note** : Sans clé Gradium, l'application utilise automatiquement la synthèse vocale iOS native (AVFoundation).

### 2. Cerebras LLM (Suggestions IA)

Cerebras fournit un modèle de langage rapide pour générer des suggestions de réponses.

**Obtenir une clé API :**

1. Rendez-vous sur [cerebras.ai](https://cerebras.ai)
2. Créez un compte développeur
3. Générez une clé API dans votre dashboard

**Configurer dans l'application :**

1. Lancez l'application CalliVox
2. Appuyez sur le bouton **"Service IA"** (icône cerveau, couleur indigo)
3. Entrez votre clé API Cerebras
4. Appuyez sur **"Enregistrer"**
5. Optionnel : Appuyez sur **"Tester la connexion"** pour vérifier

> **Note** : Sans clé Cerebras, les fonctionnalités de suggestions IA seront désactivées.

## Utilisation

### Lecture de texte

1. Saisissez votre texte dans la zone de texte principale
2. Appuyez sur le bouton **"Lire à haute voix"** (bleu) ou sur le bouton play flottant
3. Pour répéter le dernier texte : appuyez sur **"Répéter"** (vert)

### Suggestions IA

1. Saisissez un début de phrase ou un contexte
2. Appuyez sur **"Générer des suggestions"**
3. Touchez une suggestion pour la prononcer immédiatement
4. Utilisez les contrôles de guidage rapide (Salutation, Question, etc.) pour des suggestions contextuelles
5. Appuyez longuement sur une suggestion pour obtenir "Plus comme ça"
6. Appuyez sur **"Autre"** pour des suggestions différentes

### Personnalisation IA

1. Appuyez sur **"Personnalisation IA"** (icône personne, couleur cyan)
2. Ajustez :
   - **Ton** : Formel, Neutre, Décontracté
   - **Longueur** : Court, Moyen, Long
   - **Contexte personnel** : Informations sur vous pour des suggestions adaptées

### Phrases rapides

1. Appuyez sur **"Gérer les phrases"** (violet)
2. Ajoutez vos phrases fréquemment utilisées
3. Les phrases sélectionnées apparaissent en bas de l'écran pour un accès rapide

## Mode développement

### Configuration actuelle (AppConfig.swift)

```swift
// Bypass de l'authentification pour les tests
static let skipAuthentication = true

// Bypass des appels API backend
static let bypassServerAPI = true
```

### Exécuter les tests

```bash
xcodebuild test -scheme HandwritingToSpeechSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Architecture

```
HandwritingToSpeechSwiftUI/
├── Models/
│   ├── AppConfig.swift          # Configuration centralisée
│   ├── PersonalizationConfig.swift
│   └── GuidanceContext.swift
├── Services/
│   ├── GradiumTTSProvider.swift # Client API Gradium
│   └── OpenAICompatibleLLMProvider.swift
├── Managers/
│   ├── SpeechService.swift      # Orchestration TTS
│   ├── SuggestionService.swift  # Gestion des suggestions
│   ├── KeychainManager.swift    # Stockage sécurisé
│   └── NetworkMonitor.swift     # Détection réseau
└── Views/
    ├── ContentView.swift        # Vue principale
    ├── GradiumSettingsView.swift
    ├── LLMSettingsView.swift
    ├── PersonalizationSettingsView.swift
    └── SuggestionView.swift
```

## Stockage des données

- **Clés API** : Stockées de manière sécurisée dans le Keychain iOS
- **Préférences** : UserDefaults (voix sélectionnée, personnalisation)
- **Aucune donnée** n'est envoyée à un serveur tiers sans consentement explicite

## Dépannage

### La synthèse vocale ne fonctionne pas

1. Vérifiez que le volume de l'appareil n'est pas en mode silencieux
2. Si Gradium ne fonctionne pas, vérifiez votre clé API dans "Service TTS"
3. L'application basculera automatiquement sur la voix iOS native en cas d'erreur

### Les suggestions IA ne s'affichent pas

1. Vérifiez que votre clé API Cerebras est configurée dans "Service IA"
2. Utilisez "Tester la connexion" pour vérifier la validité de la clé
3. Vérifiez votre connexion internet

### Erreur "Clé API invalide"

1. Vérifiez que vous avez copié la clé complète (sans espaces)
2. Vérifiez que la clé est toujours active dans votre dashboard fournisseur
3. Supprimez et re-saisissez la clé

## Auteurs

- **Développeur** : Fabrice CROISEAUX
- **Projet développé pour** : Odile Noel

## Licence

Propriétaire - Tous droits réservés
