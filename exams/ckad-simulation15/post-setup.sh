#!/bin/bash
exam_post_setup() {
  # Install Helm release for Q5
  helm repo add bitnami https://charts.bitnami.com/bitnami > /dev/null 2>&1
  helm repo update > /dev/null 2>&1
  helm install ocean-api bitnami/nginx --namespace current > /dev/null 2>&1
  
  # Generate some warning events for Q10
  kubectl run failing-pod --image=wrong-image-for-event --namespace depths > /dev/null 2>&1
  sleep 5
  kubectl delete pod failing-pod --namespace depths --force --grace-period=0 > /dev/null 2>&1

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1/Dockerfile"
  touch "$BASE_DIR/1/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/events.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12/config-files/"
  touch "$BASE_DIR/12/config-files//.gitkeep"
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
}
