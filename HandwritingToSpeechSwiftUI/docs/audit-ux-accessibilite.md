# Audit UX Accessibilité - CalliVox iPad

**Version**: 1.0
**Date**: 27 janvier 2026
**Auteur**: Sally, UX Designer Agent
**Contexte**: Application iPad pour utilisateurs atteints de maladies dégénératives (SLA, SEP, etc.)

---

## Table des matières

1. [Résumé Exécutif](#1-résumé-exécutif)
2. [Profil Utilisateur Cible](#2-profil-utilisateur-cible)
3. [Analyse de l'Interface Actuelle](#3-analyse-de-linterface-actuelle)
4. [Problèmes Critiques Identifiés](#4-problèmes-critiques-identifiés)
5. [Recommandations Prioritaires](#5-recommandations-prioritaires)
6. [Améliorations Détaillées par Composant](#6-améliorations-détaillées-par-composant)
7. [Nouvelles Fonctionnalités Suggérées](#7-nouvelles-fonctionnalités-suggérées)
8. [Plan d'Action Recommandé](#8-plan-daction-recommandé)

---

## 1. Résumé Exécutif

### Verdict Global

L'application CalliVox présente une base solide avec des fonctionnalités pertinentes (suggestions IA, mots-clés rapides, écoute interlocuteur), mais l'interface actuelle n'est **pas optimisée pour les utilisateurs avec des déficiences motrices progressives**.

### Score d'Accessibilité Actuel

| Critère | Score | Commentaire |
|---------|-------|-------------|
| Taille des cibles tactiles | 4/10 | Nombreux éléments < 44pt |
| Contraste visuel | 6/10 | Acceptable mais améliorable |
| Charge cognitive | 5/10 | Trop d'options simultanées |
| Efficacité (nombre de taps) | 4/10 | Actions courantes trop complexes |
| Tolérance aux erreurs | 5/10 | Peu de confirmation/annulation |
| Fatigue minimisation | 4/10 | Interactions répétitives nécessaires |

**Score Global: 4.7/10** - Nécessite des améliorations significatives.

---

## 2. Profil Utilisateur Cible

### 2.1 Pathologies Concernées

- **SLA (Sclérose Latérale Amyotrophique)**: Perte progressive du contrôle moteur
- **SEP (Sclérose en Plaques)**: Fatigue, tremblements, problèmes de coordination
- **Maladie de Parkinson**: Tremblements, rigidité, lenteur des mouvements
- **Dystrophie musculaire**: Faiblesse musculaire progressive
- **AVC séquellaire**: Hémiplégie, coordination réduite

### 2.2 Limitations Fonctionnelles à Considérer

#### Motricité Fine

- Difficulté à viser de petites cibles (< 60pt recommandé)
- Tremblements rendant les glissements difficiles
- Fatigue rapide des mains et bras
- Possible utilisation d'une seule main
- Temps de réaction rallongé

#### Vision

- Fatigue visuelle accrue
- Besoin de contrastes élevés
- Difficulté à suivre des éléments mobiles
- Sensibilité à la lumière possible

#### Cognition

- Charge mentale à minimiser (fatigue générale)
- Mémoire de travail potentiellement réduite
- Besoin de repères visuels clairs

### 2.3 Contexte d'Utilisation

- **Position**: Souvent en position assise/allongée, iPad sur support
- **Durée**: Sessions courtes mais fréquentes
- **Urgence**: Communications essentielles (besoins, douleur, appels)
- **Aidants**: Parfois configuration par un tiers

---

## 3. Analyse de l'Interface Actuelle

### 3.1 Structure Globale (ContentView)

```
┌─────────────────────────────────────────────────────────────┐
│ [Indicateur hors ligne]                                      │
├────────────────┬────────────────────────────────────────────┤
│                │                                             │
│   SIDEBAR      │  "CalliVox" (titre)                        │
│   (Boutons)    │                                             │
│                │  ┌─────────────────────────────────────────┐│
│ • Parler       │  │ Zone de texte                     [▶]  ││
│ • Répéter      │  └─────────────────────────────────────────┘│
│ • Effacer      │                                             │
│ • Phrases      │  [Suggestions IA]                          │
│ • Paramètres   │                                             │
│ • Usage        │  [Contextes de guidance] → scroll horizontal│
│ • Voix         │                                             │
│ • Gradium STT  │  [Mots-clés rapides] → scroll horizontal   │
│ • Gradium TTS  │                                             │
│ • IA Settings  │  ┌─────────────────────────────────────────┐│
│ • Personnalis  │  │ Suggestions IA (cartes verticales)     ││
│   ...          │  └─────────────────────────────────────────┘│
│                │                                             │
│ [Info user]    │  [Auto-lecture ○] [Écouter]                │
│                │                                             │
│                │  Phrases rapides (grille)                   │
└────────────────┴────────────────────────────────────────────┘
```

### 3.2 Composants Analysés

#### A. ControlButtonsView (Sidebar)

**Fichier**: `Views/ControlButtonsView.swift`
**Structure**: VStack avec ~11 boutons + info utilisateur

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Largeur | min: 200pt | Acceptable |
| Taille boutons | Variable, ~40pt hauteur | Trop petit |
| Espacement | 12pt | Insuffisant |
| Scroll interne | Oui (beaucoup de boutons) | Nécessite gestes |

**Observations**:

- 11+ boutons visibles, charge cognitive élevée
- Mélange paramètres et actions fréquentes
- Pas de catégorisation visuelle claire

#### B. TextInputWithSpeakButton

**Fichier**: `ContentView.swift` (lignes 8-74)

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Bouton Speak | 50x50pt | OK mais pourrait être plus grand |
| Zone texte | Font size 24 | Bien |
| Clavier | Standard iOS | Petites touches |

**Observations**:

- Le bouton play est bien visible
- La saisie texte classique est difficile pour ces utilisateurs
- Pas d'alternatives à la saisie clavier (prédiction, phrases préfabriquées)

#### C. GuidanceControlsView

**Fichier**: `Views/GuidanceControlsView.swift`

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Padding | 14h x 8v | **CRITIQUE: < 44pt** |
| Font | .caption | Trop petit |
| Scroll | Horizontal | Difficile avec tremblements |

**Observations**:

- Boutons trop petits (estimation ~30-35pt hauteur)
- Scroll horizontal = geste difficile
- Bon concept mais mauvaise implémentation taille

#### D. KeywordChipsView

**Fichier**: `Views/KeywordChipsView.swift`

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Padding | 14h x 8v | **CRITIQUE: < 44pt** |
| Font | .subheadline | Petit |
| Scroll | Horizontal | Difficile |

**Observations**:

- Même problèmes que GuidanceControlsView
- Excellente idée (mots-clés rapides) mal dimensionnée
- Devrait être la méthode principale d'interaction

#### E. SuggestionView

**Fichier**: `Views/SuggestionView.swift`

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Bouton Edit | 44x44pt | ✓ Conforme HIG |
| Cartes | Pleine largeur | Bien |
| Boutons header | 32x32pt | Trop petit |

**Observations**:

- Cartes suggestions bien dimensionnées
- Boutons refresh/dismiss (32x32) trop petits
- Bouton "Autre" acceptable

#### F. SpeechShortcutsView

**Fichier**: `Views/SpeechShortcutsView.swift`

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Largeur boutons | 120pt | OK |
| Hauteur | Dynamique | Potentiellement petit |
| Font | .subheadline | Petit |
| Grille | Adaptive, min 120 | Bien |

**Observations**:

- Concept excellent (phrases préfabriquées)
- Taille acceptable mais pourrait être agrandie
- Pas de catégorisation des phrases

#### G. TranscriptionOverlayView

**Fichier**: `Views/TranscriptionOverlayView.swift`

| Aspect | Valeur Actuelle | Problème |
|--------|-----------------|----------|
| Bouton stop | Capsule ~150x44 | Acceptable |
| Zone tap fond | Tout l'écran | Bon |
| Texte | .title | Bien visible |

**Observations**:

- Bien conçu pour l'accessibilité
- Zone de tap large (fond entier)
- Animation claire

---

## 4. Problèmes Critiques Identifiés

### 🔴 CRITIQUE (Blocage utilisateurs)

#### C1. Tailles de cibles insuffisantes

**Composants affectés**: GuidanceControlsView, KeywordChipsView, header SuggestionView

**Impact**: Utilisateurs avec tremblements incapables de taper les bons éléments

**Standard**: Apple HIG recommande **minimum 44x44pt**, idéalement **60pt** pour l'accessibilité

**Mesures actuelles**:

- Keyword chips: ~35pt hauteur
- Guidance buttons: ~30pt hauteur
- Refresh/Dismiss buttons: 32x32pt

#### C2. Scroll horizontal excessif

**Composants affectés**: GuidanceControlsView, KeywordChipsView

**Impact**: Geste de glissement difficile avec tremblements ou fatigue

**Problème**: Contenu essentiel caché nécessitant un geste de précision

#### C3. Trop de boutons dans la sidebar

**Composant**: ControlButtonsView

**Impact**: Charge cognitive élevée, recherche visuelle difficile

**Actuel**: 11+ boutons mélangés (actions + paramètres)

### 🟡 IMPORTANT (Dégradation expérience)

#### I1. Pas de mode "grandes cibles"

**Impact**: Pas d'adaptation selon le niveau de handicap

#### I2. Absence de confirmation pour actions importantes

**Impact**: Erreurs de tap coûteuses (effacer texte, arrêter TTS)

#### I3. Phrases rapides non catégorisées

**Impact**: Recherche visuelle longue, charge cognitive

#### I4. Pas de favoris/récents pour suggestions

**Impact**: Actions répétitives non optimisées

### 🟢 AMÉLIORATION (Nice to have)

#### A1. Thème sombre manquant

**Impact**: Confort visuel réduit

#### A2. Retour haptique limité

**Impact**: Confirmation d'action moins claire

#### A3. Pas de commandes vocales

**Impact**: Opportunité manquée (si voix résiduelle)

---

## 5. Recommandations Prioritaires

### Phase 1: Corrections Urgentes (Sprint 1)

#### R1. Agrandir toutes les cibles tactiles

**Minimum absolu**: 44x44pt
**Recommandé pour accessibilité**: 60x60pt
**Optimal**: 80x80pt (personnes avec tremblements sévères)

```swift
// Avant (KeywordChip)
.padding(.horizontal, 14)
.padding(.vertical, 8)

// Après
.frame(minHeight: 60)
.padding(.horizontal, 20)
.padding(.vertical, 16)
```

#### R2. Remplacer scroll horizontal par grille

**Avant**: ScrollView horizontal de chips
**Après**: LazyVGrid adaptatif montrant tous les éléments

```swift
// Recommandé
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 100), spacing: 12)
], spacing: 12) {
    ForEach(keywords, id: \.self) { keyword in
        KeywordButton(keyword: keyword)
            .frame(minHeight: 60)
    }
}
```

#### R3. Séparer actions et paramètres dans sidebar

**Avant**: 11 boutons mélangés
**Après**: Section haute = 4-5 actions principales, paramètres dans menu séparé

```
┌────────────────┐
│ 🔊 PARLER      │  ← Action principale, très grand
├────────────────┤
│ 🔄 Répéter     │
│ 🗑️ Effacer     │
│ 📝 Phrases     │
├────────────────┤
│ ⚙️ Paramètres  │  ← Ouvre sous-menu
└────────────────┘
```

### Phase 2: Améliorations Majeures (Sprint 2)

#### R4. Mode "Accessibilité Renforcée"

Paramètre global activant:

- Cibles de 80pt minimum
- Contraste augmenté
- Animation réduites
- Confirmation sur actions destructives

#### R5. Catégorisation des phrases rapides

```
┌─────────────────────────────────────┐
│ Besoins       │ Social      │ Santé │
├───────────────┼─────────────┼───────┤
│ J'ai soif     │ Bonjour     │ Douleur│
│ J'ai faim     │ Merci       │ Fatigue│
│ Toilettes     │ Au revoir   │ Appeler│
└───────────────┴─────────────┴───────┘
```

#### R6. Historique des phrases récentes

Afficher les 3-5 dernières phrases utilisées en haut pour accès rapide.

### Phase 3: Innovations (Sprint 3+)

#### R7. Mode Scanning (balayage)

Pour utilisateurs avec motricité très réduite:

- Surbrillance automatique séquentielle des boutons
- Un seul tap/contacteur pour sélectionner

#### R8. Prédiction contextuelle améliorée

Utiliser l'IA pour proposer phrases personnalisées basées sur:

- Heure de la journée
- Historique de conversation
- Contexte médical

---

## 6. Améliorations Détaillées par Composant

### 6.1 KeywordChipsView - Refonte Complète

**État actuel**: Scroll horizontal de petits chips

**Proposition**:

```
┌───────────────────────────────────────────────────────────┐
│ Réponses rapides                              [Tout voir] │
├───────────────────────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      │
│  │   Oui   │  │   Non   │  │ D'accord│  │  Merci  │      │
│  │         │  │         │  │         │  │         │      │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      │
│  │Je ne sais│  │Peut-être│  │Bien sûr │  │ Pardon  │      │
│  │   pas   │  │         │  │         │  │         │      │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘      │
└───────────────────────────────────────────────────────────┘
```

**Spécifications**:

- Grille 4 colonnes (iPad)
- Boutons: minimum 80x60pt
- Police: .body ou .title3
- Espacement: 12pt
- Pas de scroll si < 12 éléments

### 6.2 GuidanceControlsView - Refonte

**État actuel**: Scroll horizontal de petits boutons contexte

**Proposition**: Barre de contexte avec sélection modale

```
┌───────────────────────────────────────────────────────────┐
│ Contexte: [Conversation ▼]  ← Tap ouvre menu plein écran  │
└───────────────────────────────────────────────────────────┘

Menu ouvert:
┌───────────────────────────────────────────────────────────┐
│                    Choisir un contexte                    │
│                                                           │
│   ┌─────────────────┐   ┌─────────────────┐              │
│   │   Conversation  │   │     Médical     │              │
│   │      💬         │   │       🏥        │              │
│   └─────────────────┘   └─────────────────┘              │
│   ┌─────────────────┐   ┌─────────────────┐              │
│   │    Émotionnel   │   │      Repas      │              │
│   │       😊        │   │       🍽️        │              │
│   └─────────────────┘   └─────────────────┘              │
│                                                           │
│                      [✕ Fermer]                           │
└───────────────────────────────────────────────────────────┘
```

**Spécifications**:

- Affichage actuel: 1 bouton dropdown
- Menu modal: grille 2x3 avec boutons 150x100pt minimum
- Icônes + texte pour repérage visuel rapide

### 6.3 ControlButtonsView - Réorganisation

**État actuel**: 11+ boutons en liste verticale

**Proposition**: Hiérarchie claire avec regroupement

```
┌────────────────────────────┐
│      ┌────────────────┐    │
│      │    🔊 PARLER   │    │  ← Principal: 200x80pt
│      └────────────────┘    │
├────────────────────────────┤
│  ┌──────────┐┌──────────┐  │
│  │ Répéter  ││ Effacer  │  │  ← Secondaires: 95x60pt
│  └──────────┘└──────────┘  │
├────────────────────────────┤
│  ┌────────────────────┐    │
│  │  📝 Mes phrases    │    │  ← Actions: 200x50pt
│  └────────────────────┘    │
├────────────────────────────┤
│  ┌────────────────────┐    │
│  │  ⚙️ Paramètres  ▶  │    │  ← Ouvre sous-vue
│  └────────────────────┘    │
├────────────────────────────┤
│                            │
│  👤 Jean D.                │
│  ✅ Connecté               │
└────────────────────────────┘
```

### 6.4 SuggestionView - Ajustements

**État actuel**: Bon design, petits boutons header

**Modifications**:

- Refresh button: 32→44pt
- Dismiss button: 32→44pt
- Ajouter espacement entre boutons: 8→12pt
- Confirmer avant dismiss (option)

### 6.5 SpeechShortcutsView - Améliorations

**État actuel**: Grille de phrases préfabriquées 120pt

**Modifications**:

- Largeur minimum: 120→150pt
- Hauteur minimum: ajouter minHeight: 60
- Police: .subheadline→.body
- Ajouter icônes optionnelles par catégorie
- Trier par fréquence d'utilisation

---

## 7. Nouvelles Fonctionnalités Suggérées

### 7.1 Panneau d'Urgence

**Objectif**: Accès instantané aux messages critiques

**Implémentation**:

```
┌─────────────────────────────────────────────────────────┐
│ ⚡ URGENCE (tap pour ouvrir)                            │
└─────────────────────────────────────────────────────────┘

Ouvert:
┌─────────────────────────────────────────────────────────┐
│                     ⚠️ URGENCE ⚠️                       │
│                                                          │
│   ┌─────────────────┐   ┌─────────────────┐             │
│   │   🚨 APPELER    │   │   😰 J'AI MAL   │             │
│   │    À L'AIDE     │   │                 │             │
│   └─────────────────┘   └─────────────────┘             │
│   ┌─────────────────┐   ┌─────────────────┐             │
│   │  🏥 MÉDECIN     │   │   😵 MALAISE    │             │
│   └─────────────────┘   └─────────────────┘             │
│                                                          │
│                    [✕ Fermer]                            │
└─────────────────────────────────────────────────────────┘
```

**Spécifications**:

- Boutons très grands: 200x100pt minimum
- Couleurs contrastées (rouge pour urgence vraie)
- Son/vibration forte au tap
- Accessible depuis n'importe quel écran

### 7.2 Mode Fatigue Réduite

**Objectif**: Interface minimale pour moments de grande fatigue

**Affichage**:

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│   ┌─────────────────────────────────────────────────┐   │
│   │                    OUI                           │   │
│   └─────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────┐   │
│   │                    NON                           │   │
│   └─────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────┐   │
│   │                   APPELER                        │   │
│   └─────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────┐   │
│   │                   DOULEUR                        │   │
│   └─────────────────────────────────────────────────┘   │
│                                                          │
│                    [Mode normal]                         │
└─────────────────────────────────────────────────────────┘
```

**Spécifications**:

- 4-6 boutons maximum
- Pleine largeur, 100pt hauteur
- Contraste maximum
- Configurable par l'utilisateur

### 7.3 Phrases Prédictives par Heure

**Objectif**: Proposer phrases pertinentes selon moment journée

| Heure | Suggestions Prioritaires |
|-------|-------------------------|
| 7h-9h | "Bonjour", "Café", "Médicaments" |
| 12h-14h | "J'ai faim", "Repas", "Merci" |
| 18h-20h | "Dîner", "Fatigué", "Télévision" |
| 21h-23h | "Bonne nuit", "Lit", "Lumière" |

### 7.4 Historique Intelligent

**Objectif**: Accès rapide aux messages récents/fréquents

```
┌────────────────────────────────────────────────────────┐
│ 📋 Récents                                     [Voir +] │
├────────────────────────────────────────────────────────┤
│ • "Merci beaucoup" (il y a 5 min)                      │
│ • "J'ai soif" (il y a 12 min)                          │
│ • "Oui, d'accord" (il y a 25 min)                      │
└────────────────────────────────────────────────────────┘
```

---

## 8. Plan d'Action Recommandé

### Sprint 1: Corrections Critiques (1-2 semaines)

| # | Tâche | Composant | Priorité |
|---|-------|-----------|----------|
| 1 | Agrandir keyword chips à 60pt min | KeywordChipsView | P0 |
| 2 | Agrandir guidance buttons à 60pt min | GuidanceControlsView | P0 |
| 3 | Agrandir boutons header suggestions | SuggestionView | P0 |
| 4 | Remplacer scroll horizontal par grille | KeywordChipsView | P1 |
| 5 | Réorganiser sidebar (actions vs params) | ControlButtonsView | P1 |

### Sprint 2: Améliorations Majeures (2-3 semaines)

| # | Tâche | Composant | Priorité |
|---|-------|-----------|----------|
| 6 | Créer mode "Accessibilité Renforcée" | Settings + Global | P1 |
| 7 | Catégoriser phrases rapides | SpeechShortcutsView | P2 |
| 8 | Ajouter historique récent | Nouveau composant | P2 |
| 9 | Créer menu modal pour guidance | GuidanceControlsView | P2 |
| 10 | Ajouter confirmations actions | Global | P2 |

### Sprint 3: Innovations (3-4 semaines)

| # | Tâche | Composant | Priorité |
|---|-------|-----------|----------|
| 11 | Créer panneau urgence | Nouveau composant | P2 |
| 12 | Créer mode fatigue réduite | Nouveau mode | P2 |
| 13 | Implémenter phrases prédictives horaires | SuggestionService | P3 |
| 14 | Ajouter mode scanning (optionnel) | Global | P3 |

---

## Annexes

### A. Références Standards Accessibilité

- **WCAG 2.1**: Web Content Accessibility Guidelines
- **Apple HIG**: Human Interface Guidelines - Accessibility
- **ADA**: Americans with Disabilities Act guidelines
- **Section 508**: Federal accessibility requirements

### B. Tailles de Cibles Recommandées

| Niveau Handicap | Taille Minimum | Taille Recommandée |
|-----------------|----------------|-------------------|
| Léger | 44pt | 50pt |
| Modéré | 50pt | 60pt |
| Sévère | 60pt | 80pt |
| Très sévère | 80pt | 100pt |

### C. Ressources Complémentaires

- [Apple Accessibility Programming Guide](https://developer.apple.com/accessibility/)
- [Microsoft Inclusive Design](https://inclusive.microsoft.com/)
- [AbilityNet - Motor Impairments](https://abilitynet.org.uk/)

---

*Document généré par Sally, UX Designer Agent - BMAD Framework*
*Pour questions: Contacter l'équipe CalliVox*
