#!/bin/bash
# post-setup.sh - Exam-specific post-setup for ckad-simulation4

exam_post_setup() {
	local errors=0

	# Q9 - Create broken revision for rollback exercise
	if kubectl get deployment voyage-app -n njord &>/dev/null; then
		# Wait for deployment to be available
		kubectl rollout status deployment voyage-app -n njord --timeout=60s 2>/dev/null

		# Update with broken image to create revision 2
		if kubectl set image deployment/voyage-app voyage-container=nginx:broken-voyage -n njord --record=false 2>/dev/null; then
			print_success "Q9: Created broken deployment revision (nginx:broken-voyage)"
		else
			print_fail "Q9: Failed to create broken revision"
			((errors++))
		fi
	fi

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/9"
  cat << 'EOF_FILE' > "$BASE_DIR/9/rollback-revision.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/fix-ingress.yaml"
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
  mkdir -p "$BASE_DIR/5"
  cat << 'EOF_FILE' > "$BASE_DIR/5/my-app.tar"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/5/image"
  cat << 'EOF_FILE' > "$BASE_DIR/5/image/Dockerfile"
FROM nginx:latest
# TODO: Complete this Dockerfile per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/8"
  cat << 'EOF_FILE' > "$BASE_DIR/8/broken-deploy.yaml"
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
  mkdir -p "$BASE_DIR/5/image"

  return $errors
}
