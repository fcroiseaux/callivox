# Synthèse Vocale pour Odile

## Description

Ce projet est une application iOS développée en SwiftUI qui permet de convertir du texte en parole. L'application prend en charge la saisie de texte (avec prise en charge d'Apple Pencil Scribble), la correction automatique des fautes et la lecture vocale du texte entré. Vous pouvez choisir entre deux modes de synthèse vocale :

- **Synthèse vocale native d'Apple** via `AVSpeechSynthesizer`
- **Voix d'Odile** via l'API ElevenLabs

L'application intègre également une fonctionnalité qui permet de répéter le dernier texte dicté à l'aide d'un bouton dédié.

## Fonctionnalités

- **Saisie et correction du texte**  
  Saisie du texte via un `TextEditor` avec correction automatique des erreurs grâce à `UITextChecker`.

- **Lecture vocale**  
  - Utilisation de la synthèse vocale native d'Apple.  
  - Option d'utiliser l'API ElevenLabs pour obtenir la voix d'Odile.

- **Lecture automatique**  
  Possibilité d'activer la lecture automatique après une saisie de texte.

- **Répéter le dernier texte dicté**  
  Un bouton permet de relire le dernier texte dicté.

- **Effacer le texte**  
  Un bouton pour effacer le contenu saisi et annuler toute lecture en cours.

## Prérequis

- **Xcode** : Version 13 ou ultérieure  
- **iOS** : Version 14.0 ou ultérieure  
- **Swift** : 5.x

## Installation

1. **Cloner le dépôt :**

   ```bash
   git clone https://gitlab.com/votre-utilisateur/votre-projet.git

2. **Ouvrir le projet dans Xcode :**

- Lancez Xcode et ouvrez le fichier .xcodeproj ou .xcworkspace du projet.

3. Configurer l'API ElevenLabs (facultatif) :

- Pour utiliser la voix d'Odile via ElevenLabs, assurez-vous de posséder une clé API valide.
- Dans le fichier contenant la fonction speakTextElevenLabs, remplacez la valeur de la clé API (xi-api-key) par votre propre clé.

## Utilisation
- Saisie et lecture de texte :
    - Saisissez votre texte dans l'éditeur.
    - Activez ou désactivez la lecture automatique selon vos préférences.
    - Appuyez sur le bouton "Lire à haute voix" pour écouter le texte dicté.
- Répéter le dernier texte dicté :
    Appuyez sur le bouton "Répéter le dernier texte" pour relire le dernier texte qui a été dicté.
- Effacer le texte :
    Utilisez le bouton "Effacer le texte" pour supprimer le contenu de l'éditeur et annuler la lecture en cours.

## Structure du Projet
ContentView.swift : Vue principale de l'application gérant l'interface utilisateur et l'intégration des fonctionnalités de lecture.
AudioManager.swift : Classe qui configure et gère la lecture audio via AVFoundation.
API ElevenLabs : Implémentation de l'appel API pour la synthèse vocale via ElevenLabs.

## Contributions
Les contributions sont les bienvenues ! Si vous souhaitez apporter des améliorations ou corriger des bugs, veuillez ouvrir une issue ou soumettre une merge request.

## Licence
Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus d'informations.

## Auteurs
Développeur : Fabrice CROISEAUX
Projet développé pour : Odile Noel