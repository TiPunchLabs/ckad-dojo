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

	return $errors
}
