# ADR-0005 : CLI Python comme orchestrateur

**Langue :** [English (par défaut)](0005-python-cli-orchestrator.md) | Français

**Statut** : Accepté
**Date** : 2025-12-04
**Auteurs** : @xgueret

## Contexte

Les utilisateurs interagissent avec ckad-dojo à travers plusieurs scripts (`ckad-setup.sh`, `ckad-exam.sh`, `ckad-score.sh`, `ckad-cleanup.sh`), chacun avec ses propres options et arguments. Cela crée une expérience utilisateur fragmentée — les utilisateurs doivent se souvenir du script à appeler et avec quelles options.

Un point d'entrée unifié améliorerait la découvrabilité et apporterait des fonctionnalités comme un menu interactif, l'auto-complétion dans le shell et un parsing cohérent des arguments.

## Décision

Fournir une CLI Python (`ckad_dojo.py`, invoquée via `uv run ckad-dojo`) comme orchestrateur léger. La CLI propose un menu interactif et des sous-commandes (`exam start`, `score`, `cleanup`, `list`, `info`, `status`) mais délègue tout le travail réel aux scripts Bash existants via `subprocess.run()`.

La CLI ne duplique NI ne réimplémente la logique métier — c'est uniquement une couche d'expérience utilisateur.

## Alternatives envisagées

- **Script wrapper Bash** : un unique `ckad-dojo.sh` qui dispatche vers des sous-scripts. Possible mais limité : Bash offre une ergonomie médiocre pour le parsing des arguments, aucun framework d'auto-complétion intégré, et les menus interactifs doivent être implémentés à la main.
- **Makefile** : pattern courant pour les points d'entrée CLI. Mais les Makefiles ne sont pas conçus pour des workflows interactifs et produisent des messages d'erreur peu parlants pour les utilisateurs finaux.
- **CLI Go (cobra)** : excellent framework CLI. Mais introduit un langage compilé, une étape de build et un second langage dans le projet.

## Conséquences

- **Positif** : un point d'entrée unique (`uv run ckad-dojo`) pour toutes les opérations. Découvrabilité via `--help` et le menu interactif.
- **Positif** : auto-complétion dans le shell pour bash, zsh et fish via `argcomplete`.
- **Positif** : `argparse` de Python fournit une validation structurée des arguments et des textes d'aide.
- **Positif** : aucune duplication de la logique métier — les scripts Bash restent la source de vérité.
- **Négatif** : ajoute Python comme dépendance d'exécution (déjà requis pour le serveur web).
- **Négatif** : ajoute `uv` comme outil requis pour exécuter la CLI.
