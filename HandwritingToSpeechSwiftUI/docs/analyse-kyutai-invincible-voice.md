# Analyse : Intégration Potentielle de Kyutai pour CalliVox

**Date :** 2026-01-27
**Auteur :** Équipe CalliVox
**Version :** 1.0
**Statut :** Document d'analyse

---

## Table des Matières

1. [Résumé Exécutif](#résumé-exécutif)
2. [Présentation de Kyutai](#présentation-de-kyutai)
3. [Architecture InvincibleVoice](#architecture-invinciblevoice)
4. [Comparaison avec CalliVox Actuel](#comparaison-avec-callivox-actuel)
5. [Fonctionnalités Clés de Kyutai](#fonctionnalités-clés-de-kyutai)
6. [Avantages Potentiels pour CalliVox](#avantages-potentiels-pour-callivox)
7. [Considérations Techniques](#considérations-techniques)
8. [Scénarios d'Intégration](#scénarios-dintégration)
9. [Analyse Coûts-Bénéfices](#analyse-coûts-bénéfices)
10. [Recommandations](#recommandations)

---

## Résumé Exécutif

Kyutai est un laboratoire de recherche en IA open-source qui développe **InvincibleVoice**, un système de communication vocale en temps réel destiné aux personnes ayant des difficultés à parler (notamment les patients atteints de SLA/ALS). Le projet propose une architecture complète incluant STT (Speech-to-Text), LLM (Large Language Model) et TTS (Text-to-Speech), avec la possibilité d'un hébergement entièrement privé.

### Points Clés

| Aspect | Évaluation |
|--------|------------|
| **Pertinence pour CalliVox** | Élevée - Même public cible, fonctionnalités complémentaires |
| **Maturité technique** | Bonne - Projet open-source actif avec documentation |
| **Effort d'intégration** | Modéré à Élevé - Nécessite adaptation de l'architecture |
| **Valeur ajoutée principale** | Clonage vocal, personnalisation avancée, self-hosting |

---

## Présentation de Kyutai

### Qu'est-ce que Kyutai ?

Kyutai est un laboratoire de recherche français en intelligence artificielle, focalisé sur les technologies vocales et conversationnelles. Leur mission est de développer des outils d'IA accessibles et open-source.

### Le Projet InvincibleVoice

InvincibleVoice est un système de communication conçu pour aider les personnes souffrant de maladies affectant la parole (SLA, paralysie, etc.) à communiquer naturellement avec leur entourage.

**Philosophie du projet :**

> "Instead of having the TTS reads out whatever the LLM answers, we ask the LLM to provide multiple possible answers and the TTS only utters the one selected by the user."

Cette philosophie correspond exactement à l'approche de CalliVox avec les suggestions IA.

### Ressources

- **Site officiel :** https://www.invincible-voice.com/
- **GitHub :** https://github.com/kyutai-labs/invincible-voice
- **Licence :** Open-source

---

## Architecture InvincibleVoice

### Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND (Next.js)                       │
│  - Interface utilisateur web responsive                         │
│  - Capture audio microphone (WebRTC)                            │
│  - Affichage suggestions + keywords                             │
│  - Historique conversations                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ WebSocket + REST API
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND (FastAPI Python)                     │
│  - Orchestration STT → LLM → TTS                                │
│  - Gestion utilisateurs (OAuth, JWT)                            │
│  - Stockage conversations et profils                            │
│  - Métriques Prometheus                                         │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │   STT    │        │   LLM    │        │   TTS    │
    │ Gradium  │        │ Cerebras │        │ Gradium  │
    │    ou    │        │    ou    │        │    ou    │
    │ Kyutai   │        │  vLLM    │        │ Kyutai   │
    └──────────┘        └──────────┘        └──────────┘
```

### Modes de Déploiement

#### Mode 1 : Services Cloud (Recommandé pour démarrer)

- **STT :** Gradium API (WebSocket)
- **LLM :** Cerebras API (OpenAI-compatible)
- **TTS :** Gradium API (Streaming)

#### Mode 2 : Self-Hosted (Confidentialité maximale)

- **STT :** Kyutai Delayed Stream Modelling
- **LLM :** vLLM avec modèle local
- **TTS :** Kyutai TTS avec clonage vocal

---

## Comparaison avec CalliVox Actuel

### Architecture

| Composant | CalliVox Actuel | InvincibleVoice |
|-----------|-----------------|-----------------|
| **Client** | iOS natif (SwiftUI) | Web (React/Next.js) |
| **Backend** | Aucun (appels directs) | FastAPI Python |
| **STT** | Gradium WebSocket | Gradium ou Kyutai |
| **LLM** | Cerebras (OpenAI-compat) | Cerebras ou vLLM |
| **TTS** | Gradium WebSocket | Gradium ou Kyutai |
| **Auth** | Keychain local | OAuth Google + JWT |
| **Stockage** | UserDefaults + Keychain | Fichiers JSON serveur |

### Fonctionnalités

| Fonctionnalité | CalliVox | InvincibleVoice | Écart |
|----------------|:--------:|:---------------:|:-----:|
| Suggestions IA (4 réponses) | ✅ | ✅ | = |
| Keywords rapides (10) | ✅ | ✅ | = |
| Mode édition (freeze) | ✅ | ✅ | = |
| Écriture manuscrite | ✅ | ❌ | CalliVox + |
| Phrases préenregistrées | ✅ | ❌ | CalliVox + |
| Mode hors-ligne partiel | ✅ | ❌ | CalliVox + |
| Historique persistant | ❌ | ✅ | Kyutai + |
| Profil utilisateur riche | ❌ | ✅ | Kyutai + |
| Documents contextuels | ❌ | ✅ | Kyutai + |
| Liste d'amis | ❌ | ✅ | Kyutai + |
| Contrôle longueur réponse | ❌ | ✅ | Kyutai + |
| Clonage vocal | ❌ | ✅ | Kyutai + |
| Self-hosting complet | ❌ | ✅ | Kyutai + |
| Métriques/monitoring | ❌ | ✅ | Kyutai + |
| Multi-plateforme | ❌ | ✅ | Kyutai + |

---

## Fonctionnalités Clés de Kyutai

### 1. Clonage Vocal (Voice Cloning)

**Description :** Le TTS Kyutai permet de générer une voix synthétique à partir d'un échantillon audio de l'utilisateur.

**Intérêt pour CalliVox :**

- Les utilisateurs atteints de SLA perdent progressivement leur voix
- Enregistrer leur voix avant la perte permet de la conserver
- La synthèse vocale utilise alors leur propre voix

**Configuration :**

```yaml
# voices.yaml
- name: Utilisateur
  source:
    source_type: file
    path_on_server: user-voices/fabrice.mp3
    description: Voix clonée de Fabrice
```

### 2. Personnalisation Avancée du Profil

**Données utilisateur gérées :**

```python
class UserSettings(BaseModel):
    name: str                    # Nom de l'utilisateur
    prompt: str                  # Prompt personnalisé pour le LLM
    additional_keywords: list    # Mots-clés additionnels
    friends: list[str]           # Liste des amis/contacts
    documents: list[Document]    # Documents de contexte
    thinking_mode: bool          # Mode raisonnement étendu
```

**Impact sur le LLM :** Ces informations sont injectées dans le system prompt, permettant au LLM de :

- Connaître le nom de l'utilisateur
- Adapter son style selon le prompt personnalisé
- Suggérer les noms des amis dans les réponses
- Utiliser le contexte des documents uploadés

### 3. Historique Conversationnel Persistant

**Structure :**

```python
class Conversation(BaseModel):
    messages: list[SpeakerMessage | WriterMessage]
    start_time: datetime
```

**Utilisation dans le prompt LLM :**

```
## Past conversations with dates
### Conversation of Monday, July 07, 2025 at 14:56 (2 days ago)
* Speaker: Comment vas-tu aujourd'hui ?
* Fabrice says: Ça va bien, merci !

## Current conversation with the user
* Speaker: Tu veux aller au cinéma ce soir ?
```

### 4. Contrôle de la Longueur des Réponses

**Options disponibles :**

| Taille | Mots min | Mots max |
|--------|----------|----------|
| XS | 1 | 5 |
| S | 3 | 10 |
| M | 5 | 15 |
| L | 8 | 20 |
| XL | 12 | 25 |

### 5. Self-Hosting Complet

**Avantages :**

- **Confidentialité totale** : Aucune donnée ne quitte le réseau local
- **Pas de coûts API** : Après investissement initial en matériel
- **Latence optimisée** : Réseau local vs cloud
- **Indépendance** : Pas de dépendance aux services tiers

**Prérequis matériels :**

- GPU avec VRAM suffisante pour le LLM (16GB+ recommandé)
- Serveur capable de faire tourner vLLM
- Stockage pour les modèles STT/TTS Kyutai

---

## Avantages Potentiels pour CalliVox

### Avantages Immédiats

1. **Clonage vocal personnalisé**
   - Permet aux utilisateurs de conserver leur voix
   - Différenciateur majeur sur le marché
   - Impact émotionnel fort pour les patients SLA

2. **Personnalisation contextuelle**
   - Suggestions plus pertinentes grâce au profil riche
   - Meilleure expérience utilisateur
   - Réduction du temps de sélection des réponses

3. **Historique persistant**
   - Continuité des conversations entre sessions
   - Le LLM comprend mieux le contexte familial/social
   - Amélioration progressive de la pertinence

### Avantages à Moyen Terme

4. **Multi-plateforme**
   - Version web accessible sur tous les appareils
   - Pas besoin d'un iPad pour utiliser CalliVox
   - Élargissement de la base utilisateurs

5. **Self-hosting pour institutions**
   - Hôpitaux et centres de soins avec données sensibles
   - Conformité RGPD simplifiée
   - Pas de transfert de données médicales vers le cloud

6. **Monitoring et métriques**
   - Suivi de l'utilisation
   - Détection des problèmes de performance
   - Données pour amélioration continue

---

## Considérations Techniques

### Complexité d'Intégration

#### Option A : Utiliser le Backend Kyutai

**Effort estimé :** Élevé

```
iOS App ──WebSocket──▶ Backend Kyutai ──▶ Services
```

**Modifications requises :**

- Remplacer les appels directs Gradium/Cerebras
- Implémenter l'authentification OAuth
- Adapter le format des messages WebSocket
- Gérer la synchronisation du profil utilisateur

#### Option B : Porter les Fonctionnalités dans CalliVox

**Effort estimé :** Modéré

```
iOS App ──▶ Services (Gradium/Cerebras)
   │
   └── Nouvelles fonctionnalités inspirées de Kyutai
```

**Fonctionnalités à implémenter :**

- Profil utilisateur enrichi (Core Data)
- Historique persistant (Core Data ou CloudKit)
- Injection du contexte dans le prompt LLM
- Contrôle longueur des réponses

#### Option C : Approche Hybride

**Effort estimé :** Modéré à Élevé

```
iOS App ──▶ Backend léger (optionnel) ──▶ Services
   │
   └── Fonctionnalités locales + sync cloud
```

### Dépendances Techniques

| Dépendance | CalliVox Actuel | Avec Kyutai Backend |
|------------|-----------------|---------------------|
| iOS 17+ | ✅ | ✅ |
| Connexion Internet | Requise | Requise (sauf self-host) |
| Compte utilisateur | Local | Serveur (OAuth) |
| Backend serveur | Non | Oui (FastAPI + Docker) |
| GPU (self-host) | Non | Optionnel |

### Risques Identifiés

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Latence ajoutée par le backend | Moyen | Optimiser les endpoints, cache |
| Complexité de déploiement | Élevé | Documentation, scripts automatisés |
| Maintenance du backend | Moyen | Containerisation, monitoring |
| Dépendance au projet Kyutai | Moyen | Fork du repo, contribution active |

---

## Scénarios d'Intégration

### Scénario 1 : Intégration Minimale

**Objectif :** Ajouter le clonage vocal uniquement

**Implémentation :**

- Garder l'architecture CalliVox actuelle
- Ajouter option TTS Kyutai en plus de Gradium
- Upload du fichier audio pour clonage

**Effort :** Faible
**Valeur ajoutée :** Moyenne

### Scénario 2 : Enrichissement du Profil

**Objectif :** Personnalisation avancée sans backend

**Implémentation :**

- Étendre UserModel avec les champs Kyutai
- Stocker en Core Data / CloudKit
- Modifier le prompt LLM pour inclure le contexte
- Ajouter UI de gestion du profil

**Effort :** Modéré
**Valeur ajoutée :** Élevée

### Scénario 3 : Backend Complet

**Objectif :** Fonctionnalités complètes + multi-plateforme

**Implémentation :**

- Déployer le backend InvincibleVoice
- Adapter l'app iOS pour communiquer avec le backend
- Partager le backend avec une future version web

**Effort :** Élevé
**Valeur ajoutée :** Très élevée

### Scénario Recommandé : Approche Progressive

```
Phase 1 (Court terme)
├── Enrichir le profil utilisateur (Scénario 2)
├── Ajouter contrôle longueur réponses
└── Historique persistant local

Phase 2 (Moyen terme)
├── Option clonage vocal Kyutai (Scénario 1)
└── Sync CloudKit pour multi-device

Phase 3 (Long terme)
├── Backend optionnel pour institutions
└── Version web PWA
```

---

## Analyse Coûts-Bénéfices

### Coûts

| Élément | Estimation |
|---------|------------|
| Développement Phase 1 | 2-3 semaines |
| Développement Phase 2 | 3-4 semaines |
| Développement Phase 3 | 6-8 semaines |
| Infrastructure self-host | 500-2000€/mois |
| Maintenance continue | 1-2 jours/mois |

### Bénéfices

| Bénéfice | Impact Business |
|----------|-----------------|
| Clonage vocal | Différenciateur majeur, USP |
| Personnalisation | Meilleure rétention utilisateurs |
| Self-hosting | Accès marché institutionnel |
| Multi-plateforme | Élargissement base utilisateurs |
| Open-source contribution | Visibilité, crédibilité |

### ROI Estimé

- **Phase 1 seule** : ROI positif en 2-3 mois (amélioration UX)
- **Phase 1+2** : ROI positif en 4-6 mois (différenciation marché)
- **Phase complète** : ROI positif en 8-12 mois (nouveaux marchés)

---

## Recommandations

### Recommandation Principale

**Adopter une approche progressive en 3 phases**, en commençant par l'enrichissement du profil utilisateur qui offre le meilleur rapport effort/valeur.

### Actions Immédiates

1. **Créer un tech-spec** pour l'enrichissement du profil utilisateur
   - Champs : nom, prompt perso, amis, documents
   - Stockage : Core Data avec sync CloudKit optionnel
   - UI : Nouvelle section dans les paramètres

2. **Évaluer le clonage vocal Kyutai**
   - Tester la qualité de la synthèse
   - Évaluer les prérequis techniques
   - Estimer les coûts d'hébergement

3. **Contribuer au projet InvincibleVoice**
   - Remonter les bugs/améliorations
   - Proposer des contributions (iOS client ?)
   - Établir un contact avec l'équipe Kyutai

### Points de Vigilance

- **Ne pas sur-complexifier** l'architecture actuelle de CalliVox
- **Garder la latence faible** - c'est critique pour l'UX
- **Tester avec de vrais utilisateurs** avant chaque phase
- **Documenter les choix** pour faciliter la maintenance

---

## Annexes

### A. Variables d'Environnement Kyutai

```bash
# LLM Configuration
export KYUTAI_LLM_URL=https://api.cerebras.ai/v1
export KYUTAI_LLM_MODEL=qwen-3-235b-a22b-instruct-2507
export KYUTAI_LLM_API_KEY=<your_api_key>

# STT Configuration (Gradium)
export KYUTAI_STT_URL=wss://eu.api.gradium.ai/api/speech/asr
export STT_IS_GRADIUM=true
export GRADIUM_API_KEY=<your_api_key>

# TTS Configuration (Gradium)
export TTS_SERVER=https://eu.api.gradium.ai/api/
export TTS_IS_GRADIUM=true
export TTS_VOICE_ID=<optional_voice_id>
```

### B. Structure du Prompt LLM Kyutai

```
# System prompt
You are the assistant of a user suffering from ALS...

## User's name
The user is Fabrice.

## User's prompt
[Prompt personnalisé de l'utilisateur]

## User's friends
The friends of the user are: ["Marie", "Pierre", "Sophie"]

## User's documents
[Documents uploadés pour contexte]

## Past conversations with dates
[Historique des conversations passées]

## Current conversation with the user
[Conversation en cours]

## Desired responses length
Each response should be between 5 and 15 words long.

## User's keywords sent to you to guide your answers
[Keywords sélectionnés par l'utilisateur]
```

### C. Format de Réponse JSON

```json
{
  "suggested_keywords": [
    "Oui", "Non", "D'accord", "Merci", "S'il vous plaît",
    "Je ne sais pas", "Peut-être", "Bien sûr", "Pardon", "Au revoir"
  ],
  "suggested_answers": [
    "Très bien, merci de demander !",
    "Ça va bien, et toi ?",
    "Je vais plutôt bien aujourd'hui.",
    "Pas trop mal, j'ai bien dormi."
  ]
}
```

---

*Document généré le 2026-01-27 - CalliVox Team*
