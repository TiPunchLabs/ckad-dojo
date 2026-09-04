#!/bin/bash
# CKAD Simulation 19 - Scoring Functions
# Total Points: 120

CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

EXAM_DIR="${EXAM_DIR:-./exam/course}"

score_q1() {
	local score=0
	local max_points=6
	local details=""

	if
		[ -f "$EXAM_DIR/19/q1/Dockerfile" ]
		from_cnt=$(grep -ci "FROM" "$EXAM_DIR/19/q1/Dockerfile")
	then
		if [ "$from_cnt" -ge 2 ]; then
			score=$((score + 3))
			details="Multi-stage Dockerfile present (3/3). "
		else
			details="Dockerfile not multi-stage (0/3). "
		fi
	else
		details="Dockerfile not found (0/3). "
	fi

	if resource_exists "pod" "optimized-build" "ward"; then
		score=$((score + 3))
		details+="Pod optimized-build found (3/3)."
	else
		details+="Pod optimized-build missing (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q2() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "logging-pod" "aegis"; then
		score=$((score + 2))
		details="Pod exists (2/2). "
		local containers=$(kubectl get pod logging-pod -n aegis -o jsonpath='{.spec.containers[*].name}')
		if [[ "$containers" == *"app-container"* ]] && [[ "$containers" == *"log-tailer"* ]]; then
			score=$((score + 2))
			details+="Containers exist (2/2). "
		else
			details+="Containers missing (0/2). "
		fi
		local requests=$(kubectl get pod logging-pod -n aegis -o jsonpath='{.spec.containers[?(@.name=="app-container")].resources.requests.cpu}')
		if [[ -n "$requests" ]]; then
			score=$((score + 2))
			details+="Resources set (2/2)."
		else
			details+="Resources missing (0/2)."
		fi
	else
		details="Pod missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q3() {
	local score=0
	local max_points=6
	local details=""

	local sus=$(kubectl get cronjob backup-cj -n shield -o jsonpath='{.spec.suspend}')
	if [[ "$sus" == "true" ]]; then
		score=$((score + 3))
		details="CronJob suspended (3/3). "
	else
		details="CronJob not suspended (0/3). "
	fi

	if resource_exists "job" "manual-backup" "shield"; then
		score=$((score + 3))
		details+="Manual job exists (3/3)."
	else
		details+="Manual job missing (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q4() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "init-chain" "guardian"; then
		score=$((score + 2))
		details="Pod exists (2/2). "
		local init_count=$(kubectl get pod init-chain -n guardian -o jsonpath='{.spec.initContainers}' | grep -o name | wc -l)
		if [ "$init_count" -ge 3 ]; then
			score=$((score + 4))
			details+="3 init containers found (4/4)."
		else
			details+="Not enough init containers (0/4)."
		fi
	else
		details="Pod missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q5() {
	local score=0
	local max_points=6
	local details=""

	local reps=$(helm get values guardian-app -n haven -o json | grep replicaCount | grep -o '"replicaCount":[0-9]*' | grep -o '[0-9]*')
	if [[ "$reps" == "3" ]]; then
		score=$((score + 3))
		details="Replica count updated to 3 (3/3). "
	else
		details="Replica count not updated (0/3). "
	fi

	local img=$(helm get values guardian-app -n haven -o json | grep tag)
	if [[ "$img" == *"latest"* ]]; then
		score=$((score + 3))
		details+="Image tag updated to latest (3/3)."
	else
		details+="Image tag not updated (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q6() {
	local score=0
	local max_points=6
	local details=""

	local target=$(kubectl get hpa api-hpa -n refuge -o jsonpath='{.spec.scaleTargetRef.name}')
	if [[ "$target" == "api-server" ]]; then
		score=$((score + 3))
		details="HPA target fixed (3/3). "
	else
		details="HPA target wrong (0/3). "
	fi

	local min_reps=$(kubectl get hpa api-hpa -n refuge -o jsonpath='{.spec.minReplicas}')
	if [[ "$min_reps" == "2" ]]; then
		score=$((score + 3))
		details+="HPA minReplicas fixed (3/3)."
	else
		details+="HPA minReplicas wrong (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q7() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "deployment" "worker-deploy" "bastion"; then
		local nginx_img=$(kubectl get deployment worker-deploy -n bastion -o jsonpath='{.spec.template.spec.containers[?(@.name=="nginx")].image}')
		if [[ "$nginx_img" == "nginx:1.24.0" ]]; then
			score=$((score + 3))
			details="Nginx rollback successful (3/3). "
		else
			details="Nginx rollback failed (0/3). "
		fi
		local redis_img=$(kubectl get deployment worker-deploy -n bastion -o jsonpath='{.spec.template.spec.containers[?(@.name=="redis")].image}')
		if [[ "$redis_img" == "redis:6.2" ]] || [[ "$redis_img" == "redis:7.0" ]]; then
			score=$((score + 3))
			details+="Redis container OK (3/3)."
		else
			details+="Redis container issue (0/3)."
		fi
	else
		details="Deployment missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q8() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "deployment" "my-app" "bulwark"; then
		score=$((score + 3))
		details="Deployment applied to bulwark (3/3). "
		local reps=$(kubectl get deployment my-app -n bulwark -o jsonpath='{.spec.replicas}')
		if [[ "$reps" == "4" ]]; then
			score=$((score + 3))
			details+="Replicas patched to 4 (3/3)."
		else
			details+="Replicas not patched (0/3)."
		fi
	else
		details="Deployment missing in bulwark (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q9() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "secret" "app-secret" "anchor"; then
		score=$((score + 2))
		details="Secret created (2/2). "
	else
		details="Secret missing (0/2). "
	fi

	local img=$(kubectl get deployment broken-app -n anchor -o jsonpath='{.spec.template.spec.containers[0].image}')
	if [[ "$img" == "nginx:1.25.0" ]]; then
		score=$((score + 2))
		details+="Image corrected (2/2). "
	else
		details+="Image incorrect (0/2). "
	fi

	local port=$(kubectl get deployment broken-app -n anchor -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')
	if [[ "$port" == "80" ]]; then
		score=$((score + 2))
		details+="Port corrected (2/2)."
	else
		details+="Port incorrect (0/2)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q10() {
	local score=0
	local max_points=6
	local details=""

	if [ -f "$EXAM_DIR/19/q10/cpu-usage.txt" ]; then
		local content=$(cat "$EXAM_DIR/19/q10/cpu-usage.txt")
		if [[ "$content" == *"backend-pod-"* ]]; then
			score=$((score + 6))
			details="File contains pod name (6/6)."
		else
			details="Incorrect pod name (0/6)."
		fi
	else
		details="File missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q11() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "monitored-pod" "ward"; then
		score=$((score + 2))
		details="Pod exists (2/2). "
		local liveness=$(kubectl get pod monitored-pod -n ward -o jsonpath='{.spec.containers[0].livenessProbe}')
		local readiness=$(kubectl get pod monitored-pod -n ward -o jsonpath='{.spec.containers[0].readinessProbe}')
		local startup=$(kubectl get pod monitored-pod -n ward -o jsonpath='{.spec.containers[0].startupProbe}')
		if [[ -n "$liveness" ]] && [[ -n "$readiness" ]] && [[ -n "$startup" ]]; then
			score=$((score + 4))
			details+="All probes present (4/4)."
		else
			details+="Probes missing (0/4)."
		fi
	else
		details="Pod missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q12() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "configmap" "app-config" "aegis"; then
		score=$((score + 3))
		details="ConfigMap exists (3/3). "
	else
		details="ConfigMap missing (0/3). "
	fi

	if resource_exists "pod" "config-pod" "aegis"; then
		score=$((score + 3))
		details+="Pod exists (3/3)."
	else
		details+="Pod missing (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q13() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "sa" "vault-sa" "shield"; then
		score=$((score + 3))
		details="ServiceAccount exists (3/3). "
	else
		details="ServiceAccount missing (0/3). "
	fi

	if [ -f "$EXAM_DIR/19/q13/token.txt" ]; then
		local ts=$(wc -c <"$EXAM_DIR/19/q13/token.txt")
		if [ "$ts" -gt 100 ]; then
			score=$((score + 3))
			details+="Token looks valid (3/3)."
		else
			details+="Token file empty or invalid (0/3)."
		fi
	else
		details+="Token file missing (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q14() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "secure-pod" "guardian"; then
		local p_user=$(kubectl get pod secure-pod -n guardian -o jsonpath='{.spec.securityContext.runAsUser}')
		if [[ "$p_user" == "1000" ]]; then
			score=$((score + 3))
			details="Pod SecurityContext OK (3/3). "
		else
			details="Pod SecurityContext wrong (0/3). "
		fi

		local c_user=$(kubectl get pod secure-pod -n guardian -o jsonpath='{.spec.containers[0].securityContext.runAsUser}')
		if [[ "$c_user" == "2000" ]]; then
			score=$((score + 3))
			details+="Container SecurityContext OK (3/3)."
		else
			details+="Container SecurityContext wrong (0/3)."
		fi
	else
		details="Pod missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q15() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "role" "config-editor" "haven"; then
		local rnames=$(kubectl get role config-editor -n haven -o jsonpath='{.rules[0].resourceNames}')
		if [[ "$rnames" == *"primary-config"* ]]; then
			score=$((score + 3))
			details="Role correctly targets resourceNames (3/3). "
		else
			details="Role missing resourceNames (0/3). "
		fi
	else
		details="Role missing (0/3). "
	fi

	if resource_exists "rolebinding" "dev-config-binding" "haven"; then
		score=$((score + 3))
		details+="RoleBinding exists (3/3)."
	else
		details+="RoleBinding missing (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q16() {
	local score=0
	local max_points=6
	local details=""

	local enf=$(kubectl get ns refuge -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}')
	if [[ "$enf" == "restricted" ]]; then
		score=$((score + 3))
		details="Enforce restricted label present (3/3). "
	else
		details="Enforce restricted label missing (0/3). "
	fi

	local wrn=$(kubectl get ns refuge -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/warn}')
	if [[ "$wrn" == "baseline" ]]; then
		score=$((score + 3))
		details+="Warn baseline label present (3/3)."
	else
		details+="Warn baseline label missing (0/3)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q17() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "networkpolicy" "db-protect" "bastion"; then
		score=$((score + 6))
		details="NetworkPolicy db-protect exists (6/6)."
	else
		details="NetworkPolicy db-protect missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q18() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "ingress" "regex-ingress" "bulwark"; then
		score=$((score + 3))
		details="Ingress exists (3/3). "
		local anno=$(kubectl get ingress regex-ingress -n bulwark -o jsonpath='{.metadata.annotations}')
		if [[ "$anno" == *"use-regex"* ]]; then
			score=$((score + 3))
			details+="Regex annotation present (3/3)."
		else
			details+="Regex annotation missing (0/3)."
		fi
	else
		details="Ingress missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q19() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "service" "topology-service" "anchor"; then
		score=$((score + 3))
		details="Service exists (3/3). "
		local anno=$(kubectl get service topology-service -n anchor -o jsonpath='{.metadata.annotations}')
		if [[ "$anno" == *"topology"* ]]; then
			score=$((score + 3))
			details+="Topology annotation present (3/3)."
		else
			details+="Topology annotation missing (0/3)."
		fi
	else
		details="Service missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q20() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "networkpolicy" "strict-net" "helm"; then
		score=$((score + 6))
		details="NetworkPolicy strict-net exists (6/6)."
	else
		details="NetworkPolicy strict-net missing (0/6)."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
