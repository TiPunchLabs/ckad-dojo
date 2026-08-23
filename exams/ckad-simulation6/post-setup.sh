#!/bin/bash
# post-setup.sh - Exam-specific post-setup for ckad-simulation6

exam_post_setup() {
	local errors=0

	# Q7 - Create broken revision for rollback exercise
	if kubectl get deployment rollback-deploy -n cave &>/dev/null; then
		# Wait for deployment to be available
		kubectl rollout status deployment rollback-deploy -n cave --timeout=60s 2>/dev/null

		# Update with broken image to create revision 2
		if kubectl set image deployment/rollback-deploy nginx=nginx:1.91 -n cave --record=false 2>/dev/null; then
			print_success "Q7: Created broken deployment revision (nginx:1.91)"
		else
			print_fail "Q7: Failed to create broken revision"
			((errors++))
		fi
	fi

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"

  return $errors
}
