#!/bin/bash
# scoring-functions.sh - CKAD Simulation 10 Scoring Functions
# Dojo Oni (Fortification theme) - 20 questions, 105 points total
# Inspired by real CKAD exam topics reported by candidates

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# Q1: Secrets & Environment Variables (5 points)
score_q1() {
	local score=0
	local max_points=5
	local details=""

	# Check Secret exists
	if resource_exists "secret" "db-credentials" "fortress"; then
		((score++))
		details+="Secret db-credentials exists. "

		# Check Secret has DB_USER key
		local db_user
		db_user=$(kubectl get secret db-credentials -n fortress -o jsonpath='{.data.DB_USER}' 2>/dev/null)
		if [[ -n "$db_user" ]]; then
			((score++))
			details+="Key DB_USER present. "
		else
			details+="Key DB_USER missing. "
		fi

		# Check Secret has DB_PASS key
		local db_pass
		db_pass=$(kubectl get secret db-credentials -n fortress -o jsonpath='{.data.DB_PASS}' 2>/dev/null)
		if [[ -n "$db_pass" ]]; then
			((score++))
			details+="Key DB_PASS present. "
		else
			details+="Key DB_PASS missing. "
		fi
	else
		details+="Secret db-credentials not found. "
	fi

	# Check Pod webapp uses secretKeyRef
	if resource_exists "pod" "webapp" "fortress"; then
		local env_source
		env_source=$(kubectl get pod webapp -n fortress -o jsonpath='{.spec.containers[0].env[*].valueFrom.secretKeyRef.name}' 2>/dev/null)
		if [[ "$env_source" == *"db-credentials"* ]]; then
			((score += 2))
			details+="Pod uses secretKeyRef for db-credentials."
		else
			details+="Pod does not use secretKeyRef for db-credentials."
		fi
	else
		details+="Pod webapp not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q2: Fix Broken Ingress (6 points)
score_q2() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "ingress" "frontend-ingress" "bastion"; then
		((score++))
		details+="Ingress frontend-ingress exists. "

		# Check host
		local host
		host=$(kubectl get ingress frontend-ingress -n bastion -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
		if [[ "$host" == "frontend.example.com" ]]; then
			((score++))
			details+="Host correct. "
		else
			details+="Host incorrect ($host, expected: frontend.example.com). "
		fi

		# Check service name
		local svc_name
		svc_name=$(kubectl get ingress frontend-ingress -n bastion -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
		if [[ "$svc_name" == "frontend-svc" ]]; then
			((score++))
			details+="Service name correct. "
		else
			details+="Service name incorrect ($svc_name, expected: frontend-svc). "
		fi

		# Check port
		local svc_port
		svc_port=$(kubectl get ingress frontend-ingress -n bastion -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
		if [[ "$svc_port" == "80" ]]; then
			((score++))
			details+="Port correct. "
		else
			details+="Port incorrect ($svc_port, expected: 80). "
		fi

		# Check pathType
		local path_type
		path_type=$(kubectl get ingress frontend-ingress -n bastion -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
		if [[ "$path_type" == "Prefix" ]]; then
			((score++))
			details+="PathType correct. "
		else
			details+="PathType incorrect ($path_type, expected: Prefix). "
		fi

		# Check path
		local path
		path=$(kubectl get ingress frontend-ingress -n bastion -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
		if [[ "$path" == "/" ]]; then
			((score++))
			details+="Path correct."
		else
			details+="Path incorrect ($path, expected: /)."
		fi
	else
		details+="Ingress frontend-ingress not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q3: Create New Ingress (5 points)
score_q3() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "ingress" "api-ingress" "citadel"; then
		((score++))
		details+="Ingress api-ingress exists. "

		# Check host
		local host
		host=$(kubectl get ingress api-ingress -n citadel -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
		if [[ "$host" == "api.example.com" ]]; then
			((score++))
			details+="Host correct. "
		else
			details+="Host incorrect ($host, expected: api.example.com). "
		fi

		# Check path
		local path
		path=$(kubectl get ingress api-ingress -n citadel -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
		if [[ "$path" == "/app" ]]; then
			((score++))
			details+="Path correct. "
		else
			details+="Path incorrect ($path, expected: /app). "
		fi

		# Check pathType
		local path_type
		path_type=$(kubectl get ingress api-ingress -n citadel -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
		if [[ "$path_type" == "Prefix" ]]; then
			((score++))
			details+="PathType correct. "
		else
			details+="PathType incorrect ($path_type, expected: Prefix). "
		fi

		# Check backend service and port
		local svc_name svc_port
		svc_name=$(kubectl get ingress api-ingress -n citadel -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
		svc_port=$(kubectl get ingress api-ingress -n citadel -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
		if [[ "$svc_name" == "api-svc" && "$svc_port" == "80" ]]; then
			((score++))
			details+="Backend service and port correct."
		else
			details+="Backend incorrect (name=$svc_name port=$svc_port, expected: api-svc:80)."
		fi
	else
		details+="Ingress api-ingress not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q4: NetworkPolicy Labels (6 points)
score_q4() {
	local score=0
	local max_points=6
	local details=""

	# Check frontend pod has tier=frontend
	if resource_exists "pod" "frontend" "rampart"; then
		local frontend_tier
		frontend_tier=$(kubectl get pod frontend -n rampart -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
		if [[ "$frontend_tier" == "frontend" ]]; then
			((score += 2))
			details+="Pod frontend has tier=frontend. "
		else
			details+="Pod frontend missing tier=frontend (has: $frontend_tier). "
		fi
	else
		details+="Pod frontend not found. "
	fi

	# Check backend pod has tier=backend
	if resource_exists "pod" "backend" "rampart"; then
		local backend_tier
		backend_tier=$(kubectl get pod backend -n rampart -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
		if [[ "$backend_tier" == "backend" ]]; then
			((score += 2))
			details+="Pod backend has tier=backend. "
		else
			details+="Pod backend missing tier=backend (has: $backend_tier). "
		fi
	else
		details+="Pod backend not found. "
	fi

	# Check database pod has tier=database
	if resource_exists "pod" "database" "rampart"; then
		local db_tier
		db_tier=$(kubectl get pod database -n rampart -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
		if [[ "$db_tier" == "database" ]]; then
			((score += 2))
			details+="Pod database has tier=database."
		else
			details+="Pod database missing tier=database (has: $db_tier)."
		fi
	else
		details+="Pod database not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q5: Resource Requests and Limits (5 points)
score_q5() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "compute-app" "tower"; then
		local req_cpu req_mem lim_cpu lim_mem
		req_cpu=$(kubectl get deployment compute-app -n tower -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
		req_mem=$(kubectl get deployment compute-app -n tower -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
		lim_cpu=$(kubectl get deployment compute-app -n tower -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
		lim_mem=$(kubectl get deployment compute-app -n tower -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)

		if [[ "$req_cpu" == "100m" ]]; then
			((score++))
			details+="Requests CPU correct (100m). "
		else
			details+="Requests CPU incorrect ($req_cpu, expected: 100m). "
		fi

		if [[ "$req_mem" == "128Mi" ]]; then
			((score++))
			details+="Requests memory correct (128Mi). "
		else
			details+="Requests memory incorrect ($req_mem, expected: 128Mi). "
		fi

		if [[ "$lim_cpu" == "200m" ]]; then
			((score++))
			details+="Limits CPU correct (200m). "
		else
			details+="Limits CPU incorrect ($lim_cpu, expected: 200m). "
		fi

		if [[ "$lim_mem" == "256Mi" ]]; then
			((score++))
			details+="Limits memory correct (256Mi). "
		else
			details+="Limits memory incorrect ($lim_mem, expected: 256Mi). "
		fi

		# Check pods are running
		local ready
		ready=$(kubectl get deployment compute-app -n tower -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [[ -n "$ready" && "$ready" -ge 1 ]]; then
			((score++))
			details+="Deployment has running pods."
		else
			details+="Deployment has no running pods."
		fi
	else
		details+="Deployment compute-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q6: Fix ResourceQuota Issue (5 points)
score_q6() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "quota-app" "garrison"; then
		((score++))
		details+="Deployment quota-app exists. "

		# Check pods are running (main success criteria)
		local ready
		ready=$(kubectl get deployment quota-app -n garrison -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [[ -n "$ready" && "$ready" -ge 1 ]]; then
			((score += 2))
			details+="Pods are running. "
		else
			details+="Pods are not running. "
		fi

		# Check resources fit within quota (requests.cpu <= 500m)
		local req_cpu
		req_cpu=$(kubectl get deployment quota-app -n garrison -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
		if [[ -n "$req_cpu" ]]; then
			# Convert to millicores for comparison
			local cpu_m
			if [[ "$req_cpu" == *"m" ]]; then
				cpu_m="${req_cpu%m}"
			else
				cpu_m=$((req_cpu * 1000))
			fi
			if [[ "$cpu_m" -le 500 ]]; then
				((score++))
				details+="CPU requests within quota ($req_cpu). "
			else
				details+="CPU requests exceed quota ($req_cpu). "
			fi
		else
			details+="No CPU requests set. "
		fi

		# Check resources fit within quota (requests.memory <= 512Mi)
		local req_mem
		req_mem=$(kubectl get deployment quota-app -n garrison -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
		if [[ "$req_mem" == "256Mi" || "$req_mem" == "512Mi" || "$req_mem" == "128Mi" || "$req_mem" == "384Mi" ]]; then
			((score++))
			details+="Memory requests within quota ($req_mem)."
		else
			details+="Memory requests may exceed quota ($req_mem)."
		fi
	else
		details+="Deployment quota-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q7: Docker Build & Save (5 points)
score_q7() {
	local score=0
	local max_points=5
	local details=""

	# Check image exists locally
	local image_exists
	image_exists=$(docker images -q "localhost:5000/oni-app:1.0" 2>/dev/null)
	if [[ -n "$image_exists" ]]; then
		((score += 2))
		details+="Image localhost:5000/oni-app:1.0 built. "
	else
		details+="Image localhost:5000/oni-app:1.0 not found. "
	fi

	# Check tar file exists
	if file_exists_and_not_empty "./exam/course/7/oni-app.tar"; then
		((score++))
		details+="Tar archive exists. "
	else
		details+="Tar archive not found at ./exam/course/7/oni-app.tar. "
	fi

	# Check image pushed to registry
	local registry_check
	registry_check=$(curl -s "http://localhost:5000/v2/oni-app/tags/list" 2>/dev/null)
	if [[ "$registry_check" == *"1.0"* ]]; then
		((score += 2))
		details+="Image pushed to registry."
	else
		details+="Image not found in registry."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q8: Canary Deployment (6 points)
score_q8() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "deployment" "canary-app" "bulwark"; then
		((score++))
		details+="Deployment canary-app exists. "

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment canary-app -n bulwark -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "1" ]]; then
			((score++))
			details+="Replicas correct (1). "
		else
			details+="Replicas incorrect ($replicas, expected: 1). "
		fi

		# Check image
		local image
		image=$(kubectl get deployment canary-app -n bulwark -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"nginx:1.25"* ]]; then
			((score++))
			details+="Image correct. "
		else
			details+="Image incorrect ($image, expected: nginx:1.25). "
		fi

		# Check version label
		local version_label
		version_label=$(kubectl get deployment canary-app -n bulwark -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
		if [[ "$version_label" == "v2" ]]; then
			((score++))
			details+="Label version=v2 correct. "
		else
			details+="Label version incorrect ($version_label, expected: v2). "
		fi

		# Check app label matches service selector
		local app_label
		app_label=$(kubectl get deployment canary-app -n bulwark -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
		if [[ "$app_label" == "webapp" ]]; then
			((score++))
			details+="Label app=webapp correct. "
		else
			details+="Label app incorrect ($app_label, expected: webapp). "
		fi

		# Check Service endpoints include canary pods
		local endpoints
		endpoints=$(kubectl get ep app-svc -n bulwark -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
		local stable_pods canary_pods
		stable_pods=$(kubectl get pods -n bulwark -l app=webapp,version=v1 --no-headers 2>/dev/null | wc -l)
		canary_pods=$(kubectl get pods -n bulwark -l app=webapp,version=v2 --no-headers 2>/dev/null | wc -l)
		if [[ "$canary_pods" -ge 1 && "$stable_pods" -ge 1 ]]; then
			((score++))
			details+="Service routes to both stable and canary."
		else
			details+="Service not routing to both versions (stable=$stable_pods, canary=$canary_pods)."
		fi
	else
		details+="Deployment canary-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q9: Fix Service Selector (4 points)
score_q9() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "service" "backend-svc" "parapet"; then
		((score++))
		details+="Service backend-svc exists. "

		# Check selector matches pods
		local selector
		selector=$(kubectl get svc backend-svc -n parapet -o jsonpath='{.spec.selector.app}' 2>/dev/null)
		if [[ "$selector" == "backend-api" ]]; then
			((score++))
			details+="Selector correct (app=backend-api). "
		else
			details+="Selector incorrect ($selector, expected: backend-api). "
		fi

		# Check endpoints exist
		local ep_count
		ep_count=$(kubectl get ep backend-svc -n parapet -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -c "ip" 2>/dev/null || echo "0")
		if [[ "$ep_count" -ge 1 ]]; then
			((score += 2))
			details+="Endpoints configured."
		else
			details+="No endpoints."
		fi
	else
		details+="Service backend-svc not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q10: CronJob with Proper Exit (5 points)
score_q10() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "cronjob" "cleanup-job" "stronghold"; then
		((score++))
		details+="CronJob cleanup-job exists. "

		# Check schedule
		local schedule
		schedule=$(kubectl get cronjob cleanup-job -n stronghold -o jsonpath='{.spec.schedule}' 2>/dev/null)
		if [[ "$schedule" == "*/5 * * * *" ]]; then
			((score++))
			details+="Schedule correct. "
		else
			details+="Schedule incorrect ($schedule, expected: */5 * * * *). "
		fi

		# Check image
		local image
		image=$(kubectl get cronjob cleanup-job -n stronghold -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score++))
			details+="Image correct. "
		else
			details+="Image incorrect ($image, expected: busybox:1.36). "
		fi

		# Check command contains echo
		local cmd
		cmd=$(kubectl get cronjob cleanup-job -n stronghold -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command}' 2>/dev/null)
		local args
		args=$(kubectl get cronjob cleanup-job -n stronghold -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].args}' 2>/dev/null)
		if [[ "$cmd" == *"echo"* || "$args" == *"echo"* || "$cmd" == *"sh"* ]]; then
			((score++))
			details+="Command set. "
		else
			details+="Command missing or incorrect. "
		fi

		# Check activeDeadlineSeconds
		local deadline
		deadline=$(kubectl get cronjob cleanup-job -n stronghold -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
		if [[ "$deadline" == "30" ]]; then
			((score++))
			details+="activeDeadlineSeconds correct (30)."
		else
			details+="activeDeadlineSeconds incorrect ($deadline, expected: 30)."
		fi
	else
		details+="CronJob cleanup-job not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q11: SecurityContext Merge (5 points)
score_q11() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "secure-app" "fortress"; then
		((score++))
		details+="Deployment secure-app exists. "

		# Check runAsUser (pod-level or container-level)
		local run_as_user_pod run_as_user_container
		run_as_user_pod=$(kubectl get deployment secure-app -n fortress -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
		run_as_user_container=$(kubectl get deployment secure-app -n fortress -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
		if [[ "$run_as_user_pod" == "10000" || "$run_as_user_container" == "10000" ]]; then
			((score++))
			details+="runAsUser=10000 set. "
		else
			details+="runAsUser incorrect (pod=$run_as_user_pod, container=$run_as_user_container, expected: 10000). "
		fi

		# Check readOnlyRootFilesystem preserved
		local readonly_fs
		readonly_fs=$(kubectl get deployment secure-app -n fortress -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
		if [[ "$readonly_fs" == "true" ]]; then
			((score++))
			details+="readOnlyRootFilesystem preserved. "
		else
			details+="readOnlyRootFilesystem not found or incorrect. "
		fi

		# Check allowPrivilegeEscalation preserved
		local no_escalation
		no_escalation=$(kubectl get deployment secure-app -n fortress -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
		if [[ "$no_escalation" == "false" ]]; then
			((score++))
			details+="allowPrivilegeEscalation preserved. "
		else
			details+="allowPrivilegeEscalation not found or incorrect. "
		fi

		# Check pods running
		local ready
		ready=$(kubectl get deployment secure-app -n fortress -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [[ -n "$ready" && "$ready" -ge 1 ]]; then
			((score++))
			details+="Pods running."
		else
			details+="Pods not running."
		fi
	else
		details+="Deployment secure-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q12: RBAC Fix (7 points)
score_q12() {
	local score=0
	local max_points=7
	local details=""

	# Check ServiceAccount exists
	if resource_exists "serviceaccount" "pod-reader-sa" "bastion"; then
		((score++))
		details+="ServiceAccount pod-reader-sa exists. "
	else
		details+="ServiceAccount pod-reader-sa not found. "
	fi

	# Check Role exists
	if resource_exists "role" "pod-reader-role" "bastion"; then
		((score++))
		details+="Role pod-reader-role exists. "

		# Check Role has correct verbs
		local verbs
		verbs=$(kubectl get role pod-reader-role -n bastion -o jsonpath='{.rules[0].verbs}' 2>/dev/null)
		if [[ "$verbs" == *"list"* && "$verbs" == *"get"* ]]; then
			((score++))
			details+="Role verbs correct (get, list). "
		else
			details+="Role verbs incorrect ($verbs). "
		fi

		# Check Role has correct resources
		local resources
		resources=$(kubectl get role pod-reader-role -n bastion -o jsonpath='{.rules[0].resources}' 2>/dev/null)
		if [[ "$resources" == *"pods"* ]]; then
			((score++))
			details+="Role resources correct (pods). "
		else
			details+="Role resources incorrect ($resources). "
		fi
	else
		details+="Role pod-reader-role not found. "
	fi

	# Check RoleBinding exists
	if resource_exists "rolebinding" "pod-reader-binding" "bastion"; then
		((score++))
		details+="RoleBinding pod-reader-binding exists. "

		# Check binding references correct role
		local role_ref
		role_ref=$(kubectl get rolebinding pod-reader-binding -n bastion -o jsonpath='{.roleRef.name}' 2>/dev/null)
		if [[ "$role_ref" == "pod-reader-role" ]]; then
			((score++))
			details+="RoleBinding references correct role. "
		else
			details+="RoleBinding references wrong role ($role_ref). "
		fi

		# Check binding references correct SA
		local sa_name
		sa_name=$(kubectl get rolebinding pod-reader-binding -n bastion -o jsonpath='{.subjects[0].name}' 2>/dev/null)
		if [[ "$sa_name" == "pod-reader-sa" ]]; then
			((score++))
			details+="RoleBinding references correct ServiceAccount."
		else
			details+="RoleBinding references wrong ServiceAccount ($sa_name)."
		fi
	else
		details+="RoleBinding pod-reader-binding not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q13: Deployment Rollback (5 points)
score_q13() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "web-server" "citadel"; then
		((score++))
		details+="Deployment web-server exists. "

		# Check image is nginx:1.25 (rolled back)
		local image
		image=$(kubectl get deployment web-server -n citadel -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == "nginx:1.25" ]]; then
			((score += 2))
			details+="Image correct (nginx:1.25). "
		else
			details+="Image incorrect ($image, expected: nginx:1.25). "
		fi

		# Check deployment is available
		local available
		available=$(kubectl get deployment web-server -n citadel -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [[ -n "$available" && "$available" -ge 1 ]]; then
			((score++))
			details+="Deployment running. "
		else
			details+="Deployment not running. "
		fi
	else
		details+="Deployment web-server not found. "
	fi

	# Check rollout history file
	if file_exists_and_not_empty "./exam/course/13/rollout-history.txt"; then
		((score++))
		details+="Rollout history file saved."
	else
		details+="Rollout history file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q14: Deprecated API Fix (4 points)
score_q14() {
	local score=0
	local max_points=4
	local details=""

	# Check the file was updated
	if file_exists_and_not_empty "./exam/course/14/broken-deploy.yaml"; then
		# Check apiVersion updated
		local api_version
		api_version=$(grep "apiVersion:" "./exam/course/14/broken-deploy.yaml" 2>/dev/null | head -1)
		if [[ "$api_version" == *"apps/v1"* ]]; then
			((score++))
			details+="apiVersion updated to apps/v1. "
		else
			details+="apiVersion not updated ($api_version). "
		fi

		# Check rollbackTo removed
		if ! grep -q "rollbackTo" "./exam/course/14/broken-deploy.yaml" 2>/dev/null; then
			((score++))
			details+="Deprecated rollbackTo field removed. "
		else
			details+="Deprecated rollbackTo field still present. "
		fi
	else
		details+="File broken-deploy.yaml not found. "
	fi

	# Check deployment applied and running
	if resource_exists "deployment" "legacy-app" "rampart"; then
		local ready
		ready=$(kubectl get deployment legacy-app -n rampart -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [[ -n "$ready" && "$ready" -ge 1 ]]; then
			((score += 2))
			details+="Deployment legacy-app running."
		else
			details+="Deployment legacy-app not running."
		fi
	else
		details+="Deployment legacy-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q15: Troubleshoot Failing Deployment (5 points)
score_q15() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "health-app" "tower"; then
		# Check pods running
		local ready
		ready=$(kubectl get deployment health-app -n tower -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [[ -n "$ready" && "$ready" -ge 1 ]]; then
			((score += 2))
			details+="Deployment has running pods. "
		else
			details+="Deployment has no running pods. "
		fi

		# Check liveness probe port fixed
		local probe_port
		probe_port=$(kubectl get deployment health-app -n tower -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null)
		if [[ "$probe_port" == "80" ]]; then
			((score += 2))
			details+="Liveness probe port correct (80). "
		else
			details+="Liveness probe port incorrect ($probe_port, expected: 80). "
		fi
	else
		details+="Deployment health-app not found. "
	fi

	# Check root cause file
	if file_exists_and_not_empty "./exam/course/15/root-cause.txt"; then
		((score++))
		details+="Root cause file saved."
	else
		details+="Root cause file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q16: ConfigMap as Environment Variables (5 points)
score_q16() {
	local score=0
	local max_points=5
	local details=""

	# Check ConfigMap exists
	if resource_exists "configmap" "app-config" "garrison"; then
		((score++))
		details+="ConfigMap app-config exists. "

		# Check keys
		local app_env app_debug
		app_env=$(kubectl get configmap app-config -n garrison -o jsonpath='{.data.APP_ENV}' 2>/dev/null)
		app_debug=$(kubectl get configmap app-config -n garrison -o jsonpath='{.data.APP_DEBUG}' 2>/dev/null)
		if [[ "$app_env" == "production" && "$app_debug" == "false" ]]; then
			((score++))
			details+="ConfigMap keys correct. "
		else
			details+="ConfigMap keys incorrect (APP_ENV=$app_env, APP_DEBUG=$app_debug). "
		fi
	else
		details+="ConfigMap app-config not found. "
	fi

	# Check Pod exists and uses envFrom
	if resource_exists "pod" "config-app" "garrison"; then
		((score++))
		details+="Pod config-app exists. "

		# Check envFrom configMapRef
		local cm_ref
		cm_ref=$(kubectl get pod config-app -n garrison -o jsonpath='{.spec.containers[0].envFrom[0].configMapRef.name}' 2>/dev/null)
		if [[ "$cm_ref" == "app-config" ]]; then
			((score++))
			details+="envFrom configMapRef correct. "
		else
			# Also accept individual env vars via configMapKeyRef
			local env_source
			env_source=$(kubectl get pod config-app -n garrison -o jsonpath='{.spec.containers[0].env[*].valueFrom.configMapKeyRef.name}' 2>/dev/null)
			if [[ "$env_source" == *"app-config"* ]]; then
				((score++))
				details+="configMapKeyRef used for app-config. "
			else
				details+="Pod does not reference ConfigMap app-config. "
			fi
		fi

		# Check pod running
		local phase
		phase=$(kubectl get pod config-app -n garrison -o jsonpath='{.status.phase}' 2>/dev/null)
		if [[ "$phase" == "Running" ]]; then
			((score++))
			details+="Pod running."
		else
			details+="Pod not running ($phase)."
		fi
	else
		details+="Pod config-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q17: Create ClusterIP Service (4 points)
score_q17() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "service" "backend-svc" "gate"; then
		((score++))
		details+="Service backend-svc exists. "

		# Check type
		local svc_type
		svc_type=$(kubectl get svc backend-svc -n gate -o jsonpath='{.spec.type}' 2>/dev/null)
		if [[ "$svc_type" == "ClusterIP" || -z "$svc_type" ]]; then
			((score++))
			details+="Type ClusterIP correct. "
		else
			details+="Type incorrect ($svc_type, expected: ClusterIP). "
		fi

		# Check port
		local port
		port=$(kubectl get svc backend-svc -n gate -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
		if [[ "$port" == "80" ]]; then
			((score++))
			details+="Port 80 correct. "
		else
			details+="Port incorrect ($port, expected: 80). "
		fi

		# Check endpoints
		local ep_ips
		ep_ips=$(kubectl get ep backend-svc -n gate -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
		if [[ -n "$ep_ips" ]]; then
			((score++))
			details+="Endpoints configured."
		else
			details+="No endpoints."
		fi
	else
		details+="Service backend-svc not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q18: Job with Completions and Parallelism (5 points)
score_q18() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "job" "batch-processor" "bulwark"; then
		((score++))
		details+="Job batch-processor exists. "

		# Check completions
		local completions
		completions=$(kubectl get job batch-processor -n bulwark -o jsonpath='{.spec.completions}' 2>/dev/null)
		if [[ "$completions" == "6" ]]; then
			((score++))
			details+="Completions correct (6). "
		else
			details+="Completions incorrect ($completions, expected: 6). "
		fi

		# Check parallelism
		local parallelism
		parallelism=$(kubectl get job batch-processor -n bulwark -o jsonpath='{.spec.parallelism}' 2>/dev/null)
		if [[ "$parallelism" == "2" ]]; then
			((score++))
			details+="Parallelism correct (2). "
		else
			details+="Parallelism incorrect ($parallelism, expected: 2). "
		fi

		# Check image
		local image
		image=$(kubectl get job batch-processor -n bulwark -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score++))
			details+="Image correct. "
		else
			details+="Image incorrect ($image). "
		fi

		# Check command
		local cmd
		cmd=$(kubectl get job batch-processor -n bulwark -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null)
		local args
		args=$(kubectl get job batch-processor -n bulwark -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
		if [[ "$cmd" == *"echo"* || "$args" == *"echo"* || "$cmd" == *"sh"* ]]; then
			((score++))
			details+="Command set."
		else
			details+="Command missing."
		fi
	else
		details+="Job batch-processor not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q19: Deployment Rolling Update Strategy (5 points)
score_q19() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "rolling-app" "parapet"; then
		# Check strategy type
		local strategy
		strategy=$(kubectl get deployment rolling-app -n parapet -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
		if [[ "$strategy" == "RollingUpdate" ]]; then
			((score++))
			details+="Strategy type RollingUpdate. "
		else
			details+="Strategy type incorrect ($strategy). "
		fi

		# Check maxSurge
		local max_surge
		max_surge=$(kubectl get deployment rolling-app -n parapet -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
		if [[ "$max_surge" == "1" ]]; then
			((score++))
			details+="maxSurge correct (1). "
		else
			details+="maxSurge incorrect ($max_surge, expected: 1). "
		fi

		# Check maxUnavailable
		local max_unavail
		max_unavail=$(kubectl get deployment rolling-app -n parapet -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
		if [[ "$max_unavail" == "0" ]]; then
			((score++))
			details+="maxUnavailable correct (0). "
		else
			details+="maxUnavailable incorrect ($max_unavail, expected: 0). "
		fi

		# Check pods running
		local ready replicas
		ready=$(kubectl get deployment rolling-app -n parapet -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		replicas=$(kubectl get deployment rolling-app -n parapet -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ -n "$ready" && "$ready" -ge 1 ]]; then
			((score += 2))
			details+="Pods running ($ready/$replicas)."
		else
			details+="Pods not running."
		fi
	else
		details+="Deployment rolling-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q20: Multi-container Pod with Shared Volume (5 points)
score_q20() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "logger-app" "stronghold"; then
		# Check container count
		local container_count
		container_count=$(kubectl get pod logger-app -n stronghold -o jsonpath='{.spec.containers}' 2>/dev/null | grep -c "name" 2>/dev/null || echo "0")
		if [[ "$container_count" -ge 2 ]]; then
			((score++))
			details+="Pod has 2+ containers. "
		else
			details+="Pod has fewer than 2 containers. "
		fi

		# Check shared volume exists
		local volume_name
		volume_name=$(kubectl get pod logger-app -n stronghold -o jsonpath='{.spec.volumes[0].name}' 2>/dev/null)
		local volume_type
		volume_type=$(kubectl get pod logger-app -n stronghold -o jsonpath='{.spec.volumes[0].emptyDir}' 2>/dev/null)
		if [[ -n "$volume_name" && "$volume_type" != "" ]]; then
			((score++))
			details+="Shared emptyDir volume exists. "
		else
			details+="Shared emptyDir volume not found. "
		fi

		# Check main container mounts volume
		local mount_app
		mount_app=$(kubectl get pod logger-app -n stronghold -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		if [[ "$mount_app" == "/var/log" ]]; then
			((score++))
			details+="Main container mounts /var/log. "
		else
			details+="Main container mount incorrect ($mount_app). "
		fi

		# Check sidecar container exists and mounts volume
		local sidecar_mount
		sidecar_mount=$(kubectl get pod logger-app -n stronghold -o jsonpath='{.spec.containers[1].volumeMounts[0].mountPath}' 2>/dev/null)
		if [[ "$sidecar_mount" == "/var/log" ]]; then
			((score++))
			details+="Sidecar mounts /var/log. "
		else
			details+="Sidecar mount incorrect ($sidecar_mount). "
		fi

		# Check pod running
		local phase
		phase=$(kubectl get pod logger-app -n stronghold -o jsonpath='{.status.phase}' 2>/dev/null)
		if [[ "$phase" == "Running" ]]; then
			((score++))
			details+="Pod running."
		else
			details+="Pod not running ($phase)."
		fi
	else
		details+="Pod logger-app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
