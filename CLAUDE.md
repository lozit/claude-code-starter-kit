# CLAUDE.md — starter-kit (méta)

**Important** : ce fichier guide Claude quand il **développe le plugin starter-kit**. Il ne sera **pas copié** dans les projets utilisateurs — c'est `skills/bootstrap/templates/CLAUDE.md.{fr,en}.tpl` qui sert pour ça.

## Nature du repo : deux couches disjointes

Ce repo est à la fois :

**Couche A — Sources du plugin** (ce qui est publié) :
- `.claude-plugin/plugin.json` — manifest
- `marketplace.json` — marketplace mono-plugin pour install locale
- `skills/bootstrap/SKILL.md` — logique du slash command `/starter-kit:bootstrap`
- `skills/bootstrap/templates/*.tpl` — templates Markdown utilisés à la génération

**Couche B — Doc projet du plugin lui-même** (auto-application / dogfood) :
- `README.md` — doc d'installation et d'usage publique
- `CLAUDE.md` — ce fichier
- `docs/`, `brief/`, `media/`, `PLAN.md` — générés par le plugin appliqué à lui-même

Les deux couches **ne se chevauchent jamais** au niveau des chemins. Quand tu modifies quelque chose, demande-toi : "je touche les sources du plugin (A) ou la doc projet (B) ?".

## Tester le plugin localement

```bash
# Installer la marketplace locale
claude
# puis dans Claude Code :
/plugin marketplace add /Users/guillaumeferrari/Projets/Starting-Claude
/plugin install starter-kit@starter-kit-local
```

Alternative pour itération rapide :
```bash
claude --plugin-dir /Users/guillaumeferrari/Projets/Starting-Claude
```

Tester from-scratch :
```bash
mkdir /tmp/test-bootstrap && cd /tmp/test-bootstrap
claude
# puis : /starter-kit:bootstrap
```

Recharger après modif d'un template : redémarrer Claude (ou `/reload-plugins` si dispo).

## Conventions de templates

- Chaque template porte `<!-- generated-by: starter-kit v0.3.0 -->` en tête.
- Placeholders au format `{{KEY}}` (substitution texte simple, pas de moteur de template).
- Placeholders disponibles définis dans `skills/bootstrap/SKILL.md` (Phase 4).
- Suffixes de langue : `*.fr.tpl`, `*.en.tpl` pour les fichiers qui en ont besoin. Les fichiers sans suffixe sont langue-agnostiques (gitignore, adr-template, LEARNINGS, GLOSSARY...).

## Versioning

- Bumper `version` dans `.claude-plugin/plugin.json` ET dans `marketplace.json` à chaque release.
- Bumper la signature `<!-- generated-by: starter-kit vX.Y.Z -->` dans tous les templates en cohérence.
- Tenir `CHANGELOG.md` à jour (Keep-a-Changelog).

## Quand documenter

### ADR — `docs/decisions/`
Toute décision structurante sur le plugin (format des templates, nouveau placeholder, nouvelle phase du skill...) → un ADR.

### LEARNINGS — `docs/LEARNINGS.md`
Pièges du format plugin Claude Code, comportements surprenants de `AskUserQuestion`, gotchas `gh`/`glab`...

### PLAN.md
Tâches en cours sur le développement du plugin lui-même.

## À ne pas faire

- Ne pas mettre de logique dans `plugin.json` (juste métadonnées)
- Ne pas faire une seule giga-question `AskUserQuestion` dans le SKILL → grouper par thème (3-4 questions max par appel)
- Ne pas générer un `.gitignore` opinion à partir d'une stack non confirmée → minimal par défaut
- Ne pas écraser de fichier utilisateur sans confirmation explicite (mode reprise)
- Ne pas oublier que `disable-model-invocation: true` cache le skill à l'autocomplétion : seul le slash command marche

## Stack technique

Aucune. Pur Markdown + JSON. Le "code" est dans les instructions du SKILL.md que Claude exécute à la demande.

## Liens utiles

- Référence Claude Code plugins : https://docs.claude.com/en/docs/claude-code/plugins
- Best practices CLAUDE.md : https://github.com/shanraisshan/claude-code-best-practice, https://howborisusesclaudecode.com/
- Format ADR : https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
