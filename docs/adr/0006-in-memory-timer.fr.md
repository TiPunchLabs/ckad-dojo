# ADR-0006 : timer en mémoire

**Langue :** [English (par défaut)](0006-in-memory-timer.md) | Français

**Statut** : Accepté
**Date** : 2025-12-04
**Auteurs** : @xgueret

## Contexte

Le timer de l'examen mesure le temps écoulé et fait respecter la durée d'examen de 120 minutes. Il doit prendre en charge le démarrage, la pause/reprise (lorsque la configuration de l'examen l'autorise) et la détection de la fin du temps imparti. L'état du timer doit être accessible à la fois depuis le frontend web (par interrogation périodique de l'API) et depuis le script de scoring (pour enregistrer le temps écoulé).

Les options de persistance vont du stockage sur fichier (écrire l'état dans `/tmp`) au stockage en mémoire (conserver l'état dans le processus du serveur Python), en passant par une base de données.

## Décision

Stocker l'état du timer entièrement en mémoire dans le processus du serveur web Python. Le timer est une structure de données simple (heure de démarrage, décalages de pause, indicateur d'état) gérée par le serveur et exposée via `GET /api/timer`.

## Alternatives envisagées

- **Timer sur fichier** : utilisé par les scripts Bash pour le mode terminal. Fonctionne, mais introduit des E/S fichier, des situations de concurrence (race conditions) entre lecteurs et écrivains, et un état périmé en cas de crash.
- **SQLite** : persistant, interrogeable. Mais ajoute de la complexité pour une seule donnée (les secondes restantes) qui ne vit que 2 heures.
- **Redis/stockage externe** : état accessible par le réseau. Totalement disproportionné pour une application locale mono-utilisateur.

## Conséquences

- **Positif** : l'implémentation la plus simple possible. Pas d'E/S fichier, pas de couche de persistance, aucun nettoyage nécessaire.
- **Positif** : l'état du timer est toujours cohérent — un seul processus, un seul thread pour les modifications (GIL).
- **Positif** : la réponse de l'API est instantanée — aucune lecture de fichier, on renvoie simplement la valeur en mémoire.
- **Négatif** : l'état du timer est perdu si le processus du serveur plante ou est tué. L'utilisateur doit redémarrer l'examen.
- **Négatif** : le mode terminal (sans serveur web) utilise toujours le timer sur fichier de `scripts/lib/timer.sh`. Deux implémentations du timer coexistent.
- **Compromis accepté** : un examen est éphémère (2 heures maximum). Perdre l'état du timer en cas de crash est acceptable — l'utilisateur peut simplement redémarrer.
