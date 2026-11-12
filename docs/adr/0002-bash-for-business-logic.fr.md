# ADR-0002 : Bash pour la logique métier

**Langue :** [English (par défaut)](0002-bash-for-business-logic.md) | Français

**Statut** : Accepté
**Date** : 2025-12-04
**Auteurs** : @xgueret

## Contexte

Les opérations centrales de ckad-dojo — mise en place des ressources Kubernetes, scoring des réponses, nettoyage des namespaces — sont essentiellement des séquences de commandes `kubectl`, `helm` et `docker`. Ces opérations doivent interagir directement avec l'état du cluster, parser la sortie des commandes et gérer le cycle de vie des ressources.

Un langage de plus haut niveau (Python, Go) pourrait encapsuler ces commandes, mais cela ajoute une couche d'abstraction entre l'utilisateur et les outils qu'il utilisera lors du véritable examen CKAD.

## Décision

Implémenter toute la logique métier (setup, scoring, nettoyage) dans des scripts Bash. Les scripts appellent directement `kubectl`, `helm` et `docker`, sans wrapper ni couche d'abstraction.

## Alternatives envisagées

- **Python avec le client kubernetes** : typé, structuré. Mais ajoute une dépendance lourde (paquet `kubernetes`) et éloigne les utilisateurs des outils CLI qu'ils doivent maîtriser.
- **Go avec client-go** : binaire compilé, rapide. Mais introduit une étape de build et un langage que la plupart des utilisateurs ne modifieront pas.
- **Wrappers subprocess en Python** : conserve les outils CLI mais ajoute une indirection inutile. La couche Python ne ferait que transmettre des commandes.

## Conséquences

- **Positif** : les scripts utilisent exactement les mêmes outils (`kubectl`, `helm`) que ceux avec lesquels les utilisateurs s'entraînent. Aucune couche de traduction.
- **Positif** : facile à déboguer — les utilisateurs peuvent lire et comprendre directement les fonctions de scoring.
- **Positif** : pas de compilation, pas d'installation de dépendances pour les opérations centrales.
- **Négatif** : Bash offre des structures de données, une gestion des erreurs et un support des tests limités par rapport à Python.
- **Négatif** : le parsing de chaînes complexes et la manipulation de JSON nécessitent `jq` ou un usage soigneux de `grep`/`awk`.
- **Atténué** : une bibliothèque partagée (`scripts/lib/common.sh`) fournit des helpers réutilisables pour réduire le code répétitif.
