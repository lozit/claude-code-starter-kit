---
name: verify-bootstrap
description: Vérifie qu'un projet starter-kit-bootstrappé est cohérent. Signatures versions, placeholders résiduels, CLAUDE.md taille, JSON valide, git, fichiers vs generatedFiles. Supporte --fix pour les corrections triviales.
disable-model-invocation: true
allowed-tools: Read, Edit, Bash, AskUserQuestion
---

# /starter-kit:verify-bootstrap

Tu vas vérifier la cohérence d'un projet amorcé avec starter-kit. Tu produiras un rapport ✅ / ⚠️ / ❌ et, sur demande, corriger les items safe.

Si `$ARGUMENTS` contient `--fix` (ou `fix`), passe en **mode correction** après le rapport. Sinon, rapport seul.

## Phase 1 — Pré-requis

1. `.starter-kit.json` doit exister dans le cwd. Sinon : *"Ce projet n'a pas été amorcé avec starter-kit, rien à vérifier."* Stop.
2. Lis `.starter-kit.json` → extrais :
   - `starterKitVersion` → **EXPECTED_VERSION**
   - `generatedFiles` → liste des fichiers à valider
   - `bootstrappedWithVersion` (info)

## Phase 2 — Validations par fichier

Pour chaque fichier dans `generatedFiles`, exécute ces checks dans l'ordre :

### 2.1 Existence

