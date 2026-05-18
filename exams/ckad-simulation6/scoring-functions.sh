#!/bin/bash
# scoring-functions.sh - CKAD Simulation 6 Scoring Functions
# Dojo Tengu (Mountain theme) - 20 questions, 100 points total
# Original questions: https://github.com/dgkanatsios/CKAD-exercises

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# Q1: Namespace and Pod Creation (4 points)
score_q1() {
	local score=0
	local max_points=4
	local details=""

	# Check namespace exists
	if namespace_exists "mynamespace"; then
		((score += 2))
		details+="Namespace mynamespace exists. "
	else
		details+="Namespace mynamespace not found. "
	fi

	# Check pod exists
	if resource_exists "pod" "nginx" "mynamespace"; then
		((score += 1))
		details+="Pod nginx exists. "

		# Check image
		local image
		image=$(kubectl get pod nginx -n mynamespace -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"nginx"* ]]; then
			((score += 1))
			details+="Image is nginx."
		else
			details+="Image incorrect ($image)."
		fi
	else
		details+="Pod nginx not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q2: Pod with Environment Variables (5 points)
score_q2() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "envpod" "summit"; then
		((score += 2))
		details+="Pod envpod exists. "

		# Check image
		local image
		image=$(kubectl get pod envpod -n summit -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score += 1))
			details+="Image is busybox. "
		else
			details+="Image incorrect ($image). "
		fi

		# Check env variable
		local env_val
		env_val=$(kubectl get pod envpod -n summit -o jsonpath='{.spec.containers[0].env[?(@.name=="VAR1")].value}' 2>/dev/null)
		if [[ "$env_val" == "value1" ]]; then
			((score += 2))
			details+="VAR1=value1 is set."
		else
			details+="VAR1 not found or incorrect."
		fi
	else
		details+="Pod envpod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q3: ResourceQuota (6 points)
