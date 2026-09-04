#!/bin/bash
# CKAD Simulation 15 - Scoring Functions
# Total Points: 110


# Q1: 5 points

CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

EXAM_DIR="${EXAM_DIR:-./exam/course}"

score_q1() {
	local score=0
	local max_points=5
	local details=""

	if [ -f "./exam/course/15/q1/Dockerfile" ]; then
		if grep -q "AS builder" "./exam/course/15/q1/Dockerfile" || grep -q "as builder" "./exam/course/15/q1/Dockerfile"; then
			score=$((score + 2))
			details+="Builder stage used. "
		else
			details+="Builder stage not found. "
		fi

		if grep -q "COPY --from=builder" "./exam/course/15/q1/Dockerfile"; then
			score=$((score + 3))
			details+="Copy from builder used. "
		else
			details+="Copy from builder not found. "
		fi
	else
		details+="Dockerfile not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q2: 6 points
score_q2() {
	local score=0
	local max_points=6
	local details=""
	local ns="tide"
	local pod="log-generator"

	if resource_exists pod $pod $ns; then
		score=$((score + 2))
		details+="Pod $pod exists. "

		local c_count=$(kubectl get pod $pod -n $ns -o jsonpath='{range .spec.containers[*]}{.name}{" "}{end}' | wc -w)
		if [ "$c_count" -ge 2 ]; then
			score=$((score + 2))
			details+="Pod has $c_count containers. "
		else
			details+="Pod does not have sidecar. "
		fi

		local vol=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.volumes[?(@.name=="shared-logs")].emptyDir}')
		if [ -n "$vol" ]; then
			score=$((score + 2))
			details+="Shared emptyDir volume exists. "
		else
			details+="Shared volume not found. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q3: 5 points
score_q3() {
	local score=0
	local max_points=5
	local details=""
	local ns="coral"
	local cj="data-sync"

	if resource_exists cronjob $cj $ns; then
		score=$((score + 1))
		details+="CronJob $cj exists. "

		local sched=$(kubectl get cj $cj -n $ns -o jsonpath='{.spec.schedule}')
		if [[ "$sched" == "*/10 * * * *" ]]; then
			score=$((score + 1))
			details+="Schedule correct. "
		else
			details+="Schedule incorrect ($sched). "
		fi

		local limit=$(kubectl get cj $cj -n $ns -o jsonpath='{.spec.failedJobsHistoryLimit}')
		if [[ "$limit" == "5" ]]; then
			score=$((score + 2))
			details+="History limit correct. "
		else
			details+="History limit incorrect ($limit). "
		fi

		local suspend=$(kubectl get cj $cj -n $ns -o jsonpath='{.spec.suspend}')
		if [[ "$suspend" == "true" ]]; then
			score=$((score + 1))
			details+="Suspend is true. "
		else
			details+="Suspend not true. "
		fi
	else
		details+="CronJob $cj not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q4: 6 points
score_q4() {
	local score=0
	local max_points=6
	local details=""
	local ns="abyss"
	local pod="batch-worker"

	if resource_exists pod $pod $ns; then
		score=$((score + 3))
		details+="Pod $pod exists. "

		local rp=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.restartPolicy}')
		if [[ "$rp" == "OnFailure" ]]; then
			score=$((score + 3))
			details+="Restart policy is OnFailure. "
		else
			details+="Restart policy incorrect ($rp). "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q5: 4 points
score_q5() {
	local score=0
	local max_points=4
	local details=""

	local hr=$(helm list -n current --short | grep ocean-api || echo "")
	if [ -z "$hr" ]; then
		score=$((score + 4))
		details+="Helm release ocean-api uninstalled. "
	else
		details+="Helm release ocean-api still exists. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q6: 6 points
score_q6() {
	local score=0
	local max_points=6
	local details=""
	local ns="reef"
	local dep="web-deploy"

	if resource_exists deploy $dep $ns; then
		score=$((score + 2))
		details+="Deploy $dep exists. "

		local surge=$(kubectl get deploy $dep -n $ns -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
		local unavail=$(kubectl get deploy $dep -n $ns -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')

		if [[ "$surge" == "50%" || "$surge" == "2" ]]; then
			score=$((score + 2))
			details+="MaxSurge correct. "
		else
			details+="MaxSurge incorrect ($surge). "
		fi

		if [[ "$unavail" == "25%" || "$unavail" == "1" ]]; then
			score=$((score + 2))
			details+="MaxUnavailable correct. "
		else
			details+="MaxUnavailable incorrect ($unavail). "
		fi
	else
		details+="Deploy $dep not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q7: 5 points
score_q7() {
	local score=0
	local max_points=5
	local details=""
	local ns="lagoon"
	local dep="api-server"

	if resource_exists deploy $dep $ns; then
		local img=$(kubectl get deploy $dep -n $ns -o jsonpath='{.spec.template.spec.containers[0].image}')
		if [[ "$img" == "nginx:1.24" ]]; then
			score=$((score + 5))
			details+="Deployment rolled back to nginx:1.24. "
		else
			details+="Image is $img, expected nginx:1.24. "
		fi
	else
		details+="Deploy $dep not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q8: 7 points
score_q8() {
	local score=0
	local max_points=7
	local details=""
	local ns="trench"

	if resource_exists deploy app-deploy $ns; then
		score=$((score + 2))
		details+="Deploy app-deploy created via kustomize. "

		local l_env=$(kubectl get deploy app-deploy -n $ns -o jsonpath='{.metadata.labels.env}')
		if [[ "$l_env" == "production" ]]; then
			score=$((score + 2))
			details+="Label env=production applied. "
		else
			details+="Label env incorrect. "
		fi

		local a_rel=$(kubectl get deploy app-deploy -n $ns -o jsonpath='{.metadata.annotations.release}')
		if [[ "$a_rel" == "v1.0.0" ]]; then
			score=$((score + 2))
			details+="Annotation release=v1.0.0 applied. "
		else
			details+="Annotation release incorrect. "
		fi
	else
		details+="Deploy app-deploy not found. "
	fi

	if resource_exists svc app-svc $ns; then
		score=$((score + 1))
		details+="Service app-svc created via kustomize. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q9: 5 points
score_q9() {
	local score=0
	local max_points=5
	local details=""
	local ns="wave"
	local pod="backend-pod"

	if resource_exists pod $pod $ns; then
		local img=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].image}')
		if [[ "$img" == "nginx:alpine" ]]; then
			score=$((score + 3))
			details+="Image corrected. "

			local state=$(kubectl get pod $pod -n $ns -o jsonpath='{.status.phase}')
			if [[ "$state" == "Running" || "$state" == "Pending" ]]; then
				score=$((score + 2))
				details+="Pod not in ErrImagePull. "
			fi
		else
			details+="Image is still $img. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q10: 5 points
score_q10() {
	local score=0
	local max_points=5
	local details=""

	if [ -s "./exam/course/15/q10/events.txt" ]; then
		score=$((score + 3))
		details+="File events.txt exists. "
		if grep -q "Warning" "./exam/course/15/q10/events.txt"; then
			score=$((score + 2))
			details+="Warning events found in file. "
		else
			details+="No Warning text found in file. "
		fi
	else
		details+="File events.txt not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q11: 6 points
score_q11() {
	local score=0
	local max_points=6
	local details=""
	local ns="ocean"
	local pod="grpc-checker"

	if resource_exists pod $pod $ns; then
		score=$((score + 2))
		details+="Pod $pod exists. "

		local grpc_port=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].livenessProbe.grpc.port}')
		if [[ "$grpc_port" == "8080" ]]; then
			score=$((score + 4))
			details+="gRPC probe configured on port 8080. "
		else
			details+="gRPC probe missing or incorrect. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q12: 5 points
score_q12() {
	local score=0
	local max_points=5
	local details=""
	local ns="tide"
	local cm="app-config-dir"
	local pod="config-consumer"

	if resource_exists cm $cm $ns; then
		score=$((score + 2))
		details+="ConfigMap $cm exists. "
	else
		details+="ConfigMap $cm not found. "
	fi

	if resource_exists pod $pod $ns; then
		local mnt=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="config-vol")].mountPath}')
		# name might not be exactly config-vol, check just mountPath
		local any_mnt=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}')
		if echo "$any_mnt" | grep -q "/etc/config"; then
			score=$((score + 3))
			details+="ConfigMap mounted to /etc/config. "
		else
			details+="Mount path /etc/config not found. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q13: 5 points
score_q13() {
	local score=0
	local max_points=5
	local details=""
	local ns="coral"
	local sec="db-credentials"
	local pod="secret-env-pod"

	if resource_exists secret $sec $ns; then
		score=$((score + 2))
		details+="Secret $sec exists. "
	else
		details+="Secret $sec not found. "
	fi

	if resource_exists pod $pod $ns; then
		local env1=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.key}')
		local env2=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_PASS")].valueFrom.secretKeyRef.key}')

		if [[ "$env1" == "username" && "$env2" == "password" ]]; then
			score=$((score + 3))
			details+="Environment variables configured correctly. "
		else
			details+="Environment variables incorrect. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q14: 7 points
score_q14() {
	local score=0
	local max_points=7
	local details=""
	local ns="abyss"
	local pod="secure-pod"
	local pol="secure-policy"

	if resource_exists pod $pod $ns; then
		local uid=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.securityContext.runAsUser}')
		local esc=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}')

		if [[ "$uid" == "1000" ]]; then
			score=$((score + 2))
			details+="runAsUser correct. "
		fi
		if [[ "$esc" == "false" ]]; then
			score=$((score + 2))
			details+="allowPrivilegeEscalation false. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	if resource_exists netpol $pol $ns; then
		score=$((score + 3))
		details+="NetworkPolicy $pol exists. "
	else
		details+="NetworkPolicy not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q15: 5 points
score_q15() {
	local score=0
	local max_points=5
	local details=""
	local ns="reef"
	local pod="target-pod"

	if resource_exists pod $pod $ns; then
		local eph=$(kubectl get pod $pod -n $ns -o jsonpath='{.spec.ephemeralContainers[0].name}')
		if [ -n "$eph" ]; then
			score=$((score + 5))
			details+="Ephemeral container '$eph' attached. "
		else
			details+="No ephemeral containers found. "
		fi
	else
		details+="Pod $pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q16: 6 points
score_q16() {
	local score=0
	local max_points=6
	local details=""
	local ns="lagoon"
	local dep="critical-app"
	local pdb="critical-pdb"

	if resource_exists deploy $dep $ns; then
		score=$((score + 2))
		details+="Deploy $dep exists. "
	else
		details+="Deploy $dep not found. "
	fi

	if resource_exists pdb $pdb $ns; then
		score=$((score + 2))
		details+="PDB $pdb exists. "

		local min=$(kubectl get pdb $pdb -n $ns -o jsonpath='{.spec.minAvailable}')
		if [[ "$min" == "2" ]]; then
			score=$((score + 2))
			details+="minAvailable is 2. "
		else
			details+="minAvailable incorrect. "
		fi
	else
		details+="PDB $pdb not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q17: 6 points
score_q17() {
	local score=0
	local max_points=6
	local details=""
	local ns="trench"

	if resource_exists netpol deny-all $ns; then
		score=$((score + 3))
		details+="Policy deny-all exists. "
	else
		details+="Policy deny-all not found. "
	fi

	if resource_exists netpol allow-web $ns; then
		score=$((score + 3))
		details+="Policy allow-web exists. "
	else
		details+="Policy allow-web not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q18: 5 points
score_q18() {
	local score=0
	local max_points=5
	local details=""
	local ns="wave"
	local svc="mesh-service"

	if resource_exists svc $svc $ns; then
		local ep=$(kubectl get endpoints $svc -n $ns -o jsonpath='{.subsets[0].addresses[0].ip}')
		if [ -n "$ep" ]; then
			score=$((score + 5))
			details+="Service $svc has active endpoints. "
		else
			details+="Service $svc has no endpoints. "
		fi
	else
		details+="Service $svc not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q19: 5 points
score_q19() {
	local score=0
	local max_points=5
	local details=""
	local ns="depths"
	local svc="multi-port-svc"

	if resource_exists svc $svc $ns; then
		score=$((score + 1))
		details+="Service exists. "

		local port1=$(kubectl get svc $svc -n $ns -o jsonpath='{.spec.ports[?(@.port==80)].protocol}')
		local port2=$(kubectl get svc $svc -n $ns -o jsonpath='{.spec.ports[?(@.port==53)].protocol}')

		if [[ "$port1" == "TCP" ]]; then
			score=$((score + 2))
			details+="Port 80 is TCP. "
		fi
		if [[ "$port2" == "UDP" ]]; then
			score=$((score + 2))
			details+="Port 53 is UDP. "
		fi
	else
		details+="Service not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}

# Q20: 6 points
score_q20() {
	local score=0
	local max_points=6
	local details=""
	local ns="ocean"
	local ing="rewrite-ingress"

	if resource_exists ingress $ing $ns; then
		score=$((score + 2))
		details+="Ingress $ing exists. "

		local host=$(kubectl get ingress $ing -n $ns -o jsonpath='{.spec.rules[0].host}')
		if [[ "$host" == "susanoo.com" ]]; then
			score=$((score + 2))
			details+="Host is correct. "
		fi

		local anno=$(kubectl get ingress $ing -n $ns -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/rewrite-target}')
		if [[ "$anno" == "/\$2" ]]; then
			score=$((score + 2))
			details+="Rewrite annotation is correct. "
		fi
	else
		details+="Ingress $ing not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS: $details"
}