`test -f <path>` → si absent, marquer **❌ manquant** et passer au fichier suivant (les checks suivants n'ont pas de sens).

### 2.2 Signature présente

Lis les **10 premières lignes** du fichier (pour accommoder une YAML frontmatter qui peut compter jusqu'à 8-9 lignes : `---\nname: ...\npaths:\n  - "..."\n  - "..."\n---\n<!-- signature -->`). Cherche la regex `<!-- generated-by: starter-kit v([0-9]+\.[0-9]+\.[0-9]+) -->` :
- **Match** → extraire la version (FOUND_VERSION), continuer
- **No match** → **❌ signature absente**, passer aux checks suivants quand même

**Exceptions** : les fichiers JSON (`.starter-kit.json`, `.claude/settings.json`, etc.) n'ont pas de signature (commentaire HTML invalide en JSON). Pour ces fichiers, skip ce check.

**Note frontmatter YAML** : pour les fichiers commençant par `---` (rules, skills), la signature **doit** être sur la ligne juste après le `---` closing. Ex :
```
---
paths:
  - "..."
---
<!-- generated-by: starter-kit v0.6.0 -->
```

### 2.3 Version match

Si signature trouvée :
- `FOUND_VERSION == EXPECTED_VERSION` → **✅ version OK**
- Sinon → **⚠️ version mismatch (FOUND_VERSION vs EXPECTED_VERSION)**

### 2.4 Placeholders résiduels

Cherche dans tout le contenu du fichier les **placeholders connus** de bootstrap phase 5 (whitelist exacte) :

```
\{\{(PROJECT_NAME|DESCRIPTION|LANG|STACK|DATE|HAS_PLAN|HAS_ARCHITECTURE|HAS_GLOSSARY|HAS_CHANGELOG|REMOTE_PROVIDER|REMOTE_VISIBILITY|CONTENT|INTENT_SOURCE|GOAL|USERS|CONSTRAINTS|NONGOALS|ACCEPTANCE)\}\}
```

- **Aucun match** → **✅ pas de placeholder**
- **Match** → **❌ placeholders non substitués : {{PROJECT_NAME}}, {{DESCRIPTION}}, ...**

**Important : ne PAS matcher** `{{KEY}}`, `{{X}}`, `{{Y}}`, `{{NNNN}}`, etc. — ce sont des références documentaires (en backticks dans le texte) qui parlent du concept de placeholder. Seules les vraies clés bootstrap déclenchent l'erreur.

**Exception** : si le fichier est dans `skills/bootstrap/templates/` ou est lui-même un `*.tpl`, skip ce check (les templates contiennent ces placeholders par design — c'est uniquement le cas dans le dogfood, pas dans un projet utilisateur normal).

## Phase 3 — Validations structurelles

### 3.1 `.git/`

`test -d .git` → **✅ git initialisé** / **⚠️ pas de git** (peut-être intentionnel mais inhabituel)

### 3.2 CLAUDE.md taille

Si `CLAUDE.md` existe :
- `wc -l CLAUDE.md` → nombre de lignes
- **≤ 200** → **✅ CLAUDE.md X/200 lignes**
- **> 200** → **⚠️ CLAUDE.md X lignes (cible : < 200, considérer extraire vers `.claude/rules/`)**

### 3.3 JSON valides

Pour chacun des fichiers suivants s'il existe :
- `.starter-kit.json`
- `.claude/settings.json`
- `.claude-plugin/plugin.json` (présent uniquement si le projet est lui-même un plugin)

Test JSON : `python3 -c "import json,sys; json.load(open(sys.argv[1]))" <file>` (ou `node -e "JSON.parse(require('fs').readFileSync('<file>'))"`).
- **OK** → **✅ JSON valide**
- **Parse error** → **❌ JSON invalide : <message>**

### 3.4 Cohérence générale

- Si `intent.source = "skipped"` mais `docs/00-VISION.md` existe → **⚠️ incohérence : intent skipped mais vision présente**
- Si `intent.source` ≠ `"skipped"` mais `docs/00-VISION.md` manque → **❌ vision attendue mais absente**

## Phase 4 — Affichage du rapport

Format texte clair, groupé par catégorie :

```
=== Verify Bootstrap Report ===
Project: <project name from .starter-kit.json>
Expected version: <EXPECTED_VERSION>
Bootstrapped with: <bootstrappedWithVersion>

--- Fichiers (X/Y trackés) ---
✅ docs/decisions/README.md
   ✅ signature v0.6.0 · ✅ pas de placeholder
✅ docs/00-VISION.md
   ✅ signature v0.6.0 · ✅ pas de placeholder
⚠️ docs/ARCHITECTURE.md
   ⚠️ signature v0.5.0 (expected v0.6.0)
❌ docs/missing-file.md
   ❌ fichier absent

--- Structurel ---
✅ .git/ initialisé
✅ CLAUDE.md : 78/200 lignes
✅ .starter-kit.json JSON valide
✅ .claude/settings.json JSON valide
✅ Cohérence intent/vision

--- Synthèse ---
✅ N items OK
⚠️ M items à attention (version mismatch, taille)
❌ K items en erreur (manquants, placeholders, JSON invalide)
```

## Phase 5 — Mode correction (si `--fix`)

> Si `$ARGUMENTS` ne contient pas `--fix`, **skip cette phase**. Afficher seulement : *"Pour appliquer les corrections triviales, relance avec : `/starter-kit:verify-bootstrap --fix`"*

### Items corrigibles automatiquement

- **Version mismatch (⚠️)** : remplacer la ligne signature `<!-- generated-by: starter-kit vX.Y.Z -->` par la version courante via `Edit`.

### Items NON corrigibles automatiquement (afficher, ne pas toucher)

- Fichier manquant → l'utilisateur doit décider (recréer via `migrate` ? oublier ?)
- Placeholder résiduel `{{KEY}}` → bug de bootstrap, à remonter (problème de mapping dans SKILL.md)
- JSON invalide → édition manuelle nécessaire
- CLAUDE.md > 200 lignes → refactor manuel (extraire vers `.claude/rules/`)
- Incohérence intent/vision → l'utilisateur décide

### Confirmation

Pour les corrections de version mismatch :
- Liste les fichiers concernés
- `AskUserQuestion` : `Corriger les N signatures` / `Annuler`
- Si oui, applique les Edit
- Affiche : `✅ Signatures corrigées : N fichiers`

## Phase 6 — Récap final

```
=== Résultat ===
Mode : rapport / fix
Corrections appliquées : N signatures
Items restants : K erreurs, M warnings
```

Si tout est ✅ : *"Projet cohérent. Aucune correction nécessaire."*

Si erreurs restantes : suggestion par catégorie d'action manuelle.

**Ne JAMAIS commiter automatiquement** — laisse l'utilisateur reviewer les corrections de signature avant de committer.

## Règles importantes

- **Lecture seule par défaut** : sans `--fix`, le skill ne modifie aucun fichier.
- **Fix limité aux signatures** : tout autre type de correction nécessite une intervention humaine.
- **Pas d'effet sur `.starter-kit.json`** : le skill ne modifie pas l'état — il rapporte et corrige des fichiers utilisateur seulement.
- Pour la regex de signature, accepter `v0.0.0` (3 nombres séparés par `.`) sans contrainte sur la longueur — futur-proof.
- Si `python3` et `node` sont tous deux absents pour le check JSON, utiliser un fallback : `cat <file> | python -m json.tool > /dev/null 2>&1` ou simplement skip avec un warning *"Pas de parseur JSON disponible"*.
