# Politique de sécurité

**Langue :** [English (par défaut)](SECURITY.md) | Français

## Versions prises en charge

| Version | Prise en charge    |
| ------- | ------------------ |
| Dernière (branche main) | :white_check_mark: |

## Signaler une vulnérabilité

Si vous découvrez une vulnérabilité de sécurité dans ckad-dojo, signalez-la de manière responsable :

1. **N'ouvrez pas** d'issue GitHub publique
2. Utilisez les [GitHub Security Advisories](https://github.com/TiPunchLabs/ckad-dojo/security/advisories/new) pour la signaler en privé
3. Indiquez les informations suivantes :
   - Description de la vulnérabilité
   - Étapes pour la reproduire
   - Impact potentiel
   - Correctif suggéré (le cas échéant)

### Délais de réponse

- **Accusé de réception** : sous 48 heures
- **Tri et évaluation** : sous 7 jours
- **Correctif et divulgation** : sous 90 jours

## Périmètre

Ce projet est un simulateur pédagogique de l'examen CKAD conçu pour un **usage local uniquement**. Il :

- Exécute un serveur web local sur `localhost:9090`
- Utilise `ttyd` pour fournir un terminal intégré sur `localhost:7681`
- Crée des ressources Kubernetes dans votre cluster local
- Ne transmet aucune donnée à l'extérieur

### Vulnérabilités dans le périmètre

- Intégrité de la chaîne d'approvisionnement (dépendances, pipelines CI/CD)
- Secrets ou identifiants dans les fichiers de configuration ou les manifests
- Injection dans les scripts d'automatisation bash (injection de commandes, traversée de répertoires)
- Cross-site scripting (XSS) dans l'interface web

### Hors périmètre

- Problèmes nécessitant un accès physique à la machine hôte
- Déni de service sur un service uniquement local
- Vulnérabilités des dépendances en amont (à signaler au projet concerné)

## Bonnes pratiques de sécurité

- N'exécutez le simulateur que sur des clusters Kubernetes locaux de confiance
- N'exposez pas l'interface web sur des réseaux publics
- Relisez les questions d'examen avant de les lancer dans des environnements partagés

## Remerciements

Nous apprécions la divulgation responsable des vulnérabilités de sécurité. Les personnes qui signalent des problèmes de sécurité avérés seront remerciées (avec leur accord) dans les notes de version.