score_q3() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "resourcequota" "cliff-quota" "cliff"; then
		((score += 2))
		details+="ResourceQuota cliff-quota exists. "

		# Check CPU (accept both 'cpu' and 'limits.cpu')
		local cpu cpu_limits
		cpu=$(kubectl get quota cliff-quota -n cliff -o jsonpath='{.spec.hard.cpu}' 2>/dev/null)
		cpu_limits=$(kubectl get quota cliff-quota -n cliff -o jsonpath='{.spec.hard.limits\.cpu}' 2>/dev/null)
		if [[ "$cpu" == "1" || "$cpu_limits" == "1" ]]; then
			((score += 1))
			details+="CPU limit is 1. "
		else
			details+="CPU limit incorrect (cpu=$cpu, limits.cpu=$cpu_limits). "
		fi

		# Check memory (accept both 'memory' and 'limits.memory', various units)
		local memory memory_limits
		memory=$(kubectl get quota cliff-quota -n cliff -o jsonpath='{.spec.hard.memory}' 2>/dev/null)
		memory_limits=$(kubectl get quota cliff-quota -n cliff -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)
		if [[ "$memory" == "1G" || "$memory" == "1Gi" || "$memory_limits" == "1G" || "$memory_limits" == "1Gi" ]]; then
			((score += 2))
			details+="Memory limit is 1G. "
		else
			details+="Memory limit incorrect (memory=$memory, limits.memory=$memory_limits). "
		fi

		# Check pods
		local pods
		pods=$(kubectl get quota cliff-quota -n cliff -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
		if [[ "$pods" == "2" ]]; then
			((score += 1))
			details+="Pods limit is 2."
		else
			details+="Pods limit incorrect ($pods)."
		fi
	else
		details+="ResourceQuota cliff-quota not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q4: Labels and Selectors (5 points)
score_q4() {
	local score=0
	local max_points=5
	local details=""

	# Check pods exist
	local pods_exist=0
	for pod in nginx1 nginx2 nginx3; do
		if resource_exists "pod" "$pod" "ridge"; then
			((pods_exist++))
		fi
	done

	if [[ $pods_exist -eq 3 ]]; then
		((score += 1))
		details+="All 3 pods exist. "
	else
		details+="Only $pods_exist/3 pods found. "
	fi

	# Check nginx2 has app=v2
	local nginx2_label
	nginx2_label=$(kubectl get pod nginx2 -n ridge -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
	if [[ "$nginx2_label" == "v2" ]]; then
		((score += 2))
		details+="nginx2 has app=v2. "
	else
		details+="nginx2 label incorrect ($nginx2_label). "
	fi

	# Check nginx1 and nginx3 have tier=web
	local nginx1_tier nginx3_tier
	nginx1_tier=$(kubectl get pod nginx1 -n ridge -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
	nginx3_tier=$(kubectl get pod nginx3 -n ridge -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
	if [[ "$nginx1_tier" == "web" && "$nginx3_tier" == "web" ]]; then
		((score += 2))
		details+="nginx1 and nginx3 have tier=web."
	else
		details+="tier=web label missing on some pods."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q5: Deployment Creation (6 points)
score_q5() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "deployment" "nginx-deploy" "valley"; then
		((score += 2))
		details+="Deployment nginx-deploy exists. "

		# Q6 mutates this deployment's image, so accept current spec OR revision 1
		local image_current image_rev1
		image_current=$(kubectl get deployment nginx-deploy -n valley -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		image_rev1=$(kubectl rollout history deployment nginx-deploy -n valley --revision=1 2>/dev/null | awk '/Image:/ {print $2; exit}')
		if [[ "$image_current" == "nginx:1.18.0" || "$image_rev1" == "nginx:1.18.0" ]]; then
			((score += 2))
			details+="Image nginx:1.18.0 (rev1=$image_rev1, current=$image_current). "
		else
			details+="Image nginx:1.18.0 not found (rev1=$image_rev1, current=$image_current). "
		fi

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment nginx-deploy -n valley -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "2" ]]; then
			((score += 1))
			details+="Replicas is 2. "
		else
			details+="Replicas is $replicas (expected 2). "
		fi

		# Check container port
		local port
		port=$(kubectl get deployment nginx-deploy -n valley -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}' 2>/dev/null)
		if [[ "$port" == "80" ]]; then
			((score += 1))
			details+="Port is 80."
		else
			details+="Port not configured or incorrect."
		fi
	else
		details+="Deployment nginx-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q6: Deployment Rollout (5 points)
score_q6() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "nginx-deploy" "valley"; then
		((score += 1))
		details+="Deployment exists. "

		# Check image is updated to 1.19.8
		local image
		image=$(kubectl get deployment nginx-deploy -n valley -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == "nginx:1.19.8" ]]; then
			((score += 3))
			details+="Image updated to nginx:1.19.8. "
		else
			details+="Image is $image (expected nginx:1.19.8). "
		fi

		# Check rollout status
		local available
		available=$(kubectl get deployment nginx-deploy -n valley -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
		if [[ -n "$available" && "$available" -ge 1 ]]; then
			((score += 1))
			details+="Rollout completed."
		else
			details+="Rollout not completed."
		fi
	else
		details+="Deployment nginx-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q7: Deployment Rollback (5 points)
score_q7() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "rollback-deploy" "cave"; then
		((score += 1))
		details+="Deployment exists. "

		# Check image is NOT the wrong one (nginx:1.91)
		local image
		image=$(kubectl get deployment rollback-deploy -n cave -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" != "nginx:1.91" && "$image" == *"nginx"* ]]; then
			((score += 2))
			details+="Image rolled back from nginx:1.91. "
		else
			details+="Image still shows nginx:1.91 or invalid. "
		fi

		# Check pods are running
		local running_pods
		running_pods=$(kubectl get pods -n cave -l app=rollback-deploy --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
		if [[ "$running_pods" -ge 1 ]]; then
			((score += 2))
			details+="Pods are running."
		else
			details+="No running pods found."
		fi
	else
		details+="Deployment rollback-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q8: Job with Completions (5 points)
score_q8() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "job" "echo-job" "stone"; then
		((score += 2))
		details+="Job echo-job exists. "

		# Check completions
		local completions
		completions=$(kubectl get job echo-job -n stone -o jsonpath='{.spec.completions}' 2>/dev/null)
		if [[ "$completions" == "5" ]]; then
			((score += 2))
			details+="Completions is 5. "
		else
			details+="Completions is $completions (expected 5). "
		fi

		# Check image
		local image
		image=$(kubectl get job echo-job -n stone -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score += 1))
			details+="Image is busybox."
		else
			details+="Image incorrect ($image)."
		fi
	else
		details+="Job echo-job not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q9: CronJob (5 points)
score_q9() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "cronjob" "date-job" "mist"; then
		((score += 2))
		details+="CronJob date-job exists. "

		# Check schedule
		local schedule
		schedule=$(kubectl get cronjob date-job -n mist -o jsonpath='{.spec.schedule}' 2>/dev/null)
		if [[ "$schedule" == "*/1 * * * *" || "$schedule" == "* * * * *" ]]; then
			((score += 2))
			details+="Schedule is every minute. "
		else
			details+="Schedule incorrect ($schedule). "
		fi

		# Check image
		local image
		image=$(kubectl get cronjob date-job -n mist -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score += 1))
			details+="Image is busybox."
		else
			details+="Image incorrect ($image)."
		fi
	else
		details+="CronJob date-job not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q10: Multi-Container Pod (6 points)
score_q10() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "multi-container" "alpine"; then
		((score += 2))
		details+="Pod multi-container exists. "

		# Check number of containers
		local container_count
		container_count=$(kubectl get pod multi-container -n alpine -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
		if [[ "$container_count" -eq 2 ]]; then
			((score += 2))
			details+="Has 2 containers. "
		else
			details+="Has $container_count containers (expected 2). "
		fi

		# Check both are busybox
		local images
		images=$(kubectl get pod multi-container -n alpine -o jsonpath='{.spec.containers[*].image}' 2>/dev/null)
		if [[ "$images" == *"busybox"*"busybox"* ]]; then
			((score += 2))
			details+="Both containers use busybox."
		else
			details+="Container images incorrect."
		fi
	else
		details+="Pod multi-container not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q11: Init Container (6 points)
score_q11() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "init-pod" "crest"; then
		((score += 2))
		details+="Pod init-pod exists. "

		# Check init container exists
		local init_name
		init_name=$(kubectl get pod init-pod -n crest -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
		if [[ -n "$init_name" ]]; then
			((score += 2))
			details+="Init container exists. "
		else
			details+="Init container not found. "
		fi

		# Check main container is nginx
		local main_image
		main_image=$(kubectl get pod init-pod -n crest -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [[ "$main_image" == *"nginx"* ]]; then
			((score += 1))
			details+="Main container is nginx. "
		else
			details+="Main container incorrect. "
		fi

		# Check volume
		local volume
		volume=$(kubectl get pod init-pod -n crest -o jsonpath='{.spec.volumes[0].emptyDir}' 2>/dev/null)
		if [[ "$volume" == "{}" ]]; then
			((score += 1))
			details+="EmptyDir volume configured."
		else
			details+="EmptyDir volume not found."
		fi
	else
		details+="Pod init-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q12: ConfigMap from Literals (4 points)
score_q12() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "configmap" "app-config" "peak"; then
		((score += 2))
		details+="ConfigMap app-config exists. "

		# Check foo=lala
		local foo
		foo=$(kubectl get cm app-config -n peak -o jsonpath='{.data.foo}' 2>/dev/null)
		if [[ "$foo" == "lala" ]]; then
			((score += 1))
			details+="foo=lala. "
		else
			details+="foo incorrect ($foo). "
		fi

		# Check foo2=lolo
		local foo2
		foo2=$(kubectl get cm app-config -n peak -o jsonpath='{.data.foo2}' 2>/dev/null)
		if [[ "$foo2" == "lolo" ]]; then
			((score += 1))
			details+="foo2=lolo."
		else
			details+="foo2 incorrect ($foo2)."
		fi
	else
		details+="ConfigMap app-config not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q13: ConfigMap as Environment Variable (5 points)
score_q13() {
	local score=0
	local max_points=5
	local details=""

	# Check ConfigMap
	if resource_exists "configmap" "options" "summit"; then
		((score += 1))
		details+="ConfigMap options exists. "

		local var5
		var5=$(kubectl get cm options -n summit -o jsonpath='{.data.var5}' 2>/dev/null)
		if [[ "$var5" == "val5" ]]; then
			((score += 1))
			details+="var5=val5 in ConfigMap. "
		else
			details+="var5 incorrect. "
		fi
	else
		details+="ConfigMap options not found. "
	fi

	# Check Pod
	if resource_exists "pod" "config-pod" "summit"; then
		((score += 1))
		details+="Pod config-pod exists. "

		# Check env var reference
		local env_ref
		env_ref=$(kubectl get pod config-pod -n summit -o jsonpath='{.spec.containers[0].env[?(@.name=="OPTION")].valueFrom.configMapKeyRef.name}' 2>/dev/null)
		if [[ "$env_ref" == "options" ]]; then
			((score += 2))
			details+="OPTION env uses ConfigMap options."
		else
			details+="OPTION env not configured correctly."
		fi
	else
		details+="Pod config-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q14: ConfigMap as Volume (5 points)
score_q14() {
	local score=0
	local max_points=5
	local details=""

	# Check ConfigMap
	if resource_exists "configmap" "cmvolume" "cliff"; then
		((score += 1))
		details+="ConfigMap cmvolume exists. "
	else
		details+="ConfigMap cmvolume not found. "
	fi

	# Check Pod
	if resource_exists "pod" "vol-pod" "cliff"; then
		((score += 2))
		details+="Pod vol-pod exists. "

		# Check volume mount path
		local mount_path
		mount_path=$(kubectl get pod vol-pod -n cliff -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		mount_path="${mount_path%/}" # Remove trailing slash
		if [[ "$mount_path" == "/etc/lala" ]]; then
			((score += 2))
			details+="Volume mounted at /etc/lala."
		else
			details+="Mount path incorrect ($mount_path)."
		fi
	else
		details+="Pod vol-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q15: Secret Creation and Usage (5 points)
score_q15() {
	local score=0
	local max_points=5
	local details=""

	# Check Secret
	if resource_exists "secret" "mysecret" "ridge"; then
		((score += 2))
		details+="Secret mysecret exists. "
	else
		details+="Secret mysecret not found. "
	fi

	# Check Pod
	if resource_exists "pod" "secret-pod" "ridge"; then
		((score += 1))
		details+="Pod secret-pod exists. "

		# Check volume mount path
		local mount_path
		mount_path=$(kubectl get pod secret-pod -n ridge -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		mount_path="${mount_path%/}"
		if [[ "$mount_path" == "/etc/foo" ]]; then
			((score += 2))
			details+="Secret mounted at /etc/foo."
		else
			details+="Mount path incorrect ($mount_path)."
		fi
	else
		details+="Pod secret-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q16: SecurityContext (5 points)
score_q16() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "secure-pod" "valley"; then
		((score += 2))
		details+="Pod secure-pod exists. "

		# Check runAsUser (pod-level or container-level)
		local run_as_user_pod run_as_user_container
		run_as_user_pod=$(kubectl get pod secure-pod -n valley -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
		run_as_user_container=$(kubectl get pod secure-pod -n valley -o jsonpath='{.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)

		if [[ "$run_as_user_pod" == "101" || "$run_as_user_container" == "101" ]]; then
			((score += 3))
			details+="runAsUser is 101."
		else
			details+="runAsUser incorrect (pod: $run_as_user_pod, container: $run_as_user_container)."
		fi
	else
		details+="Pod secure-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q17: Resource Requests and Limits (5 points)
score_q17() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "resource-pod" "cave"; then
		((score += 1))
		details+="Pod resource-pod exists. "

		# Check requests
		local cpu_req mem_req
		cpu_req=$(kubectl get pod resource-pod -n cave -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
		mem_req=$(kubectl get pod resource-pod -n cave -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)

		if [[ "$cpu_req" == "100m" ]]; then
			((score += 1))
			details+="CPU request is 100m. "
		else
			details+="CPU request incorrect ($cpu_req). "
		fi

		if [[ "$mem_req" == "256Mi" ]]; then
			((score += 1))
			details+="Memory request is 256Mi. "
		else
			details+="Memory request incorrect ($mem_req). "
		fi

		# Check limits
		local cpu_lim mem_lim
		cpu_lim=$(kubectl get pod resource-pod -n cave -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
		mem_lim=$(kubectl get pod resource-pod -n cave -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)

		if [[ "$cpu_lim" == "200m" ]]; then
			((score += 1))
			details+="CPU limit is 200m. "
		else
			details+="CPU limit incorrect ($cpu_lim). "
		fi

		if [[ "$mem_lim" == "512Mi" ]]; then
			((score += 1))
			details+="Memory limit is 512Mi."
		else
			details+="Memory limit incorrect ($mem_lim)."
		fi
	else
		details+="Pod resource-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q18: Liveness Probe (5 points)
score_q18() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "liveness-pod" "stone"; then
		((score += 2))
		details+="Pod liveness-pod exists. "

		# Check liveness probe exists (exec type)
		local exec_cmd
		exec_cmd=$(kubectl get pod liveness-pod -n stone -o jsonpath='{.spec.containers[0].livenessProbe.exec.command}' 2>/dev/null)
		if [[ -n "$exec_cmd" ]]; then
			((score += 1))
			details+="Exec liveness probe configured. "
		else
			details+="Liveness probe not found. "
		fi

		# Check initialDelaySeconds
		local initial_delay
		initial_delay=$(kubectl get pod liveness-pod -n stone -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
		if [[ "$initial_delay" == "5" ]]; then
			((score += 1))
			details+="initialDelaySeconds is 5. "
		else
			details+="initialDelaySeconds incorrect ($initial_delay). "
		fi

		# Check periodSeconds
		local period
		period=$(kubectl get pod liveness-pod -n stone -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
		if [[ "$period" == "5" ]]; then
			((score += 1))
			details+="periodSeconds is 5."
		else
			details+="periodSeconds incorrect ($period)."
		fi
	else
		details+="Pod liveness-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q19: Service and NetworkPolicy (6 points)
score_q19() {
	local score=0
	local max_points=6
	local details=""

	# Check Deployment
	if resource_exists "deployment" "web" "mist"; then
		((score += 1))
		details+="Deployment web exists. "

		local replicas
		replicas=$(kubectl get deployment web -n mist -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "2" ]]; then
			((score += 1))
			details+="Replicas is 2. "
		else
			details+="Replicas incorrect ($replicas). "
		fi
	else
		details+="Deployment web not found. "
	fi

	# Check Service
	if resource_exists "service" "web" "mist"; then
		((score += 1))
		details+="Service web exists. "
	else
		details+="Service web not found. "
	fi

	# Check NetworkPolicy
	if resource_exists "networkpolicy" "web-policy" "mist"; then
		((score += 2))
		details+="NetworkPolicy web-policy exists. "

		# Check ingress rule has access=granted selector
		local selector
		selector=$(kubectl get networkpolicy web-policy -n mist -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.access}' 2>/dev/null)
		if [[ "$selector" == "granted" ]]; then
			((score += 1))
			details+="Ingress from access=granted."
		else
			details+="Ingress selector incorrect."
		fi
	else
		details+="NetworkPolicy web-policy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q20: PersistentVolume and PersistentVolumeClaim (8 points)
score_q20() {
	local score=0
	local max_points=8
	local details=""

	# Check PV (cluster-scoped)
	if kubectl get pv myvolume &>/dev/null; then
		((score += 2))
		details+="PV myvolume exists. "

		# Check capacity
		local capacity
		capacity=$(kubectl get pv myvolume -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
		if [[ "$capacity" == "10Gi" ]]; then
			((score += 1))
			details+="Capacity is 10Gi. "
		else
			details+="Capacity incorrect ($capacity). "
		fi
	else
		details+="PV myvolume not found. "
	fi

	# Check PVC
	if resource_exists "persistentvolumeclaim" "mypvc" "alpine"; then
		((score += 2))
		details+="PVC mypvc exists. "

		# Check request
		local request
		request=$(kubectl get pvc mypvc -n alpine -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
		if [[ "$request" == "4Gi" ]]; then
			((score += 1))
			details+="PVC request is 4Gi. "
		else
			details+="PVC request incorrect ($request). "
		fi
	else
		details+="PVC mypvc not found. "
	fi

	# Check Pod
	if resource_exists "pod" "pv-pod" "alpine"; then
		((score += 1))
		details+="Pod pv-pod exists. "

		# Check mount path
		local mount_path
		mount_path=$(kubectl get pod pv-pod -n alpine -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		mount_path="${mount_path%/}"
		if [[ "$mount_path" == "/etc/foo" ]]; then
			((score += 1))
			details+="PVC mounted at /etc/foo."
		else
			details+="Mount path incorrect ($mount_path)."
		fi
	else
		details+="Pod pv-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
