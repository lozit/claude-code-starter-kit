---
name: migrate
description: Mettre à jour un projet starter-kit vers la version courante du plugin. Diff par fichier, jamais d'écrasement sans confirmation explicite.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# /starter-kit:migrate

Tu vas mettre à jour un projet amorcé avec starter-kit vers la version courante du plugin.

Si `$ARGUMENTS` contient `--dry-run` (ou `dry-run`), exécute toutes les phases d'analyse mais **n'écris aucun fichier** : termine par un rapport seul.

## Phase 1 — Détection des versions

1. `.starter-kit.json` doit exister dans le cwd. Sinon : *"Ce projet n'a pas été amorcé avec starter-kit, rien à migrer."* Stop.
2. Lis `.starter-kit.json` → extrais :
   - `starterKitVersion` → **OLD**
   - `answers` → réponses originales de l'interview
   - `generatedFiles` → liste des fichiers générés au bootstrap
3. Lis `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → extrais `version` → **NEW**.
4. Compare :
   - **OLD == NEW** → *"Projet à jour en version NEW. Rien à migrer."* Stop.
   - **OLD > NEW** (semver) → *"Version projet (OLD) plus récente que le plugin installé (NEW). Refus de downgrade."* Stop.
   - **OLD < NEW** → continue.

## Phase 2 — Afficher ce qui change

Lis `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md`. Extrais et affiche les entrées entre OLD et NEW pour que l'utilisateur comprenne ce qu'il va récupérer.

## Phase 3 — Analyser les fichiers trackés

Pour chaque fichier listé dans `generatedFiles` :

1. Identifie le template qui l'a produit. Utilise le même mapping que `skills/bootstrap/SKILL.md` phase 4 :
   - Fichiers avec variante `{lang}` → sélectionne d'après `answers.lang` (`fr` → `*.fr.tpl`, `en` → `*.en.tpl`, `mix` → `*.en.tpl` pour README, `*.fr.tpl` pour les autres)
   - Fichiers sans variante → template fixe
2. Lis `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap/templates/<template>` (version courante).
3. Substitue les placeholders avec `answers` (même logique que bootstrap phase 4).
4. Lis le fichier sur disque.
5. Compare via Bash `diff -u <(printf '%s' "$current") <(printf '%s' "$generated")` :
   - **Identique** → noter "déjà à jour"
   - **Diffère** → noter "à arbitrer" + garder le diff sous la main

## Phase 4 — Détecter les nouveaux fichiers disponibles

Pour chaque template du plugin courant qui produirait un fichier d'après `answers` (en respectant les flags `HAS_*`) **mais qui n'est PAS dans `generatedFiles`** :

- C'est un nouveau template introduit dans une version récente → proposer la création.

## Phase 5 — Récap et arbitrage

Affiche un tableau récap :

```
| Fichier                | État              | Action proposée      |
|------------------------|-------------------|----------------------|
| CLAUDE.md              | contenu modifié   | montrer diff puis choisir |
| docs/LEARNINGS.md      | identique         | skip                 |
| docs/ARCHITECTURE.md   | identique         | skip                 |
| (nouveau) docs/...     | template ajouté   | créer ? (optionnel)  |
```

Pour chaque fichier "contenu modifié", pose une question via `AskUserQuestion` (groupe par 3-4) :

- `Voir le diff` — affiche le diff via Bash `diff -u`, puis re-pose la question
- `Écraser avec le nouveau template` — destructif, mais met à jour
- `Garder mon fichier` — skip
- `Sauver le nouveau en .new` — écrit le nouveau contenu dans `<fichier>.new` pour merge manuel par l'utilisateur

Pour chaque "nouveau template disponible" : `Créer` / `Skip`.

## Phase 6 — Appliquer les décisions

> Si `--dry-run` : skip cette phase, va directement à la phase 8 avec un rapport "aurait fait :".

Pour chaque "Écraser" → `Write` du nouveau contenu.
Pour chaque "Sauver en .new" → `Write` vers `<fichier>.new`.
Pour chaque "Créer" → `Write` du nouveau fichier.

## Phase 7 — Mise à jour de `.starter-kit.json`

Mettre à jour :
- `starterKitVersion` → NEW
- `generatedFiles` → liste mise à jour (ajouter les fichiers nouvellement créés)
- Ajouter (ou créer) un tableau `migrations` avec l'entrée :
  ```json
  {"from": "OLD", "to": "NEW", "at": "YYYY-MM-DD"}
  ```

## Phase 8 — Récap final

Affiche :
- ✅ Fichiers mis à jour (écrasement)
- ✅ Fichiers créés (nouveaux templates)
- 📁 Fichiers `.new` à merger manuellement
- ⏭️ Fichiers laissés tels quels (choix utilisateur)
- 📋 Next steps :
  1. Reviewer les fichiers `.new` et merger manuellement ce qui te plaît
  2. Compléter les sections projet-spécifiques (Setup/Build/Test commands, stack, etc.) dans CLAUDE.md si elles ont été régénérées
  3. Commiter quand prêt

**Ne JAMAIS commiter automatiquement.**

## Règles importantes

- **Aucun écrasement sans choix explicite** de l'utilisateur (phase 5).
- **Refus de downgrade** : si la version projet est plus récente que le plugin installé, stop.
- Si un template référencé dans `generatedFiles` **n'existe plus** dans le plugin courant (fichier retiré dans une version récente), ne pas toucher le fichier ; signaler dans le récap.
- Si `--dry-run` : aucune écriture, juste un rapport — utile pour comprendre avant de s'engager.
- Le diff doit être lisible : préférer `diff -u` (unified) à `diff` brut.
