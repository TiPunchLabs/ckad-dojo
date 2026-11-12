# ADR-0003 : frontend en JS vanilla

**Langue :** [English (par défaut)](0003-vanilla-js-frontend.md) | Français

**Statut** : Accepté
**Date** : 2025-12-04
**Auteurs** : @xgueret

## Contexte

L'interface web doit afficher les questions de l'examen (Markdown avec blocs de code), permettre la navigation entre les questions, gérer un compte à rebours et afficher les résultats du scoring. Un framework JavaScript (React, Vue, Svelte) pourrait accélérer le développement et offrir une meilleure gestion de l'état.

Cependant, le frontend est servi directement par le serveur HTTP Python, sans pipeline de build. Ajouter un framework imposerait une étape de build (webpack, vite), un répertoire `node_modules` et un pipeline CI pour le frontend — tout cela pour une interface qui est fondamentalement une visionneuse de document monopage.

## Décision

Utiliser du JavaScript vanilla (ES6+) sans framework et sans étape de build. Les bibliothèques externes se limitent à des utilitaires chargés depuis un CDN : `marked.js` pour le rendu Markdown, `highlight.js` pour la coloration syntaxique et `Lucide` pour les icônes.

## Alternatives envisagées

- **React** : le modèle de composants aiderait à organiser l'UI. Mais nécessite la compilation JSX, un bundler et `node_modules`. Disproportionné pour une application monopage.
- **Vue (mode CDN)** : viable sans étape de build. Mais ajoute des concepts propres au framework (réactivité, directives) qui compliquent les contributions des développeurs qui ne connaissent pas Vue.
- **Svelte** : excellente expérience développeur, mais nécessite un compilateur. Exclu sans pipeline de build.
- **htmx** : intéressant pour les applications rendues côté serveur. Mais l'UI de l'examen a besoin d'un état côté client (timer, flags, navigation) que htmx gère mal.

## Conséquences

- **Positif** : pas d'étape de build. On modifie `app.js`, on rafraîchit le navigateur. Boucle de retour instantanée.
- **Positif** : pas de `node_modules`, pas de `package.json`, pas de configuration de bundler.
- **Positif** : toute personne qui connaît JavaScript peut contribuer — aucune connaissance d'un framework particulier n'est requise.
- **Négatif** : manipulation manuelle du DOM. La gestion de l'état est ad hoc (variables au niveau du module, attributs du DOM).
- **Négatif** : à mesure que l'UI grandit, l'unique fichier `app.js` devient plus difficile à maintenir.
- **Atténué** : le périmètre de l'UI est volontairement limité — c'est une visionneuse d'examen, pas une application complète.
