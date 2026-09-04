#!/bin/bash
# CKAD Simulation 18 - Scoring Functions
# DOJO_NAME="Dojo Izanagi"


# Q1: 6 points

CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

EXAM_DIR="${EXAM_DIR:-./exam/course}"

score_q1() {
	local score=0
	local max_points=6
	local details=""

	if docker image inspect localhost:5000/genesis-app:v1 >/dev/null 2>&1; then
		score=$((score + 1))
		details+="Image built and tagged. "
		local user=$(docker image inspect localhost:5000/genesis-app:v1 | jq -r '.[0].Config.User')
		if [[ "$user" == "1000" ]]; then
			score=$((score + 2))
			details+="USER 1000 instruction found. "
		else
			details+="USER 1000 instruction missing. "
		fi
	else
		details+="Image localhost:5000/genesis-app:v1 not found locally. "
	fi

	if resource_exists pod genesis-pod genesis; then
		score=$((score + 1))
		local image=$(kubectl get pod genesis-pod -n genesis -o jsonpath='{.spec.containers[0].image}')
		if [[ "$image" == "localhost:5000/genesis-app:v1" ]]; then
			score=$((score + 2))
			details+="Pod uses correct image. "
		else
			details+="Pod uses wrong image. "
		fi
	else
		details+="Pod genesis-pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q2: 6 points
score_q2() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists pod data-transformer origin; then
		score=$((score + 2))

		local c_count=$(kubectl get pod data-transformer -n origin -o jsonpath='{.spec.containers[*].name}' | wc -w)
		if [[ "$c_count" -ge 2 ]]; then
			score=$((score + 1))
			details+="Pod has 2 containers. "
		fi

		local vol=$(kubectl get pod data-transformer -n origin -o jsonpath='{.spec.volumes[?(@.name=="shared-data")].emptyDir}')
		if [[ -n "$vol" ]]; then
			score=$((score + 1))
			details+="Shared emptyDir volume found. "
		fi

		local vol_mounts=$(kubectl get pod data-transformer -n origin -o jsonpath='{.spec.containers[*].volumeMounts[?(@.name=="shared-data")].mountPath}')
		if [[ "$vol_mounts" == *"/var/log"*"/var/log"* ]]; then
			score=$((score + 2))
			details+="Volume mounted in both containers. "
		fi
	else
		details+="Pod data-transformer not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q3: 5 points
score_q3() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists job index-processor primal; then
		score=$((score + 2))

		local mode=$(kubectl get job index-processor -n primal -o jsonpath='{.spec.completionMode}')
		if [[ "$mode" == "Indexed" ]]; then
			score=$((score + 1))
			details+="Indexed completion mode set. "
		fi

		local completions=$(kubectl get job index-processor -n primal -o jsonpath='{.spec.completions}')
		if [[ "$completions" == "5" ]]; then
			score=$((score + 1))
		fi

		local para=$(kubectl get job index-processor -n primal -o jsonpath='{.spec.parallelism}')
		if [[ "$para" == "2" ]]; then
			score=$((score + 1))
		fi
	else
		details+="Job index-processor not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q4: 6 points
score_q4() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists pod graceful-shutdown ancient; then
		score=$((score + 2))

		local grace=$(kubectl get pod graceful-shutdown -n ancient -o jsonpath='{.spec.terminationGracePeriodSeconds}')
		if [[ "$grace" == "45" ]]; then
			score=$((score + 2))
			details+="terminationGracePeriodSeconds is 45. "
		fi

		local prestop=$(kubectl get pod graceful-shutdown -n ancient -o jsonpath='{.spec.containers[0].lifecycle.preStop.exec.command}')
		if [[ -n "$prestop" ]]; then
			score=$((score + 2))
			details+="preStop hook found. "
		fi
	else
		details+="Pod graceful-shutdown not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q5: 6 points
score_q5() {
	local score=0
	local max_points=6
	local details=""

	if helm status genesis-web -n nexus >/dev/null 2>&1; then
		local reps=$(helm get values genesis-web -n nexus -a | grep -A 0 'replicaCount:' | awk '{print $2}')
		if [[ "$reps" == "3" ]]; then
			score=$((score + 3))
			details+="replicaCount updated. "
		fi

		local label=$(helm get values genesis-web -n nexus -a | grep -A 0 'customLabel:' | awk '{print $2}')
		if [[ "$label" == "initial-install" ]]; then
			score=$((score + 3))
			details+="customLabel retained. "
		else
			details+="customLabel lost. "
		fi
	else
		details+="Helm release genesis-web not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q6: 6 points
score_q6() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists deployment terra-web terra; then
		score=$((score + 2))

		local reps=$(kubectl get deployment terra-web -n terra -o jsonpath='{.spec.replicas}')
		if [[ "$reps" == "4" ]]; then
			score=$((score + 1))
		fi
	else
		details+="Deployment terra-web not found. "
	fi

	if resource_exists pdb terra-pdb terra; then
		score=$((score + 1))

		local min=$(kubectl get pdb terra-pdb -n terra -o jsonpath='{.spec.minAvailable}')
		if [[ "$min" == "75%" ]]; then
			score=$((score + 2))
			details+="PDB minAvailable is 75%. "
		fi
	else
		details+="PDB terra-pdb not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q7: 6 points
score_q7() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists deployment eden-api eden; then
		local img=$(kubectl get deployment eden-api -n eden -o jsonpath='{.spec.template.spec.containers[0].image}')
		if [[ "$img" == "nginx:1.21" ]]; then
			score=$((score + 2))
			details+="Image updated. "
		fi

		local anno=$(kubectl get deployment eden-api -n eden -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}')
		if [[ -n "$anno" ]]; then
			score=$((score + 2))
			details+="Revision annotation exists. "
		fi

		local max_s=$(kubectl get deployment eden-api -n eden -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
		local max_u=$(kubectl get deployment eden-api -n eden -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')
		if [[ "$max_s" == "2" || "$max_s" == "25%" ]] && [[ "$max_u" == "0" || "$max_u" == "0%" ]]; then
			score=$((score + 2))
			details+="Strategy updated. "
		fi
	else
		details+="Deployment eden-api not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q8: 6 points
score_q8() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists secret matrix-secret matrix; then
		score=$((score + 3))

		local val=$(kubectl get secret matrix-secret -n matrix -o jsonpath='{.data.db-password}' | base64 -d)
		if [[ "$val" == "supersecret" ]]; then
			score=$((score + 3))
			details+="Secret has correct data without hash. "
		fi
	else
		details+="Secret matrix-secret not found (ensure disableNameSuffixHash is used). "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q9: 6 points
score_q9() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists pod stuck-pod cosmos; then
		local phase=$(kubectl get pod stuck-pod -n cosmos -o jsonpath='{.status.phase}')
		if [[ "$phase" == "Running" ]]; then
			score=$((score + 6))
			details+="Pod is running successfully. "
		else
			details+="Pod is not Running. "
		fi
	else
		details+="Pod stuck-pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q10: 5 points
score_q10() {
	local score=0
	local max_points=5
	local details=""
	local file_path="./exam/course/10/events.txt"

	if [ -f "$file_path" ]; then
		score=$((score + 2))

		local header=$(head -n 1 "$file_path")
		if echo "$header" | grep -q "TYPE.*REASON.*MESSAGE"; then
			score=$((score + 3))
			details+="File created with correct headers. "
		else
			details+="File headers incorrect. "
		fi
	else
		details+="File not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q11: 6 points
score_q11() {
	local score=0
	local max_points=6
	local details=""
	local script_path="./exam/course/11/check.sh"

	if [ -f "$script_path" ]; then
		score=$((score + 2))

		if grep -q "kubectl port-forward.*svc/backend-api.*9999:8080" "$script_path"; then
			score=$((score + 2))
		fi

		if grep -q "curl.*http://localhost:9999/health" "$script_path"; then
			score=$((score + 2))
			details+="Port-forward script appears correct. "
		fi
	else
		details+="Script check.sh not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q12: 7 points
score_q12() {
	local score=0
	local max_points=7
	local details=""

	if resource_exists pod projected-pod origin; then
		score=$((score + 1))

		local proj=$(kubectl get pod projected-pod -n origin -o jsonpath='{.spec.volumes[?(@.projected)].projected.sources}')
		if [[ -n "$proj" ]]; then
			if echo "$proj" | grep -q "my-secret"; then score=$((score + 1)); fi
			if echo "$proj" | grep -q "my-config"; then score=$((score + 1)); fi
			if echo "$proj" | grep -q "downwardAPI"; then score=$((score + 2)); fi
			if echo "$proj" | grep -q "serviceAccountToken"; then score=$((score + 2)); fi
			details+="Projected volume sources checked. "
		else
			details+="Projected volume not found. "
		fi
	else
		details+="Pod projected-pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q13: 5 points
score_q13() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists secret static-creds primal; then
		score=$((score + 2))

		local im=$(kubectl get secret static-creds -n primal -o jsonpath='{.immutable}')
		if [[ "$im" == "true" ]]; then
			score=$((score + 3))
			details+="Secret is immutable. "
		else
			details+="Secret is not immutable. "
		fi
	else
		details+="Secret static-creds not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q14: 7 points
score_q14() {
	local score=0
	local max_points=7
	local details=""

	if resource_exists pod secure-pod ancient; then
		score=$((score + 1))

		local sc=$(kubectl get pod secure-pod -n ancient -o jsonpath='{.spec.containers[0].securityContext}')

		if echo "$sc" | grep -q '"runAsNonRoot":true'; then score=$((score + 1)); fi
		if echo "$sc" | grep -q '"readOnlyRootFilesystem":true'; then score=$((score + 2)); fi
		if echo "$sc" | grep -q '"allowPrivilegeEscalation":false'; then score=$((score + 1)); fi

		local drop=$(kubectl get pod secure-pod -n ancient -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop}')
		if [[ "$drop" == *"ALL"* ]]; then score=$((score + 2)); fi

		details+="SecurityContext checked. "
	else
		details+="Pod secure-pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q15: 6 points
score_q15() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists clusterrole monitor-viewer; then
		score=$((score + 2))

		local lbl=$(kubectl get clusterrole monitor-viewer -o jsonpath='{.metadata.labels}')
		if [[ -n "$lbl" ]]; then
			score=$((score + 2))
			details+="monitor-viewer has labels. "
		fi
	else
		details+="ClusterRole monitor-viewer not found. "
	fi

	if resource_exists clusterrole aggregated-monitor; then
		local agg=$(kubectl get clusterrole aggregated-monitor -o jsonpath='{.aggregationRule}')
		if [[ -n "$agg" ]]; then
			score=$((score + 2))
			details+="aggregated-monitor has aggregationRule. "
		fi
	else
		details+="ClusterRole aggregated-monitor not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q16: 6 points
score_q16() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists resourcequota priority-quota eden; then
		score=$((score + 2))

		local pods=$(kubectl get resourcequota priority-quota -n eden -o jsonpath='{.spec.hard.pods}')
		if [[ "$pods" == "5" ]]; then score=$((score + 1)); fi

		local cpu=$(kubectl get resourcequota priority-quota -n eden -o jsonpath='{.spec.hard.requests\.cpu}')
		if [[ "$cpu" == "2" ]]; then score=$((score + 1)); fi

		local scopes=$(kubectl get resourcequota priority-quota -n eden -o jsonpath='{.spec.scopeSelector.matchExpressions[0].scopeName}')
		if [[ "$scopes" == "PriorityClass" ]]; then
			score=$((score + 2))
			details+="Scope correctly defined. "
		fi
	else
		details+="ResourceQuota priority-quota not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q17: 6 points
score_q17() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists networkpolicy allow-named-port matrix; then
		score=$((score + 2))

		local port=$(kubectl get networkpolicy allow-named-port -n matrix -o jsonpath='{.spec.ingress[0].ports[0].port}')
		if [[ "$port" == "api-port" ]]; then
			score=$((score + 4))
			details+="Named port used correctly. "
		fi
	else
		details+="NetworkPolicy allow-named-port not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q18: 5 points
score_q18() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists ingress cosmos-ingress cosmos; then
		score=$((score + 1))

		local ic=$(kubectl get ingress cosmos-ingress -n cosmos -o jsonpath='{.spec.ingressClassName}')
		if [[ "$ic" == "nginx" ]]; then
			score=$((score + 2))
			details+="ingressClassName is nginx. "
		fi

		local port=$(kubectl get ingress cosmos-ingress -n cosmos -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
		if [[ "$port" == "80" ]]; then
			score=$((score + 2))
			details+="Port corrected to 80. "
		fi
	else
		details+="Ingress cosmos-ingress not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q19: 6 points
score_q19() {
	local score=0
	local max_points=6
	local details=""
	local fqdn_file="./exam/course/19/fqdn.txt"

	if resource_exists pod dns-tester zenith; then
		score=$((score + 2))
	fi

	if [ -f "$fqdn_file" ]; then
		local content=$(cat "$fqdn_file")
		if [[ "$content" == *"data-svc.ancient.svc.cluster.local"* ]]; then
			score=$((score + 4))
			details+="FQDN correct. "
		else
			details+="FQDN incorrect in file. "
		fi
	else
		details+="File fqdn.txt not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q20: 6 points
score_q20() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists networkpolicy isolate-namespace nexus; then
		score=$((score + 2))

		local types=$(kubectl get networkpolicy isolate-namespace -n nexus -o jsonpath='{.spec.policyTypes}')
		if [[ "$types" == *"Ingress"* && "$types" == *"Egress"* ]]; then
			score=$((score + 2))
		fi

		local psel=$(kubectl get networkpolicy isolate-namespace -n nexus -o jsonpath='{.spec.podSelector}')
		if [[ "$psel" == "{}" ]]; then
			score=$((score + 2))
			details+="Policy isolates correctly. "
		fi
	else
		details+="NetworkPolicy isolate-namespace not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
