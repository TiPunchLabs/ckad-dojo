#!/bin/bash
exam_post_setup() {
  local BASE_DIR="./exam/course/16"
  
  kubectl apply -f "exams/ckad-simulation16/manifests/setup/setup.yaml" 2>/dev/null || true
  kubectl set image deployment/legacy-app -n verse app=nginx:1.15
  kubectl rollout status deployment/legacy-app -n verse --timeout=60s || true
  kubectl set image deployment/legacy-app -n verse app=nginx:1.16
  kubectl rollout status deployment/legacy-app -n verse --timeout=60s || true
  kubectl set image deployment/legacy-app -n verse app=nginx:missing-tag
  
  mkdir -p $BASE_DIR/q1/app
  echo "Benzaiten Wisdom" > $BASE_DIR/q1/app/index.html
  cat << 'EOF_FILE' > $BASE_DIR/q1/Dockerfile
FROM nginx:alpine
# TODO: Complete Dockerfile
EOF_FILE
  
  mkdir -p $BASE_DIR/q5/chart/templates
  cat <<'EOF' > $BASE_DIR/q5/chart/Chart.yaml
apiVersion: v2
name: wisdom-app
version: 0.1.0
dependencies:
  - name: nginx
    version: 15.1.0
    repository: https://charts.bitnami.com/bitnami
EOF
  cat <<'EOF' > $BASE_DIR/q5/chart/values.yaml
replicaCount: 1
service:
  port: 80
EOF
  cat << 'EOF_FILE' > $BASE_DIR/q5/values.yaml
# override values here
EOF_FILE

  mkdir -p $BASE_DIR/q8/base
  cat <<'EOF' > $BASE_DIR/q8/base/kustomization.yaml
resources:
  - deployment.yaml
EOF
  cat <<'EOF' > $BASE_DIR/q8/base/deployment.yaml
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

  mkdir -p $BASE_DIR/q8/overlays/production
  cat <<'EOF' > $BASE_DIR/q8/kustomization.yaml
# TODO: Complete Kustomize config
EOF

  mkdir -p $BASE_DIR/q10
  mkdir -p $BASE_DIR/q13
  echo -n "binary-data-test" > $BASE_DIR/q13/data.bin
  mkdir -p $BASE_DIR/q15
  mkdir -p $BASE_DIR/q19

  return 0
}
