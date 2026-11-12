# 🥋 Get Started with ckad-dojo in 3 Steps

**Language:** English (default) | [Français](QUICKSTART.fr.md)

![Kubernetes 1.28+](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?logo=kubernetes&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-required-326CE5)
![helm 3.x](https://img.shields.io/badge/helm-3.x-0F1689?logo=helm&logoColor=white)
![docker 20.x+](https://img.shields.io/badge/docker-20.x+-2496ED?logo=docker&logoColor=white)
![ttyd 1.7+](https://img.shields.io/badge/ttyd-1.7+-black)
![Python 3.12+](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python&logoColor=white)
![Setup ~5 min](https://img.shields.io/badge/setup-~5_min-brightgreen)

---

## Step 1 — Prerequisites

A working Kubernetes cluster and the following tools installed:

```bash
kubectl cluster-info && helm version && docker --version && ttyd --version
```

If a command fails, install the missing tool. Details: [README.md#prerequisites](README.md#prerequisites).

---

## Step 2 — Install and Run

```bash
git clone https://github.com/TiPunchLabs/ckad-dojo.git && cd ckad-dojo
direnv allow   # if you use direnv (otherwise ignore)
curl -LsSf https://astral.sh/uv/install.sh | sh
uv run ckad-dojo
```

> 💡 **Note**: ckad-dojo requires Python 3.12 or newer (Python 3.10 and 3.11 are no longer supported). You do not need to install it yourself: `uv` downloads a compatible version automatically. If these downloads are set to `manual`, run `uv python install 3.12` first; if they are set to `never`, install Python 3.12+ with your system package manager.

The interactive menu appears. The web interface opens at `http://localhost:9090`.

---

## Step 3 — Start the Exam

Pick a dojo from the menu, or start one directly:

```bash
uv run ckad-dojo exam start -e ckad-simulation1
```

120-minute timer. Built-in kubectl terminal. Automatic scoring.

---

## What's Next?

- **Check your score**: `uv run ckad-dojo score -e ckad-simulation1`
- **20 dojos available** (398 questions) — see the [full list](README.md#the-twenty-dojos)
- **Full guide**: [README.md](README.md)
