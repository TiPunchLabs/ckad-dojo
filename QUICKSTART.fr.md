# 🥋 Démarrer avec ckad-dojo en 3 étapes

**Langue :** [English (par défaut)](QUICKSTART.md) | Français

![Kubernetes 1.28+](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?logo=kubernetes&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-required-326CE5)
![helm 3.x](https://img.shields.io/badge/helm-3.x-0F1689?logo=helm&logoColor=white)
![docker 20.x+](https://img.shields.io/badge/docker-20.x+-2496ED?logo=docker&logoColor=white)
![ttyd 1.7+](https://img.shields.io/badge/ttyd-1.7+-black)
![Python 3.12+](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python&logoColor=white)
![Setup ~5 min](https://img.shields.io/badge/setup-~5_min-brightgreen)

---

## Étape 1 — Prérequis

Un cluster Kubernetes fonctionnel et les outils suivants installés :

```bash
kubectl cluster-info && helm version && docker --version && ttyd --version
```

Si une commande échoue, installez l'outil manquant. Détails : [README.fr.md#prérequis](README.fr.md#prérequis).

---

## Étape 2 — Installer et lancer

```bash
git clone https://github.com/TiPunchLabs/ckad-dojo.git && cd ckad-dojo
direnv allow   # si vous utilisez direnv (sinon, ignorez cette ligne)
curl -LsSf https://astral.sh/uv/install.sh | sh
uv run ckad-dojo
```

> 💡 **Note** : ckad-dojo requiert Python 3.12 ou plus récent (Python 3.10 et 3.11 ne sont plus pris en charge). Inutile de l'installer vous-même : `uv` télécharge automatiquement une version compatible. Si ces téléchargements sont en mode `manual`, lancez d'abord `uv python install 3.12` ; en mode `never`, installez Python 3.12+ avec le gestionnaire de paquets de votre système.

Le menu interactif s'affiche. L'interface web s'ouvre sur `http://localhost:9090`.

---

## Étape 3 — Commencer l'examen

Choisissez un dojo dans le menu, ou lancez-en un directement :

```bash
uv run ckad-dojo exam start -e ckad-simulation1
```

Minuteur de 120 minutes. Terminal kubectl intégré. Notation automatique.

---

## Et ensuite ?

- **Vérifier votre score** : `uv run ckad-dojo score -e ckad-simulation1`
- **20 dojos disponibles** (398 questions) — voir la [liste complète](README.fr.md#les-vingt-dojos)
- **Guide complet** : [README.fr.md](README.fr.md)
