#!/bin/bash

# Post-setup script for CKAD Simulation 13
# This script is executed after the standard setup process

exam_post_setup() {
    echo "Running post-setup for Simulation 13..."
    
    # Deploy the Helm chart for question 5
    helm install storm-app ./exam/course/13/q5/storm-chart -n typhoon
    
    echo "Post-setup complete."

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/13/q1/Dockerfile"
  touch "$BASE_DIR/13/q1/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/13/q10"
  cat << 'EOF_FILE' > "$BASE_DIR/13/q10/top-pods.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/13/q20"
  cat << 'EOF_FILE' > "$BASE_DIR/13/q20/svc-env.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/13/q4"
  cat << 'EOF_FILE' > "$BASE_DIR/13/q4/pod.yaml"
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
  mkdir -p "$BASE_DIR/13/q5/storm-chart"
  touch "$BASE_DIR/13/q5/storm-chart/.gitkeep"
  mkdir -p "$BASE_DIR/13/q8/"
  touch "$BASE_DIR/13/q8//.gitkeep"
  mkdir -p "$BASE_DIR/13/q8"
  cat << 'EOF_FILE' > "$BASE_DIR/13/q8/kustomization.yaml"
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
