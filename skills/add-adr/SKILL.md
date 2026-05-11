---
name: add-adr
description: Créer un nouvel ADR dans docs/decisions/ — numéro auto-incrémenté, langue déduite, index mis à jour.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# /starter-kit:add-adr

Tu vas créer un nouvel **Architecture Decision Record** dans le projet courant.

## Phase 1 — Contexte projet

1. Vérifie que `docs/decisions/` existe dans le cwd. Sinon : avertir l'utilisateur que le projet n'a pas la structure starter-kit et proposer `/starter-kit:bootstrap` d'abord. Stop.
2. Lis `.starter-kit.json` à la racine si présent — en extraire `answers.lang` (`fr` / `en` / `mix`). Si absent ou `mix`, défaut = `en`.
3. Calcule le **prochain numéro d'ADR** :
   - `ls docs/decisions/[0-9]*.md 2>/dev/null`
   - Extrais le préfixe NNNN de chaque nom de fichier (ignore `0000-template.md`)
   - Prochain numéro = max + 1, formaté sur 4 chiffres (ex: `0003`)
   - Si aucun ADR existant (hors template) → `0001`

## Phase 2 — Collecter les infos

Si `$ARGUMENTS` est non-vide, utilise-le comme **titre** brut (la première ligne).

Sinon, pose les questions via `AskUserQuestion` (un seul appel, max 3 questions) :

- **Titre court** (1 phrase, ex: "Database choice for analytics module")
- **Statut initial** : `Proposed` (recommandé) / `Accepted`
- **Mode** : `Squelette` (juste le template avec placeholders à remplir) / `Pré-rempli` (poser 2 questions de plus pour Context et Decision en 1-2 phrases chacune)

Si mode `Pré-rempli`, faire un 2e appel :
- **Context (1-3 phrases)** : pourquoi cette décision se pose maintenant
- **Decision (1-2 phrases)** : ce qui est décidé

## Phase 3 — Slugification du titre

Convertir le titre en kebab-case pour le nom de fichier :
- Tout en minuscules
- Strip accents (é→e, à→a, etc.)
- Caractères non-alphanumériques → tiret
- Tirets consécutifs → un seul tiret
- Trim tirets en début/fin
- Limite à ~60 caractères

Exemple : `"Database choice for the analytics module"` → `database-choice-for-the-analytics-module`

Nom final : `NNNN-{slug}.md`

## Phase 4 — Génération

1. Lis le template : `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/adr-template.{lang}.md`
2. Substitutions à faire dans le contenu lu :
   - `NNNN — Titre court de la décision` (FR) ou `NNNN — Short decision title` (EN) → `NNNN — {Titre fourni}`
   - `**Date** : YYYY-MM-DD` ou `**Date**: YYYY-MM-DD` → date du jour ISO
   - `**Statut** : Proposé | Accepté | ...` ou `**Status**: Proposed | Accepted | ...` → `**Statut/Status**: {Statut choisi}`
   - Mettre à jour la signature `<!-- generated-by: starter-kit vX.Y.Z -->` à la version actuelle du plugin (lire depuis `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`)
   - Si mode `Pré-rempli` : remplacer la section Context et Decision par les phrases fournies (laisser Alternatives/Consequences/Notes avec leurs placeholders)
3. Écris à `docs/decisions/NNNN-{slug}.md` via `Write`.

## Phase 5 — Mettre à jour l'index

Lis `docs/decisions/README.md`. Trouve la ligne tableau correspondant au dernier ADR existant (ou la ligne `| 0000 | Template | — | — |` si premier ADR).

Insère **après cette ligne** une nouvelle ligne :

```
| [NNNN](NNNN-{slug}.md) | {Titre} | {Statut} | {Date} |
```

Utilise l'outil `Edit` avec `old_string` = la ligne précédente, `new_string` = la ligne précédente + `\n` + la nouvelle ligne.

## Phase 6 — Récap

Affiche à l'utilisateur :
- ✅ Chemin du nouvel ADR créé
- ✅ Numéro attribué
- 📋 Next steps :
  - Ouvrir le fichier et remplir les sections Alternatives / Consequences
  - Si mode `Squelette` : remplir Context et Decision

**Ne JAMAIS commit automatiquement** — laisse l'utilisateur décider quand commiter.

## Règles importantes

- Si un ADR avec le même slug existe déjà → afficher l'erreur, proposer un titre légèrement différent.
- Ne pas écraser un ADR existant.
- Conserver la signature `generated-by` pour cohérence avec les autres fichiers du projet.
