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
- **Phrases du moment** : Suggestions intelligentes adaptées à l'heure de la journée (matin, midi, soir, nuit)
- **Mode scanning** : Navigation séquentielle pour les utilisateurs à mobilité très réduite (les boutons s'illuminent tour à tour)
- **Panneau d'urgence** : Accès rapide à 4 messages d'urgence personnalisables
- **Mode fatigue** : Interface simplifiée avec gros boutons pour les moments de fatigue intense
- **Accessibilité renforcée** : Cibles tactiles agrandies (80pt), contraste élevé, animations réduites

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

### Accessibilité renforcée

1. Appuyez sur **"Accessibilité"** dans la barre latérale
2. Activez **"Accessibilité Renforcée"** pour :
   - Des cibles tactiles agrandies (80pt)
   - Un contraste élevé
   - Des animations réduites
3. Optionnel : Activez **"Demander confirmation"** pour les actions destructives

### Phrases du moment

1. Les phrases sont automatiquement adaptées à l'heure de la journée :
   - **Matin (7h-9h)** : "Bonjour", "Bien dormi ?"
   - **Midi (12h-14h)** : "Bon appétit", "J'ai faim"
   - **Soir (18h-20h)** : "Bonne soirée", "À demain"
   - **Nuit (21h-23h)** : "Bonne nuit", "Je suis fatigué"
2. Personnalisez-les dans **Accessibilité > Phrases du moment**

### Mode scanning (mobilité réduite)

1. Activez dans **Accessibilité > Mode Scanning**
2. Les boutons s'illuminent tour à tour automatiquement
3. Tapez n'importe où sur l'écran lorsque le bouton souhaité est surligné
4. Configurez :
   - **Vitesse** : Lent (3s), Normal (2s), Rapide (1s)
   - **Direction** : Aller simple ou Aller-retour
   - **Retour sonore** : Son subtil à chaque changement

### Panneau d'urgence

1. Appuyez sur le bouton **d'urgence** (rouge) dans la barre latérale
2. 4 messages d'urgence pré-configurés :
   - "J'ai besoin d'aide"
   - "Appelez les secours"
   - "J'ai mal"
   - "Quelque chose ne va pas"
3. Personnalisez-les dans **Accessibilité > Messages d'urgence**

### Mode fatigue

1. Activez dans **Accessibilité > Mode Fatigue**
2. Interface épurée avec 4 gros boutons essentiels
3. Personnalisez les messages dans les réglages

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
│   ├── AppConfig.swift              # Configuration centralisée
│   ├── PersonalizationConfig.swift
│   └── GuidanceContext.swift
├── Services/
│   ├── GradiumTTSProvider.swift     # Client API Gradium
│   └── OpenAICompatibleLLMProvider.swift
├── Managers/
│   ├── SpeechService.swift          # Orchestration TTS
│   ├── SuggestionService.swift      # Gestion des suggestions
│   ├── KeychainManager.swift        # Stockage sécurisé
│   ├── NetworkMonitor.swift         # Détection réseau
│   ├── AccessibilitySettings.swift  # Mode accessibilité renforcée
│   ├── TimeBasedPhraseSettings.swift # Phrases selon l'heure
│   ├── ScanningModeSettings.swift   # Configuration scanning
│   └── ScanningModeController.swift # Contrôleur scanning actif
└── Views/
    ├── ContentView.swift            # Vue principale
    ├── GradiumSettingsView.swift
    ├── LLMSettingsView.swift
    ├── PersonalizationSettingsView.swift
    ├── SuggestionView.swift
    ├── AccessibilitySettingsView.swift   # Réglages accessibilité
    ├── TimeBasedPhrasesSettingsView.swift # Config phrases temporelles
    ├── ScanningModeSettingsView.swift    # Config mode scanning
    ├── EmergencyPanelView.swift          # Panneau d'urgence
    └── FatigueModeView.swift             # Interface mode fatigue
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
