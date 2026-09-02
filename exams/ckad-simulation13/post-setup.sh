#!/bin/bash

exam_post_setup() {
	echo "Running post-setup for Simulation 13..."
	local BASE_DIR="./exam/course"

	mkdir -p "$BASE_DIR/13/q1"
	cat <<'EOF_FILE' >"$BASE_DIR/13/q1/Dockerfile"
FROM nginx:1.22
# TODO: Complete this manifest per the task instructions
EOF_FILE

	mkdir -p "$BASE_DIR/13/q4"
	cat <<'EOF_FILE' >"$BASE_DIR/13/q4/pod.yaml"
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

	mkdir -p "$BASE_DIR/13/q5/storm-chart/templates"
	cat <<'EOF_FILE' >"$BASE_DIR/13/q5/storm-chart/Chart.yaml"
apiVersion: v2
name: storm-chart
version: 0.1.0
EOF_FILE
	cat <<'EOF_FILE' >"$BASE_DIR/13/q5/storm-chart/values.yaml"
replicaCount: 1
image:
  tag: "v1.0.0"
EOF_FILE
	cat <<'EOF_FILE' >"$BASE_DIR/13/q5/storm-chart/templates/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storm-app
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: storm-app
  template:
    metadata:
      labels:
        app: storm-app
    spec:
      containers:
      - name: app
        image: "nginx:{{ .Values.image.tag }}"
EOF_FILE

	mkdir -p "$BASE_DIR/13/q8"
	cat <<'EOF_FILE' >"$BASE_DIR/13/q8/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tornado-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tornado-app
  template:
    metadata:
      labels:
        app: tornado-app
    spec:
      containers:
      - name: app
        image: nginx
EOF_FILE

	mkdir -p "$BASE_DIR/13/q10"

	mkdir -p "$BASE_DIR/13/q20"

	return 0
}
