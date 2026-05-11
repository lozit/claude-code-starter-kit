---
name: bootstrap
description: Bootstrap interactif d'un nouveau projet Claude Code — interview, structure docs/, git init, remote optionnel.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# /starter-kit:bootstrap

Tu vas amorcer un projet Claude Code dans le **répertoire de travail courant**. Suis ces phases dans l'ordre, sans en sauter.

## Phase 1 — Scan du dossier

1. Exécute `ls -la` sur le cwd.
2. Détecte les marqueurs suivants et note ce qui est présent :
   - `.git/` (repo git existant)
   - `.starter-kit.json` (état d'une précédente invocation — si présent, charge-le et passe en **mode reprise**)
   - `CLAUDE.md`, `README.md`, `docs/`, `brief/`, `media/`, `PLAN.md`, `CHANGELOG.md`, `.gitignore`
   - `package.json` (→ stack Node), `pyproject.toml`/`requirements.txt` (→ Python), `Cargo.toml` (→ Rust), `go.mod` (→ Go)
3. Pour chaque fichier que tu vas potentiellement créer, classe-le :
   - **Absent** → à créer
   - **Présent avec signature `<!-- generated-by: starter-kit -->` en tête** → reconnu, proposer "ignorer / régénérer"
   - **Présent sans signature** → fichier étranger, défaut "ignorer"

Si le dossier est complètement vide → mode bootstrap classique. Sinon → mode reprise (annoncer clairement à l'utilisateur en début d'interview).

## Phase 2 — Interview

Groupe les questions par thème via `AskUserQuestion` (4 questions max par appel pour bonne UX).

### Appel 1 — Identité du projet
- **Nom du projet** : utilise le nom du dossier comme suggestion par défaut, demande confirmation. (1 question)
- **Description courte** (1 phrase) (1 question)
- **Langue des fichiers générés** : `Tout en français` / `README EN, reste FR` / `Tout en anglais` (1 question)
- **Type de projet** : `Codant (app, lib, CLI...)` / `Non-codant (doc, recherche, notes...)` (1 question)

### Appel 2 — Stack et docs (si codant)
Si projet codant :
- **Stack principale** : pré-remplir avec ce que tu as détecté (Node, Python, etc.), proposer `Autre`, `Aucune particulière` (1 question)
- **`docs/ARCHITECTURE.md`** : Oui (recommandé pour projet codant) / Non (1 question)
- **`docs/GLOSSARY.md`** : `Oui, jargon métier` / `Non` (1 question)
- **`CHANGELOG.md` (Keep-a-Changelog)** : `Oui, releases versionnées prévues` / `Non` (1 question)

Si non-codant, ne pose que les 2 dernières (GLOSSARY, CHANGELOG).

### Appel 3 — Pilotage et git
- **`PLAN.md` à la racine** (todo actif maintenu par Claude) : `Oui (recommandé)` / `Non` (1 question)
- **Remote git** : `GitHub` / `GitLab` / `Aucun pour l'instant` (1 question)
- Si remote ≠ "Aucun" :
  - **Visibilité** : `Privé (recommandé)` / `Public` (1 question)

## Phase 3 — Récap et confirmation

Affiche un récapitulatif clair en texte :
- Liste des fichiers qui seront **créés** (chemin complet)
- Liste des fichiers qui seront **ignorés** (mode reprise)
- Actions git prévues (`git init`, premier commit, remote)

Puis une question `AskUserQuestion` finale : `Confirmer et générer` / `Annuler`.

## Phase 4 — Génération des fichiers

Pour chaque fichier à créer :

1. Lis le template correspondant dans `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/` (le plugin root est accessible via cette variable d'environnement).
2. Remplace les placeholders `{{KEY}}` par les valeurs collectées. Placeholders disponibles :
   - `{{PROJECT_NAME}}` — nom du projet
   - `{{DESCRIPTION}}` — description courte
   - `{{LANG}}` — `fr` / `en` / `mix`
   - `{{STACK}}` — stack ou chaîne vide
   - `{{DATE}}` — date du jour ISO (YYYY-MM-DD)
   - `{{HAS_PLAN}}`, `{{HAS_ARCHITECTURE}}`, `{{HAS_GLOSSARY}}`, `{{HAS_CHANGELOG}}` — `true`/`false`
   - `{{REMOTE_PROVIDER}}` — `github` / `gitlab` / chaîne vide
   - `{{REMOTE_VISIBILITY}}` — `private` / `public` / chaîne vide
3. **Substitution texte simple** : pas de moteur de template, juste `replace` sur chaque placeholder.
4. Écris le fichier à destination via l'outil `Write`.

### Sélection des templates par langue

- Pour `{{LANG}}=fr` : utilise `*.fr.tpl`
- Pour `{{LANG}}=en` : utilise `*.en.tpl`
- Pour `{{LANG}}=mix` : `README.md` ← `*.en.tpl`, le reste ← `*.fr.tpl`

### Mapping fichiers (toujours créés)

| Template | Destination |
|---|---|
| `README.md.{lang}.tpl` | `README.md` |
| `CLAUDE.md.{lang}.tpl` | `CLAUDE.md` |
| `gitignore.minimal` | `.gitignore` |
| `decisions-README.md.{lang}.tpl` | `docs/decisions/README.md` |
| `adr-template.{lang}.md` | `docs/decisions/0000-template.md` |
| `LEARNINGS.md.tpl` | `docs/LEARNINGS.md` |
| `brief-README.md.tpl` | `brief/README.md` |
| `media-README.md.tpl` | `media/README.md` |

### Mapping fichiers (conditionnels)

| Condition | Template | Destination |
|---|---|---|
| `HAS_PLAN=true` | `PLAN.md.tpl` | `PLAN.md` |
| `HAS_ARCHITECTURE=true` | `ARCHITECTURE.md.tpl` | `docs/ARCHITECTURE.md` |
| `HAS_GLOSSARY=true` | `GLOSSARY.md.tpl` | `docs/GLOSSARY.md` |
| `HAS_CHANGELOG=true` | `CHANGELOG.md.tpl` | `CHANGELOG.md` |

### État persisté

Écris `.starter-kit.json` à la racine avec les réponses de l'interview (pour traçabilité et futures invocations).

## Phase 5 — Git

1. Si `.git/` absent dans cwd → `git init -b main`.
2. `git add -A`
3. Vérifie qu'il y a quelque chose à committer : `git diff --cached --quiet` → si rien, skip le commit.
4. Sinon : `git commit -m "chore: bootstrap project structure with starter-kit v0.3.0"`

## Phase 6 — Remote (si demandé)

Si `{{REMOTE_PROVIDER}}=github` :
1. `command -v gh` → si absent, affiche message d'instruction manuelle et passe à la phase 7.
2. `gh auth status` → si non authentifié, indique `gh auth login` et passe à la phase 7.
3. `gh repo create {{PROJECT_NAME}} --{{REMOTE_VISIBILITY}} --source=. --remote=origin --push`

Si `{{REMOTE_PROVIDER}}=gitlab` : idem avec `glab` au lieu de `gh`. La commande est `glab repo create {{PROJECT_NAME}} --{{REMOTE_VISIBILITY}}` puis `git push -u origin main`.

En cas d'échec gracieux (CLI absent / auth manquante) : afficher la commande prête à coller pour exécution manuelle.

## Phase 7 — Récap final

Affiche à l'utilisateur :
- ✅ Liste des fichiers créés (chemins relatifs)
- ✅ Actions git réalisées (init, commit hash court, remote URL si créé)
- 📋 Next steps suggérés :
  1. Remplir `brief/` avec les notes amont
  2. Préciser le contenu de `CLAUDE.md` (sections à compléter)
  3. Si `PLAN.md` créé : ajouter les premières tâches
  4. Lire les docs Claude Code best practices pertinentes

## Règles importantes

- **Ne JAMAIS écraser un fichier sans confirmation explicite** (cf. phase 3).
- **Toujours** ajouter `<!-- generated-by: starter-kit v0.3.0 -->` en tête de chaque fichier généré (les templates le contiennent déjà).
- **Idempotence** : si l'utilisateur relance le skill, mode reprise détecte les fichiers déjà à jour et ne fait rien.
- **Trace les erreurs** : si une étape échoue (ex. `gh repo create` retourne une erreur), ne fais pas semblant que ça a marché. Affiche l'erreur, propose une action.
- **Conserver le `.starter-kit.json`** : c'est la source de vérité pour le mode reprise.
