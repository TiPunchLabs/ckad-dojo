#!/bin/bash
# scoring-functions.sh - CKAD Simulation 11 Scoring Functions
# Dojo Amaterasu (Sun/Light theme) - 20 questions, 104 points total
# Covers CKAD curriculum: container builds, Deployments with labels/annotations,
# sidecar containers, PVC, Blue/Green, Kustomize, startup probes, CRDs,
# TLS/docker-registry secrets, SecurityContext hardening, RBAC, NetworkPolicy ipBlock, Ingress TLS

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# ============================================================================
# Q1: Build Container Image and Save as Tarball (6 points)
# ============================================================================
score_q1() {
	local score=0
	local max_points=6
	local details=""

	# Check image exists
	local image_exists
	image_exists=$(docker images solar-app:1.0 --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "solar-app:1.0" && echo true || echo false)
	if [[ "$image_exists" == "true" ]]; then
		((score += 3))
		details+="Image solar-app:1.0 exists. "
	else
		details+="Image solar-app:1.0 not found. "
	fi

	# Check tarball exists
	if [[ -f "$EXAM_DIR/1/solar-app.tar" ]]; then
		((score += 3))
		details+="Tarball exists at exam/course/1/solar-app.tar."
	else
		details+="Tarball not found at exam/course/1/solar-app.tar."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q2: Create Deployment with Labels and Annotations (4 points)
# ============================================================================
score_q2() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "deployment" "frontend-app" "solar"; then
		((score++))
		details+="Deployment frontend-app exists. "

		# Check replicas
		local replicas
		replicas=$(kubectl get deploy frontend-app -n solar -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "3" ]]; then
			((score++))
			details+="Replicas is 3. "
		else
			details+="Replicas is $replicas (expected: 3). "
		fi

		# Check pod labels
		local app_label
		app_label=$(kubectl get deploy frontend-app -n solar -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
		local tier_label
		tier_label=$(kubectl get deploy frontend-app -n solar -o jsonpath='{.spec.template.metadata.labels.tier}' 2>/dev/null)
		if [[ "$app_label" == "frontend" ]] && [[ "$tier_label" == "web" ]]; then
			((score++))
			details+="Pod labels correct (app=frontend, tier=web). "
		else
			details+="Pod labels incorrect (app=$app_label, tier=$tier_label). "
		fi

		# Check annotation
		local annotation
		annotation=$(kubectl get deploy frontend-app -n solar -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null)
		if [[ "$annotation" == "initial deployment" ]]; then
			((score++))
			details+="Annotation kubernetes.io/change-cause correct."
		else
			details+="Annotation kubernetes.io/change-cause is '${annotation:-missing}'."
		fi
	else
		details+="Deployment frontend-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q3: Sidecar Container with Shared Volume (6 points)
# ============================================================================
score_q3() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "web-with-sidecar" "corona"; then
		((score++))
		details+="Pod web-with-sidecar exists. "

		# Check container count
		local container_count
		container_count=$(kubectl get pod web-with-sidecar -n corona -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 2))
			details+="Pod has $container_count containers. "
		else
			details+="Pod has $container_count containers (expected: 2). "
		fi

		# Check emptyDir volume exists
		local volumes
		volumes=$(kubectl get pod web-with-sidecar -n corona -o jsonpath='{.spec.volumes}' 2>/dev/null)
		if [[ "$volumes" == *"emptyDir"* ]]; then
			((score++))
			details+="emptyDir volume configured. "
		else
			details+="emptyDir volume missing. "
		fi

		# Check both containers mount the volume
		local mount_count
		mount_count=$(kubectl get pod web-with-sidecar -n corona -o jsonpath='{range .spec.containers[*]}{.volumeMounts}{"\n"}{end}' 2>/dev/null | grep -c "log-volume\|/var/log/nginx")
		if [[ "$mount_count" -ge 2 ]]; then
			((score += 2))
			details+="Both containers mount shared volume."
		else
			details+="Not all containers mount the shared volume ($mount_count/2)."
		fi
	else
		details+="Pod web-with-sidecar not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q4: Create PVC and Mount in Pod (6 points)
