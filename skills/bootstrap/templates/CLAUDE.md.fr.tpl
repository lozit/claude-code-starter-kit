<!-- generated-by: starter-kit v0.3.0 -->
# CLAUDE.md — {{PROJECT_NAME}}

> Ce fichier est **mutable et itératif**. Mets-le à jour à chaque erreur de Claude ou convention découverte. Cible : < 200 lignes.

## Description

{{DESCRIPTION}}

## Setup / Build / Test

> **Test critique** : un nouveau dev (ou Claude) doit pouvoir lancer le projet et ses tests **du premier coup** avec les commandes ci-dessous. Si ce n'est pas le cas, complète cette section avant tout.

- Installer les deps : `<à compléter>`
- Lancer en dev : `<à compléter>`
- Tester : `<à compléter>`
- Linter : `<à compléter>`
- Build : `<à compléter>`

## Fichiers et dossiers clés

- `README.md` — présentation publique
- `CLAUDE.md` — ce fichier
- `PLAN.md` — todo actif (si présent), maintenu en cours de travail
- `docs/` — documentation projet
  - `docs/decisions/` — ADR (un fichier par décision structurante)
  - `docs/LEARNINGS.md` — apprentissages au fil du projet (antichronologique)
  - `docs/ARCHITECTURE.md` — snapshot archi (si présent)
  - `docs/GLOSSARY.md` — vocabulaire métier (si présent)
- `brief/` — notes amont (lis ce dossier pour le contexte métier en début de session)
- `media/` — assets visuels
- `.claude/` — config Claude Code
  - `.claude/settings.json` — config équipe, checké dans git
  - `.claude/rules/*.md` — règles auto-chargées (frontmatter `paths:` pour scoping)
  - `.claude/commands/`, `.claude/skills/`, `.claude/agents/`, `.claude/hooks/` — automatisations

## Conventions

### Commits

Conventional Commits : `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`. Petits et atomiques. Ne pas mélanger refactor et feature.

### Code

{{STACK}}

Lisibilité > concision. Pas d'abstractions prématurées. Pas de commentaires qui paraphrasent le code — réservés au "pourquoi" non évident.

### Permissions et settings

- Permissions safe pré-allouées via `/permissions` (ex : `"Bash(npm run *)"`, `"Bash(git status)"`)
- Config équipe dans `.claude/settings.json`, checké dans git
- Pour des règles spécifiques à un sous-dossier : `.claude/rules/<topic>.md` avec frontmatter `paths:` plutôt que d'alourdir ce fichier

## Vérifier le travail

Avant de déclarer une tâche terminée :

- Exécuter la commande de test ci-dessus
- Pour UI : utiliser réellement la feature dans un navigateur, pas juste compiler
- Pour data : vérifier les données réelles, pas juste l'absence d'erreur
- Produire un **behavior diff** (avant/après) — pas juste "j'ai lancé les tests"

> *"Prove to me this works"* — si tu ne peux pas le prouver, ce n'est pas fini.

## Quand documenter

### ADR — `docs/decisions/`

Dès qu'une **décision structurante** est prise (techno, pattern, tradeoff), propose un ADR. Copie `0000-template.md` → `NNNN-titre-kebab.md`. Garde-le < 1 page.

### LEARNINGS — `docs/LEARNINGS.md`

Dès qu'un **apprentissage non-trivial** émerge (piège évité, bug subtil, convention découverte), ajoute une entrée datée en tête.

### PLAN.md

Maintenir à jour : cocher fait, ajouter émergent, noter blocages.

## Mettre à jour ce fichier

Ce fichier est vivant.

- Quand Claude se trompe : ajoute la règle pour qu'il ne recommence pas
- Quand tu repères une convention non écrite : codifie-la ici
- Pour une règle qui **doit absolument survivre** à la croissance du fichier : `<important if="situation">règle</important>`
- Si le fichier dépasse 200 lignes ou si une section gonfle : extraire vers `docs/` ou `.claude/rules/`
- Pour les règles applicables à un certain type de fichier : préférer `.claude/rules/` avec `paths:` plutôt que de tout mettre ici

> *"Anytime we see Claude do something incorrectly we add it to the CLAUDE.md"* — itère jusqu'à ce que le taux d'erreur soit acceptable.

## Workflow Claude Code

- **Plan mode** (`shift+tab`) avant toute tâche non triviale
- **`/compact [hint]`** en cours de tâche pour comprimer le contexte ; **`/clear`** quand tu changes de tâche
- **Git worktrees** pour sessions parallèles : `claude --worktree <nom>`
- **Skills/commands custom** dans `.claude/` — si tu fais quelque chose plus d'une fois par jour, automatise-le
- **Délégation > pair-programming** : avec Opus 4.6+, donne le **goal**, les **contraintes**, et les **critères d'acceptation** en premier message, plutôt que de guider ligne par ligne

## Workflow git

- Ne committer que sur demande explicite (jamais en fin de tâche par défaut)
- Vérifier qu'aucun secret ni fichier de debug n'est inclus
- Branche par feature si la modification est non triviale

## À ne pas faire

- Ne pas ajouter de dépendances sans confirmer
- Ne pas commiter sans demande explicite
- Ne pas créer de nouveaux fichiers doc sans nécessité (préférer enrichir)
- Ne pas faire de refactor opportuniste pendant une feature
- Ne pas ignorer une règle de ce fichier — si elle ne tient pas, **modifie-la**, ne la contourne pas

## Stack technique

{{STACK}}

## Notes

Projet amorcé avec [starter-kit](https://github.com/guillaumeferrari/starter-kit) le {{DATE}}.
