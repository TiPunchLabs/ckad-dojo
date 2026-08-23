#!/bin/bash

# Post-setup script for Simulation 17

function exam_post_setup() {
    echo "Running post-setup tasks for Simulation 17..."
    
    # Q5: Helm chart and release setup
    mkdir -p ./exam/course/5/
    helm create ./exam/course/5/battle-chart > /dev/null 2>&1
    
    # The default nginx chart works, so let's just make sure it's installed
    helm install battle-web ./exam/course/5/battle-chart -n garrison --set replicaCount=1 > /dev/null 2>&1
    
    
    
    # Q8: Kustomize setup
    mkdir -p ./exam/course/8/
    cat <<EOF2 > ./exam/course/8/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF2
    cat <<EOF2 > ./exam/course/8/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vanguard-web
  namespace: vanguard
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vanguard-web
  template:
    metadata:
      labels:
        app: vanguard-web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.0-alpine
EOF2

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1" "$BASE_DIR/2" "$BASE_DIR/3" "$BASE_DIR/4" "$BASE_DIR/6" "$BASE_DIR/8"
  mkdir -p "$BASE_DIR/12" "$BASE_DIR/13" "$BASE_DIR/14" "$BASE_DIR/15" "$BASE_DIR/16" "$BASE_DIR/17" "$BASE_DIR/18" "$BASE_DIR/19" "$BASE_DIR/20"

  for i in 1 2 3 4 6 12 13 14 15 16 17 18 19 20; do
    # Just touch them or make empty manifests. Actually for yaml files:
    cat << 'EOF_FILE' > "$BASE_DIR/$i/stub.yaml"
# TODO: Complete this manifest per the task instructions
EOF_FILE
  done

  # Specific file names based on questions:
  mv "$BASE_DIR/1/stub.yaml" "$BASE_DIR/1/pod.yaml"
  mv "$BASE_DIR/2/stub.yaml" "$BASE_DIR/2/init-pod.yaml"
  mv "$BASE_DIR/3/stub.yaml" "$BASE_DIR/3/cronjob.yaml"
  mv "$BASE_DIR/4/stub.yaml" "$BASE_DIR/4/shared-pid.yaml"
  mv "$BASE_DIR/6/stub.yaml" "$BASE_DIR/6/deploy.yaml"
  mv "$BASE_DIR/12/stub.yaml" "$BASE_DIR/12/downward.yaml"
  mv "$BASE_DIR/13/stub.yaml" "$BASE_DIR/13/sa-pod.yaml"
  mv "$BASE_DIR/14/stub.yaml" "$BASE_DIR/14/seccomp.yaml"
  mv "$BASE_DIR/15/stub.yaml" "$BASE_DIR/15/multi-secret.yaml"
  mv "$BASE_DIR/16/stub.yaml" "$BASE_DIR/16/limit-range.yaml"
  mv "$BASE_DIR/17/stub.yaml" "$BASE_DIR/17/netpol.yaml"
  mv "$BASE_DIR/18/stub.yaml" "$BASE_DIR/18/ingress.yaml"
  mv "$BASE_DIR/19/stub.yaml" "$BASE_DIR/19/manual-svc.yaml"
  mv "$BASE_DIR/20/stub.yaml" "$BASE_DIR/20/coredns.yaml"

  echo "Post-setup complete."
}
exam_post_setup
