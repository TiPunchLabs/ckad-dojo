# 🥋 Démarrer avec ckad-dojo en 3 étapes

![Kubernetes 1.28+](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?logo=kubernetes&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-required-326CE5)
![helm 3.x](https://img.shields.io/badge/helm-3.x-0F1689?logo=helm&logoColor=white)
![docker 20.x+](https://img.shields.io/badge/docker-20.x+-2496ED?logo=docker&logoColor=white)
![ttyd 1.7+](https://img.shields.io/badge/ttyd-1.7+-black)
![Setup ~5 min](https://img.shields.io/badge/setup-~5_min-brightgreen)

---

## Étape 1 — Prérequis

Un cluster Kubernetes fonctionnel + les outils suivants installés :

```bash
kubectl cluster-info && helm version && docker --version && ttyd --version
```

Si une commande échoue, installez l'outil manquant. Détails : [README.md#prerequisites](README.md#prerequisites).

---

## Étape 2 — Installer et lancer

```bash
git clone https://github.com/TiPunchLabs/ckad-dojo.git && cd ckad-dojo
curl -LsSf https://astral.sh/uv/install.sh | sh
uv run ckad-dojo
```

Le menu interactif s'affiche. L'interface web s'ouvre sur `http://localhost:9090`.

---

## Étape 3 — Commencer l'examen

Choisissez un dojo dans le menu, ou lancez directement :

```bash
uv run ckad-dojo exam start -e ckad-simulation1
```

Timer 120 min. Terminal kubectl intégré. Scoring automatique.

---

## Et ensuite ?

- **Vérifier votre score** : `uv run ckad-dojo score -e ckad-simulation1`
- **10 dojos disponibles** (198 questions) — voir la [liste complète](README.md#the-ten-dojos)
- **Full guide** : [README.md](README.md)
