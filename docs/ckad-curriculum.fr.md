# Référence du programme officiel du CKAD

**Langue :** [English (par défaut)](ckad-curriculum.md) | Français

> **Source** : [dépôt du programme de la CNCF](https://github.com/cncf/curriculum)
> **Fichier** : `CKAD_Curriculum_v1.35.pdf`
> **Version de Kubernetes** : 1.35
> **Dernière mise à jour** : 2026-03-14
> **Durée de l'examen** : 2 heures | **Questions** : 15-20 tâches | **Score de réussite** : 66%

------

## Comment tenir ce document à jour

La CNCF met à jour le programme à la sortie d'une nouvelle version mineure de Kubernetes (en général tous les ~4 mois). L'environnement d'examen s'aligne sur la dernière version mineure de K8s dans les 4 à 8 semaines suivant sa sortie.

| Source | URL | Que surveiller |
|--------|-----|----------------|
| Programme de la CNCF (GitHub) | https://github.com/cncf/curriculum | Surveiller le dépôt pour les commits sur les fichiers CKAD |
| Linux Foundation CKAD | https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/ | Mises à jour de la version de K8s, changements de format de l'examen |
| Page de certification de la CNCF | https://www.cncf.io/training/certification/ckad/ | Annonces officielles |

Lorsque le programme change :

1. Vérifier la présence d'un nouveau `CKAD_Curriculum_v1.XX.pdf` dans le dépôt de la CNCF
2. Comparer les domaines et compétences avec les tableaux ci-dessous
3. Mettre à jour ce fichier et `docs/simulation-coverage.csv`
4. Ouvrir une issue pour suivre toute nouvelle compétence qui nécessite une couverture dans les simulations

------

## Domaines et compétences officiels (5 domaines, 22 compétences)

### 1. Conception et construction d'applications (Application Design and Build) — 20%

| ID | Compétence |
|----|------------|
| DB-01 | Définir, construire et modifier des images de conteneurs |
| DB-02 | Choisir et utiliser la bonne ressource de charge de travail (Deployment, DaemonSet, CronJob, etc.) |
| DB-03 | Comprendre les design patterns de Pod multi-conteneurs (par ex. sidecar, init et autres) |
| DB-04 | Utiliser des volumes persistants et éphémères |

### 2. Déploiement d'applications (Application Deployment) — 20%

| ID | Compétence |
|----|------------|
| AD-01 | Utiliser les primitives Kubernetes pour mettre en œuvre des stratégies de déploiement courantes (par ex. blue/green ou canary) |
| AD-02 | Comprendre les Deployments et savoir effectuer des rolling updates |
| AD-03 | Utiliser le gestionnaire de paquets Helm pour déployer des paquets existants |
| AD-04 | Kustomize |

### 3. Observabilité et maintenance des applications (Application Observability and Maintenance) — 15%

| ID | Compétence |
|----|------------|
| OM-01 | Comprendre les dépréciations d'API |
| OM-02 | Mettre en place des probes et des contrôles de santé |
| OM-03 | Utiliser les outils CLI intégrés pour surveiller les applications Kubernetes |
| OM-04 | Exploiter les logs des conteneurs |
| OM-05 | Débogage dans Kubernetes |

### 4. Environnement, configuration et sécurité des applications (Application Environment, Configuration and Security) — 25%

| ID | Compétence |
|----|------------|
| CS-01 | Découvrir et utiliser les ressources qui étendent Kubernetes (CRD, Operators) |
| CS-02 | Comprendre l'authentification, l'autorisation et le contrôle d'admission |
| CS-03 | Comprendre les requests, limits et quotas |
| CS-04 | Comprendre les ConfigMaps |
| CS-05 | Créer et consommer des Secrets |
| CS-06 | Comprendre les ServiceAccounts |
| CS-07 | Comprendre la sécurité des applications (SecurityContexts, Capabilities, etc.) |

### 5. Services et réseau (Services and Networking) — 20%

| ID | Compétence |
|----|------------|
| SN-01 | Démontrer une compréhension de base des NetworkPolicies |
| SN-02 | Fournir et dépanner l'accès aux applications via des Services |
| SN-03 | Utiliser des règles Ingress pour exposer des applications |

------

## Décomposition des compétences en savoir-faire testables

Chaque compétence officielle correspond à des savoir-faire concrets qui peuvent être testés dans les simulations.

### DB-01 : Images de conteneurs

- Construire des images avec un Dockerfile
- Builds Dockerfile multi-étapes (multi-stage)
- Modifier/taguer des images existantes
- Pousser vers le registry local

### DB-02 : Ressources de charge de travail

- Deployments (création, mise à l'échelle, mise à jour)
- DaemonSets
- CronJobs / Jobs (completions, parallelism, activeDeadlineSeconds)
- StatefulSets
- ReplicaSets

### DB-03 : Patterns multi-conteneurs

- Conteneurs sidecar
- Init containers (un seul ou plusieurs)
- Pattern Ambassador
- Pattern Adapter

### DB-04 : Volumes

- PersistentVolumes / PersistentVolumeClaims
- emptyDir (partagé entre conteneurs)
- hostPath
- ConfigMap/Secret en tant que volumes

### AD-01 : Stratégies de déploiement

- Déploiement blue/green
- Déploiement canary
- Rollback vers une révision précise

### AD-02 : Rolling updates

- Stratégie de rolling update (maxSurge, maxUnavailable)
- Historique de rollout / undo
- Mise en pause/reprise des rollouts

### AD-03 : Helm

- Installer/mettre à niveau/annuler (rollback) des releases
- Rechercher et ajouter des dépôts
- Inspecter les values
- Créer des charts (helm create)
- Rendu des templates

### AD-04 : Kustomize

- kustomization.yaml
- Overlays et patches
- kubectl apply -k

### OM-01 : Dépréciations d'API

- Identifier les versions d'API dépréciées
- Migrer des ressources vers les versions d'API actuelles

### OM-02 : Probes et contrôles de santé

- Liveness probes (httpGet, tcpSocket, exec)
- Readiness probes
- Startup probes
- Paramètres des probes (initialDelaySeconds, periodSeconds, etc.)

### OM-03 : Outils CLI de surveillance

- kubectl top (pods, nodes)
- kubectl describe (événements)
- kubectl get (sortie wide, colonnes personnalisées)
- kubectl debug (conteneurs éphémères)

### OM-04 : Logs des conteneurs

- kubectl logs (actuels, précédents)
- Sélection des logs dans un Pod multi-conteneurs (-c)

### OM-05 : Débogage

- Dépanner un CrashLoopBackOff
- Dépanner un ImagePullBackOff
- kubectl exec dans les conteneurs
- Analyse des événements
- Drain/cordon de nœud

### CS-01 : CRD et Operators

- Découvrir les CRD (kubectl get crd)
- Utiliser des ressources personnalisées (custom resources)

### CS-02 : Authentification et contrôle d'admission

- RBAC (Roles, RoleBindings, ClusterRoles, ClusterRoleBindings)
- kubectl auth can-i
- Montage du token de ServiceAccount

### CS-03 : Requests, limits, quotas

- Requests et limits de ressources (cpu, memory)
- LimitRange
- ResourceQuota
- Dépanner les dépassements de quota

### CS-04 : ConfigMaps

- Création depuis un littéral, un fichier, un env-file
- Montage en tant que volume
- Utilisation en tant que variables d'environnement (envFrom, valueFrom)

### CS-05 : Secrets

- Créer des secrets generic, docker-registry, tls
- Montage en tant que volume
- Utilisation en tant que variables d'environnement (secretKeyRef)
- Encodage/décodage Base64

### CS-06 : ServiceAccounts

- Créer et assigner aux pods
- Projection de token
- Contrôle de l'automount

### CS-07 : Sécurité des applications

- SecurityContext (runAsUser, runAsGroup, runAsNonRoot, fsGroup)
- Capabilities (add/drop)
- seccompProfile
- readOnlyRootFilesystem

### SN-01 : NetworkPolicies

- Règles Ingress (podSelector, namespaceSelector, ipBlock)
- Règles Egress
- Politiques de refus par défaut (default deny)
- Sélection par labels

### SN-02 : Services

- ClusterIP, NodePort, LoadBalancer
- Services ExternalName
- Dépannage des sélecteurs de Service
- kubectl expose
- Résolution DNS

### SN-03 : Ingress

- Routage par chemin
- Routage par hôte
- Terminaison TLS
- Dépannage de l'Ingress controller
