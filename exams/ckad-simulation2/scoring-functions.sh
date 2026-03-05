#!/bin/bash
# scoring-functions.sh - Scoring functions for CKAD Simulation 2 (Dojo Byakko 🐯)
# 20 original questions - 105 points total
# Each function outputs EXACTLY: N/N then DETAILS:description

# Source common utilities from scripts/lib
CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

# Exam directory for student answers
EXAM_DIR="${EXAM_DIR:-./exam/course}"

# ============================================================================
# QUESTION 1 - Pod with Anti-Affinity (6 points)
# ============================================================================
score_q1() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "titan-alpha" "zeus"; then
		((score += 2))
		details+="Pod titan-alpha exists. "

		# Check label
		local label
		label=$(kubectl get pod titan-alpha -n zeus -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
		if [[ "$label" == "titan" ]]; then
			((score += 1))
			details+="Label app=titan correct. "
		else
			details+="Label app=titan missing. "
		fi

		# Check image
		local image
		image=$(kubectl get pod titan-alpha -n zeus -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == "nginx:1.21" ]]; then
			((score += 1))
			details+="Image nginx:1.21 correct. "
		else
			details+="Image incorrect ($image). "
		fi

		# Check anti-affinity
		local anti_affinity
		anti_affinity=$(kubectl get pod titan-alpha -n zeus -o jsonpath='{.spec.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution}' 2>/dev/null)
		if [[ -n "$anti_affinity" ]]; then
			((score += 2))
			details+="Pod anti-affinity configured."
		else
			details+="Pod anti-affinity missing."
		fi
	else
		details+="Pod titan-alpha not found in zeus."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 2 - ConfigMap from Multiple Sources (5 points)
