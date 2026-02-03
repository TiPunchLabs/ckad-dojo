#!/bin/bash
# scoring-functions.sh - CKAD Simulation 8 Scoring Functions
# Dojo Inari (Harvest theme) - 20 questions, 100 points total
# Original questions: https://github.com/dgkanatsios/CKAD-exercises

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# Q1: Service ClusterIP and Endpoints (5 points)
score_q1() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "web" "harvest"; then
		((score += 2))
		details+="Pod web exists. "
	else
		details+="Pod web not found. "
	fi

	# Check Service exists
	if resource_exists "service" "web" "harvest"; then
		((score += 2))
		details+="Service web exists. "

		# Check endpoints
		local endpoints
		endpoints=$(kubectl get ep web -n harvest -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
		if [[ -n "$endpoints" ]]; then
			((score += 1))
			details+="Endpoints configured."
		else
			details+="No endpoints."
		fi
	else
		details+="Service web not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q2: Convert Service to NodePort (5 points)
score_q2() {
	local score=0
	local max_points=5
	local details=""

	# Check Service exists
	if resource_exists "service" "app-svc" "grain"; then
		((score += 2))
		details+="Service app-svc exists. "

		# Check type is NodePort
		local svc_type
		svc_type=$(kubectl get svc app-svc -n grain -o jsonpath='{.spec.type}' 2>/dev/null)
		if [[ "$svc_type" == "NodePort" ]]; then
			((score += 3))
			details+="Type is NodePort."
		else
			details+="Type is $svc_type (expected: NodePort)."
		fi
	else
		details+="Service app-svc not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q3: Deployment with Service (6 points)
score_q3() {
	local score=0
	local max_points=6
	local details=""

	# Check Deployment exists
	if resource_exists "deployment" "backend" "rice"; then
		((score += 2))
		details+="Deployment backend exists. "

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment backend -n rice -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "3" ]]; then
			((score += 1))
			details+="Replicas 3 correct. "
		else
			details+="Replicas incorrect ($replicas). "
		fi
	else
		details+="Deployment backend not found. "
	fi

	# Check Service exists
	if resource_exists "service" "backend" "rice"; then
		((score += 1))
		details+="Service backend exists. "

		# Check port
		local port
		port=$(kubectl get svc backend -n rice -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
		if [[ "$port" == "6262" ]]; then
			((score += 1))
			details+="Service port 6262 correct. "
		else
			details+="Service port incorrect ($port). "
		fi

		# Check target port
		local target_port
		target_port=$(kubectl get svc backend -n rice -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
		if [[ "$target_port" == "8080" ]]; then
			((score += 1))
			details+="Target port 8080 correct."
		else
			details+="Target port incorrect."
		fi
	else
		details+="Service backend not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q4: Readiness Probe HTTP (5 points)
score_q4() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "ready-pod" "field"; then
		((score += 2))
		details+="Pod ready-pod exists. "

		# Check readiness probe
		local http_path
		http_path=$(kubectl get pod ready-pod -n field -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
		if [[ "$http_path" == "/" ]]; then
			((score += 2))
			details+="Readiness probe path correct. "
		else
			details+="Readiness probe not configured. "
		fi

		local http_port
		http_port=$(kubectl get pod ready-pod -n field -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
		if [[ "$http_port" == "80" ]]; then
			((score += 1))
			details+="Readiness probe port correct."
		else
			details+="Readiness probe port incorrect."
		fi
	else
		details+="Pod ready-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q5: Liveness Probe with Delay (5 points)
score_q5() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "live-pod" "shrine"; then
		((score += 1))
		details+="Pod live-pod exists. "

		# Check liveness probe exec
		local exec_cmd
		exec_cmd=$(kubectl get pod live-pod -n shrine -o jsonpath='{.spec.containers[0].livenessProbe.exec.command}' 2>/dev/null)
		if [[ "$exec_cmd" == *"ls"* ]]; then
			((score += 1))
			details+="Exec command correct. "
		else
			details+="Exec command missing. "
		fi

		# Check initial delay
		local init_delay
		init_delay=$(kubectl get pod live-pod -n shrine -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
		if [[ "$init_delay" == "5" ]]; then
			((score += 1))
			details+="InitialDelay 5s correct. "
		else
			details+="InitialDelay incorrect. "
		fi

		# Check period
		local period
		period=$(kubectl get pod live-pod -n shrine -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
		if [[ "$period" == "10" ]]; then
			((score += 2))
			details+="Period 10s correct."
		else
			details+="Period incorrect."
		fi
	else
		details+="Pod live-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q6: LimitRange for Namespace (6 points)
score_q6() {
	local score=0
	local max_points=6
	local details=""

	# Check LimitRange exists
	if resource_exists "limitrange" "pod-limits" "blessing"; then
		((score += 2))
		details+="LimitRange pod-limits exists. "

		# Check max memory
		local max_mem
		max_mem=$(kubectl get limitrange pod-limits -n blessing -o jsonpath='{.spec.limits[0].max.memory}' 2>/dev/null)
		if [[ "$max_mem" == "500Mi" ]]; then
			((score += 2))
			details+="Max memory 500Mi correct. "
		else
			details+="Max memory incorrect ($max_mem). "
		fi

		# Check min memory
		local min_mem
		min_mem=$(kubectl get limitrange pod-limits -n blessing -o jsonpath='{.spec.limits[0].min.memory}' 2>/dev/null)
		if [[ "$min_mem" == "100Mi" ]]; then
			((score += 2))
			details+="Min memory 100Mi correct."
		else
			details+="Min memory incorrect ($min_mem)."
		fi
	else
		details+="LimitRange pod-limits not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q7: ResourceQuota with Requests and Limits (6 points)
score_q7() {
	local score=0
	local max_points=6
	local details=""

	# Check ResourceQuota exists
	if resource_exists "resourcequota" "compute-quota" "fortune"; then
		((score += 2))
		details+="ResourceQuota compute-quota exists. "

		# Check requests.cpu
		local req_cpu
		req_cpu=$(kubectl get quota compute-quota -n fortune -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
		if [[ "$req_cpu" == "1" ]]; then
			((score += 1))
			details+="requests.cpu correct. "
		else
			details+="requests.cpu incorrect. "
		fi

		# Check requests.memory
		local req_mem
		req_mem=$(kubectl get quota compute-quota -n fortune -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)
		if [[ "$req_mem" == "1Gi" ]]; then
			((score += 1))
			details+="requests.memory correct. "
		else
			details+="requests.memory incorrect. "
		fi

		# Check limits.cpu
		local lim_cpu
		lim_cpu=$(kubectl get quota compute-quota -n fortune -o jsonpath='{.spec.hard.limits\.cpu}' 2>/dev/null)
		if [[ "$lim_cpu" == "2" ]]; then
			((score += 1))
			details+="limits.cpu correct. "
		else
			details+="limits.cpu incorrect. "
		fi

		# Check limits.memory
		local lim_mem
		lim_mem=$(kubectl get quota compute-quota -n fortune -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)
		if [[ "$lim_mem" == "2Gi" ]]; then
			((score += 1))
			details+="limits.memory correct."
		else
			details+="limits.memory incorrect."
		fi
	else
		details+="ResourceQuota compute-quota not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q8: Pod within ResourceQuota (5 points)
score_q8() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "quota-pod" "fortune"; then
		((score += 2))
		details+="Pod quota-pod exists. "

		# Check resources are set
		local req_cpu
		req_cpu=$(kubectl get pod quota-pod -n fortune -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
		if [[ -n "$req_cpu" ]]; then
			((score += 1))
			details+="Resource requests set. "
		else
			details+="Resource requests missing. "
		fi

		local lim_cpu
		lim_cpu=$(kubectl get pod quota-pod -n fortune -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
		if [[ -n "$lim_cpu" ]]; then
			((score += 2))
			details+="Resource limits set."
		else
			details+="Resource limits missing."
		fi
	else
		details+="Pod quota-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q9: Security Context with Capabilities (6 points)
score_q9() {
	local score=0
	local max_points=6
	local details=""

	# Check Pod exists
	if resource_exists "pod" "cap-pod" "golden"; then
		((score += 2))
		details+="Pod cap-pod exists. "

		# Check capabilities
		local caps
		caps=$(kubectl get pod cap-pod -n golden -o jsonpath='{.spec.containers[0].securityContext.capabilities.add}' 2>/dev/null)
		if [[ "$caps" == *"NET_ADMIN"* ]]; then
			((score += 2))
			details+="NET_ADMIN capability added. "
		else
			details+="NET_ADMIN capability missing. "
		fi

		if [[ "$caps" == *"SYS_TIME"* ]]; then
			((score += 2))
			details+="SYS_TIME capability added."
		else
			details+="SYS_TIME capability missing."
		fi
	else
		details+="Pod cap-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q10: Shared Volume Between Containers (6 points)
score_q10() {
	local score=0
	local max_points=6
	local details=""

	# Check Pod exists
	if resource_exists "pod" "shared-pod" "bounty"; then
		((score += 2))
		details+="Pod shared-pod exists. "

		# Check two containers
		local container_count
		container_count=$(kubectl get pod shared-pod -n bounty -o jsonpath='{.spec.containers}' 2>/dev/null | grep -o '"name"' | wc -l)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 2))
			details+="Two containers present. "
		else
			details+="Less than 2 containers. "
		fi

		# Check emptyDir volume
		local vol_type
		vol_type=$(kubectl get pod shared-pod -n bounty -o jsonpath='{.spec.volumes[0].emptyDir}' 2>/dev/null)
		if [[ "$vol_type" == "{}" ]]; then
			((score += 2))
			details+="emptyDir volume configured."
		else
			details+="emptyDir volume missing."
		fi
	else
		details+="Pod shared-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q11: Annotations (4 points)
score_q11() {
	local score=0
	local max_points=4
	local details=""

	# Check Pod exists
	if resource_exists "pod" "annotated-pod" "prosperity"; then
		((score += 2))
		details+="Pod annotated-pod exists. "

		# Check annotation
		local annotation
		annotation=$(kubectl get pod annotated-pod -n prosperity -o jsonpath='{.metadata.annotations.owner}' 2>/dev/null)
		if [[ "$annotation" == "marketing" ]]; then
			((score += 2))
			details+="Annotation owner=marketing correct."
		else
			details+="Annotation missing or incorrect."
		fi
	else
		details+="Pod annotated-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q12: Labels Selection (5 points)
score_q12() {
	local score=0
	local max_points=5
	local details=""

	# Check pods exist with labels
	local prod_pods
	prod_pods=$(kubectl get pods -n harvest -l env=prod -o name 2>/dev/null | wc -l)
	if [[ "$prod_pods" -ge 2 ]]; then
		((score += 2))
		details+="Pods with env=prod exist. "
	else
		details+="Not enough pods with env=prod. "
	fi

	local dev_pods
	dev_pods=$(kubectl get pods -n harvest -l env=dev -o name 2>/dev/null | wc -l)
	if [[ "$dev_pods" -ge 1 ]]; then
		((score += 1))
		details+="Pod with env=dev exists. "
	else
		details+="No pod with env=dev. "
	fi

	# Check file exists
	if file_exists_and_not_empty "./exam/course/12/pods.txt"; then
		((score += 2))
		details+="Pods file saved."
	else
		details+="Pods file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q13: Helm Add Repository (4 points)
score_q13() {
	local score=0
	local max_points=4
	local details=""

	# Check bitnami repo exists
	local repo
	repo=$(helm repo list 2>/dev/null | grep -i bitnami)
	if [[ -n "$repo" ]]; then
		((score += 4))
		details+="Bitnami repo added."
	else
		details+="Bitnami repo not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q14: Helm Show Values (5 points)
score_q14() {
	local score=0
	local max_points=5
	local details=""

	# Check file exists
	if file_exists_and_not_empty "./exam/course/14/values.txt"; then
		((score += 5))
		details+="Values file saved."
	else
		details+="Values file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q15: Helm List Releases (4 points)
score_q15() {
	local score=0
	local max_points=4
	local details=""

	# Check file exists
	if [ -f "./exam/course/15/releases.txt" ]; then
		((score += 4))
		details+="Releases file saved."
	else
		details+="Releases file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q16: Canary Deployment Setup (6 points)
score_q16() {
	local score=0
	local max_points=6
	local details=""

	# Check app-v1 deployment
	if resource_exists "deployment" "app-v1" "grain"; then
		((score += 1))
		details+="Deployment app-v1 exists. "

		local v1_replicas
		v1_replicas=$(kubectl get deployment app-v1 -n grain -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$v1_replicas" == "3" ]]; then
			((score += 1))
			details+="app-v1 replicas correct. "
		fi
	else
		details+="Deployment app-v1 not found. "
	fi

	# Check app-v2 deployment
	if resource_exists "deployment" "app-v2" "grain"; then
		((score += 1))
		details+="Deployment app-v2 exists. "

		local v2_replicas
		v2_replicas=$(kubectl get deployment app-v2 -n grain -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$v2_replicas" == "1" ]]; then
			((score += 1))
			details+="app-v2 replicas correct. "
		fi
	else
		details+="Deployment app-v2 not found. "
	fi

	# Check Service
	if resource_exists "service" "app" "grain"; then
		((score += 2))
		details+="Service app exists."
	else
		details+="Service app not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q17: emptyDir Volume for Data Sharing (5 points)
score_q17() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "data-pod" "rice"; then
		((score += 2))
		details+="Pod data-pod exists. "

		# Check two containers
		local container_count
		container_count=$(kubectl get pod data-pod -n rice -o jsonpath='{.spec.containers}' 2>/dev/null | grep -o '"name"' | wc -l)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 2))
			details+="Two containers present. "
		else
			details+="Less than 2 containers. "
		fi

		# Check emptyDir
		local vol_type
		vol_type=$(kubectl get pod data-pod -n rice -o jsonpath='{.spec.volumes[?(@.name=="data-volume")].emptyDir}' 2>/dev/null)
		if [[ "$vol_type" == "{}" ]]; then
			((score += 1))
			details+="emptyDir volume data-volume exists."
		else
			details+="Volume data-volume missing."
		fi
	else
		details+="Pod data-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q18: Pod DNS Resolution (5 points)
score_q18() {
	local score=0
	local max_points=5
	local details=""

	# Check file exists
	if file_exists_and_not_empty "./exam/course/18/dns.txt"; then
		((score += 5))
		details+="DNS file saved."
	else
		details+="DNS file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q19: Network Policy Allow Specific Label (6 points)
score_q19() {
	local score=0
	local max_points=6
	local details=""

	# Check NetworkPolicy exists
	if resource_exists "networkpolicy" "db-policy" "shrine"; then
		((score += 2))
		details+="NetworkPolicy db-policy exists. "

		# Check podSelector
		local pod_selector
		pod_selector=$(kubectl get networkpolicy db-policy -n shrine -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
		if [[ "$pod_selector" == "db" ]]; then
			((score += 2))
			details+="PodSelector app=db correct. "
		else
			details+="PodSelector incorrect. "
		fi

		# Check ingress from
		local ingress_label
		ingress_label=$(kubectl get networkpolicy db-policy -n shrine -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.access}' 2>/dev/null)
		if [[ "$ingress_label" == "true" ]]; then
			((score += 2))
			details+="Ingress from access=true correct."
		else
			details+="Ingress rule incorrect."
		fi
	else
		details+="NetworkPolicy db-policy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q20: Generate API Token for ServiceAccount (5 points)
score_q20() {
	local score=0
	local max_points=5
	local details=""

	# Check ServiceAccount exists
	if resource_exists "serviceaccount" "token-sa" "blessing"; then
		((score += 2))
		details+="ServiceAccount token-sa exists. "
	else
		details+="ServiceAccount token-sa not found. "
	fi

	# Check token file
	if file_exists_and_not_empty "./exam/course/20/token.txt"; then
		((score += 3))
		details+="Token file saved."
	else
		details+="Token file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
