---
paths:
  - ".claude-plugin/**"
  - "skills/**"
  - "**/*.tpl"
---

# Plugin meta-development rules

Auto-loaded when Claude touches plugin sources (manifests, skills, templates).

## Template over code

Cette repo est un plugin Claude Code, pas une application. Toute logique vit dans des **instructions Markdown** dans `skills/*/SKILL.md` que Claude exécute à la demande. Pour les templates utilisateur (`*.tpl`), substitution texte simple `{{KEY}}` uniquement — jamais de moteur de template (Jinja, Handlebars...) ni de génération de code applicatif. Cf. ADR 0002.

## Dogfooding et deux couches

Le repo est en **deux couches disjointes** (cf. ADR 0003 + le `CLAUDE.md` racine) :
- **Couche A** = sources publiées (`.claude-plugin/`, `skills/`, `marketplace.json`)
- **Couche B** = doc projet auto-appliquée (`README.md`, `CLAUDE.md` racine, `docs/`, `brief/`, `media/`, `PLAN.md`...)

Quand tu modifies quelque chose, demande-toi : "couche A (sources) ou couche B (dogfood) ?". Les chemins ne se chevauchent jamais.

## User handoff

Tout `CLAUDE.md` produit par `bootstrap` est un **starter**, pas une vérité finale. L'utilisateur édite et enrichit. Les sections du template (Setup/Build/Test, Verifying the work, etc.) doivent être **rempliçables** : placeholders explicites (`<à compléter>`), pas de valeur fabriquée. Pour les ADR, LEARNINGS et VISION, idem : structure fournie, contenu remplissable par le user.

## Versioning et signatures

Tout fichier généré porte `<!-- generated-by: starter-kit vX.Y.Z -->`. Bumper la version dans `.claude-plugin/plugin.json`, `marketplace.json`, et la signature dans **tous** les templates à chaque release significative. Cf. CLAUDE.md racine section "Versioning".

## Idempotence et mode reprise

Tous les skills à effets de bord (`bootstrap`, `migrate`, `apply-best-practices`) doivent supporter la **réexécution** sans dégât : détecter ce qui existe déjà, proposer "skip / overwrite / save as .new", ne jamais écraser silencieusement.
