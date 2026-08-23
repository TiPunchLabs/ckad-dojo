#!/bin/bash
exam_post_setup() {
  kubectl apply -f "$EXAM_DIR/manifests/setup/setup.yaml"
  kubectl set image deployment/legacy-app -n verse app=nginx:1.15
  kubectl rollout status deployment/legacy-app -n verse --timeout=60s || true
  kubectl set image deployment/legacy-app -n verse app=nginx:1.16
  kubectl rollout status deployment/legacy-app -n verse --timeout=60s || true
  kubectl set image deployment/legacy-app -n verse app=nginx:missing-tag
  
  mkdir -p $EXAM_DIR/1/app
  echo "Benzaiten Wisdom" > $EXAM_DIR/1/app/index.html
  
  mkdir -p $EXAM_DIR/5/chart/templates
  cat <<'EOF' > $EXAM_DIR/5/chart/Chart.yaml
apiVersion: v2
name: wisdom-app
version: 0.1.0
dependencies:
  - name: nginx
    version: 15.1.0
    repository: https://charts.bitnami.com/bitnami
EOF
  cat <<'EOF' > $EXAM_DIR/5/chart/values.yaml
replicaCount: 1
service:
  port: 80
EOF

  mkdir -p $EXAM_DIR/8/base
  cat <<'EOF' > $EXAM_DIR/8/base/kustomization.yaml
resources:
  - deployment.yaml
EOF
  cat <<'EOF' > $EXAM_DIR/8/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: main
        image: nginx:alpine
EOF

  mkdir -p $EXAM_DIR/10
  mkdir -p $EXAM_DIR/13
  echo -n "binary-data-test" > $EXAM_DIR/13/data.bin
  mkdir -p $EXAM_DIR/15
  mkdir -p $EXAM_DIR/19

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1/Dockerfile"
  touch "$BASE_DIR/1/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/1/app"
  touch "$BASE_DIR/1/app/.gitkeep"
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/metrics.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/13"
  cat << 'EOF_FILE' > "$BASE_DIR/13/data.bin"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/token.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/19"
  cat << 'EOF_FILE' > "$BASE_DIR/19/endpoints.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/5/chart"
  touch "$BASE_DIR/5/chart/.gitkeep"
  mkdir -p "$BASE_DIR/5"
  cat << 'EOF_FILE' > "$BASE_DIR/5/values.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/8/base"
  touch "$BASE_DIR/8/base/.gitkeep"
  mkdir -p "$BASE_DIR/8"
  cat << 'EOF_FILE' > "$BASE_DIR/8/kustomization.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/8/overlays/production"
  touch "$BASE_DIR/8/overlays/production/.gitkeep"
}
