**Langue :** [English (par défaut)](README.md) | Français

<p align="center">
  <pre>
 ██████╗██╗  ██╗ █████╗ ██████╗        ██████╗  ██████╗      ██╗ ██████╗
██╔════╝██║ ██╔╝██╔══██╗██╔══██╗       ██╔══██╗██╔═══██╗     ██║██╔═══██╗
██║     █████╔╝ ███████║██║  ██║ ████╗ ██║  ██║██║   ██║     ██║██║   ██║
██║     ██╔═██╗ ██╔══██║██║  ██║ ╚═══╝ ██║  ██║██║   ██║██   ██║██║   ██║
╚██████╗██║  ██╗██║  ██║██████╔╝       ██████╔╝╚██████╔╝╚█████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝        ╚═════╝  ╚═════╝  ╚════╝  ╚═════╝
  </pre>
</p>

<h3 align="center">Simulateur d'examen CKAD</h3>

<p align="center">
  Entraînez-vous à l'examen Certified Kubernetes Application Developer en conditions réelles
</p>

<p align="center">
  <strong><a href="https://ckad-dojo.tipunchlabs.fr/">ckad-dojo.tipunchlabs.fr</a></strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" alt="Kubernetes">
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" alt="Helm">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash">
</p>

<p align="center">
  <a href="https://ckad-dojo.tipunchlabs.fr/"><img src="https://img.shields.io/badge/Website-ckad--dojo.tipunchlabs.fr-2ea44f" alt="Site web"></a>
  <a href="docs/ckad-curriculum.fr.md"><img src="https://img.shields.io/badge/CKAD_Curriculum-v1.35-326CE5" alt="Programme CKAD v1.35"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-lightgrey" alt="Licence : CC BY-NC-SA 4.0"></a>
  <a href="https://scorecard.dev/viewer/?uri=github.com/TiPunchLabs/ckad-dojo"><img src="https://api.scorecard.dev/projects/github.com/TiPunchLabs/ckad-dojo/badge" alt="OpenSSF Scorecard"></a>
</p>

<p align="center">
  <strong>⭐ Si ce projet vous a aidé à réussir le CKAD, ajoutez une étoile au dépôt — cela aide d'autres personnes à le trouver !</strong>
</p>

<p align="center">
  <em>🧠 Utilisé par des ingénieurs du monde entier pour préparer la certification CKAD</em>
</p>

---