# ============================================================================
score_q2() {
	local score=0
	local max_points=5
	local details=""

	# Check ConfigMap
	if resource_exists "configmap" "app-config" "athena"; then
		((score += 1))
		details+="ConfigMap app-config exists. "

		local log_level
		log_level=$(kubectl get configmap app-config -n athena -o jsonpath='{.data.LOG_LEVEL}' 2>/dev/null)
		if [[ "$log_level" == "debug" ]]; then
			((score += 1))
			details+="LOG_LEVEL=debug correct. "
		else
			details+="LOG_LEVEL incorrect. "
		fi

		local max_conn
		max_conn=$(kubectl get configmap app-config -n athena -o jsonpath='{.data.MAX_CONNECTIONS}' 2>/dev/null)
		if [[ "$max_conn" == "100" ]]; then
			((score += 1))
			details+="MAX_CONNECTIONS=100 correct. "
		else
			details+="MAX_CONNECTIONS incorrect. "
		fi
	else
		details+="ConfigMap app-config not found. "
	fi

	# Check Pod
	if resource_exists "pod" "config-reader" "athena"; then
		((score += 1))
		details+="Pod config-reader exists. "

		local mount_path
		mount_path=$(kubectl get pod config-reader -n athena -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		if [[ "$mount_path" == "/etc/config" ]]; then
			((score += 1))
			details+="ConfigMap mounted at /etc/config."
		else
			details+="Mount path incorrect ($mount_path)."
		fi
	else
		details+="Pod config-reader not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 3 - ExternalName Service (4 points)
# ============================================================================
score_q3() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "service" "external-api" "hermes"; then
		((score += 2))
		details+="Service external-api exists. "

		local svc_type
		svc_type=$(kubectl get svc external-api -n hermes -o jsonpath='{.spec.type}' 2>/dev/null)
		if [[ "$svc_type" == "ExternalName" ]]; then
			((score += 1))
			details+="Type is ExternalName. "
		else
			details+="Type is $svc_type (expected ExternalName). "
		fi

		local ext_name
		ext_name=$(kubectl get svc external-api -n hermes -o jsonpath='{.spec.externalName}' 2>/dev/null)
		if [[ "$ext_name" == "api.external-service.com" ]]; then
			((score += 1))
			details+="ExternalName correct."
		else
			details+="ExternalName incorrect ($ext_name)."
		fi
	else
		details+="Service external-api not found in hermes."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 4 - LimitRange Configuration (6 points)
# ============================================================================
score_q4() {
	local score=0
	local max_points=6
	local details=""

	# Check LimitRange
	if resource_exists "limitrange" "resource-limits" "apollo"; then
		((score += 2))
		details+="LimitRange resource-limits exists. "

		local default_cpu
		default_cpu=$(kubectl get limitrange resource-limits -n apollo -o jsonpath='{.spec.limits[0].default.cpu}' 2>/dev/null)
		if [[ "$default_cpu" == "500m" ]]; then
			((score += 1))
			details+="Default CPU limit 500m correct. "
		else
			details+="Default CPU limit incorrect ($default_cpu). "
		fi

		local default_mem
		default_mem=$(kubectl get limitrange resource-limits -n apollo -o jsonpath='{.spec.limits[0].default.memory}' 2>/dev/null)
		if [[ "$default_mem" == "256Mi" ]]; then
			((score += 1))
			details+="Default memory limit 256Mi correct. "
		else
			details+="Default memory limit incorrect ($default_mem). "
		fi
	else
		details+="LimitRange resource-limits not found. "
	fi

	# Check Pod
	if resource_exists "pod" "limited-pod" "apollo"; then
		((score += 2))
		details+="Pod limited-pod exists."
	else
		details+="Pod limited-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 5 - SecurityContext - Read-Only Root Filesystem (5 points)
# ============================================================================
score_q5() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "secure-app" "hades"; then
		((score += 1))
		details+="Pod secure-app exists. "

		# Check readOnlyRootFilesystem
		local readonly_fs
		readonly_fs=$(kubectl get pod secure-app -n hades -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
		if [[ "$readonly_fs" == "true" ]]; then
			((score += 2))
			details+="readOnlyRootFilesystem enabled. "
		else
			details+="readOnlyRootFilesystem not enabled. "
		fi

		# Check volumes mounted
		local volume_count
		volume_count=$(kubectl get pod secure-app -n hades -o jsonpath='{range .spec.volumes[?(@.emptyDir)]}{.name}{"\n"}{end}' 2>/dev/null | grep -c . || echo "0")
		if [[ "$volume_count" -ge 3 ]]; then
			((score += 2))
			details+="EmptyDir volumes mounted correctly."
		else
			details+="EmptyDir volumes missing or incomplete."
		fi
	else
		details+="Pod secure-app not found in hades."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 6 - Pod with Multiple Init Containers (6 points)
# ============================================================================
score_q6() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "multi-init" "poseidon"; then
		((score += 2))
		details+="Pod multi-init exists. "

		# Check init containers count
		local init_count
		init_count=$(kubectl get pod multi-init -n poseidon -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null | wc -w)
		if [[ "$init_count" -ge 2 ]]; then
			((score += 2))
			details+="Two init containers configured. "
		else
			details+="Init containers missing (found $init_count). "
		fi

		# Check main container
		local main_container
		main_container=$(kubectl get pod multi-init -n poseidon -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
		if [[ "$main_container" == "app" ]]; then
			((score += 1))
			details+="Main container 'app' exists. "
		else
			details+="Main container 'app' missing. "
		fi

		# Check volume
		local volume
		volume=$(kubectl get pod multi-init -n poseidon -o jsonpath='{.spec.volumes[0].name}' 2>/dev/null)
		if [[ "$volume" == "workdir" ]]; then
			((score += 1))
			details+="Shared volume 'workdir' exists."
		else
			details+="Shared volume 'workdir' missing."
		fi
	else
		details+="Pod multi-init not found in poseidon."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 7 - Deployment with Pause/Resume (5 points)
# ============================================================================
score_q7() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "battle-app" "ares"; then
		((score += 1))
		details+="Deployment battle-app exists. "

		# Check if rollout is paused
		local paused
		paused=$(kubectl get deployment battle-app -n ares -o jsonpath='{.spec.paused}' 2>/dev/null)
		if [[ "$paused" == "true" ]]; then
			((score += 2))
			details+="Rollout is paused. "
		else
			details+="Rollout is not paused. "
		fi

		# Check status file
		local status_file="$EXAM_DIR/7/rollout-status.txt"
		if [[ -f "$status_file" ]] && [[ -s "$status_file" ]]; then
			((score += 2))
			details+="Rollout status saved to file."
		else
			details+="Rollout status file missing or empty."
		fi
	else
		details+="Deployment battle-app not found in ares."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 8 - Ambassador Pattern - Sidecar Proxy (7 points)
# ============================================================================
score_q8() {
	local score=0
	local max_points=7
	local details=""

	if resource_exists "pod" "ambassador-pod" "olympus"; then
		((score += 2))
		details+="Pod ambassador-pod exists. "

		# Check container count
		local container_count
		container_count=$(kubectl get pod ambassador-pod -n olympus -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 2))
			details+="Two containers configured. "
		else
			details+="Expected 2 containers (found $container_count). "
		fi

		# Check app container
		local app_image
		app_image=$(kubectl get pod ambassador-pod -n olympus -o jsonpath='{.spec.containers[?(@.name=="app")].image}' 2>/dev/null)
		if [[ "$app_image" == "nginx:1.21" ]]; then
			((score += 1))
			details+="Container 'app' with nginx:1.21. "
		else
			details+="Container 'app' image incorrect. "
		fi

		# Check proxy container
		local proxy_image
		proxy_image=$(kubectl get pod ambassador-pod -n olympus -o jsonpath='{.spec.containers[?(@.name=="proxy")].image}' 2>/dev/null)
		if [[ "$proxy_image" == *"envoy"* ]]; then
			((score += 2))
			details+="Container 'proxy' with envoy image."
		else
			details+="Container 'proxy' missing or wrong image."
		fi
	else
		details+="Pod ambassador-pod not found in olympus."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 9 - Job with Backoff Limit (5 points)
# ============================================================================
score_q9() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "job" "retry-job" "artemis"; then
		((score += 2))
		details+="Job retry-job exists. "

		# Check backoffLimit
		local backoff
		backoff=$(kubectl get job retry-job -n artemis -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
		if [[ "$backoff" == "3" ]]; then
			((score += 2))
			details+="backoffLimit is 3. "
		else
			details+="backoffLimit incorrect ($backoff). "
		fi

		# Check restartPolicy
		local restart
		restart=$(kubectl get job retry-job -n artemis -o jsonpath='{.spec.template.spec.restartPolicy}' 2>/dev/null)
		if [[ "$restart" == "Never" ]]; then
			((score += 1))
			details+="restartPolicy is Never."
		else
			details+="restartPolicy incorrect ($restart)."
		fi
	else
		details+="Job retry-job not found in artemis."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 10 - Secret Types - Docker Registry (6 points)
# ============================================================================
score_q10() {
	local score=0
	local max_points=6
	local details=""

	# Check Secret
	if resource_exists "secret" "registry-creds" "hera"; then
		((score += 2))
		details+="Secret registry-creds exists. "

		local secret_type
		secret_type=$(kubectl get secret registry-creds -n hera -o jsonpath='{.type}' 2>/dev/null)
		if [[ "$secret_type" == "kubernetes.io/dockerconfigjson" ]]; then
			((score += 1))
			details+="Secret type is docker-registry. "
		else
			details+="Secret type incorrect ($secret_type). "
		fi
	else
		details+="Secret registry-creds not found. "
	fi

	# Check Pod
	if resource_exists "pod" "private-app" "hera"; then
		((score += 2))
		details+="Pod private-app exists. "

		local pull_secret
		pull_secret=$(kubectl get pod private-app -n hera -o jsonpath='{.spec.imagePullSecrets[0].name}' 2>/dev/null)
		if [[ "$pull_secret" == "registry-creds" ]]; then
			((score += 1))
			details+="imagePullSecret configured."
		else
			details+="imagePullSecret missing."
		fi
	else
		details+="Pod private-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 11 - Adapter Pattern - Log Transformer (6 points)
# ============================================================================
score_q11() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "adapter-pod" "zeus"; then
		((score += 2))
		details+="Pod adapter-pod exists. "

		# Check container count
		local container_count
		container_count=$(kubectl get pod adapter-pod -n zeus -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 2))
			details+="Two containers configured. "
		else
			details+="Expected 2 containers. "
		fi

		# Check shared volume
		local volume
		volume=$(kubectl get pod adapter-pod -n zeus -o jsonpath='{.spec.volumes[0].emptyDir}' 2>/dev/null)
		if [[ -n "$volume" ]]; then
			((score += 2))
			details+="Shared emptyDir volume exists."
		else
			details+="Shared volume missing."
		fi
	else
		details+="Pod adapter-pod not found in zeus."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 12 - Network Policy - Egress Rules (5 points)
# ============================================================================
score_q12() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "networkpolicy" "egress-policy" "athena"; then
		((score += 2))
		details+="NetworkPolicy egress-policy exists. "

		# Check policy type includes Egress
		local policy_types
		policy_types=$(kubectl get networkpolicy egress-policy -n athena -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
		if [[ "$policy_types" == *"Egress"* ]]; then
			((score += 2))
			details+="Egress policy type configured. "
		else
			details+="Egress policy type missing. "
		fi

		# Check pod selector
		local selector
		selector=$(kubectl get networkpolicy egress-policy -n athena -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
		if [[ "$selector" == "restricted" ]]; then
			((score += 1))
			details+="Pod selector app=restricted correct."
		else
			details+="Pod selector incorrect."
		fi
	else
		details+="NetworkPolicy egress-policy not found in athena."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 13 - RBAC - Service Account Permissions (6 points)
# ============================================================================
score_q13() {
	local score=0
	local max_points=6
	local details=""

	# Check ServiceAccount
	if resource_exists "serviceaccount" "deployment-manager" "hermes"; then
		((score += 2))
		details+="ServiceAccount deployment-manager exists. "
	else
		details+="ServiceAccount deployment-manager not found. "
	fi

	# Check Role
	if resource_exists "role" "deploy-role" "hermes"; then
		((score += 2))
		details+="Role deploy-role exists. "
	else
		details+="Role deploy-role not found. "
	fi

	# Check RoleBinding
	if resource_exists "rolebinding" "deploy-binding" "hermes"; then
		((score += 2))
		details+="RoleBinding deploy-binding exists."
	else
		details+="RoleBinding deploy-binding not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 14 - Deployment Rolling Update Strategy (5 points)
# ============================================================================
score_q14() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "rolling-app" "apollo"; then
		((score += 1))
		details+="Deployment rolling-app exists. "

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment rolling-app -n apollo -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "4" ]]; then
			((score += 1))
			details+="Replicas is 4. "
		else
			details+="Replicas incorrect ($replicas). "
		fi

		# Check strategy type
		local strategy
		strategy=$(kubectl get deployment rolling-app -n apollo -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
		if [[ "$strategy" == "RollingUpdate" ]]; then
			((score += 1))
			details+="Strategy is RollingUpdate. "
		else
			details+="Strategy incorrect ($strategy). "
		fi

		# Check maxSurge
		local max_surge
		max_surge=$(kubectl get deployment rolling-app -n apollo -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
		if [[ "$max_surge" == "25%" ]]; then
			((score += 1))
			details+="maxSurge is 25%. "
		else
			details+="maxSurge incorrect ($max_surge). "
		fi

		# Check version label
		local version
		version=$(kubectl get deployment rolling-app -n apollo -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
		if [[ "$version" == "v1" ]]; then
			((score += 1))
			details+="Label version=v1 correct."
		else
			details+="Label version missing."
		fi
	else
		details+="Deployment rolling-app not found in apollo."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 15 - Ingress with Path-Based Routing (6 points)
# ============================================================================
score_q15() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "ingress" "path-ingress" "poseidon"; then
		((score += 2))
		details+="Ingress path-ingress exists. "

		# Check /api path
		local api_path
		api_path=$(kubectl get ingress path-ingress -n poseidon -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/api")].backend.service.name}' 2>/dev/null)
		if [[ "$api_path" == "api-svc" ]]; then
			((score += 2))
			details+="/api routes to api-svc. "
		else
			details+="/api route incorrect. "
		fi

		# Check /web path
		local web_path
		web_path=$(kubectl get ingress path-ingress -n poseidon -o jsonpath='{.spec.rules[0].http.paths[?(@.path=="/web")].backend.service.name}' 2>/dev/null)
		if [[ "$web_path" == "web-svc" ]]; then
			((score += 2))
			details+="/web routes to web-svc."
		else
			details+="/web route incorrect."
		fi
	else
		details+="Ingress path-ingress not found in poseidon."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 16 - Pod with Token Projection (5 points)
# ============================================================================
score_q16() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "token-pod" "hades"; then
		((score += 2))
		details+="Pod token-pod exists. "

		# Check projected volume
		local projected
		projected=$(kubectl get pod token-pod -n hades -o jsonpath='{.spec.volumes[0].projected}' 2>/dev/null)
		if [[ -n "$projected" ]]; then
			((score += 2))
			details+="Projected volume configured. "
		else
			details+="Projected volume missing. "
		fi

		# Check mount path
		local mount_path
		mount_path=$(kubectl get pod token-pod -n hades -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		if [[ "$mount_path" == "/var/run/secrets/tokens" ]]; then
			((score += 1))
			details+="Mount path correct."
		else
			details+="Mount path incorrect ($mount_path)."
		fi
	else
		details+="Pod token-pod not found in hades."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 17 - CronJob with Concurrency Policy (5 points)
# ============================================================================
score_q17() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "cronjob" "scheduled-task" "ares"; then
		((score += 2))
		details+="CronJob scheduled-task exists. "

		# Check concurrency policy
		local policy
		policy=$(kubectl get cronjob scheduled-task -n ares -o jsonpath='{.spec.concurrencyPolicy}' 2>/dev/null)
		if [[ "$policy" == "Forbid" ]]; then
			((score += 1))
			details+="Concurrency policy is Forbid. "
		else
			details+="Concurrency policy incorrect ($policy). "
		fi

		# Check schedule
		local schedule
		schedule=$(kubectl get cronjob scheduled-task -n ares -o jsonpath='{.spec.schedule}' 2>/dev/null)
		if [[ "$schedule" == "*/5 * * * *" ]]; then
			((score += 1))
			details+="Schedule correct. "
		else
			details+="Schedule incorrect ($schedule). "
		fi

		# Check history limits
		local success_limit
		success_limit=$(kubectl get cronjob scheduled-task -n ares -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
		if [[ "$success_limit" == "3" ]]; then
			((score += 1))
			details+="History limits correct."
		else
			details+="History limits incorrect."
		fi
	else
		details+="CronJob scheduled-task not found in ares."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 18 - Pod Disruption Budget (4 points)
# ============================================================================
score_q18() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "pdb" "app-pdb" "hera"; then
		((score += 2))
		details+="PDB app-pdb exists. "

		# Check minAvailable
		local min_avail
		min_avail=$(kubectl get pdb app-pdb -n hera -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
		if [[ "$min_avail" == "2" ]]; then
			((score += 1))
			details+="minAvailable is 2. "
		else
			details+="minAvailable incorrect ($min_avail). "
		fi

		# Check selector
		local selector
		selector=$(kubectl get pdb app-pdb -n hera -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
		if [[ "$selector" == "critical" ]]; then
			((score += 1))
			details+="Selector app=critical correct."
		else
			details+="Selector incorrect."
		fi
	else
		details+="PDB app-pdb not found in hera."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 19 - Deployment with Annotations (4 points)
# ============================================================================
score_q19() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "deployment" "annotated-app" "olympus"; then
		((score += 1))
		details+="Deployment annotated-app exists. "

		# Check deployment annotation
		local deploy_annot
		deploy_annot=$(kubectl get deployment annotated-app -n olympus -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null)
		if [[ -n "$deploy_annot" ]]; then
			((score += 1))
			details+="Deployment annotation exists. "
		else
			details+="Deployment annotation missing. "
		fi

		# Check pod template annotation
		local pod_annot
		pod_annot=$(kubectl get deployment annotated-app -n olympus -o jsonpath='{.spec.template.metadata.annotations.prometheus\.io/scrape}' 2>/dev/null)
		if [[ "$pod_annot" == "true" ]]; then
			((score += 1))
			details+="Pod template annotation correct. "
		else
			details+="Pod template annotation missing. "
		fi

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment annotated-app -n olympus -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "2" ]]; then
			((score += 1))
			details+="Replicas is 2."
		else
			details+="Replicas incorrect."
		fi
	else
		details+="Deployment annotated-app not found in olympus."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# ============================================================================
# QUESTION 20 - Multi-Container Pod with Shared Process Namespace (5 points)
# ============================================================================
score_q20() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "shared-pid" "artemis"; then
		((score += 2))
		details+="Pod shared-pid exists. "

		# Check shareProcessNamespace
		local share_pid
		share_pid=$(kubectl get pod shared-pid -n artemis -o jsonpath='{.spec.shareProcessNamespace}' 2>/dev/null)
		if [[ "$share_pid" == "true" ]]; then
			((score += 1))
			details+="shareProcessNamespace enabled. "
		else
			details+="shareProcessNamespace not enabled. "
		fi

		# Check container count
		local container_count
		container_count=$(kubectl get pod shared-pid -n artemis -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 2))
			details+="Two containers configured."
		else
			details+="Expected 2 containers."
		fi
	else
		details+="Pod shared-pid not found in artemis."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
