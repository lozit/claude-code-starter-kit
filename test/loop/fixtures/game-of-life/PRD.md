<!-- generated-by: groundrules v1.10.0 (loop tutorial fixture) -->
# PRD — Game of Life (banc d'essai du loop Groundrules)

> Objet : sujet minimal servant à valider le mécanisme de loop goal-driven.
> Le but n'est pas le jeu de la vie en soi, mais d'avoir un oracle déterministe
> que la première implémentation a de fortes chances de ne **pas** passer,
> afin que la boucle s'enclenche réellement.

## Problem

Implémenter le jeu de la vie de Conway (règles B3/S23) sous forme d'une fonction
pure qui calcule la génération suivante d'une grille finie. La difficulté tient
à trois pièges classiques (mise à jour simultanée, comptage des 8 voisines,
bords) qui produisent du code « qui compile mais qui est faux ». L'oracle
fourni (`life_test.go`) tranche sans ambiguïté.

## Success criteria

Le critère unique et déterministe : `go test ./...` passe au vert. Les tests :

1. **Block** (2×2) — *still life* : inchangé après 1 génération.
2. **Block en coin** (rows/cols 0-1) : inchangé. Vérifie que les voisines
   hors-grille comptent comme mortes (et qu'on ne plante pas en lisière).
3. **Blinker** : devient vertical après 1 génération, revient horizontal après 2
   (période 2). Vérifie naissance + mort appliquées au même tour.
4. **Glider** : après 4 générations, le motif réapparaît identique mais décalé
   de (+1 ligne, +1 colonne). Vérifie la mise à jour simultanée sur toute la grille.

Pas de jugement humain : la boucle ne s'arrête que quand les 4 tests sont verts.

## Scope

**Dans le périmètre**

- Une grille rectangulaire finie `[][]bool`, `g[row][col]`, `true` = vivante.
- Une fonction `Step(g [][]bool) [][]bool` (package `life`) renvoyant la
  génération suivante, mêmes dimensions.
- Règles B3/S23, voisinage de Moore (8 voisines), hors-grille = morte.

**Hors périmètre**

- Visualisation / GUI / animation.
- Grille infinie ou torique (bords qui bouclent).
- Optimisation de performance, parallélisme.
- Chargement de motifs (RLE), I/O fichier, configurabilité des règles.

## Constraints

- **Langage** : Go. Oracle = `go test`, pass/fail binaire et reproductible.
- **Contrat d'API exact** (pour que l'oracle compile) :
  - package `life`
  - `func Step(g [][]bool) [][]bool`
  - grille rectangulaire, `g[row][col]`, `true` = vivante
  - voisines hors-grille traitées comme mortes
  - `Step` doit être **pure** : ne modifie jamais son argument, renvoie une
    nouvelle grille.
- **Déterminisme total** : aucun aléa, aucune horloge, aucune goroutine.
- Aucune dépendance externe ; un seul fichier `life.go` suffit.

## Build plan

1. Représentation de la grille + helper de comptage des voisines vivantes
   (8 directions, hors-grille = morte).
2. `Step` : construire une **nouvelle** grille de mêmes dimensions, calculer
   chaque cellule à partir de l'instantané d'entrée, appliquer B3/S23.
3. Lancer `go test ./...`, lire les échecs, corriger, recommencer jusqu'au vert.

## Risks

- **Mise à jour en place** (risque principal) : muter la grille pendant le
  parcours fausse le calcul. Le glider se désintègre au lieu de glisser →
  capté par le test 4.
- **Comptage des voisines** : oublier une direction ou se compter soi-même →
  capté par blinker/glider.
- **Bords** : accès hors-grille qui plante, ou bord traité comme vivant →
  capté par le test 2 (block en coin).
- **Faux positif de la boucle** : l'agent se déclare « fini » sans lancer les
  tests. Mitigation : le seul critère d'arrêt est `go test` au vert, pas
  l'auto-évaluation de l'agent.
