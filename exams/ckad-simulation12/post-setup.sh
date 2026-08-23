#!/bin/bash
# CKAD Simulation 12 - Post Setup

function exam_post_setup() {
  echo "Running post-setup for Simulation 12..."
  
  echo "Upgrading Helm chart api-release with a bad image to create failure scenario..."
  helm upgrade api-release bitnami/nginx --set image.tag="nonexistent-tag-12345" -n nebula --reuse-values --wait=false

  echo "Triggering rollout deployment update for Q7..."
  kubectl set image deployment/critical-processor app=nginx:1.25 -n nightfall

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/12/q1"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q1/Dockerfile"
# /opt/course/12/q1/Dockerfile
FROM golang:1.20-alpine
# TODO: Complete this Dockerfile per the task instructions
EOF_FILE

  cat << 'EOF_FILE' > "$BASE_DIR/12/q1/main.go"
package main
import "fmt"
func main() {
    fmt.Println("Stub main.go")
}
EOF_FILE

  mkdir -p "$BASE_DIR/12/q8"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q8/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: dusk
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: web
        image: nginx:1.24
EOF_FILE

  cat << 'EOF_FILE' > "$BASE_DIR/12/q8/kustomization.yaml"
resources:
  - deployment.yaml
EOF_FILE

  mkdir -p "$BASE_DIR/12/q10"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q10/cpu-usage.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE

  mkdir -p "$BASE_DIR/12/q20"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q20/nslookup.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE

  return 0
}
