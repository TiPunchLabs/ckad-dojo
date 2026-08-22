#!/bin/bash
set -e

exam_post_setup() {
    echo "Running post-setup for CKAD Simulation 19..."

    # Q1 Setup
    mkdir -p /opt/course/19/q1
    cat <<EOF > /opt/course/19/q1/main.go
package main
import "fmt"
func main() {
    fmt.Println("Hello Dojo")
}
EOF
    cat <<EOF > /opt/course/19/q1/Dockerfile
FROM golang:1.20-alpine
WORKDIR /app
COPY . .
# Add multi-stage steps
EOF

    # Q5 Setup (Helm)
    helm create /tmp/guardian-app > /dev/null 2>&1
    helm install guardian-app /tmp/guardian-app -n haven --set replicaCount=1 --set image.tag=1.16.0 > /dev/null 2>&1

    # Q8 Setup (Kustomize)
    mkdir -p /opt/course/19/q8
    cat <<EOF > /opt/course/19/q8/deployment.yaml
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
EOF

    # Q10 Setup
    mkdir -p /opt/course/19/q10

    # Q13 Setup
    mkdir -p /opt/course/19/q13

    echo "Post-setup complete."
}