# ============================================================================
score_q4() {
	local score=0
	local max_points=6
	local details=""

	# Check PVC exists
	if resource_exists "persistentvolumeclaim" "app-data-pvc" "aurora"; then
		((score++))
		details+="PVC app-data-pvc exists. "

		# Check access mode
		local access_mode
		access_mode=$(kubectl get pvc app-data-pvc -n aurora -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
		if [[ "$access_mode" == "ReadWriteOnce" ]]; then
			((score++))
			details+="Access mode is ReadWriteOnce. "
		else
			details+="Access mode is $access_mode (expected: ReadWriteOnce). "
		fi

		# Check storage request
		local storage
		storage=$(kubectl get pvc app-data-pvc -n aurora -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
		if [[ "$storage" == "500Mi" ]]; then
			((score++))
			details+="Storage request is 500Mi. "
		else
			details+="Storage request is $storage (expected: 500Mi). "
		fi
	else
		details+="PVC app-data-pvc not found. "
	fi

	# Check Pod exists and uses PVC
	if resource_exists "pod" "data-pod" "aurora"; then
		((score++))
		details+="Pod data-pod exists. "

		# Check PVC is mounted
		local claim_name
		claim_name=$(kubectl get pod data-pod -n aurora -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}' 2>/dev/null)
		if [[ "$claim_name" == "app-data-pvc" ]]; then
			((score++))
			details+="Pod uses PVC app-data-pvc. "
		else
			details+="Pod does not use PVC app-data-pvc (found: ${claim_name:-none}). "
		fi

		# Check mount path
		local mount_path
		mount_path=$(kubectl get pod data-pod -n aurora -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		mount_path="${mount_path%/}"
		if [[ "$mount_path" == "/usr/share/nginx/html" ]]; then
			((score++))
			details+="Volume mounted at /usr/share/nginx/html."
		else
			details+="Mount path is $mount_path (expected: /usr/share/nginx/html)."
		fi
	else
		details+="Pod data-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q5: Blue/Green Deployment (8 points)
# ============================================================================
score_q5() {
	local score=0
	local max_points=8
	local details=""

	# Check green deployment exists
	if resource_exists "deployment" "app-green" "flare"; then
		((score++))
		details+="Deployment app-green exists. "

		# Check green replicas
		local green_replicas
		green_replicas=$(kubectl get deploy app-green -n flare -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$green_replicas" == "3" ]]; then
			((score++))
			details+="Green has 3 replicas. "
		else
			details+="Green has $green_replicas replicas (expected: 3). "
		fi

		# Check green labels
		local green_app
		green_app=$(kubectl get deploy app-green -n flare -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
		local green_version
		green_version=$(kubectl get deploy app-green -n flare -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
		if [[ "$green_app" == "webapp" ]] && [[ "$green_version" == "green" ]]; then
			((score += 2))
			details+="Green labels correct (app=webapp, version=green). "
		else
			details+="Green labels incorrect (app=$green_app, version=$green_version). "
		fi
	else
		details+="Deployment app-green not found. "
	fi

	# Check service points to green
	local svc_version
	svc_version=$(kubectl get svc webapp-svc -n flare -o jsonpath='{.spec.selector.version}' 2>/dev/null)
	if [[ "$svc_version" == "green" ]]; then
		((score += 2))
		details+="Service selector is version=green. "
	else
		details+="Service selector version is $svc_version (expected: green). "
	fi

	# Check blue scaled to 0
	local blue_replicas
	blue_replicas=$(kubectl get deploy app-blue -n flare -o jsonpath='{.spec.replicas}' 2>/dev/null)
	if [[ "$blue_replicas" == "0" ]]; then
		((score += 2))
		details+="Blue scaled to 0 replicas."
	else
		details+="Blue has $blue_replicas replicas (expected: 0)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q6: Configure Rolling Update Strategy (6 points)
# ============================================================================
score_q6() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "deployment" "api-app" "dawn"; then
		# Check strategy type
		local strategy
		strategy=$(kubectl get deploy api-app -n dawn -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
		if [[ "$strategy" == "RollingUpdate" ]]; then
			((score++))
			details+="Strategy type is RollingUpdate. "
		else
			details+="Strategy type is $strategy (expected: RollingUpdate). "
		fi

		# Check maxSurge
		local max_surge
		max_surge=$(kubectl get deploy api-app -n dawn -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
		if [[ "$max_surge" == "1" ]]; then
			((score += 2))
			details+="maxSurge is 1. "
		else
			details+="maxSurge is $max_surge (expected: 1). "
		fi

		# Check maxUnavailable
		local max_unavail
		max_unavail=$(kubectl get deploy api-app -n dawn -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
		if [[ "$max_unavail" == "0" ]]; then
			((score += 2))
			details+="maxUnavailable is 0. "
		else
			details+="maxUnavailable is $max_unavail (expected: 0). "
		fi

		# Check image updated
		local image
		image=$(kubectl get deploy api-app -n dawn -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == "nginx:1.26" ]]; then
			((score++))
			details+="Image updated to nginx:1.26."
		else
			details+="Image is $image (expected: nginx:1.26)."
		fi
	else
		details+="Deployment api-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q7: Deploy with Kustomize (6 points)
# ============================================================================
score_q7() {
	local score=0
	local max_points=6
	local details=""

	# Check Deployment with namePrefix exists
	if resource_exists "deployment" "prod-web-app" "zenith"; then
		((score += 2))
		details+="Deployment prod-web-app exists. "

		# Check replicas
		local replicas
		replicas=$(kubectl get deploy prod-web-app -n zenith -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "3" ]]; then
			((score += 2))
			details+="Replicas is 3. "
		else
			details+="Replicas is $replicas (expected: 3). "
		fi
	else
		details+="Deployment prod-web-app not found. "
	fi

	# Check Service with namePrefix exists
	if resource_exists "service" "prod-web-svc" "zenith"; then
		((score += 2))
		details+="Service prod-web-svc exists."
	else
		details+="Service prod-web-svc not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q8: Helm Upgrade with Custom Values (4 points)
# ============================================================================
score_q8() {
	local score=0
	local max_points=4
	local details=""

	# Check release exists
	local release_info
	release_info=$(helm list -n radiance -f web-release -o json 2>/dev/null | grep -o '"name":"web-release"' || true)
	if [[ -n "$release_info" ]]; then
		((score++))
		details+="Release web-release exists. "

		# Check revision >= 2
		local revision
		revision=$(helm history web-release -n radiance --max 1 -o json 2>/dev/null | grep -o '"revision":[0-9]*' | head -1 | grep -o '[0-9]*')
		if [[ -n "$revision" ]] && [[ "$revision" -ge 2 ]]; then
			((score += 2))
			details+="Revision is $revision (>= 2). "
		else
			details+="Revision is ${revision:-unknown} (expected: >= 2). "
		fi

		# Check replica count via deployment
		local replicas
		replicas=$(kubectl get deploy -n radiance -l app.kubernetes.io/instance=web-release -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "3" ]]; then
			((score++))
			details+="Replicas is 3."
		else
			details+="Replicas is ${replicas:-unknown} (expected: 3)."
		fi
	else
		details+="Release web-release not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q9: Add Startup Probe (4 points)
# ============================================================================
score_q9() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "deployment" "slow-app" "eclipse"; then
		((score++))
		details+="Deployment slow-app exists. "

		# Check startup probe path
		local probe_path
		probe_path=$(kubectl get deploy slow-app -n eclipse -o jsonpath='{.spec.template.spec.containers[0].startupProbe.httpGet.path}' 2>/dev/null)
		if [[ "$probe_path" == "/healthz" ]]; then
			((score++))
			details+="Startup probe path is /healthz. "
		else
			details+="Startup probe path is ${probe_path:-missing} (expected: /healthz). "
		fi

		# Check startup probe port
		local probe_port
		probe_port=$(kubectl get deploy slow-app -n eclipse -o jsonpath='{.spec.template.spec.containers[0].startupProbe.httpGet.port}' 2>/dev/null)
		if [[ "$probe_port" == "8080" ]]; then
			((score++))
			details+="Startup probe port is 8080. "
		else
			details+="Startup probe port is ${probe_port:-missing} (expected: 8080). "
		fi

		# Check failureThreshold
		local failure_threshold
		failure_threshold=$(kubectl get deploy slow-app -n eclipse -o jsonpath='{.spec.template.spec.containers[0].startupProbe.failureThreshold}' 2>/dev/null)
		if [[ "$failure_threshold" == "30" ]]; then
			((score++))
			details+="failureThreshold is 30."
		else
			details+="failureThreshold is ${failure_threshold:-missing} (expected: 30)."
		fi
	else
		details+="Deployment slow-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q10: Troubleshoot Pending Pod (6 points)
# ============================================================================
score_q10() {
	local score=0
	local max_points=6
	local details=""

	# Check reason file exists with correct content
	if [[ -f "$EXAM_DIR/10/pending-reason.txt" ]]; then
		local reason
		reason=$(cat "$EXAM_DIR/10/pending-reason.txt" 2>/dev/null | tr -d '[:space:]')
		if [[ "$reason" == "disktype" ]]; then
			((score += 2))
			details+="Reason file correct (disktype). "
		else
			details+="Reason file has '$reason' (expected: disktype). "
		fi
	else
		details+="File pending-reason.txt not found. "
	fi

	# Check Pod is Running
	local pod_status
	pod_status=$(kubectl get pod stuck-pod -n solar -o jsonpath='{.status.phase}' 2>/dev/null)
	if [[ "$pod_status" == "Running" ]]; then
		((score += 4))
		details+="Pod stuck-pod is Running."
	elif [[ "$pod_status" == "Pending" ]]; then
		details+="Pod stuck-pod still Pending."
	else
		details+="Pod stuck-pod status is ${pod_status:-not found}."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q11: Extract Logs from Multi-container Pod (4 points)
# ============================================================================
score_q11() {
	local score=0
	local max_points=4
	local details=""

	# Check log file exists
	if [[ -f "$EXAM_DIR/11/sidecar-logs.txt" ]]; then
		((score += 2))
		details+="File sidecar-logs.txt exists. "

		# Check file has content (sidecar logs)
		local line_count
		line_count=$(wc -l <"$EXAM_DIR/11/sidecar-logs.txt" 2>/dev/null)
		if [[ "$line_count" -gt 0 ]]; then
			local has_sidecar
			has_sidecar=$(grep -c "sidecar" "$EXAM_DIR/11/sidecar-logs.txt" 2>/dev/null || true)
			if [[ "$has_sidecar" -gt 0 ]]; then
				((score += 2))
				details+="File contains sidecar logs ($line_count lines)."
			else
				details+="File has content but no sidecar logs."
			fi
		else
			details+="File is empty."
		fi
	else
		details+="File sidecar-logs.txt not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q12: Discover and Use Custom Resource Definition (6 points)
# ============================================================================
score_q12() {
	local score=0
	local max_points=6
	local details=""

	# Check CRD group file
	if [[ -f "$EXAM_DIR/12/crd-group.txt" ]]; then
		local group
		group=$(cat "$EXAM_DIR/12/crd-group.txt" 2>/dev/null | tr -d '[:space:]')
		if [[ "$group" == "ckad.example.com" ]]; then
			((score += 2))
			details+="CRD group correct (ckad.example.com). "
		else
			details+="CRD group is '$group' (expected: ckad.example.com). "
		fi
	else
		details+="File crd-group.txt not found. "
	fi

	# Check Backup CR exists
	if kubectl get backup daily-backup -n aurora &>/dev/null; then
		((score += 2))
		details+="Backup daily-backup exists. "

		# Check spec fields
		local schedule
		schedule=$(kubectl get backup daily-backup -n aurora -o jsonpath='{.spec.schedule}' 2>/dev/null)
		local retention
		retention=$(kubectl get backup daily-backup -n aurora -o jsonpath='{.spec.retentionDays}' 2>/dev/null)
		if [[ "$schedule" == "0 2 * * *" ]] && [[ "$retention" == "30" ]]; then
			((score += 2))
			details+="Spec fields correct (schedule, retentionDays)."
		else
			details+="Spec fields incorrect (schedule=$schedule, retentionDays=$retention)."
		fi
	else
		details+="Backup daily-backup not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q13: Create TLS Secret (4 points)
# ============================================================================
score_q13() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "secret" "web-tls" "flare"; then
		((score++))
		details+="Secret web-tls exists. "

		# Check type is TLS
		local secret_type
		secret_type=$(kubectl get secret web-tls -n flare -o jsonpath='{.type}' 2>/dev/null)
		if [[ "$secret_type" == "kubernetes.io/tls" ]]; then
			((score++))
			details+="Type is kubernetes.io/tls. "
		else
			details+="Type is $secret_type (expected: kubernetes.io/tls). "
		fi

		# Check has tls.crt
		local has_crt
		has_crt=$(kubectl get secret web-tls -n flare -o jsonpath='{.data.tls\.crt}' 2>/dev/null)
		if [[ -n "$has_crt" ]]; then
			((score++))
			details+="Has tls.crt key. "
		else
			details+="Missing tls.crt key. "
		fi

		# Check has tls.key
		local has_key
		has_key=$(kubectl get secret web-tls -n flare -o jsonpath='{.data.tls\.key}' 2>/dev/null)
		if [[ -n "$has_key" ]]; then
			((score++))
			details+="Has tls.key key."
		else
			details+="Missing tls.key key."
		fi
	else
		details+="Secret web-tls not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q14: Harden Deployment with SecurityContext (4 points)
# ============================================================================
score_q14() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "deployment" "hardened-app" "dawn"; then
		((score++))
		details+="Deployment hardened-app exists. "

		# Check runAsNonRoot at pod level
		local run_as_non_root
		run_as_non_root=$(kubectl get deploy hardened-app -n dawn -o jsonpath='{.spec.template.spec.securityContext.runAsNonRoot}' 2>/dev/null)
		if [[ "$run_as_non_root" == "true" ]]; then
			((score++))
			details+="runAsNonRoot is true. "
		else
			details+="runAsNonRoot is ${run_as_non_root:-missing} (expected: true). "
		fi

		# Check readOnlyRootFilesystem and drop ALL at container level
		local read_only
		read_only=$(kubectl get deploy hardened-app -n dawn -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
		local drop_caps
		drop_caps=$(kubectl get deploy hardened-app -n dawn -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.drop}' 2>/dev/null)
		if [[ "$read_only" == "true" ]] && [[ "$drop_caps" == *"ALL"* ]]; then
			((score++))
			details+="readOnlyRootFilesystem and drop ALL configured. "
		else
			details+="readOnlyRootFilesystem=${read_only:-missing}, drop=${drop_caps:-missing}. "
		fi

		# Check deployment is running
		local available
		available=$(kubectl get deploy hardened-app -n dawn -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
		if [[ -n "$available" ]] && [[ "$available" -ge 1 ]]; then
			((score++))
			details+="Deployment has available replicas."
		else
			details+="Deployment has no available replicas."
		fi
	else
		details+="Deployment hardened-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q15: ServiceAccount with RBAC and Verification (6 points)
# ============================================================================
score_q15() {
	local score=0
	local max_points=6
	local details=""

	# Check ServiceAccount exists
	if resource_exists "serviceaccount" "deploy-sa" "zenith"; then
		((score++))
		details+="ServiceAccount deploy-sa exists. "
	else
		details+="ServiceAccount deploy-sa not found. "
	fi

	# Check Role exists
	if resource_exists "role" "deploy-role" "zenith"; then
		((score++))
		details+="Role deploy-role exists. "

		# Check Role grants correct verbs on deployments
		local role_yaml
		role_yaml=$(kubectl get role deploy-role -n zenith -o yaml 2>/dev/null)
		if echo "$role_yaml" | grep -q "deployments" && echo "$role_yaml" | grep -q "list" && echo "$role_yaml" | grep -q "create"; then
			((score++))
			details+="Role grants correct verbs on deployments. "
		else
			details+="Role verbs or resources incorrect. "
		fi
	else
		details+="Role deploy-role not found. "
	fi

	# Check RoleBinding exists
	if resource_exists "rolebinding" "deploy-rb" "zenith"; then
		((score++))
		details+="RoleBinding deploy-rb exists. "
	else
		details+="RoleBinding deploy-rb not found. "
	fi

	# Check auth-check.txt file
	if [[ -f "$EXAM_DIR/15/auth-check.txt" ]]; then
		local auth_result
		auth_result=$(cat "$EXAM_DIR/15/auth-check.txt" 2>/dev/null | tr -d '[:space:]')
		if [[ "$auth_result" == "yes" ]]; then
			((score += 2))
			details+="auth-check.txt contains 'yes'."
		else
			details+="auth-check.txt contains '$auth_result' (expected: yes)."
		fi
	else
		details+="File auth-check.txt not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q16: ConfigMap from env-file (4 points)
# ============================================================================
score_q16() {
	local score=0
	local max_points=4
	local details=""

	# Check ConfigMap exists
	if resource_exists "configmap" "app-config" "eclipse"; then
		((score++))
		details+="ConfigMap app-config exists. "

		# Check has expected keys
		local has_app_name
		has_app_name=$(kubectl get configmap app-config -n eclipse -o jsonpath='{.data.APP_NAME}' 2>/dev/null)
		if [[ -n "$has_app_name" ]]; then
			((score++))
			details+="ConfigMap has APP_NAME key. "
		else
			details+="ConfigMap missing APP_NAME key. "
		fi
	else
		details+="ConfigMap app-config not found. "
	fi

	# Check Pod exists and uses envFrom
	if resource_exists "pod" "config-pod" "eclipse"; then
		((score++))
		details+="Pod config-pod exists. "

		local env_from
		env_from=$(kubectl get pod config-pod -n eclipse -o jsonpath='{.spec.containers[0].envFrom}' 2>/dev/null)
		if [[ "$env_from" == *"app-config"* ]]; then
			((score++))
			details+="Pod uses envFrom with app-config."
		else
			details+="Pod does not use envFrom with app-config."
		fi
	else
		details+="Pod config-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q17: Create docker-registry Secret (4 points)
# ============================================================================
score_q17() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "secret" "registry-creds" "radiance"; then
		((score++))
		details+="Secret registry-creds exists. "

		# Check type
		local secret_type
		secret_type=$(kubectl get secret registry-creds -n radiance -o jsonpath='{.type}' 2>/dev/null)
		if [[ "$secret_type" == "kubernetes.io/dockerconfigjson" ]]; then
			((score++))
			details+="Type is kubernetes.io/dockerconfigjson. "
		else
			details+="Type is $secret_type (expected: kubernetes.io/dockerconfigjson). "
		fi

		# Check server in dockerconfigjson
		local docker_config
		docker_config=$(kubectl get secret registry-creds -n radiance -o jsonpath='{.data.\.dockerconfigjson}' 2>/dev/null | base64 -d 2>/dev/null)
		if [[ "$docker_config" == *"registry.example.com"* ]]; then
			((score++))
			details+="Server is registry.example.com. "
		else
			details+="Server not found in config. "
		fi

		# Check username
		if [[ "$docker_config" == *"admin"* ]]; then
			((score++))
			details+="Username is admin."
		else
			details+="Username not found."
		fi
	else
		details+="Secret registry-creds not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q18: NetworkPolicy with ipBlock (6 points)
# ============================================================================
score_q18() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "networkpolicy" "api-allow" "sunbeam"; then
		((score++))
		details+="NetworkPolicy api-allow exists. "

		# Check podSelector targets app=api
		local pod_selector
		pod_selector=$(kubectl get networkpolicy api-allow -n sunbeam -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
		if [[ "$pod_selector" == "api" ]]; then
			((score++))
			details+="podSelector targets app=api. "
		else
			details+="podSelector targets app=$pod_selector (expected: api). "
		fi

		# Check has podSelector ingress rule (role=frontend)
		local np_yaml
		np_yaml=$(kubectl get networkpolicy api-allow -n sunbeam -o yaml 2>/dev/null)
		if echo "$np_yaml" | grep -q "role: frontend"; then
			((score += 2))
			details+="Has podSelector rule for role=frontend. "
		else
			details+="Missing podSelector rule for role=frontend. "
		fi

		# Check has ipBlock rule
		if echo "$np_yaml" | grep -q "ipBlock"; then
			local cidr
			cidr=$(kubectl get networkpolicy api-allow -n sunbeam -o jsonpath='{.spec.ingress[0].from[*].ipBlock.cidr}' 2>/dev/null)
			if [[ "$cidr" == *"10.0.0.0/24"* ]]; then
				((score += 2))
				details+="Has ipBlock rule for 10.0.0.0/24."
			else
				details+="ipBlock CIDR is $cidr (expected: 10.0.0.0/24)."
			fi
		else
			details+="Missing ipBlock rule."
		fi
	else
		details+="NetworkPolicy api-allow not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q19: Ingress with TLS Termination (6 points)
# ============================================================================
score_q19() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "ingress" "secure-ingress" "solstice"; then
		((score++))
		details+="Ingress secure-ingress exists. "

		# Check TLS configured
		local tls_secret
		tls_secret=$(kubectl get ingress secure-ingress -n solstice -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)
		local tls_host
		tls_host=$(kubectl get ingress secure-ingress -n solstice -o jsonpath='{.spec.tls[0].hosts[0]}' 2>/dev/null)
		if [[ "$tls_secret" == "secure-tls" ]] && [[ "$tls_host" == "secure.example.com" ]]; then
			((score += 2))
			details+="TLS configured with secure-tls for secure.example.com. "
		else
			details+="TLS config incorrect (secret=$tls_secret, host=$tls_host). "
		fi

		# Check host rule
		local rule_host
		rule_host=$(kubectl get ingress secure-ingress -n solstice -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
		if [[ "$rule_host" == "secure.example.com" ]]; then
			((score++))
			details+="Rule host is secure.example.com. "
		else
			details+="Rule host is $rule_host (expected: secure.example.com). "
		fi

		# Check backend
		local backend_svc
		backend_svc=$(kubectl get ingress secure-ingress -n solstice -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
		local backend_port
		backend_port=$(kubectl get ingress secure-ingress -n solstice -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
		if [[ "$backend_svc" == "secure-svc" ]] && [[ "$backend_port" == "443" ]]; then
			((score += 2))
			details+="Backend is secure-svc:443."
		else
			details+="Backend is ${backend_svc:-missing}:${backend_port:-missing} (expected: secure-svc:443)."
		fi
	else
		details+="Ingress secure-ingress not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# Q20: Fix Service and Verify DNS Resolution (4 points)
# ============================================================================
score_q20() {
	local score=0
	local max_points=4
	local details=""

	# Check Service selector is correct
	local svc_selector
	svc_selector=$(kubectl get svc dns-svc -n sunbeam -o jsonpath='{.spec.selector.app}' 2>/dev/null)
	if [[ "$svc_selector" == "dns-app" ]]; then
		((score++))
		details+="Service selector is app=dns-app. "
	else
		details+="Service selector is app=$svc_selector (expected: dns-app). "
	fi

	# Check Service has endpoints
	local endpoints
	endpoints=$(kubectl get endpoints dns-svc -n sunbeam -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
	if [[ -n "$endpoints" ]]; then
		((score++))
		details+="Service has endpoints. "
	else
		details+="Service has no endpoints. "
	fi

	# Check DNS output file exists with content
	if [[ -f "$EXAM_DIR/20/dns-output.txt" ]]; then
		((score++))
		details+="File dns-output.txt exists. "

		local has_address
		has_address=$(grep -ciE "address|name" "$EXAM_DIR/20/dns-output.txt" 2>/dev/null || true)
		if [[ "$has_address" -gt 0 ]]; then
			((score++))
			details+="File contains DNS resolution output."
		else
			details+="File does not contain DNS output."
		fi
	else
		details+="File dns-output.txt not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
