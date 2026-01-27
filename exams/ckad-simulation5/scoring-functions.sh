#!/bin/bash
# scoring-functions.sh - CKAD Simulation 5 Scoring Functions
# Dojo Kappa - 16 questions, 88 points total
# Original questions: https://github.com/aravind4799/CKAD-Practice-Questions

# Source common utilities (includes check_criterion function)
# Use EXAM_SCRIPT_DIR to avoid conflict with common.sh's SCRIPT_DIR
EXAM_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$EXAM_SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true
source "$EXAM_SCRIPT_DIR/../../scripts/lib/scoring-functions.sh" 2>/dev/null || true

# ============================================================================
# QUESTION 1 - Secret from Hardcoded Variables (4 points)
# ============================================================================
score_q1() {
	local score=0
	local total=4

	echo "Question 1 | Secret from Hardcoded Variables"

	# Check Secret exists
	local secret_exists
	secret_exists=$(kubectl get secret db-credentials -n stream &>/dev/null && echo true || echo false)
	check_criterion "Secret db-credentials exists in stream namespace" "$secret_exists" && ((score++))

	if [ "$secret_exists" = "true" ]; then
		# Check Secret has DB_USER key
		local has_user
		has_user=$(kubectl get secret db-credentials -n stream -o jsonpath='{.data.DB_USER}' 2>/dev/null)
		check_criterion "Secret has DB_USER key" "$([ -n "$has_user" ] && echo true || echo false)" && ((score++))

		# Check Secret has DB_PASS key
		local has_pass
		has_pass=$(kubectl get secret db-credentials -n stream -o jsonpath='{.data.DB_PASS}' 2>/dev/null)
		check_criterion "Secret has DB_PASS key" "$([ -n "$has_pass" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Secret has DB_USER key" "false"
		check_criterion "Secret has DB_PASS key" "false"
	fi

	# Check Deployment uses secretKeyRef
	local deploy_env
	deploy_env=$(kubectl get deploy api-server -n stream -o yaml 2>/dev/null)
	local uses_secret
	uses_secret=$(echo "$deploy_env" | grep -q "secretKeyRef" && echo true || echo false)
	check_criterion "Deployment api-server uses secretKeyRef" "$uses_secret" && ((score++))

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 2 - CronJob with Schedule and History Limits (8 points)
# ============================================================================
score_q2() {
	local score=0
	local total=8

	echo "Question 2 | CronJob with History Limits"

	# Check CronJob exists
	local cj_exists
	cj_exists=$(kubectl get cronjob backup-job -n pond &>/dev/null && echo true || echo false)
	check_criterion "CronJob backup-job exists in pond namespace" "$cj_exists" && ((score++))

	if [ "$cj_exists" = "true" ]; then
		# Check schedule
		local schedule
		schedule=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.schedule}' 2>/dev/null)
		check_criterion "Schedule is */30 * * * *" "$([ "$schedule" = "*/30 * * * *" ] && echo true || echo false)" && ((score++))

		# Check image
		local image
		image=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
		check_criterion "Image is busybox:latest" "$([[ "$image" == *"busybox"* ]] && echo true || echo false)" && ((score++))

		# Check container name
		local container_name
		container_name=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].name}' 2>/dev/null)
		check_criterion "Container name is backup" "$([ "$container_name" = "backup" ] && echo true || echo false)" && ((score++))

		# Check successfulJobsHistoryLimit
		local success_limit
		success_limit=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
		check_criterion "successfulJobsHistoryLimit is 3" "$([ "$success_limit" = "3" ] && echo true || echo false)" && ((score++))

		# Check failedJobsHistoryLimit
		local failed_limit
		failed_limit=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
		check_criterion "failedJobsHistoryLimit is 2" "$([ "$failed_limit" = "2" ] && echo true || echo false)" && ((score++))

		# Check activeDeadlineSeconds
		local deadline
		deadline=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
		check_criterion "activeDeadlineSeconds is 300" "$([ "$deadline" = "300" ] && echo true || echo false)" && ((score++))

		# Check restartPolicy
		local restart
		restart=$(kubectl get cronjob backup-job -n pond -o jsonpath='{.spec.jobTemplate.spec.template.spec.restartPolicy}' 2>/dev/null)
		check_criterion "restartPolicy is Never" "$([ "$restart" = "Never" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Schedule is */30 * * * *" "false"
		check_criterion "Image is busybox:latest" "false"
		check_criterion "Container name is backup" "false"
		check_criterion "successfulJobsHistoryLimit is 3" "false"
		check_criterion "failedJobsHistoryLimit is 2" "false"
		check_criterion "activeDeadlineSeconds is 300" "false"
		check_criterion "restartPolicy is Never" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 3 - ServiceAccount, Role, and RoleBinding (8 points)
