#!/bin/bash
set -e

exam_post_setup() {
    echo "Running post-setup for CKAD Simulation 19..."

    local BASE_DIR="./exam/course/19"
    
    # Q1 Setup
    mkdir -p "$BASE_DIR/q1"
    cat <<EOF2 > "$BASE_DIR/q1/main.go"
package main
import "fmt"
func main() {
    fmt.Println("Hello Dojo")
}
EOF2
    cat <<EOF2 > "$BASE_DIR/q1/Dockerfile"
FROM golang:1.20-alpine
WORKDIR /app
COPY . .
# Add multi-stage steps
EOF2

    # Q5 Setup (Helm)
    helm create /tmp/guardian-app > /dev/null 2>&1
    helm install guardian-app /tmp/guardian-app -n haven --set replicaCount=1 --set image.tag=1.16.0 > /dev/null 2>&1
    mkdir -p "$BASE_DIR/q5"
    touch "$BASE_DIR/q5/old-values.yaml" "$BASE_DIR/q5/new-values.yaml" "$BASE_DIR/q5/values.yaml"

    # Q8 Setup (Kustomize)
    mkdir -p "$BASE_DIR/q8"
    cat <<EOF2 > "$BASE_DIR/q8/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
EOF2

    cat <<EOF2 > "$BASE_DIR/q8/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF2

    # Q10 Setup
    mkdir -p "$BASE_DIR/q10"

    # Q13 Setup
    mkdir -p "$BASE_DIR/q13"

    echo "Post-setup complete."
  return 0
}
