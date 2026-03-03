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

	return $errors
}