# ============================================================================
score_q3() {
	local score=0
	local total=8

	echo "Question 3 | RBAC Configuration"

	# Check ServiceAccount exists
	local sa_exists
	sa_exists=$(kubectl get sa log-sa -n marsh &>/dev/null && echo true || echo false)
	check_criterion "ServiceAccount log-sa exists in marsh" "$sa_exists" && ((score++))

	# Check Role exists
	local role_exists
	role_exists=$(kubectl get role log-role -n marsh &>/dev/null && echo true || echo false)
	check_criterion "Role log-role exists in marsh" "$role_exists" && ((score++))

	if [ "$role_exists" = "true" ]; then
		# Check Role has correct verbs
		local role_verbs
		role_verbs=$(kubectl get role log-role -n marsh -o jsonpath='{.rules[0].verbs}' 2>/dev/null)
		local has_verbs
		has_verbs=$([[ "$role_verbs" == *"get"* ]] && [[ "$role_verbs" == *"list"* ]] && [[ "$role_verbs" == *"watch"* ]] && echo true || echo false)
		check_criterion "Role has get, list, watch verbs" "$has_verbs" && ((score++))

		# Check Role targets pods
		local role_resources
		role_resources=$(kubectl get role log-role -n marsh -o jsonpath='{.rules[0].resources}' 2>/dev/null)
		check_criterion "Role targets pods resource" "$([[ "$role_resources" == *"pods"* ]] && echo true || echo false)" && ((score++))
	else
		check_criterion "Role has get, list, watch verbs" "false"
		check_criterion "Role targets pods resource" "false"
	fi

	# Check RoleBinding exists
	local rb_exists
	rb_exists=$(kubectl get rolebinding log-rb -n marsh &>/dev/null && echo true || echo false)
	check_criterion "RoleBinding log-rb exists in marsh" "$rb_exists" && ((score++))

	if [ "$rb_exists" = "true" ]; then
		# Check RoleBinding references correct Role
		local rb_role
		rb_role=$(kubectl get rolebinding log-rb -n marsh -o jsonpath='{.roleRef.name}' 2>/dev/null)
		check_criterion "RoleBinding references log-role" "$([ "$rb_role" = "log-role" ] && echo true || echo false)" && ((score++))

		# Check RoleBinding references correct ServiceAccount
		local rb_sa
		rb_sa=$(kubectl get rolebinding log-rb -n marsh -o jsonpath='{.subjects[0].name}' 2>/dev/null)
		check_criterion "RoleBinding references log-sa" "$([ "$rb_sa" = "log-sa" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "RoleBinding references log-role" "false"
		check_criterion "RoleBinding references log-sa" "false"
	fi

	# Check Pod uses ServiceAccount
	local pod_sa
	pod_sa=$(kubectl get pod log-collector -n marsh -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
	check_criterion "Pod log-collector uses log-sa ServiceAccount" "$([ "$pod_sa" = "log-sa" ] && echo true || echo false)" && ((score++))

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 4 - Fix Broken Pod with Correct ServiceAccount (4 points)
# ============================================================================
score_q4() {
	local score=0
	local total=4

	echo "Question 4 | Fix Pod ServiceAccount"

	# Check Pod exists
	local pod_exists
	pod_exists=$(kubectl get pod metrics-pod -n delta &>/dev/null && echo true || echo false)
	check_criterion "Pod metrics-pod exists in delta" "$pod_exists" && ((score++))

	if [ "$pod_exists" = "true" ]; then
		# Check Pod uses monitor-sa
		local pod_sa
		pod_sa=$(kubectl get pod metrics-pod -n delta -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
		check_criterion "Pod uses monitor-sa ServiceAccount" "$([ "$pod_sa" = "monitor-sa" ] && echo true || echo false)" && ((score += 2))

		# Check Pod is Running
		local pod_status
		pod_status=$(kubectl get pod metrics-pod -n delta -o jsonpath='{.status.phase}' 2>/dev/null)
		check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Pod uses monitor-sa ServiceAccount" "false"
		check_criterion "Pod is Running" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 5 - Build Container Image and Save as Tarball (8 points)
# ============================================================================
score_q5() {
	local score=0
	local total=8

	echo "Question 5 | Build Container Image"

	# Check image exists
	local image_exists
	image_exists=$(docker images my-app:1.0 --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "my-app:1.0" && echo true || echo false)
	check_criterion "Image my-app:1.0 exists" "$image_exists" && ((score += 4))

	# Check tarball exists
	local tarball_exists
	tarball_exists=$([ -f "$EXAM_DIR/5/my-app.tar" ] && echo true || echo false)
	check_criterion "Tarball exists at exam/course/5/my-app.tar" "$tarball_exists" && ((score += 4))

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 6 - Canary Deployment with Manual Traffic Split (8 points)
# ============================================================================
score_q6() {
	local score=0
	local total=8

	echo "Question 6 | Canary Deployment"

	# Check web-app has 8 replicas
	local web_app_replicas
	web_app_replicas=$(kubectl get deploy web-app -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
	check_criterion "Deployment web-app has 8 replicas" "$([ "$web_app_replicas" = "8" ] && echo true || echo false)" && ((score += 2))

	# Check web-app-canary exists
	local canary_exists
	canary_exists=$(kubectl get deploy web-app-canary -n default &>/dev/null && echo true || echo false)
	check_criterion "Deployment web-app-canary exists" "$canary_exists" && ((score++))

	if [ "$canary_exists" = "true" ]; then
		# Check canary has 2 replicas
		local canary_replicas
		canary_replicas=$(kubectl get deploy web-app-canary -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
		check_criterion "Canary deployment has 2 replicas" "$([ "$canary_replicas" = "2" ] && echo true || echo false)" && ((score += 2))

		# Check canary has app=webapp label
		local canary_label
		canary_label=$(kubectl get deploy web-app-canary -n default -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
		check_criterion "Canary has app=webapp label" "$([ "$canary_label" = "webapp" ] && echo true || echo false)" && ((score++))

		# Check canary has version=v2 label
		local canary_version
		canary_version=$(kubectl get deploy web-app-canary -n default -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
		check_criterion "Canary has version=v2 label" "$([ "$canary_version" = "v2" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Canary deployment has 2 replicas" "false"
		check_criterion "Canary has app=webapp label" "false"
		check_criterion "Canary has version=v2 label" "false"
	fi

	# Check Service endpoints include both deployments
	local endpoints_count
	endpoints_count=$(kubectl get endpoints web-service -n default -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o "ip" | wc -l)
	check_criterion "Service web-service has endpoints from both deployments" "$([ "$endpoints_count" -ge 5 ] && echo true || echo false)" && ((score++))

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 7 - Fix NetworkPolicy by Updating Pod Labels (8 points)
# ============================================================================
score_q7() {
	local score=0
	local total=8

	echo "Question 7 | Fix NetworkPolicy Labels"

	# Check frontend has correct label
	local frontend_label
	frontend_label=$(kubectl get pod frontend -n spring -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
	check_criterion "Pod frontend has role=frontend label" "$([ "$frontend_label" = "frontend" ] && echo true || echo false)" && ((score += 2))

	# Check backend has correct label
	local backend_label
	backend_label=$(kubectl get pod backend -n spring -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
	check_criterion "Pod backend has role=backend label" "$([ "$backend_label" = "backend" ] && echo true || echo false)" && ((score += 3))

	# Check database has correct label
	local db_label
	db_label=$(kubectl get pod database -n spring -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
	check_criterion "Pod database has role=db label" "$([ "$db_label" = "db" ] && echo true || echo false)" && ((score += 3))

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 8 - Fix Broken Deployment YAML (4 points)
# ============================================================================
score_q8() {
	local score=0
	local total=4

	echo "Question 8 | Fix Broken Deployment"

	# Check Deployment exists
	local deploy_exists
	deploy_exists=$(kubectl get deploy broken-app -n default &>/dev/null && echo true || echo false)
	check_criterion "Deployment broken-app exists" "$deploy_exists" && ((score++))

	if [ "$deploy_exists" = "true" ]; then
		# Check Deployment is available
		local available
		available=$(kubectl get deploy broken-app -n default -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
		check_criterion "Deployment has available replicas" "$([ -n "$available" ] && [ "$available" -ge 1 ] && echo true || echo false)" && ((score++))

		# Check apiVersion is apps/v1
		local api_version
		api_version=$(kubectl get deploy broken-app -n default -o jsonpath='{.apiVersion}' 2>/dev/null)
		check_criterion "Deployment uses apps/v1 API" "$([ "$api_version" = "apps/v1" ] && echo true || echo false)" && ((score++))

		# Check selector matches template labels
		local selector_app
		selector_app=$(kubectl get deploy broken-app -n default -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
		local template_app
		template_app=$(kubectl get deploy broken-app -n default -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
		check_criterion "Selector matches template labels" "$([ "$selector_app" = "$template_app" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Deployment has available replicas" "false"
		check_criterion "Deployment uses apps/v1 API" "false"
		check_criterion "Selector matches template labels" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 9 - Perform Rolling Update and Rollback (8 points)
# ============================================================================
score_q9() {
	local score=0
	local total=8

	echo "Question 9 | Rolling Update and Rollback"

	# Check Deployment exists
	local deploy_exists
	deploy_exists=$(kubectl get deploy app-v1 -n brook &>/dev/null && echo true || echo false)
	check_criterion "Deployment app-v1 exists in brook" "$deploy_exists" && ((score++))

	if [ "$deploy_exists" = "true" ]; then
		# Check current image is nginx:1.20 (after rollback)
		local current_image
		current_image=$(kubectl get deploy app-v1 -n brook -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		check_criterion "Image is nginx:1.20 (after rollback)" "$([ "$current_image" = "nginx:1.20" ] && echo true || echo false)" && ((score += 3))

		# Check rollout history has multiple revisions
		local revision_count
		revision_count=$(kubectl rollout history deploy app-v1 -n brook 2>/dev/null | grep -c "^[0-9]")
		check_criterion "Deployment has multiple revisions" "$([ "$revision_count" -ge 2 ] && echo true || echo false)" && ((score += 2))
	else
		check_criterion "Image is nginx:1.20 (after rollback)" "false"
		check_criterion "Deployment has multiple revisions" "false"
	fi

	# Check rollback-revision.txt exists
	local file_exists
	file_exists=$([ -f "$EXAM_DIR/9/rollback-revision.txt" ] && echo true || echo false)
	check_criterion "File rollback-revision.txt exists" "$file_exists" && ((score++))

	if [ "$file_exists" = "true" ]; then
		# Check file contains a revision number
		local revision
		revision=$(cat "$EXAM_DIR/9/rollback-revision.txt" 2>/dev/null | tr -d '[:space:]')
		check_criterion "File contains revision number" "$([[ "$revision" =~ ^[0-9]+$ ]] && echo true || echo false)" && ((score++))
	else
		check_criterion "File contains revision number" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 10 - Add Readiness Probe to Deployment (4 points)
# ============================================================================
score_q10() {
	local score=0
	local total=4

	echo "Question 10 | Readiness Probe"

	# Check Deployment exists
	local deploy_exists
	deploy_exists=$(kubectl get deploy api-deploy -n rapids &>/dev/null && echo true || echo false)
	check_criterion "Deployment api-deploy exists in rapids" "$deploy_exists" && ((score++))

	if [ "$deploy_exists" = "true" ]; then
		# Check readiness probe exists
		local probe_path
		probe_path=$(kubectl get deploy api-deploy -n rapids -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
		check_criterion "Readiness probe path is /ready" "$([ "$probe_path" = "/ready" ] && echo true || echo false)" && ((score++))

		# Check probe port
		local probe_port
		probe_port=$(kubectl get deploy api-deploy -n rapids -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
		check_criterion "Readiness probe port is 8080" "$([ "$probe_port" = "8080" ] && echo true || echo false)" && ((score++))

		# Check initialDelaySeconds
		local initial_delay
		initial_delay=$(kubectl get deploy api-deploy -n rapids -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
		local period
		period=$(kubectl get deploy api-deploy -n rapids -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
		check_criterion "Probe has correct timing (delay=5, period=10)" "$([ "$initial_delay" = "5" ] && [ "$period" = "10" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Readiness probe path is /ready" "false"
		check_criterion "Readiness probe port is 8080" "false"
		check_criterion "Probe has correct timing (delay=5, period=10)" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 11 - Configure Pod and Container Security Context (6 points)
# ============================================================================
score_q11() {
	local score=0
	local total=6

	echo "Question 11 | Security Context"

	# Check Deployment exists
	local deploy_exists
	deploy_exists=$(kubectl get deploy secure-app -n cascade &>/dev/null && echo true || echo false)
	check_criterion "Deployment secure-app exists in cascade" "$deploy_exists" && ((score++))

	if [ "$deploy_exists" = "true" ]; then
		# Check runAsUser at Pod level
		local run_as_user
		run_as_user=$(kubectl get deploy secure-app -n cascade -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
		check_criterion "Pod-level runAsUser is 1000" "$([ "$run_as_user" = "1000" ] && echo true || echo false)" && ((score += 2))

		# Check container has NET_ADMIN capability
		local capabilities
		capabilities=$(kubectl get deploy secure-app -n cascade -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.add}' 2>/dev/null)
		check_criterion "Container has NET_ADMIN capability" "$([[ "$capabilities" == *"NET_ADMIN"* ]] && echo true || echo false)" && ((score += 2))

		# Check Deployment is running
		local available
		available=$(kubectl get deploy secure-app -n cascade -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
		check_criterion "Deployment has available replicas" "$([ -n "$available" ] && [ "$available" -ge 1 ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Pod-level runAsUser is 1000" "false"
		check_criterion "Container has NET_ADMIN capability" "false"
		check_criterion "Deployment has available replicas" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 12 - Fix Service Selector (2 points)
# ============================================================================
score_q12() {
	local score=0
	local total=2

	echo "Question 12 | Fix Service Selector"

	# Check Service selector
	local svc_selector
	svc_selector=$(kubectl get svc web-svc -n shoal -o jsonpath='{.spec.selector.app}' 2>/dev/null)
	check_criterion "Service selector is app=webapp" "$([ "$svc_selector" = "webapp" ] && echo true || echo false)" && ((score++))

	# Check Service has endpoints
	local endpoints
	endpoints=$(kubectl get endpoints web-svc -n shoal -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
	check_criterion "Service has endpoints" "$([ -n "$endpoints" ] && echo true || echo false)" && ((score++))

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 13 - Create NodePort Service (4 points)
# ============================================================================
score_q13() {
	local score=0
	local total=4

	echo "Question 13 | NodePort Service"

	# Check Service exists
	local svc_exists
	svc_exists=$(kubectl get svc api-nodeport -n default &>/dev/null && echo true || echo false)
	check_criterion "Service api-nodeport exists" "$svc_exists" && ((score++))

	if [ "$svc_exists" = "true" ]; then
		# Check Service type is NodePort
		local svc_type
		svc_type=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.type}' 2>/dev/null)
		check_criterion "Service type is NodePort" "$([ "$svc_type" = "NodePort" ] && echo true || echo false)" && ((score++))

		# Check Service port is 80
		local svc_port
		svc_port=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
		check_criterion "Service port is 80" "$([ "$svc_port" = "80" ] && echo true || echo false)" && ((score++))

		# Check Service targetPort is 9090
		local target_port
		target_port=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
		check_criterion "Target port is 9090" "$([ "$target_port" = "9090" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Service type is NodePort" "false"
		check_criterion "Service port is 80" "false"
		check_criterion "Target port is 9090" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 14 - Create Ingress Resource (4 points)
# ============================================================================
score_q14() {
	local score=0
	local total=4

	echo "Question 14 | Create Ingress"

	# Check Ingress exists
	local ingress_exists
	ingress_exists=$(kubectl get ingress web-ingress -n eddy &>/dev/null && echo true || echo false)
	check_criterion "Ingress web-ingress exists in eddy" "$ingress_exists" && ((score++))

	if [ "$ingress_exists" = "true" ]; then
		# Check host
		local host
		host=$(kubectl get ingress web-ingress -n eddy -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
		check_criterion "Host is web.example.com" "$([ "$host" = "web.example.com" ] && echo true || echo false)" && ((score++))

		# Check path and pathType
		local path_type
		path_type=$(kubectl get ingress web-ingress -n eddy -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
		check_criterion "PathType is Prefix" "$([ "$path_type" = "Prefix" ] && echo true || echo false)" && ((score++))

		# Check backend service
		local backend_svc
		backend_svc=$(kubectl get ingress web-ingress -n eddy -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
		local backend_port
		backend_port=$(kubectl get ingress web-ingress -n eddy -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
		check_criterion "Backend is web-svc:8080" "$([ "$backend_svc" = "web-svc" ] && [ "$backend_port" = "8080" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Host is web.example.com" "false"
		check_criterion "PathType is Prefix" "false"
		check_criterion "Backend is web-svc:8080" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 15 - Fix Ingress PathType (4 points)
# ============================================================================
score_q15() {
	local score=0
	local total=4

	echo "Question 15 | Fix Ingress PathType"

	# Check Ingress exists
	local ingress_exists
	ingress_exists=$(kubectl get ingress api-ingress -n default &>/dev/null && echo true || echo false)
	check_criterion "Ingress api-ingress exists" "$ingress_exists" && ((score++))

	if [ "$ingress_exists" = "true" ]; then
		# Check pathType is valid
		local path_type
		path_type=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
		local valid_type
		valid_type=$([[ "$path_type" == "Prefix" ]] || [[ "$path_type" == "Exact" ]] || [[ "$path_type" == "ImplementationSpecific" ]] && echo true || echo false)
		check_criterion "PathType is valid (Prefix/Exact/ImplementationSpecific)" "$valid_type" && ((score++))

		# Check path is /api
		local path
		path=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
		check_criterion "Path is /api" "$([ "$path" = "/api" ] && echo true || echo false)" && ((score++))

		# Check backend service
		local backend_svc
		backend_svc=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
		check_criterion "Backend is api-svc" "$([ "$backend_svc" = "api-svc" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "PathType is valid (Prefix/Exact/ImplementationSpecific)" "false"
		check_criterion "Path is /api" "false"
		check_criterion "Backend is api-svc" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# QUESTION 16 - Add Resource Requests and Limits to Pod (4 points)
# ============================================================================
score_q16() {
	local score=0
	local total=4

	echo "Question 16 | Resource Requests and Limits"

	# Check Pod exists
	local pod_exists
	pod_exists=$(kubectl get pod resource-pod -n pond &>/dev/null && echo true || echo false)
	check_criterion "Pod resource-pod exists in pond" "$pod_exists" && ((score++))

	if [ "$pod_exists" = "true" ]; then
		# Check requests exist
		local req_cpu
		req_cpu=$(kubectl get pod resource-pod -n pond -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
		local req_mem
		req_mem=$(kubectl get pod resource-pod -n pond -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
		check_criterion "Pod has resource requests" "$([ -n "$req_cpu" ] && [ -n "$req_mem" ] && echo true || echo false)" && ((score++))

		# Check limits exist
		local lim_cpu
		lim_cpu=$(kubectl get pod resource-pod -n pond -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
		local lim_mem
		lim_mem=$(kubectl get pod resource-pod -n pond -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
		check_criterion "Pod has resource limits" "$([ -n "$lim_cpu" ] && [ -n "$lim_mem" ] && echo true || echo false)" && ((score++))

		# Check Pod is Running
		local pod_status
		pod_status=$(kubectl get pod resource-pod -n pond -o jsonpath='{.status.phase}' 2>/dev/null)
		check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "Pod has resource requests" "false"
		check_criterion "Pod has resource limits" "false"
		check_criterion "Pod is Running" "false"
	fi

	echo "$score/$total"
	return $score
}

# ============================================================================
# PREVIEW QUESTION 1 - Pod Topology Spread Constraints (3 points)
# ============================================================================
score_preview_q1() {
	local score=0
	local total=3

	echo "Preview Question 1 | Topology Spread Constraints"

	# Check Pod exists
	local pod_exists
	pod_exists=$(kubectl get pod spread-pod -n eddy &>/dev/null && echo true || echo false)
	check_criterion "Pod spread-pod exists in eddy" "$pod_exists" && ((score++))

	if [ "$pod_exists" = "true" ]; then
		# Check topology spread constraint
		local max_skew
		max_skew=$(kubectl get pod spread-pod -n eddy -o jsonpath='{.spec.topologySpreadConstraints[0].maxSkew}' 2>/dev/null)
		check_criterion "maxSkew is 1" "$([ "$max_skew" = "1" ] && echo true || echo false)" && ((score++))

		# Check topologyKey
		local topology_key
		topology_key=$(kubectl get pod spread-pod -n eddy -o jsonpath='{.spec.topologySpreadConstraints[0].topologyKey}' 2>/dev/null)
		check_criterion "topologyKey is kubernetes.io/hostname" "$([ "$topology_key" = "kubernetes.io/hostname" ] && echo true || echo false)" && ((score++))
	else
		check_criterion "maxSkew is 1" "false"
		check_criterion "topologyKey is kubernetes.io/hostname" "false"
	fi

	echo "$score/$total"
	return $score
}
