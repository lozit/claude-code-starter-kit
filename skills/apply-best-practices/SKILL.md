---
name: apply-best-practices
description: Fetch shanraisshan/claude-code-best-practice, propose les recommandations adaptées à la vision du projet, applique celles que l'utilisateur sélectionne.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Bash
---

# /starter-kit:apply-best-practices

Tu vas fetcher les bonnes pratiques Claude Code maintenues à jour par la communauté, les filtrer en fonction de la **vision** du projet, et appliquer les recommandations sélectionnées par l'utilisateur.

## Phase 1 — Pré-requis

1. `.starter-kit.json` doit exister dans le cwd. Sinon : *"Ce projet n'a pas été amorcé avec starter-kit. Lance d'abord `/starter-kit:bootstrap`."* Stop.
2. `docs/00-VISION.md` doit exister. Sinon : *"Pas de vision du projet trouvée. Cette commande a besoin de l'intent pour proposer des pratiques adaptées. Lance `/starter-kit:bootstrap` (ou ajoute manuellement la vision avant de relancer)."* Stop.
3. Lis `.starter-kit.json` → extrais `answers.lang` pour la langue de l'interaction.
4. Lis `docs/00-VISION.md` → contenu intégral à passer au fetch.

## Phase 2 — Fetch des bonnes pratiques

Utilise `WebFetch` sur `https://github.com/shanraisshan/claude-code-best-practice` avec ce prompt (à adapter à la langue) :

> Voici la vision d'un projet Claude Code :
>
> ```
> <contenu intégral de docs/00-VISION.md>
> ```
>
> Extrais de cette page les meilleures pratiques Claude Code qui sont **pertinentes pour CE projet précisément** (pas une liste générique). Catégorise les recommandations en :
>
> 1. **Sections à ajouter ou enrichir dans `CLAUDE.md`** — pour chaque section, donner : nom proposé, contenu suggéré en 3-6 lignes, raison liée à la vision
> 2. **Fichiers `.claude/rules/<topic>.md`** — pour chaque règle, donner : nom de fichier, frontmatter `paths:` si applicable, contenu, raison
> 3. **Permissions à pré-allouer dans `.claude/settings.json`** — liste des patterns (`Bash(npm run *)`, `Edit(/docs/**)`, etc.) avec justification
> 4. **Hooks à considérer** — type de hook (PreToolUse, PostToolUse, Stop...), but, snippet
> 5. **Skills / agents / slash commands custom à créer** — nom, but, déclencheur
>
> Pour chaque recommandation, attribue une priorité **High / Medium / Low** basée sur l'adéquation à la vision. Maximum 15 recommandations totales — privilégie la pertinence sur l'exhaustivité.
>
> Format de sortie : Markdown structuré, une recommandation par bloc avec `### NOM` + `**Catégorie** | **Priorité** | **Raison** | **Contenu suggéré**`.

## Phase 3 — Présenter les recommandations

Affiche le résultat du WebFetch à l'utilisateur, formaté lisiblement.

Note : si WebFetch échoue (réseau, repo déplacé, etc.) → afficher l'erreur, proposer de réessayer ou skip. Stop si skip.

## Phase 4 — Sélection

Pose une `AskUserQuestion` multi-select avec les recommandations. Si > 10 items, grouper par catégorie en plusieurs appels (max 4 options par appel pour bonne UX).

Pour chaque recommandation, l'option label : `[PRIO] Nom court — raison en 1 ligne`.

## Phase 5 — Récap avant application

Affiche en texte les recommandations sélectionnées et ce qui va concrètement changer (fichier par fichier).

`AskUserQuestion` finale : `Appliquer maintenant` / `Sauver les recommandations dans docs/best-practices-pending.md et appliquer plus tard` / `Annuler`.

## Phase 6 — Application

Pour chaque recommandation sélectionnée :

### Si "section CLAUDE.md"

