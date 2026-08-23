#!/bin/bash
# post-setup.sh - Exam-specific post-setup for ckad-simulation9

exam_post_setup() {
	local errors=0

	# Q4 - Create Helm release with revision 2 for rollback question
	if ! helm status rollback-app -n wave &>/dev/null; then
		helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
		helm repo update >/dev/null 2>&1

		# Install initial release (revision 1)
		if helm install rollback-app bitnami/nginx -n wave \
			--set replicaCount=1 \
			--set service.type=ClusterIP \
			--wait --timeout 120s >/dev/null 2>&1; then
			# Upgrade to revision 2
			if helm upgrade rollback-app bitnami/nginx -n wave \
				--set replicaCount=2 \
				--set service.type=ClusterIP \
				--wait --timeout 120s >/dev/null 2>&1; then
				print_success "Q4: Created Helm release rollback-app with 2 revisions"
			else
				print_fail "Q4: Failed to upgrade rollback-app to revision 2"
				((errors++))
			fi
		else
			print_fail "Q4: Failed to install rollback-app"
			((errors++))
		fi
	else
		print_skip "Q4: rollback-app already exists"
	fi

	# Q16 - Create multiple revisions for web-deploy
	if kubectl get deployment web-deploy -n tide &>/dev/null; then
		kubectl set image deployment/web-deploy nginx=nginx:1.19 -n tide --record >/dev/null 2>&1
		kubectl rollout status deployment/web-deploy -n tide --timeout=60s >/dev/null 2>&1
		kubectl set image deployment/web-deploy nginx=nginx:1.20 -n tide --record >/dev/null 2>&1
		kubectl rollout status deployment/web-deploy -n tide --timeout=60s >/dev/null 2>&1
		print_success "Q16: Created deployment revisions for web-deploy"
	fi

	# Q17 - Create revision 3 for history-deploy
	if kubectl get deployment history-deploy -n wave &>/dev/null; then
		kubectl set image deployment/history-deploy nginx=nginx:1.19 -n wave --record >/dev/null 2>&1
		kubectl rollout status deployment/history-deploy -n wave --timeout=60s >/dev/null 2>&1
		kubectl set image deployment/history-deploy nginx=nginx:1.20 -n wave --record >/dev/null 2>&1
		kubectl rollout status deployment/history-deploy -n wave --timeout=60s >/dev/null 2>&1
		print_success "Q17: Created deployment revisions for history-deploy"
	fi

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1"
  touch "$BASE_DIR/1/.gitkeep"
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/pod.yaml"
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
  mkdir -p "$BASE_DIR/11"
  cat << 'EOF_FILE' > "$BASE_DIR/11/events.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12"
  cat << 'EOF_FILE' > "$BASE_DIR/12/hostname.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/13"
  cat << 'EOF_FILE' > "$BASE_DIR/13/previous.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/14"
  cat << 'EOF_FILE' > "$BASE_DIR/14/nodes.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/config.env"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/17"
  cat << 'EOF_FILE' > "$BASE_DIR/17/revision.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/top-pods.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  return $errors
}
