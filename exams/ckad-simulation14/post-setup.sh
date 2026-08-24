#!/bin/bash

exam_post_setup() {
  echo "Running post-setup for CKAD Simulation 14..."
  
  # Q5 Helm Chart setup
  mkdir -p ./exam/course/14/q5/chart/templates
  cat << 'EOF_FILE' > ./exam/course/14/q5/chart/Chart.yaml
apiVersion: v2
name: thunder-web
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
EOF_FILE

  cat << 'EOF_FILE' > ./exam/course/14/q5/chart/values.yaml
replicaCount: 1
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.16.0"
EOF_FILE

  cat << 'EOF_FILE' > ./exam/course/14/q5/chart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "thunder-web.fullname" . }}
  labels:
    app: {{ include "thunder-web.name" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "thunder-web.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "thunder-web.name" . }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
EOF_FILE

  cat << 'EOF_FILE' > ./exam/course/14/q5/chart/templates/_helpers.tpl
{{- define "thunder-web.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "thunder-web.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
EOF_FILE

  # Q6 Deployment update to create a revision history
  kubectl create deployment api-gateway --image=nginx:1.23 -n voltage
  kubectl wait --for=condition=available deployment/api-gateway -n voltage --timeout=90s || true
  kubectl set image deployment/api-gateway nginx=nginx:broken-tag-123 -n voltage --record=true
  
  # Q8 Base files
  mkdir -p ./exam/course/14/q8/
  cat << 'EOF_FILE' > ./exam/course/14/q8/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-worker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-worker
  template:
    metadata:
      labels:
        app: api-worker
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sleep", "3600"]
EOF_FILE


  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/14/q1"
    
  mkdir -p "$BASE_DIR/14/q2"
    
  mkdir -p "$BASE_DIR/14/q3"
    
  mkdir -p "$BASE_DIR/14/q4"
    
  mkdir -p "$BASE_DIR/14/q5"
  cat << 'EOF_FILE' > "$BASE_DIR/14/q5/output.yaml"
# Rendered helm templates will go here
EOF_FILE
  
  mkdir -p "$BASE_DIR/14/q8"
  cat << 'EOF_FILE' > "$BASE_DIR/14/q8/kustomization.yaml"
resources:
  - deployment.yaml
EOF_FILE
  
  mkdir -p "$BASE_DIR/14/q10"
    
  mkdir -p "$BASE_DIR/14/q11"
    
  mkdir -p "$BASE_DIR/14/q12"
    
  mkdir -p "$BASE_DIR/14/q13"
    
  mkdir -p "$BASE_DIR/14/q14"
    
  mkdir -p "$BASE_DIR/14/q15"
  
  mkdir -p "$BASE_DIR/14/q17"
    
  mkdir -p "$BASE_DIR/14/q18"
    
  mkdir -p "$BASE_DIR/14/q19"
    
  mkdir -p "$BASE_DIR/14/q20"
    
  return 0
}
