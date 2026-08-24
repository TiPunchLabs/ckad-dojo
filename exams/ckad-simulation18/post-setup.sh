#!/bin/bash

# Post-setup for CKAD Simulation 18

exam_post_setup() {
  local exam_dir=$1
  
  # Install genesis-web helm chart in nexus namespace
  echo "Installing genesis-web Helm chart..."
  helm install genesis-web "./exams/ckad-simulation18/templates/5/genesis-web-chart" -n nexus --set customLabel="initial-install" --wait

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1" "$BASE_DIR/5" "$BASE_DIR/8" "$BASE_DIR/10" "$BASE_DIR/11" "$BASE_DIR/19"
  
  cat << 'EOF_D' > "$BASE_DIR/1/Dockerfile"
FROM nginx:alpine
# TODO: Complete this manifest per the task instructions
EOF_D

  cp -r "./exams/ckad-simulation18/templates/5/genesis-web-chart" "$BASE_DIR/5/"

  mkdir -p "$BASE_DIR/8/kustomize"
  cat << 'EOF_K' > "$BASE_DIR/8/kustomize/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF_K
  cat << 'EOF_K2' > "$BASE_DIR/8/kustomize/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stub
spec:
  template:
    spec:
      containers:
      - name: c
        image: nginx
EOF_K2

  touch "$BASE_DIR/10/events.txt"
  
  cat << 'EOF_S' > "$BASE_DIR/11/check.sh"
#!/bin/bash
# TODO: Complete this script per the task instructions
EOF_S
  chmod +x "$BASE_DIR/11/check.sh"
  
  touch "$BASE_DIR/11/health.log"
  touch "$BASE_DIR/19/fqdn.txt"

  return 0
}
