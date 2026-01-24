# CalliVox - Intégration de l'Authentification

Ce document explique comment l'authentification Apple Sign In est intégrée entre l'application iOS et le backend.

## Architecture d'Authentification

L'authentification fonctionne en plusieurs étapes :

1. L'utilisateur lance le processus "Sign in with Apple" dans l'application iOS
2. Apple authentifie l'utilisateur et renvoie un token d'identité à l'application
3. L'application envoie ce token au backend CalliVox
4. Le backend vérifie le token auprès d'Apple et crée/authentifie l'utilisateur
5. Le backend renvoie un token JWT personnalisé à l'application
6. L'application stocke le token dans le trousseau (Keychain) et l'utilise pour les requêtes ultérieures

## Configuration de l'Application iOS

### 1. Configuration de l'URL du Backend

L'URL du backend est configurée dans `AppConfig.swift`. Par défaut :

- Développement : `http://localhost:8080`
- Production : `https://api.callivox.app`

Pour modifier ces valeurs, éditez le fichier `HandwritingToSpeechSwiftUI/Models/AppConfig.swift`.

### 2. Activation de "Sign in with Apple"

Assurez-vous que la capacité "Sign in with Apple" est activée dans les capacités de votre projet Xcode :

1. Ouvrez le projet dans Xcode
2. Sélectionnez le projet dans le navigateur
3. Allez dans l'onglet "Signing & Capabilities"
4. Ajoutez la capacité "Sign in with Apple" si elle n'est pas déjà présente

### 3. Mode de développement

En mode développement, vous pouvez contourner l'authentification réelle :

- Définissez `AppConfig.Features.useMockAuth = true` pour simuler l'authentification
- Les informations d'utilisateur simulées seront utilisées au lieu d'appeler le backend

## Configuration du Backend

### 1. Variables d'environnement

Le backend a besoin des variables d'environnement suivantes :

```
APPLE_CLIENT_ID=com.votre.app.id
APPLE_TEAM_ID=VOTRE_TEAM_ID_APPLE
APPLE_KEY_ID=VOTRE_CLE_ID_APPLE
APPLE_PRIVATE_KEY_LOCATION=./chemin/vers/votre/cle.p8
APPLE_CALLBACK_URL=http://votreserveur.com/auth/apple/callback
```

Créez un fichier `.env` à partir du modèle `.env.example` et remplissez-le avec vos informations.

### 2. Clé privée Apple

Vous devez générer une clé privée pour l'authentification Apple :

1. Connectez-vous au [portail développeur Apple](https://developer.apple.com/)
2. Accédez à "Certificates, Identifiers & Profiles"
3. Sous "Keys", créez une nouvelle clé avec la capacité "Sign in with Apple"
4. Téléchargez le fichier `.p8` et placez-le à l'emplacement spécifié dans `.env`

## Flux d'Authentification

### Côté Application iOS

1. L'utilisateur appuie sur le bouton "Sign in with Apple"
2. La méthode `handleSignInWithAppleCompletion` dans `AppleSignInView.swift` traite le résultat
3. Si l'authentification est réussie, `userModel.authenticateWithApple` est appelée
4. Cette méthode extrait le token et appelle le backend via `APIService`
5. Une fois authentifié, le token et les informations utilisateur sont stockés dans le trousseau

### Côté Backend

1. Le backend reçoit la requête à `/auth/apple/mobile`
2. Il vérifie la validité du token d'identité Apple
3. Il crée ou met à jour l'utilisateur dans la base de données
4. Il génère un JWT personnalisé pour l'utilisateur
5. Il renvoie le token et les informations utilisateur à l'application

## Dépannage

### Problèmes d'authentification côté application

Si l'authentification échoue, vérifiez :

1. Les logs de la console pour les erreurs spécifiques
2. Que l'application a une connexion Internet fonctionnelle
3. Que l'URL du backend est correcte
4. Que "Sign in with Apple" est configuré correctement dans Xcode
5. En développement, essayez de définir `useMockAuth = true` pour contourner les problèmes de backend

### Problèmes d'authentification côté backend

Si le backend ne valide pas l'authentification :

1. Vérifiez que les variables d'environnement sont correctement configurées
2. Assurez-vous que la clé privée (.p8) est à l'emplacement correct
3. Vérifiez les logs du serveur pour les erreurs spécifiques
4. Vérifiez que l'ID client Apple correspond à celui de votre application

## Ressources

- [Documentation Apple Sign In](https://developer.apple.com/sign-in-with-apple/)
- [Documentation NestJS](https://docs.nestjs.com/)
- [Documentation SwiftUI](https://developer.apple.com/documentation/swiftui)