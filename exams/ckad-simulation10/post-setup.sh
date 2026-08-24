#!/bin/bash
# post-setup.sh - Exam-specific post-setup for ckad-simulation10
# Creates broken deployment revisions for rollback exercise (Q13)

exam_post_setup() {
	local errors=0

	# Q13 - Create deployment revision history for rollback exercise
	if kubectl get deployment web-server -n citadel &>/dev/null; then
		# Wait for initial deployment (revision 1: nginx:1.24)
		kubectl rollout status deployment web-server -n citadel --timeout=60s 2>/dev/null

		# Create revision 2: nginx:1.25 (the working version to roll back to)
		if kubectl set image deployment/web-server web-server=nginx:1.25 -n citadel 2>/dev/null; then
			kubectl rollout status deployment web-server -n citadel --timeout=60s 2>/dev/null
			print_success "Q13: Created revision 2 (nginx:1.25)"
		else
			print_fail "Q13: Failed to create revision 2"
			((errors++))
		fi

		# Create revision 3: nginx:broken-oni (broken version — current state)
		if kubectl set image deployment/web-server web-server=nginx:broken-oni -n citadel 2>/dev/null; then
			print_success "Q13: Created broken revision 3 (nginx:broken-oni)"
		else
			print_fail "Q13: Failed to create broken revision 3"
			((errors++))
		fi
	else
		print_fail "Q13: Deployment web-server not found in citadel"
		((errors++))
	fi

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/13"
  mkdir -p "$BASE_DIR/14"
  cat << 'EOF_FILE' > "$BASE_DIR/14/broken-deploy.yaml"
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: legacy-app
  namespace: rampart
spec:
  replicas: 2
  rollbackTo:
    revision: 1
  template:
    metadata:
      labels:
        app: legacy-app
    spec:
      containers:
      - name: legacy-app
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/sidecar-pod.yaml"
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
  mkdir -p "$BASE_DIR/7/image"
  cat << 'EOF_FILE' > "$BASE_DIR/7/image/Dockerfile"
FROM nginx:1.25
# TODO: Complete this Dockerfile per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/7"
  return $errors
}
