#!/bin/bash
# scoring-functions.sh - CKAD Simulation 4 Scoring Functions
# Dojo Genbu (Ocean/Water theme) - 20 questions, 105 points total

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# Helper function to check a condition and return result
check_criterion() {
	if eval "$1" &>/dev/null; then
		return 0
	else
		return 1
	fi
}

# Q1: ResourceQuota (5 points)
score_q1() {
	local score=0
	local max_points=5

	# Check ResourceQuota exists
	if kubectl get resourcequota namespace-limits -n shell &>/dev/null; then
		((score++))

		# Check pods limit
		local pods_limit
		pods_limit=$(kubectl get resourcequota namespace-limits -n shell -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
		if [ "$pods_limit" = "10" ]; then
			((score++))
		fi

		# Check CPU requests limit
		local cpu_req
		cpu_req=$(kubectl get resourcequota namespace-limits -n shell -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
		if [ "$cpu_req" = "4" ]; then
			((score++))
		fi

		# Check memory requests limit
		local mem_req
		mem_req=$(kubectl get resourcequota namespace-limits -n shell -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)
		if [ "$mem_req" = "4Gi" ]; then
			((score++))
		fi

		# Check configmaps limit
		local cm_limit
		cm_limit=$(kubectl get resourcequota namespace-limits -n shell -o jsonpath='{.spec.hard.configmaps}' 2>/dev/null)
		if [ "$cm_limit" = "10" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q2: HorizontalPodAutoscaler (6 points)
score_q2() {
	local score=0
	local max_points=6

	# Check HPA exists
	if kubectl get hpa web-app-hpa -n ocean &>/dev/null; then
		((score++))

		# Check target deployment
		local target
		target=$(kubectl get hpa web-app-hpa -n ocean -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
		if [ "$target" = "web-app" ]; then
			((score++))
		fi

		# Check min replicas
		local min_rep
		min_rep=$(kubectl get hpa web-app-hpa -n ocean -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
		if [ "$min_rep" = "2" ]; then
			((score++))
		fi

		# Check max replicas
		local max_rep
		max_rep=$(kubectl get hpa web-app-hpa -n ocean -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
		if [ "$max_rep" = "10" ]; then
			((score++))
		fi

		# Check CPU target (70%)
		local cpu_target
		cpu_target=$(kubectl get hpa web-app-hpa -n ocean -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)
		if [ "$cpu_target" = "70" ]; then
			((score++))
		fi

		# Check HPA is active (has reference)
		local ref_kind
		ref_kind=$(kubectl get hpa web-app-hpa -n ocean -o jsonpath='{.spec.scaleTargetRef.kind}' 2>/dev/null)
		if [ "$ref_kind" = "Deployment" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q3: StatefulSet (8 points)
score_q3() {
	local score=0
	local max_points=8

	# Check StatefulSet exists
	if kubectl get statefulset db-cluster -n reef &>/dev/null; then
		((score++))

		# Check replicas
		local replicas
		replicas=$(kubectl get statefulset db-cluster -n reef -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [ "$replicas" = "3" ]; then
			((score++))
		fi

		# Check image
		local image
		image=$(kubectl get statefulset db-cluster -n reef -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"redis"* ]]; then
			((score++))
		fi

		# Check serviceName
		local svc_name
		svc_name=$(kubectl get statefulset db-cluster -n reef -o jsonpath='{.spec.serviceName}' 2>/dev/null)
		if [ "$svc_name" = "db-headless" ]; then
			((score++))
		fi

		# Check volumeClaimTemplates exist
		if kubectl get statefulset db-cluster -n reef -o jsonpath='{.spec.volumeClaimTemplates[0].metadata.name}' | grep -q "data"; then
			((score++))
		fi
	fi

	# Check headless service exists
	if kubectl get service db-headless -n reef &>/dev/null; then
		((score++))

		# Check clusterIP is None
		local cluster_ip
		cluster_ip=$(kubectl get service db-headless -n reef -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
		if [ "$cluster_ip" = "None" ]; then
			((score++))
		fi

		# Check port
		local port
		port=$(kubectl get service db-headless -n reef -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
		if [ "$port" = "6379" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q4: DaemonSet (6 points)
score_q4() {
	local score=0
	local max_points=6

	# Check DaemonSet exists
	if kubectl get daemonset node-monitor -n deep &>/dev/null; then
		((score++))

		# Check image
		local image
		image=$(kubectl get daemonset node-monitor -n deep -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score++))
		fi

		# Check container name
		local container_name
		container_name=$(kubectl get daemonset node-monitor -n deep -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
		if [ "$container_name" = "monitor" ]; then
			((score++))
		fi

		# Check NODE_NAME env var exists with fieldRef
		if kubectl get daemonset node-monitor -n deep -o jsonpath='{.spec.template.spec.containers[0].env[*].valueFrom.fieldRef.fieldPath}' | grep -q "spec.nodeName"; then
			((score++))
		fi

		# Check toleration for control-plane
		if kubectl get daemonset node-monitor -n deep -o jsonpath='{.spec.template.spec.tolerations[*].key}' | grep -q "node-role.kubernetes.io/control-plane"; then
			((score++))
		fi

		# Check DaemonSet is running on nodes
		local desired
		desired=$(kubectl get daemonset node-monitor -n deep -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)
		if [ "$desired" -ge 1 ] 2>/dev/null; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q5: PriorityClass (5 points)
score_q5() {
	local score=0
	local max_points=5

	# Check PriorityClass exists
	if kubectl get priorityclass critical-priority &>/dev/null; then
		((score++))

		# Check value
		local value
		value=$(kubectl get priorityclass critical-priority -o jsonpath='{.value}' 2>/dev/null)
		if [ "$value" = "1000000" ]; then
			((score++))
		fi

		# Check not global default
		local default
		default=$(kubectl get priorityclass critical-priority -o jsonpath='{.globalDefault}' 2>/dev/null)
		if [ "$default" != "true" ]; then
			((score++))
		fi
	fi

	# Check Pod exists with priority class
	if kubectl get pod critical-pod -n tide &>/dev/null; then
		((score++))

		# Check pod uses priority class
		local pod_priority
		pod_priority=$(kubectl get pod critical-pod -n tide -o jsonpath='{.spec.priorityClassName}' 2>/dev/null)
		if [ "$pod_priority" = "critical-priority" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q6: startupProbe (5 points)
score_q6() {
	local score=0
	local max_points=5

	# Check Pod exists
	if kubectl get pod slow-starter -n wave &>/dev/null; then
		((score++))

		# Check startupProbe exists
		if kubectl get pod slow-starter -n wave -o jsonpath='{.spec.containers[0].startupProbe}' | grep -q "httpGet"; then
			((score++))
		fi

		# Check startupProbe failureThreshold
		local failure
		failure=$(kubectl get pod slow-starter -n wave -o jsonpath='{.spec.containers[0].startupProbe.failureThreshold}' 2>/dev/null)
		if [ "$failure" = "30" ]; then
			((score++))
		fi

		# Check livenessProbe exists
		if kubectl get pod slow-starter -n wave -o jsonpath='{.spec.containers[0].livenessProbe}' | grep -q "httpGet"; then
			((score++))
		fi

		# Check pod is running
		local phase
		phase=$(kubectl get pod slow-starter -n wave -o jsonpath='{.status.phase}' 2>/dev/null)
		if [ "$phase" = "Running" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q7: Pod Affinity (6 points)
score_q7() {
	local score=0
	local max_points=6

	# Check Deployment exists
	if kubectl get deployment web-frontend -n coral &>/dev/null; then
		((score++))

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment web-frontend -n coral -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [ "$replicas" = "3" ]; then
			((score++))
		fi

		# Check labels
		if kubectl get deployment web-frontend -n coral -o jsonpath='{.spec.template.metadata.labels.app}' | grep -q "web-frontend"; then
			((score++))
		fi

		# Check preferredDuringSchedulingIgnoredDuringExecution affinity exists
		if kubectl get deployment web-frontend -n coral -o jsonpath='{.spec.template.spec.affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution}' | grep -q "weight"; then
			((score++))
		fi

		# Check topology key
		if kubectl get deployment web-frontend -n coral -o jsonpath='{.spec.template.spec.affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey}' | grep -q "kubernetes.io/hostname"; then
			((score++))
		fi

		# Check label selector for cache
		if kubectl get deployment web-frontend -n coral -o yaml | grep -q "app: cache"; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q8: Ingress with Path Routing (6 points)
score_q8() {
	local score=0
	local max_points=6

	# Check Ingress exists
	if kubectl get ingress api-routing -n lagoon &>/dev/null; then
		((score++))

		# Check host
		local host
		host=$(kubectl get ingress api-routing -n lagoon -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
		if [ "$host" = "api.lagoon.local" ]; then
			((score++))
		fi

		# Check /v1 path exists
		if kubectl get ingress api-routing -n lagoon -o yaml | grep -q "/v1"; then
			((score++))
		fi

		# Check /v2 path exists
		if kubectl get ingress api-routing -n lagoon -o yaml | grep -q "/v2"; then
			((score++))
		fi

		# Check api-v1-svc backend
		if kubectl get ingress api-routing -n lagoon -o yaml | grep -q "api-v1-svc"; then
			((score++))
		fi

		# Check api-v2-svc backend
		if kubectl get ingress api-routing -n lagoon -o yaml | grep -q "api-v2-svc"; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q9: Job with Completions and Parallelism (5 points)
score_q9() {
	local score=0
	local max_points=5

	# Check Job exists
	if kubectl get job parallel-processor -n current &>/dev/null; then
		((score++))

		# Check completions
		local completions
		completions=$(kubectl get job parallel-processor -n current -o jsonpath='{.spec.completions}' 2>/dev/null)
		if [ "$completions" = "6" ]; then
			((score++))
		fi

		# Check parallelism
		local parallelism
		parallelism=$(kubectl get job parallel-processor -n current -o jsonpath='{.spec.parallelism}' 2>/dev/null)
		if [ "$parallelism" = "3" ]; then
			((score++))
		fi

		# Check backoffLimit
		local backoff
		backoff=$(kubectl get job parallel-processor -n current -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
		if [ "$backoff" = "4" ]; then
			((score++))
		fi

		# Check container name
		local container
		container=$(kubectl get job parallel-processor -n current -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
		if [ "$container" = "processor" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q10: kubectl debug (4 points)
score_q10() {
	local score=0
	local max_points=4

	# Check original pod exists
	if kubectl get pod troubled-app -n anchor &>/dev/null; then
		((score++))
	fi

	# Check output file exists
	if [ -f "./exam/course/10/debug-output.txt" ]; then
		((score++))

		# Check file has content
		if [ -s "./exam/course/10/debug-output.txt" ]; then
			((score++))
		fi

		# Check file contains directory listing
		if grep -q "data" "./exam/course/10/debug-output.txt" 2>/dev/null || grep -q "total" "./exam/course/10/debug-output.txt" 2>/dev/null; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q11: EndpointSlice (3 points)
score_q11() {
	local score=0
	local max_points=3

	# Check service exists
	if kubectl get service backend-svc -n shell &>/dev/null; then
		((score++))
	fi

	# Check output file exists
	if [ -f "./exam/course/11/endpoints-info.txt" ]; then
		((score++))

		# Check file has endpoint information
		if [ -s "./exam/course/11/endpoints-info.txt" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q12: Service internalTrafficPolicy (4 points)
score_q12() {
	local score=0
	local max_points=4

	# Check Service exists
	if kubectl get service local-svc -n ocean &>/dev/null; then
		((score++))

		# Check internalTrafficPolicy is Local
		local policy
		policy=$(kubectl get service local-svc -n ocean -o jsonpath='{.spec.internalTrafficPolicy}' 2>/dev/null)
		if [ "$policy" = "Local" ]; then
			((score += 3))
		fi
	fi

	echo "$score/$max_points"
}

# Q13: EmptyDir with sizeLimit (4 points)
score_q13() {
	local score=0
	local max_points=4

	# Check Pod exists
	if kubectl get pod cache-pod -n reef &>/dev/null; then
		((score++))

		# Check emptyDir volume with sizeLimit
		if kubectl get pod cache-pod -n reef -o jsonpath='{.spec.volumes[*].emptyDir.sizeLimit}' | grep -q "100Mi"; then
			((score++))
		fi

		# Check medium is Memory
		if kubectl get pod cache-pod -n reef -o jsonpath='{.spec.volumes[*].emptyDir.medium}' | grep -q "Memory"; then
			((score++))
		fi

		# Check mount path
		if kubectl get pod cache-pod -n reef -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}' | grep -q "/cache"; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q14: Secret with stringData (4 points)
score_q14() {
	local score=0
	local max_points=4

	# Check Secret exists
	if kubectl get secret app-credentials -n deep &>/dev/null; then
		((score++))

		# Check immutable
		local immutable
		immutable=$(kubectl get secret app-credentials -n deep -o jsonpath='{.immutable}' 2>/dev/null)
		if [ "$immutable" = "true" ]; then
			((score++))
		fi
	fi

	# Check Pod exists
	if kubectl get pod secret-consumer -n deep &>/dev/null; then
		((score++))

		# Check secret is mounted
		if kubectl get pod secret-consumer -n deep -o jsonpath='{.spec.volumes[*].secret.secretName}' | grep -q "app-credentials"; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q15: kubectl patch (5 points)
score_q15() {
	local score=0
	local max_points=5

	# Check Deployment exists
	if kubectl get deployment patch-demo -n tide &>/dev/null; then
		((score++))

		# Check image is updated
		local image
		image=$(kubectl get deployment patch-demo -n tide -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [ "$image" = "nginx:1.22" ]; then
			((score++))
		fi

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment patch-demo -n tide -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [ "$replicas" = "4" ]; then
			((score++))
		fi

		# Check ENV_MODE env var
		if kubectl get deployment patch-demo -n tide -o yaml | grep -q "production"; then
			((score++))
		fi
	fi

	# Check patch commands file exists
	if [ -f "./exam/course/15/patch-commands.sh" ]; then
		((score++))
	fi

	echo "$score/$max_points"
}

# Q16: NetworkPolicy with IPBlock (8 points)
score_q16() {
	local score=0
	local max_points=8

	# Check NetworkPolicy exists
	if kubectl get networkpolicy external-access -n wave &>/dev/null; then
		((score++))

		# Check podSelector
		if kubectl get networkpolicy external-access -n wave -o jsonpath='{.spec.podSelector.matchLabels.tier}' | grep -q "api"; then
			((score++))
		fi

		# Check ingress rule exists
		if kubectl get networkpolicy external-access -n wave -o jsonpath='{.spec.ingress}' | grep -q "from"; then
			((score++))
		fi

		# Check ipBlock in ingress
		if kubectl get networkpolicy external-access -n wave -o yaml | grep -q "ipBlock"; then
			((score++))
		fi

		# Check except block
		if kubectl get networkpolicy external-access -n wave -o yaml | grep -q "except"; then
			((score++))
		fi

		# Check egress rule exists
		if kubectl get networkpolicy external-access -n wave -o jsonpath='{.spec.egress}' | grep -q "to"; then
			((score++))
		fi

		# Check DNS port 53
		if kubectl get networkpolicy external-access -n wave -o yaml | grep -q "53"; then
			((score++))
		fi

		# Check HTTPS port 443
		if kubectl get networkpolicy external-access -n wave -o yaml | grep -q "443"; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q17: Pod with hostNetwork (5 points)
score_q17() {
	local score=0
	local max_points=5

	# Check Pod exists
	if kubectl get pod network-diagnostic -n coral &>/dev/null; then
		((score++))

		# Check hostNetwork
		local host_net
		host_net=$(kubectl get pod network-diagnostic -n coral -o jsonpath='{.spec.hostNetwork}' 2>/dev/null)
		if [ "$host_net" = "true" ]; then
			((score++))
		fi

		# Check hostPID
		local host_pid
		host_pid=$(kubectl get pod network-diagnostic -n coral -o jsonpath='{.spec.hostPID}' 2>/dev/null)
		if [ "$host_pid" = "true" ]; then
			((score++))
		fi

		# Check container name
		local container
		container=$(kubectl get pod network-diagnostic -n coral -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
		if [ "$container" = "netshoot" ]; then
			((score++))
		fi

		# Check pod is running
		local phase
		phase=$(kubectl get pod network-diagnostic -n coral -o jsonpath='{.status.phase}' 2>/dev/null)
		if [ "$phase" = "Running" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q18: ClusterRole and ClusterRoleBinding (6 points)
score_q18() {
	local score=0
	local max_points=6

	# Check ServiceAccount exists
	if kubectl get serviceaccount node-monitor-sa -n lagoon &>/dev/null; then
		((score++))
	fi

	# Check ClusterRole exists
	if kubectl get clusterrole node-reader &>/dev/null; then
		((score++))

		# Check nodes permission
		if kubectl get clusterrole node-reader -o yaml | grep -q "nodes"; then
			((score++))
		fi

		# Check namespaces permission
		if kubectl get clusterrole node-reader -o yaml | grep -q "namespaces"; then
			((score++))
		fi
	fi

	# Check ClusterRoleBinding exists
	if kubectl get clusterrolebinding node-reader-binding &>/dev/null; then
		((score++))

		# Check binding to correct SA
		if kubectl get clusterrolebinding node-reader-binding -o yaml | grep -q "node-monitor-sa"; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q19: kubectl auth can-i (4 points)
score_q19() {
	local score=0
	local max_points=4

	# Check ServiceAccount exists
	if kubectl get serviceaccount app-deployer -n current &>/dev/null; then
		((score++))
	fi

	# Check permissions file exists
	if [ -f "./exam/course/19/permissions.txt" ]; then
		((score++))

		# Check file has content
		if [ -s "./exam/course/19/permissions.txt" ]; then
			((score++))
		fi

		# Check file has correct format
		if grep -q "deployments" "./exam/course/19/permissions.txt" 2>/dev/null; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}

# Q20: Multi-Container with Shared Volume (6 points)
score_q20() {
	local score=0
	local max_points=6

	# Check Pod exists
	if kubectl get pod data-pipeline -n anchor &>/dev/null; then
		((score++))

		# Check producer container
		if kubectl get pod data-pipeline -n anchor -o jsonpath='{.spec.containers[*].name}' | grep -q "producer"; then
			((score++))
		fi

		# Check consumer container
		if kubectl get pod data-pipeline -n anchor -o jsonpath='{.spec.containers[*].name}' | grep -q "consumer"; then
			((score++))
		fi

		# Check monitor container
		if kubectl get pod data-pipeline -n anchor -o jsonpath='{.spec.containers[*].name}' | grep -q "monitor"; then
			((score++))
		fi

		# Check emptyDir volume
		if kubectl get pod data-pipeline -n anchor -o jsonpath='{.spec.volumes[*].emptyDir}' | grep -q "{}"; then
			((score++))
		fi

		# Check pod is running
		local phase
		phase=$(kubectl get pod data-pipeline -n anchor -o jsonpath='{.status.phase}' 2>/dev/null)
		if [ "$phase" = "Running" ]; then
			((score++))
		fi
	fi

	echo "$score/$max_points"
}