[Capture vidéo du 2026-04-11 12-09-26.webm](https://github.com/user-attachments/assets/246fc11f-9fbc-4c38-96e1-0b2991326ddf)


## Présentation

**ckad-dojo** est un simulateur local d'examen CKAD qui vous permet de vous entraîner dans des conditions proches de l'examen réel, avec :

- **Mise en place automatisée de l'environnement** - Tous les namespaces, ressources et releases Helm sont préconfigurés

- **Notation en temps réel** - Retour immédiat sur plus de 100 critères

- **Interface web moderne** - Minuteur, navigation entre les questions et mode sombre

- **Scripts idempotents** - Relançables sans risque à tout moment



---

## Fonctionnalités

| Fonctionnalité | Description |
|---------|-------------|
| **20 dojos** | 398 questions réparties dans 20 dojos thématiques |
| **CLI unifiée** | Une seule commande `uv run ckad-dojo` pour toutes les opérations |
| **Interface web** | Interface moderne avec un compte à rebours de 120 minutes |
| **Notation automatique** | Plus de 400 critères évalués automatiquement |
| **Menu interactif** | Navigation simple sans avoir à mémoriser les commandes |
| **Thèmes** | Mode sombre et mode clair |
| **Accueil du dojo** | Bannière ASCII personnalisée dans le terminal intégré |

### Alertes du minuteur

| Temps restant | Couleur |
|----------------|-------|
| > 15 min | Normale |
| 15 min | Jaune |
| 5 min | Orange |
| 1 min | Rouge |

---

## Les vingt dojos

La liste des dojos couvre les gardiens Shishin classiques, le folklore japonais et des scénarios Kubernetes de plus en plus avancés, sur l'ensemble du programme CKAD.

| # | Examen | Dojo | Thème | Questions | Points | Crédit |
|:-:|------|------|-------|:---------:|:------:|--------|
| 1 | `ckad-simulation1` | 🔥 **Suzaku** | Constellations (Orion, Andromeda...) | 21 | 112 | — |
| 2 | `ckad-simulation2` | 🐯 **Byakko** | Mythologie grecque (Olympus, Zeus...) | 20 | 105 | — |
| 3 | `ckad-simulation3` | 🐢 **Genbu** | Mythologie nordique (Odin, Thor...) | 20 | 105 | — |
| 4 | `ckad-simulation4` | 🐸 **Kappa** | Rivière/eau (stream, pond...) | 17 | 91 | [@aravind4799](https://github.com/aravind4799) |
| 5 | `ckad-simulation5` | 🦌 **Kirin** | Océan (shell, ocean, reef...) | 20 | 105 | — |
| 6 | `ckad-simulation6` | 👺 **Tengu** | Montagne (peak, summit...) | 20 | 100 | [@dgkanatsios](https://github.com/dgkanatsios) |
| 7 | `ckad-simulation7` | 🦝 **Tanuki** | Forêt (grove, thicket...) | 20 | 100 | [@dgkanatsios](https://github.com/dgkanatsios) |
| 8 | `ckad-simulation8` | 🦊 **Inari** | Récolte (harvest, grain...) | 20 | 100 | [@dgkanatsios](https://github.com/dgkanatsios) |
| 9 | `ckad-simulation9` | 🐲 **Ryujin** | Mer (tide, wave, depths...) | 20 | 100 | [@dgkanatsios](https://github.com/dgkanatsios) |
| 10 | `ckad-simulation10` | 👹 **Oni** | Fortification (fortress, bastion...) | 20 | 102 | — |
| 11 | `ckad-simulation11` | ☀️ **Amaterasu** | Soleil/lumière (solar, corona...) | 20 | 104 | — |
| 12 | `ckad-simulation12` | 🌙 **Tsukuyomi** | Obscurité lunaire (nightfall, eclipse, darkness...) | 20 | 108 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 13 | `ckad-simulation13` | 🌬️ **Fujin** | Vents de tempête (tempest, gale, thundercloud...) | 20 | 110 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 14 | `ckad-simulation14` | ⚡ **Raijin** | Tonnerre et éclairs (strike, surge, charge...) | 20 | 112 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 15 | `ckad-simulation15` | 🌊 **Susanoo** | Mer et marée (current, reef, abyss...) | 20 | 110 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 16 | `ckad-simulation16` | 🎶 **Benzaiten** | Harmonie et fluidité (melody, rhythm, cadence...) | 20 | 114 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 17 | `ckad-simulation17` | ⚔️ **Hachiman** | Stratégie et bataille (fortress, frontier, war...) | 20 | 119 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 18 | `ckad-simulation18` | ✨ **Izanagi** | Création et ordre (origin, balance, bloom...) | 20 | 118 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 19 | `ckad-simulation19` | 🛡️ **Bishamonten** | Veille et défense (guard, might, watch...) | 20 | 120 | [@Sai7Teja](https://github.com/Sai7Teja) |
| 20 | `ckad-simulation20` | 🏆 **Musashi** | Maîtrise et duels (finale, discipline, victory...) | 20 | 122 | [@Sai7Teja](https://github.com/Sai7Teja) |

> Les mentions de crédit d'origine sont conservées pour les sources adaptées, et les simulations plus récentes sont attribuées à l'auteur du dépôt qui les a ajoutées.

<details>
<summary><strong>Citations des dojos</strong></summary>

| Dojo | Citation |
|------|-------|
| 🔥 Suzaku | *「朱雀は灰から蘇る」— Le phénix renaît de ses cendres* |
| 🐯 Byakko | *「白虎は正確に打つ」— Le tigre frappe avec précision* |
| 🐢 Genbu | *「玄武は世界を支える」— La tortue porte le monde* |
| 🐸 Kappa | *「河童は水を知る」— Le kappa connaît les eaux* |
| 🦌 Kirin | *「麒麟は平和をもたらす」— Le kirin apporte la paix* |
| 👺 Tengu | *「天狗は山を守る」— Le tengu garde la montagne* |
| 🦝 Tanuki | *「狸は森に潜む」— Le tanuki se cache dans la forêt* |
| 🦊 Inari | *「稲荷は豊穣を祝う」— Inari célèbre la récolte* |
| 🐲 Ryujin | *「龍神は波を操る」— Ryujin commande aux vagues* |
| 👹 Oni | *「鬼の目にも涙」— Même le démon verse des larmes* |
| ☀️ Amaterasu | *「天照は光を導く」 - Amaterasu guide la lumière* |
| 🌙 Tsukuyomi | *「月読は闇を照らす」- Tsukuyomi illumine les ténèbres* |
| 🌬️ Fujin | *「風神は嵐を呼ぶ」- Fujin invoque la tempête* |
| ⚡ Raijin | *「雷神は天を裂く」- Raijin fend les cieux* |
| 🌊 Susanoo | *「スサノオは海を支配する」- Susanoo règne sur les mers* |
| 🎶 Benzaiten | *「弁財天は智慧を授ける」- Benzaiten accorde la sagesse* |
| ⚔️ Hachiman | *「八幡は戦略を練る」- Hachiman affine la stratégie* |
| ✨ Izanagi | *「イザナギは世界を創る」- Izanagi crée le monde* |
| 🛡️ Bishamonten | *「毘沙門天は正義を守る」- Bishamonten protège la justice* |
| 🏆 Musashi | *「武蔵は二刀を極める」- Musashi maîtrise les deux sabres* |

</details>

### Parcours recommandé

Les numéros des dojos reflètent l'ordre dans lequel ils ont été ajoutés, pas leur difficulté. Si vous ne savez pas par où commencer, suivez ce parcours :

| Étape | Dojos | Pourquoi |
|:----:|-------|-----|
| 1. Fondamentaux | 👺 Tengu, 🦝 Tanuki | Bases des Pods, des workloads et de la configuration. Peu de réseau et d'observabilité. |
| 2. Préparation à l'examen | 🐸 Kappa, 🦊 Inari, 👹 Oni | Les plus proches de la répartition des domaines de l'examen réel. Oni se concentre sur la réparation de workloads défaillants. |
| 3. Entraînement large | 🔥 Suzaku, 🐯 Byakko, 🐢 Genbu, 🦌 Kirin, puis ☀️ Amaterasu → 🏆 Musashi | Large couverture de tout le programme, dans leur ordre actuel. |
| Exercice ciblé | 🐲 Ryujin | Helm, stockage et débogage en CLI. Aucune question Services/Networking : utilisez-le comme exercice ciblé plutôt que comme simulation complète. |

---

## 🚀 Démarrage rapide (5 minutes)

> **Nouveau venu ?** Consultez le [QUICKSTART.fr.md](QUICKSTART.fr.md) — 3 étapes, sans fioritures.

```bash
git clone https://github.com/TiPunchLabs/ckad-dojo.git && cd ckad-dojo
uv run ckad-dojo
```

> **Déjà cloné ?** Lancez simplement `uv run ckad-dojo` depuis le répertoire du dépôt.

---

## Installation

### Option 1 : installation globale (recommandée)

Installez `ckad-dojo` globalement pour l'utiliser depuis n'importe où :

```bash
# Installation globale depuis PyPI (une fois publié)
uv tool install ckad-dojo

# Ou installation depuis un clone local
git clone https://github.com/TiPunchLabs/ckad-dojo.git
uv tool install ./ckad-dojo

# Ou installation directe depuis GitHub
uv tool install git+https://github.com/TiPunchLabs/ckad-dojo.git
```

Après l'installation, `ckad-dojo` est disponible dans tout le système :

```bash
ckad-dojo              # Menu interactif
ckad-dojo list         # Lister les examens
ckad-dojo exam start   # Démarrer un examen
```

**Gérer l'installation :**

```bash
uv tool list           # Lister les outils installés
uv tool upgrade ckad-dojo   # Mettre à jour vers la dernière version (ajoutez --python 3.12 si l'outil a été installé avec Python 3.10 ou 3.11)
uv tool uninstall ckad-dojo # Désinstaller
```

### Option 2 : exécution depuis le dépôt

Exécution directe sans installation globale :

```bash
git clone https://github.com/TiPunchLabs/ckad-dojo.git
cd ckad-dojo
uv run ckad-dojo       # uv gère les dépendances automatiquement
```

### Option 3 : scripts Bash uniquement

Si vous préférez ne pas utiliser la CLI Python (l'interface web passe tout de même par `uv` et Python 3.12+) :

```bash
git clone https://github.com/TiPunchLabs/ckad-dojo.git
cd ckad-dojo
./scripts/ckad-exam.sh # Exécution bash directe
```

---

## Prérequis

### Outils requis

| Outil | Version | Rôle | Installation |
|------|---------|---------|--------------|
| Cluster Kubernetes | 1.28+ | kubeadm, minikube, kind... | [kubernetes.io](https://kubernetes.io/docs/setup/) ou [vagrant-k8s-cluster](https://github.com/TiPunchLabs/vagrant-k8s-cluster) |
| `kubectl` | 1.28+ | CLI Kubernetes | `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` |
| `helm` | 3.x | Gestionnaire de paquets | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| `docker` | 20.x+ | Runtime de conteneurs | [docs.docker.com](https://docs.docker.com/engine/install/) |
| `ttyd` | 1.7+ | Terminal web intégré | `apt install ttyd` ou [github.com/tsl0922/ttyd](https://github.com/tsl0922/ttyd) |
| `uv` | 0.4+ | Gestionnaire de paquets Python | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Python | 3.12+ | Runtime de la CLI et du serveur web | Installé par `uv` à la demande, ou `uv python install 3.12` |
| `bash` | 4.0+ | Exécution des scripts | Préinstallé sous Linux |

> 💡 **Note** : Python 3.10 et 3.11 ne sont plus pris en charge. Vous n'avez pas besoin d'installer Python vous-même : `uv` télécharge automatiquement un interpréteur compatible. Si les téléchargements automatiques sont réglés sur `manual`, lancez d'abord `uv python install 3.12`. S'ils sont réglés sur `never` (`python-downloads` ou `UV_PYTHON_DOWNLOADS`), `uv` refuse tout téléchargement : installez Python 3.12+ avec le gestionnaire de paquets de votre système, ou passez le réglage à `manual`.

### Vérifier l'installation

```bash
# Vérifier la connexion au cluster
kubectl cluster-info

# Vérifier tous les outils
kubectl version --client
helm version
docker --version
ttyd --version
uv --version
bash --version
```

---

## Utilisation de la CLI (recommandée)

La CLI `ckad-dojo` fournit une interface unifiée pour toutes les opérations d'examen :

```bash
# Menu interactif (lancer sans argument)
uv run ckad-dojo

# Commandes directes
uv run ckad-dojo list                           # Lister tous les examens disponibles
uv run ckad-dojo info -e ckad-simulation2       # Afficher les détails d'un examen
uv run ckad-dojo exam start -e ckad-simulation2 # Démarrer un examen (setup + interface web)
uv run ckad-dojo setup -e ckad-simulation2      # Setup uniquement (sans interface web)
uv run ckad-dojo score -e ckad-simulation2      # Noter vos réponses
uv run ckad-dojo cleanup -e ckad-simulation2    # Nettoyer les ressources
uv run ckad-dojo status                         # Vérifier l'état de l'environnement
```

**Options de la CLI :**

| Option | Description |
|--------|-------------|
| `-e, --exam` | Indiquer l'identifiant de l'examen |
| `-b, --browser` | Navigateur à utiliser (firefox, chrome, chromium, brave, default) |
| `--no-color` | Désactiver la sortie colorée |
| `--help` | Afficher l'aide |
| `--version` | Afficher la version |

### Choix du navigateur

Par défaut, l'examen s'ouvre dans le navigateur par défaut de votre système. Vous pouvez indiquer un autre navigateur :

```bash
# Utiliser Firefox
uv run ckad-dojo exam start -e ckad-simulation2 --browser firefox

# Utiliser Chrome
uv run ckad-dojo exam start -e ckad-simulation2 --browser chrome

# Ou définir un navigateur par défaut via une variable d'environnement
export CKAD_BROWSER=firefox
uv run ckad-dojo exam start -e ckad-simulation2
```

**Navigateurs pris en charge :** `firefox`, `chrome`, `chromium`, `brave`, `default`

### Autocomplétion du shell

Activez la complétion par tabulation pour les commandes, les options et les identifiants d'examen.

#### Installation globale (recommandée)

Si vous avez installé l'outil avec `uv tool install`, l'autocomplétion fonctionne automatiquement après activation d'argcomplete :

```bash
# Bash - à ajouter dans ~/.bashrc
eval "$(register-python-argcomplete ckad-dojo)"

# Puis recharger
source ~/.bashrc
```

#### Utilisation depuis le dépôt local

Si vous lancez l'outil avec `uv run` depuis le dépôt, créez une fonction d'enrobage :

```bash
# À ajouter dans ~/.bashrc (adaptez le chemin à votre installation)
ckad-dojo() {
    uv run --project /path/to/ckad-dojo ckad-dojo "$@"
}
eval "$(register-python-argcomplete ckad-dojo)"
```

Puis rechargez : `source ~/.bashrc`

#### Utilisation

```bash
ckad-dojo <TAB>           # → setup, exam, score, cleanup, list
ckad-dojo exam <TAB>      # → start, --exam, --help
ckad-dojo -e <TAB>        # → ckad-simulation1, ckad-simulation2, ...
```

**Alternative : scripts de complétion intégrés**

<details>
<summary>Bash (sans fonction d'enrobage)</summary>

```bash
# Enregistrer dans le répertoire des complétions
mkdir -p ~/.local/share/bash-completion/completions
uv run ckad-dojo completion bash > ~/.local/share/bash-completion/completions/ckad-dojo
```

</details>

<details>
<summary>Zsh</summary>

```bash
mkdir -p ~/.zfunc
echo 'fpath=(~/.zfunc $fpath)' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
uv run ckad-dojo completion zsh > ~/.zfunc/_ckad-dojo
source ~/.zshrc
```

</details>

<details>
<summary>Fish</summary>

```bash
mkdir -p ~/.config/fish/completions
uv run ckad-dojo completion fish > ~/.config/fish/completions/ckad-dojo.fish
```

</details>

---

## Utilisation des scripts Bash

> 💡 La CLI (`uv run ckad-dojo`) enrobe ces scripts bash dans une interface plus conviviale. Les deux approches sont équivalentes — utilisez celle que vous préférez.

### Interface web (recommandée)

```bash
./scripts/ckad-exam.sh              # Sélection interactive de l'examen et de la question
./scripts/ckad-exam.sh web          # Identique à la commande précédente
./scripts/ckad-exam.sh -e ckad-simulation2 -q 5   # Démarrer un examen précis à la question 5
```

**Options de lancement :**

| Option | Description |
|--------|-------------|
| `-e, --exam EXAM` | Indiquer l'examen (sans sélection interactive) |
| `-q, --question N` | Commencer à la question N |
| `-y, --yes` | Ignorer les demandes de confirmation |
| `--no-terminal` | Désactiver le panneau de terminal intégré |
| `--no-docs` | Ne pas ouvrir les onglets de documentation K8s/Helm |
| `--no-pause` | Désactiver la mise en pause du minuteur |
| `--no-hints` | Désactiver les indices (retire les encadrés Hint/Tip) |
| `--browser NAME` | Navigateur à utiliser (firefox, chrome, chromium, brave, default) |
| `--port PORT` | Utiliser un port personnalisé (par défaut : 9090) |
| `--terminal-port PORT` | Port du terminal (par défaut : 7681) |

**Terminal intégré :**

L'interface d'examen comprend un panneau de terminal intégré (propulsé par ttyd) affiché à côté des questions. Il offre une expérience d'examen unifiée, proche de celle de l'examen CKAD réel.

- **Affichage scindé** : les questions à gauche, le terminal à droite
- **Redimensionnable** : faites glisser le séparateur pour ajuster la taille des panneaux
- **Persistant** : la session du terminal est conservée lors de la navigation entre les questions

**Raccourcis clavier :**

| Touche | Action |
|-----|--------|
| `←` / `→` | Question précédente / suivante |
| `F` | Marquer la question pour la revoir |

### Mode terminal

```bash
./scripts/ckad-exam.sh start    # Démarrer l'examen avec le minuteur
./scripts/ckad-exam.sh timer    # Suivre le compte à rebours (dans un autre terminal)
./scripts/ckad-exam.sh status   # Vérifier l'état de l'examen
```

### Opérations manuelles

```bash
./scripts/ckad-setup.sh         # Mettre en place l'environnement
./scripts/ckad-score.sh         # Consulter votre score
./scripts/ckad-cleanup.sh       # Tout réinitialiser
```

---

## Notation

```bash
./scripts/ckad-score.sh
```

```
═══════════════════════════════════════════════════════════════════
                           SCORE SUMMARY
═══════════════════════════════════════════════════════════════════

Question Score        Topic
-------- --------     -----------------------------
Q1       1/1          Namespaces
Q2       5/5          Pods
Q3       6/6          Job
...

═══════════════════════════════════════════════════════════════════

TOTAL SCORE: 87 / 113 (77%)

PASS - Congratulations!
```

---

## Déroulement type

```
1. Lancer un examen         →  uv run ckad-dojo exam start -e ckad-simulation1
2. Résoudre les questions   →  Travaillez dans le terminal intégré (ou le vôtre)
3. Noter vos réponses       →  uv run ckad-dojo score -e ckad-simulation1
4. Revoir les solutions     →  Ouvrez exams/ckad-simulation1/solutions.md
5. Nettoyer et recommencer  →  uv run ckad-dojo cleanup -e ckad-simulation1
```

> 💡 **Astuce** : vous pouvez noter vos réponses à tout moment pendant l'examen — inutile d'attendre la fin. Cela vous permet d'avancer question par question.

---

## Correspondance des chemins

Les questions font référence à des chemins comme `/opt/course/N/` (comme dans l'examen CKAD réel). En local, ils correspondent à votre répertoire de travail :

| Chemin de l'examen | Chemin local |
|-----------|------------|
| `/opt/course/N/` | `./exam/course/N/` |
| Registre | `localhost:5000` |

---

## Structure du projet

```
ckad-dojo/
├── .github/
│   └── workflows/
│       └── scorecard.yml     # Analyse de sécurité OpenSSF Scorecard
├── ckad_dojo.py              # CLI Python unifiée
├── pyproject.toml            # Configuration du projet Python (uv)
├── scripts/
│   ├── ckad-exam.sh          # Lanceur principal (bash)
│   ├── ckad-setup.sh         # Mise en place de l'environnement
│   ├── ckad-score.sh         # Notation automatique
│   ├── ckad-cleanup.sh       # Nettoyage
│   └── lib/                  # Fonctions partagées
├── web/                      # Interface web
├── exams/                    # Définitions des examens
│   ├── ckad-simulation1/     # Dojo Suzaku 🔥 - 21 questions, 112 points
│   ├── ckad-simulation2/     # Dojo Byakko 🐯 - 20 questions, 105 points
│   ├── ckad-simulation3/     # Dojo Genbu 🐢 - 20 questions, 105 points
│   ├── ckad-simulation4/     # Dojo Kappa 🐸 - 17 questions, 91 points
│   ├── ckad-simulation5/     # Dojo Kirin 🦌 - 20 questions, 100 points
│   ├── ckad-simulation6/     # Dojo Tengu 👺 - 20 questions, 100 points
│   ├── ckad-simulation7/     # Dojo Tanuki 🦝 - 20 questions, 100 points
│   ├── ckad-simulation8/     # Dojo Inari 🦊 - 20 questions, 100 points
│   ├── ckad-simulation9/     # Dojo Ryujin 🐲 - 20 questions, 100 points
│   ├── ckad-simulation10/    # Dojo Oni 👹 - 20 questions, 102 points
│   ├── ckad-simulation11/    # Dojo Amaterasu ☀️ - 20 questions, 104 points
│   ├── ckad-simulation12/    # Dojo Tsukuyomi 🌙 - 20 questions, 108 points
│   ├── ckad-simulation13/    # Dojo Fujin 🌬️ - 20 questions, 110 points
│   ├── ckad-simulation14/    # Dojo Raijin ⚡ - 20 questions, 112 points
│   ├── ckad-simulation15/    # Dojo Susanoo 🌊 - 20 questions, 110 points
│   ├── ckad-simulation16/    # Dojo Benzaiten 🎶 - 20 questions, 114 points
│   ├── ckad-simulation17/    # Dojo Hachiman ⚔️ - 20 questions, 119 points
│   ├── ckad-simulation18/    # Dojo Izanagi ✨ - 20 questions, 118 points
│   ├── ckad-simulation19/    # Dojo Bishamonten 🛡️ - 20 questions, 120 points
│   └── ckad-simulation20/    # Dojo Musashi 🏆 - 20 questions, 122 points
│       ├── exam.conf         # Configuration
│       ├── questions.md      # Questions
│       ├── solutions.md      # Solutions
│       ├── scoring-functions.sh # Scoring
│       ├── post-setup.sh     # Post-setup facultatif
│       ├── manifests/setup/  # Ressources K8s
│       └── templates/        # Fichiers modèles
├── exam/course/              # Vos réponses (créées par le setup)
└── tests/                    # Tests unitaires
```

---

## Astuces

| Astuce | Commande |
|-----|---------|
| Utiliser un alias | `alias k=kubectl` |
| Générer du YAML | `kubectl ... --dry-run=client -oyaml` |
| Consulter la documentation | kubernetes.io/docs (autorisée pendant l'examen réel) |
| Vérifier votre travail | Lancez `./scripts/ckad-score.sh` après chaque question |

---

## Dépannage

<details>
<summary><strong>L'interface web ne se charge pas</strong></summary>

```bash
uv --version                              # Vérifier que uv est installé
lsof -i :9090                             # Vérifier la disponibilité du port
./scripts/ckad-exam.sh web --port 8888    # Utiliser un autre port
```

</details>

<details>
<summary><strong>Erreur de version Python après une mise à jour (Python 3.10 ou 3.11)</strong></summary>

ckad-dojo nécessite désormais Python 3.12+. Une erreur comme `the current Python version (3.11.x) does not satisfy Python>=3.12` signifie que `uv` utilise encore un interpréteur plus ancien.

Exécution depuis le clone du dépôt (option 2), depuis le répertoire `ckad-dojo` :

```bash
uv sync                                   # Recrée .venv s'il a été construit avec 3.10 ou 3.11
```

Installation globale (option 1), depuis n'importe quel répertoire :

```bash
uv tool install --reinstall --python 3.12 <source>
```

Utilisez la même `<source>` que lors de l'installation : `ckad-dojo`, le chemin de votre clone, ou l'URL `git+https://`. Sans `--python`, `uv tool install --reinstall` et `uv tool upgrade` peuvent conserver l'ancien Python de l'outil et échouer à résoudre les dépendances.

Si aucun Python 3.12+ n'est disponible, lancez d'abord `uv python install 3.12` (impossible lorsque les téléchargements sont réglés sur `never` : voir [Prérequis](#prérequis)).

</details>

<details>
<summary><strong>Échec du push vers le registre (<code>localhost:5000</code>)</strong></summary>

Docker autorise déjà le HTTP simple pour `localhost` (`127.0.0.0/8`) : aucune modification de `insecure-registries` n'est généralement nécessaire.

**Sous macOS** : depuis Monterey, le récepteur AirPlay écoute sur le port 5000, si bien que `localhost:5000` peut répondre en tant qu'AirPlay au lieu du registre (la notation affiche alors « Image not found in registry »). Vérifiez quel processus occupe le port :

```bash
docker ps --filter name=registry
curl -si http://localhost:5000/v2/    # un registre fonctionnel répond 200 avec {}
lsof -nP -i :5000                     # ControlCenter sur :5000 = récepteur AirPlay
```

S'il s'agit d'AirPlay, désactivez-le (Réglages Système → Général → AirDrop et Handoff → Récepteur AirPlay) puis relancez le push.

Si votre configuration Docker rejette toujours le HTTP, ajoutez le registre dans `/etc/docker/daemon.json` :

```bash
# { "insecure-registries": ["localhost:5000"] }
sudo systemctl restart docker
```

</details>

<details>
<summary><strong>La notation affiche 0 pour des questions terminées</strong></summary>

- Vérifiez que les ressources se trouvent dans le bon namespace
- Vérifiez que les chemins de fichiers correspondent à `./exam/course/N/filename`
- Assurez-vous que les noms des ressources correspondent à ce qui est demandé

</details>

<details>
<summary><strong>La création d'un Ingress échoue avec une erreur de webhook</strong></summary>

Si vous obtenez cette erreur lors de la création d'un Ingress :

```
Error from server (InternalError): error when creating "ingress.yaml": Internal error occurred:
failed calling webhook "validate.nginx.ingress.kubernetes.io": Post
"https://ingress-nginx-controller-admission.ingress-nginx.svc:443/...": dial tcp ...:443: connect: connection refused
```

Le contrôleur ingress-nginx ne tourne pas. Corrigez le problème avec :

```bash
# Vérifier l'état du contrôleur
kubectl get pods -n ingress-nginx

# Option 1 : redémarrer le contrôleur
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx

# Option 2 : installer ingress-nginx s'il est absent
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Option 3 : supprimer le webhook (contournement)
kubectl delete validatingwebhookconfiguration ingress-nginx-admission
```

</details>

---

## Couverture du programme CKAD

Aligné sur le **[programme officiel CNCF CKAD v1.35](docs/ckad-curriculum.fr.md)** (Kubernetes 1.35).

| Domaine | Poids | Couverture | Sujets clés |
|--------|:------:|:--------:|------------|
| Application Design & Build | 20% | `██████████░░` 66% | Pods, Jobs, CronJobs, multi-conteneurs, volumes, images |
| Application Deployment | 20% | `█████████░░░` 71% | Deployments, rollouts, Helm, canary |
| Observability & Maintenance | 15% | `██████████░░` 81% | Probes, logs, débogage, dépréciations d'API |
| Config & Security | 25% | `█████████░░░` 73% | ConfigMaps, Secrets, RBAC, SecurityContext, quotas |
| Services & Networking | 20% | `██████████░░` 84% | Services, NetworkPolicies, Ingress |

<details>
<summary><strong>Compétences non couvertes (prioritaires pour les futures simulations)</strong></summary>

**Design & Build** : builds Dockerfile multi-étapes, patterns Ambassador/Adapter, ReplicaSets, volumes hostPath

**Deployment** : stratégie Blue/Green, Kustomize (kustomization.yaml, overlays, `kubectl apply -k`)

**Observability** : startup probes, `kubectl debug` (conteneurs éphémères), drain/cordon de nœuds

**Config & Security** : CRDs/Operators, secrets docker-registry et TLS, projection de tokens, seccompProfile

**Networking** : NetworkPolicy ipBlock, terminaison TLS sur l'Ingress

</details>

> Matrice de couverture complète : [`docs/simulation-coverage.csv`](docs/simulation-coverage.csv)
> Référence complète du programme : [`docs/ckad-curriculum.fr.md`](docs/ckad-curriculum.fr.md)

---

## Contribuer

Ce projet est open source et les contributions sont les bienvenues !

### Processus de développement

J'utilise Claude Code pour implémenter les modifications et Codex pour les relire de manière indépendante,
Herdr assurant la coordination du passage de relais. Le dépôt comprend
[`CLAUDE.fr.md`](CLAUDE.fr.md) pour les instructions d'implémentation,
[`AGENTS.fr.md`](AGENTS.fr.md) pour les instructions de relecture, et un
[guide du processus](docs/agent-workflow.fr.md) qui décrit comment je les utilise ensemble.

### Signaler un bug

Vous avez trouvé un bug ? Merci d'[ouvrir une issue](https://github.com/TiPunchLabs/ckad-dojo/issues/new?template=bug_report.md) contenant :

- Une description claire du problème
- Les étapes pour le reproduire
- Le comportement attendu et le comportement observé
- Votre environnement (OS, version de kubectl, etc.)

### Proposer une amélioration

Vous avez une idée pour améliorer ckad-dojo ? [Créez une demande de fonctionnalité](https://github.com/TiPunchLabs/ckad-dojo/issues/new?template=feature_request.md) contenant :

- Une description de la fonctionnalité proposée
- Le cas d'usage et ses bénéfices
- Des idées d'implémentation (facultatif)

### Configuration de l'environnement de développement

Ce projet utilise [direnv](https://direnv.net/) et [pre-commit](https://pre-commit.com/) pour garantir un environnement de développement cohérent.

```bash
# 1. Installer direnv (s'il n'est pas déjà installé)
# Ubuntu/Debian : sudo apt install direnv
# macOS : brew install direnv

# 2. Autoriser direnv pour ce projet
direnv allow

# 3. Installer les hooks pre-commit
uv sync --group dev
uv run pre-commit install
uv run pre-commit install --hook-type commit-msg
```

**Les hooks pre-commit comprennent :**

| Hook | Rôle |
|------|---------|
| `shellcheck` | Analyse statique des scripts shell |
| `shfmt` | Formatage des scripts shell |
| `flake8` | Analyse statique du Python |
| `yamllint` | Validation YAML |
| `markdownlint` | Formatage Markdown |
| `gitleaks` | Détection de secrets |
| `commitizen` | Messages de commit conventionnels |

### Ajouter une nouvelle simulation

Vous souhaitez contribuer un nouveau dojo ? Commencez ici :

1. Consultez la **[couverture du programme CKAD](docs/ckad-curriculum.fr.md)** pour connaître les domaines officiels de l'examen et leurs poids
2. Parcourez la **[matrice de couverture](docs/simulation-coverage.csv)** pour repérer les compétences non couvertes (colonne `covered_in` vide)
3. Visez environ 20 questions réparties entre les domaines : Design & Build (20%), Deployment (20%), Observability (15%), Config & Security (25%), Networking (20%)
4. Suivez la structure des simulations existantes dans `exams/ckad-simulation*/`

### Soumettre une pull request

1. Forkez le dépôt
2. Créez une branche de fonctionnalité (`git checkout -b feature/my-feature`)
3. Apportez vos modifications
4. Testez vos modifications (`./tests/run-tests.sh`)
5. Lancez les vérifications pre-commit (`pre-commit run --all-files`)
6. Committez avec un [message conventionnel](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, etc.)
7. Ouvrez une pull request

Toutes les contributions doivent respecter la licence [CC BY-NC-SA 4.0](LICENSE).

---

## Remerciements

Un grand merci aux contributeurs suivants, dont le travail a été adapté pour ce projet :

| Dojo | Source | Auteur |
|------|--------|--------|
| 🐸 Dojo Kappa (Simulation 4) | [CKAD-Practice-Questions](https://github.com/aravind4799/CKAD-Practice-Questions) | [@aravind4799](https://github.com/aravind4799) |
| 👺 Dojo Tengu (Simulation 6) | [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) | [@dgkanatsios](https://github.com/dgkanatsios) |
| 🦝 Dojo Tanuki (Simulation 7) | [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) | [@dgkanatsios](https://github.com/dgkanatsios) |
| 🦊 Dojo Inari (Simulation 8) | [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) | [@dgkanatsios](https://github.com/dgkanatsios) |
| 🐲 Dojo Ryujin (Simulation 9) | [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) | [@dgkanatsios](https://github.com/dgkanatsios) |
| 🌙 Dojo Tsukuyomi (Simulation 12) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| 🌬️ Dojo Fujin (Simulation 13) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| ⚡ Dojo Raijin (Simulation 14) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| 🌊 Dojo Susanoo (Simulation 15) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| 🎶 Dojo Benzaiten (Simulation 16) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| ⚔️ Dojo Hachiman (Simulation 17) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| ✨ Dojo Izanagi (Simulation 18) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| 🛡️ Dojo Bishamonten (Simulation 19) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |
| 🏆 Dojo Musashi (Simulation 20) | Contenu de dojo original | [@Sai7Teja](https://github.com/Sai7Teja) |

---

## Licence

Ce projet est distribué sous licence **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International** (CC BY-NC-SA 4.0).

**Vous êtes libre de :**

- Utiliser, copier et partager ce projet à des fins personnelles et éducatives
- Le modifier et créer des œuvres dérivées (sous la même licence)

**Vous n'êtes PAS autorisé à :**

- Utiliser ce projet à des fins commerciales sans autorisation explicite
- Le vendre ou l'inclure dans des produits ou services payants

Pour une licence commerciale, veuillez contacter l'auteur.

Consultez le fichier [LICENSE](LICENSE) pour tous les détails.

---

<p align="center">
  <strong>À des fins éducatives uniquement</strong>
</p>
