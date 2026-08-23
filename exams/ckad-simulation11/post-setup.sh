#!/bin/bash
# post-setup.sh - Exam-specific post-setup for ckad-simulation11

exam_post_setup() {
	local errors=0

	# Q8 - Install Helm release for upgrade question
	if ! helm status web-release -n radiance &>/dev/null; then
		helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
		helm repo update >/dev/null 2>&1

		if helm install web-release bitnami/nginx -n radiance \
			--set replicaCount=1 \
			--set service.type=ClusterIP \
			--wait --timeout 120s >/dev/null 2>&1; then
			print_success "Q8: Installed Helm release web-release (revision 1)"
		else
			print_fail "Q8: Failed to install web-release"
			((errors++))
		fi
	else
		print_skip "Q8: web-release already exists"
	fi

	# Q13 - Generate TLS cert/key for TLS Secret question
	if [ -d "$EXAM_DIR/13" ]; then
		if command -v openssl &>/dev/null; then
			openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
				-keyout "$EXAM_DIR/13/tls.key" \
				-out "$EXAM_DIR/13/tls.crt" \
				-subj "/CN=web.flare.example.com" \
				>/dev/null 2>&1
			print_success "Q13: Generated TLS cert/key in exam/course/13/"
		else
			print_fail "Q13: openssl not available, cannot generate TLS cert/key"
			((errors++))
		fi
	fi

	# Q19 - Create TLS Secret for Ingress TLS termination question
	if ! kubectl get secret secure-tls -n solstice &>/dev/null; then
		if command -v openssl &>/dev/null; then
			local tmpdir
			tmpdir=$(mktemp -d)
			openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
				-keyout "$tmpdir/tls.key" \
				-out "$tmpdir/tls.crt" \
				-subj "/CN=secure.example.com" \
				>/dev/null 2>&1
			if kubectl create secret tls secure-tls \
				--cert="$tmpdir/tls.crt" \
				--key="$tmpdir/tls.key" \
				-n solstice >/dev/null 2>&1; then
				print_success "Q19: Created TLS Secret secure-tls in solstice"
			else
				print_fail "Q19: Failed to create TLS Secret"
				((errors++))
			fi
			rm -rf "$tmpdir"
		else
			print_fail "Q19: openssl not available"
			((errors++))
		fi
	else
		print_skip "Q19: secure-tls already exists"
	fi

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1/image"
  cat << 'EOF_FILE' > "$BASE_DIR/1/image/Dockerfile"
FROM nginx:1.25
# TODO: Complete this Dockerfile per the task instructions
EOF_FILE
  cat << 'EOF_FILE' > "$BASE_DIR/1/image/index.html"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/1"
  cat << 'EOF_FILE' > "$BASE_DIR/1/solar-app.tar"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/pending-reason.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/11"
  cat << 'EOF_FILE' > "$BASE_DIR/11/sidecar-logs.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12"
  cat << 'EOF_FILE' > "$BASE_DIR/12/crd-group.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/auth-check.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/16"
  cat << 'EOF_FILE' > "$BASE_DIR/16/app.env"
APP_NAME=my-app
APP_ENV=production
EOF_FILE
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/dns-output.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/7"
  cat << 'EOF_FILE' > "$BASE_DIR/7/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: zenith
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF_FILE
  mkdir -p "$BASE_DIR/7"
  cat << 'EOF_FILE' > "$BASE_DIR/7/service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: zenith
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
EOF_FILE
  return $errors
}
