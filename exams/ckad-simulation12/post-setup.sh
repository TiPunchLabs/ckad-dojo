#!/bin/bash
# CKAD Simulation 12 - Post Setup

function exam_post_setup() {
	echo "Running post-setup for Simulation 12..."

	# Q1 asks the candidate to build lunar-app:v1.0 and tag the reloaded image
	# lunar-app:v1.0-verified. These images live in the local Docker store, which
	# ckad-cleanup.sh does not touch, so an earlier attempt would leave them behind
	# and score_q1 would award their points before the candidate does anything.
	# Removing them here makes every setup start Q1 from a clean state.
	docker rmi -f lunar-app:v1.0 lunar-app:v1.0-verified &>/dev/null || true

	echo "Upgrading Helm chart api-release with a bad image to create failure scenario..."
	helm upgrade api-release bitnami/nginx --set image.tag="nonexistent-tag-12345" -n nebula --reuse-values --wait=false

	echo "Rolling critical-processor to nginx:1.25 so Q7 starts with a revision history..."
	kubectl set image deployment/critical-processor app=nginx:1.25 -n nightfall

	# === Auto-generated starter files ===
	local BASE_DIR="./exam/course"
	mkdir -p "$BASE_DIR/1"
	cat <<'EOF_FILE' >"$BASE_DIR/1/Dockerfile"
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o /app/server main.go

FROM alpine:3.18
COPY --from=builder /app/server /opt/server
ENTRYPOINT ["/opt/server"]
EOF_FILE

	cat <<'EOF_FILE' >"$BASE_DIR/1/main.go"
package main

import "fmt"

func main() {
	fmt.Println("Tsukuyomi server running")
}
EOF_FILE

	mkdir -p "$BASE_DIR/8"
	cat <<'EOF_FILE' >"$BASE_DIR/8/deployment.yaml"
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

	cat <<'EOF_FILE' >"$BASE_DIR/8/kustomization.yaml"
resources:
  - deployment.yaml
EOF_FILE

	mkdir -p "$BASE_DIR/11"
	cat <<'EOF_FILE' >"$BASE_DIR/11/broken-deploy.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
  namespace: lunar
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken-app
  template:
    metadata:
      labels:
        app: broken
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 2
          periodSeconds: 3
EOF_FILE

	return 0
}
