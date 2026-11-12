# ADR-0001 : bibliothèque standard uniquement pour le serveur web

**Langue :** [English (par défaut)](0001-stdlib-only-web-server.md) | Français

**Statut** : Accepté
**Date** : 2025-12-04
**Auteurs** : @xgueret

## Contexte

Le serveur web de ckad-dojo doit servir des fichiers statiques, exposer une API REST pour le frontend, gérer un timer d'examen et exécuter le scoring et le nettoyage via des appels subprocess. Un framework web (Flask, FastAPI, etc.) pourrait simplifier le routage et le traitement des requêtes.

Cependant, ckad-dojo s'adresse à des utilisateurs qui préparent l'examen CKAD sur des machines personnelles ou des environnements de lab. Ces installations varient beaucoup et peuvent avoir un accès à Internet limité ou restreint. Ajouter des dépendances Python alourdit l'installation et introduit des risques d'incompatibilité.

## Décision

Utiliser uniquement la bibliothèque standard Python (`http.server`, `json`, `subprocess`, `threading`) pour le serveur web. Aucun paquet Python externe n'est requis à l'exécution pour le composant serveur.

## Alternatives envisagées

- **Flask** : léger, mais ajoute une dépendance (plus Werkzeug). Disproportionné pour une poignée de routes.
- **FastAPI** : puissant, mais apporte uvicorn, pydantic et d'autres dépendances transitives. Bien trop lourd pour ce cas d'usage.
- **Node.js/Express** : ajouterait un second runtime à la stack et fragmenterait la base de code.

## Conséquences

- **Positif** : serveur sans aucune dépendance. Fonctionne sur toute machine disposant de Python 3.8+. Pas d'étape `pip install`, pas de virtualenv nécessaire pour le serveur. `uv run` s'occupe de tout.
- **Positif** : surface d'attaque réduite — aucun code tiers dans le serveur.
- **Négatif** : routage manuel via `do_GET`/`do_POST` avec correspondance des chemins. Plus de code répétitif qu'avec un framework.
- **Négatif** : pas de validation des requêtes, de middleware ni de négociation de contenu intégrés. Ils doivent être implémentés à la main si nécessaire.
