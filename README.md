# starter-kit

Plugin Claude Code qui **bootstrappe** un nouveau projet via un slash command interactif.

> Interview → structure de projet adaptée → `git init` → premier commit → remote optionnel.

## Slash commands fournis

- `/starter-kit:bootstrap` — interview + génération from-scratch d'un nouveau projet
- `/starter-kit:add-adr` — créer un nouvel ADR avec numéro auto, index mis à jour
- `/starter-kit:learn` — ajouter une entrée datée à `docs/LEARNINGS.md`
- `/starter-kit:migrate` — mettre à jour un projet existant vers la version courante du plugin (diff par fichier, jamais d'écrasement sans confirmation, supporte `--dry-run`)

## Ce que fait `/starter-kit:bootstrap`

`/starter-kit:bootstrap` lance une interview courte (4-8 questions groupées) puis génère :

- `README.md`, `CLAUDE.md`, `.gitignore` — toujours
- `docs/decisions/` (ADR Michael Nygard), `docs/LEARNINGS.md` — toujours
- `brief/`, `media/` — toujours, avec README explicatifs
- `PLAN.md`, `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`, `CHANGELOG.md` — selon tes réponses
- `git init` + premier commit
- Création du repo distant via `gh` (GitHub) ou `glab` (GitLab) si tu choisis un fournisseur

Tous les fichiers générés portent une signature `<!-- generated-by: starter-kit -->` pour permettre le **mode reprise** : tu peux relancer la commande sur un dossier non-vide sans risque d'écrasement.

## Installation

### Depuis ce repo (local)

```bash
# Dans Claude Code :
/plugin marketplace add /chemin/vers/starter-kit
/plugin install starter-kit@starter-kit-local
```

### Depuis GitHub (si publié)

```bash
/plugin marketplace add https://github.com/guillaumeferrari/starter-kit
/plugin install starter-kit
```

### Mode dev (itération rapide sans install)

```bash
claude --plugin-dir /chemin/vers/starter-kit
```

## Usage

Dans le dossier vide d'un nouveau projet :

```bash
cd ~/Projets/mon-nouveau-projet
claude
```

Puis dans Claude Code :

```
/starter-kit:bootstrap
```

Réponds aux questions. La structure est générée, git est initialisé, et (si demandé) le repo distant est créé.

## Langues supportées

Les fichiers générés peuvent être en français, en anglais, ou en mix (README EN + reste FR). Choix pendant l'interview.

## Structure du plugin

```
starter-kit/
├── .claude-plugin/plugin.json    # manifest
├── marketplace.json              # mono-plugin marketplace
└── skills/bootstrap/
    ├── SKILL.md                  # logique du slash command
    └── templates/                # templates Markdown
```

## Prérequis pour le remote

- `gh` CLI pour GitHub : https://cli.github.com/
- `glab` CLI pour GitLab : https://gitlab.com/gitlab-org/cli

Si absent, le plugin affiche les commandes prêtes à coller pour exécution manuelle.

## Roadmap

- [x] V0.1 — bootstrap from-scratch + mode reprise
- [x] V0.2 — `CLAUDE.md` template restructuré avec best practices (Boris Cherny, shanraisshan)
- [x] V0.3 — skills `/starter-kit:add-adr` (nouvel ADR auto-incrémenté) et `/starter-kit:learn` (entrée datée dans LEARNINGS)
- [x] V0.4 — skill `/starter-kit:migrate` (diff par fichier, `.new` fallback, `--dry-run`)
- [ ] Publication marketplace publique sur GitHub

## Licence

À définir.