- Lis le `CLAUDE.md` actuel
- Trouve l'endroit logique d'insertion (avant la section "À ne pas faire" / "Don't" qui est généralement en fin)
- Utilise `Edit` pour insérer la nouvelle section avec son contenu suggéré
- Vérifie que le fichier reste sous 200 lignes ; si dépassé, alerter l'utilisateur et suggérer extraction vers `.claude/rules/`

### Si "fichier `.claude/rules/<topic>.md`"

- Crée le fichier avec son frontmatter (incluant `paths:` si suggéré) et son contenu
- **Signature** : placer `<!-- generated-by: starter-kit vX.Y.Z -->` sur la ligne immédiatement après le `---` closing du frontmatter (PAS en ligne 1, car le frontmatter doit y rester). Format :
  ```
  ---
  paths:
    - "..."
  ---
  <!-- generated-by: starter-kit v0.6.0 -->

  # Titre
  ...
  ```
- Vérifie que le dossier `.claude/rules/` existe (créer si besoin via `Write` qui crée les parents)

### Si "permission `.claude/settings.json`"

- Lis `.claude/settings.json` s'il existe ; sinon démarre avec `{}` minimal
- Ajoute la permission au tableau `permissions.allow` (créer la clé si absente)
- Write back

### Si "hook"

- N'applique **pas automatiquement** — affiche le snippet à coller manuellement dans `.claude/settings.json` ou `.claude/hooks/`
- Raison : les hooks ont des effets de bord (commandes shell) qui exigent revue humaine
- Sauve le snippet dans `docs/best-practices-pending.md` pour qu'il ne soit pas oublié

### Si "skill / agent / command custom"

- N'applique pas — affiche le nom et le but, suggère à l'utilisateur de le créer manuellement ou de relancer `apply-best-practices` après avoir réfléchi
- Sauve le suggestion dans `docs/best-practices-pending.md`

### Si "sauver pour plus tard" choisi en phase 5

Au lieu d'appliquer, écris tout dans `docs/best-practices-pending.md` (format Markdown structuré, copie/colle facile). Pas d'application directe.

## Phase 7 — Mise à jour de `.starter-kit.json`

Ajoute (ou met à jour) le champ `appliedPractices` :

```json
"appliedPractices": [
  {
    "appliedAt": "YYYY-MM-DD",
    "source": "shanraisshan/claude-code-best-practice",
    "items": [
      {"category": "claudemd-section", "name": "...", "status": "applied" | "pending"},
      ...
    ]
  }
]
```

L'array est append-only : chaque exécution ajoute un objet daté (utile si shanraisshan évolue et que l'utilisateur réapplique).

## Phase 8 — Récap final

Affiche :
- ✅ Pratiques appliquées (avec fichier modifié/créé)
- 📁 Pratiques en attente (sauvées dans `docs/best-practices-pending.md`)
- ⏭️ Pratiques ignorées (non sélectionnées par l'utilisateur)
- 📋 Next steps :
  - Reviewer `docs/best-practices-pending.md` pour les hooks et skills suggérés
  - Reviewer `CLAUDE.md` (si modifié) avant de commiter
  - Lancer `/starter-kit:apply-best-practices` à nouveau plus tard si shanraisshan évolue

**Ne JAMAIS commiter automatiquement.**

## Règles importantes

- Le fetch est **fait à chaque exécution** : pas de cache local des recommandations (sinon le repo source — qui évolue régulièrement — ne sert à rien).
- Pour les modifications de `CLAUDE.md`, **toujours montrer le diff** avant de write (afficher l'ancien et le nouveau via Edit's natural display).
- Si `appliedPractices` existe déjà (re-exécution), ne pas dupliquer les pratiques déjà appliquées ; signaler "déjà appliqué le YYYY-MM-DD" et permettre de skip ou ré-appliquer (utile si la pratique a évolué).
- Hooks et skills custom ne sont **jamais** appliqués automatiquement — toujours sauvés en `pending`.
