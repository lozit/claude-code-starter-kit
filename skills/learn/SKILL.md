---
name: learn
description: Ajouter une entrée datée en tête de docs/LEARNINGS.md — court, en place, sans cérémonie.
disable-model-invocation: true
allowed-tools: Read, Edit, AskUserQuestion, Bash
---

# /starter-kit:learn

Tu vas ajouter une entrée d'apprentissage en tête de `docs/LEARNINGS.md` du projet courant.

## Phase 1 — Vérifications

1. `docs/LEARNINGS.md` doit exister dans le cwd. Sinon : avertir et proposer `/starter-kit:bootstrap`. Stop.
2. Lis `.starter-kit.json` si présent → `answers.lang` (`fr` / `en` / `mix`). Défaut = `en`.

## Phase 2 — Collecter l'entrée

Si `$ARGUMENTS` non-vide, utilise-le comme **titre court** (la première ligne).

Pose les questions via `AskUserQuestion` (un seul appel) :

- **Titre court** (1 phrase, ex: "Long task names break the spinner") — skip si déjà fourni via `$ARGUMENTS`
- **Contexte** (1-2 phrases : ce qu'on faisait quand on a découvert ça)
- **Leçon** (1-3 phrases : ce qu'on a appris et comment l'appliquer)

Garde les réponses **courtes**. Si l'utilisateur écrit un pavé, garde l'essentiel ; pas de hagiographie.

## Phase 3 — Formatage

Date du jour au format ISO (YYYY-MM-DD).

Format de l'entrée :

**Langue FR** :
```markdown
## {DATE} — {TITRE}

**Contexte** : {CONTEXTE}
**Leçon** : {LECON}
```

**Langue EN** (et `mix`) :
```markdown
## {DATE} — {TITLE}

**Context**: {CONTEXT}
**Lesson**: {LESSON}
```

## Phase 4 — Insertion

Lis `docs/LEARNINGS.md`.

Trouve le séparateur `---` (le premier après l'intro). Les nouvelles entrées vont **juste après** ce `---`, en tête (antichronologique).

Utilise `Edit` avec :
- `old_string` = `\n---\n\n` (le séparateur tel quel, avec ses retours à la ligne)
- `new_string` = `\n---\n\n{ENTRÉE FORMATÉE}\n\n` (le séparateur + l'entrée + double saut pour aérer)

Si l'utilisateur a déjà des entrées et que `---` n'a plus la forme `\n---\n\n<!-- Example`, adapte : insère après le `---` en respectant le format existant.

## Phase 5 — Récap

Affiche :
- ✅ Entrée ajoutée à `docs/LEARNINGS.md`
- 📋 Le titre et la date

**Ne JAMAIS commit automatiquement**.

## Règles importantes

- Garde l'entrée **courte** : c'est un journal, pas un essai. Si l'utilisateur veut écrire plus, suggère plutôt un ADR ou une section dans `docs/`.
- Si deux entrées sont ajoutées dans la même journée, c'est OK — les deux apparaissent l'une après l'autre, la plus récente en haut.
- Conserve la signature `generated-by` du fichier en l'état (ne pas la régénérer ici).
