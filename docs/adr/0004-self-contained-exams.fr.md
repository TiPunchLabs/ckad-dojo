# ADR-0004 : répertoires d'examen autonomes

**Langue :** [English (par défaut)](0004-self-contained-exams.md) | Français

**Statut** : Accepté
**Date** : 2025-12-04
**Auteurs** : @xgueret

## Contexte

Le projet prend en charge plusieurs simulations d'examen (dojos), chacune avec ses propres questions, solutions, logique de scoring, manifests Kubernetes et configuration. Ces composants doivent être organisés de façon à pouvoir ajouter, modifier ou supprimer facilement un examen sans affecter les autres.

Deux approches ont été envisagées : une structure centralisée (toutes les questions dans un fichier, tout le scoring dans un fichier) ou une structure décentralisée (chaque examen est un répertoire autonome).

## Décision

Chaque examen est un répertoire entièrement autonome sous `exams/{exam-id}/` qui contient toutes ses ressources : `exam.conf`, `questions.md`, `solutions.md`, `scoring-functions.sh`, `manifests/setup/`, `templates/` et, en option, `post-setup.sh`.

## Alternatives envisagées

- **Structure centralisée** : un unique répertoire `questions/` contenant toutes les questions, un unique `scoring.sh` contenant toutes les fonctions. Plus simple à petite échelle, mais devient ingérable avec 9+ examens et 178+ questions.
- **Pilotage par base de données** : stocker les questions et les critères de scoring dans SQLite ou du JSON. Puissant pour les requêtes, mais disproportionné pour du contenu statique et compliquerait le processus de contribution.

## Conséquences

- **Positif** : ajouter un nouvel examen revient à ajouter un répertoire — aucune modification des fichiers existants.
- **Positif** : chaque examen peut être développé, testé et contribué indépendamment (voir les simulations 4-9 issues de contributeurs externes).
- **Positif** : facile d'exclure via gitignore les examens privés ou purement locaux à l'aide de motifs standard.
- **Négatif** : une certaine duplication entre les examens (par ex. des patterns de scoring similaires, la structure YAML des namespaces).
- **Atténué** : des helpers de scoring partagés dans `scripts/lib/common.sh` réduisent le code répétitif dans chaque fichier `scoring-functions.sh`.
