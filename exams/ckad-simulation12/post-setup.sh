#!/bin/bash
# CKAD Simulation 12 - Post Setup

function exam_post_setup() {
  echo "Running post-setup for Simulation 12..."
  
  # Create a dummy Helm chart for Q5
  local chart_dir=$(mktemp -d)
  
  cat <<EOF > "$chart_dir/Chart.yaml"
apiVersion: v2
name: dummy-api
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
EOF

  mkdir -p "$chart_dir/templates"
  
  cat <<EOF > "$chart_dir/templates/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "dummy-api.fullname" . }}
  labels:
    app: {{ include "dummy-api.name" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "dummy-api.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "dummy-api.name" . }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
EOF

  cat <<EOF > "$chart_dir/templates/_helpers.tpl"
{{- define "dummy-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "dummy-api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- \$name := default .Chart.Name .Values.nameOverride }}
{{- if contains \$name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name \$name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
EOF

  cat <<EOF > "$chart_dir/values.yaml"
replicaCount: 1
image:
  repository: nginx
  tag: "1.24"
nameOverride: ""
fullnameOverride: ""
EOF

  echo "Installing Helm chart api-release..."
  helm install api-release "$chart_dir" -n nebula --wait --timeout=120s
  
  # Upgrade with a bad image to create the failure scenario
  cat <<EOF > "$chart_dir/values.yaml"
replicaCount: 1
image:
  repository: nginx
  tag: "nonexistent-tag-12345"
EOF

  echo "Upgrading Helm chart api-release with a bad image..."
  helm upgrade api-release "$chart_dir" -n nebula

  rm -rf "$chart_dir"
  
  echo "Triggering rollout deployment update for Q7..."
  kubectl set image deployment/critical-processor app=nginx:1.25 -n nightfall

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/12/q1/Dockerfile"
  touch "$BASE_DIR/12/q1/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/12/q1"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q1/main.go"
package main
import "fmt"
func main() {
    fmt.Println("Stub main.go")
}
EOF_FILE
  mkdir -p "$BASE_DIR/12/q10"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q10/cpu-usage.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12/q20"
  cat << 'EOF_FILE' > "$BASE_DIR/12/q20/nslookup.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12/q8/"
  touch "$BASE_DIR/12/q8//.gitkeep"
}
