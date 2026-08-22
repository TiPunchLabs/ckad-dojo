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
}
