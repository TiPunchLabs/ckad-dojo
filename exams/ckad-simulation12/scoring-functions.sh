#!/bin/bash
# CKAD Simulation 12 - Scoring Functions (108 points total)

CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

EXAM_DIR="${EXAM_DIR:-./exam/course}"

score_q1() {
	local score=0
	local max_points=6
	local details=""

	if [ -f "$EXAM_DIR/12/q1/Dockerfile" ]; then
		if grep -q -E "FROM golang:1.20-alpine AS builder|FROM golang:1.20-alpine as builder" "$EXAM_DIR/12/q1/Dockerfile"; then
			((score += 2))
			details+="Builder stage defined. "
		fi
		if grep -q "FROM alpine:3.18" "$EXAM_DIR/12/q1/Dockerfile"; then
			((score += 2))
			details+="Alpine stage defined. "
		fi
		if grep -q "COPY --from=builder" "$EXAM_DIR/12/q1/Dockerfile"; then
			((score += 2))
			details+="Binary copied from builder. "
		fi
	else
		details+="Dockerfile not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q2() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "data-processor" "crescent"; then
		((score += 1))

		local init_img=$(kubectl get pod data-processor -n crescent -o jsonpath='{.spec.initContainers[0].image}' 2>/dev/null)
		if [ "$init_img" == "busybox:1.36" ]; then
			((score += 2))
			details+="Init container image correct. "
		else
			details+="Init container image incorrect. "
		fi

		local main_img=$(kubectl get pod data-processor -n crescent -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [ "$main_img" == "nginx:alpine" ]; then
			((score += 2))
			details+="Main container image correct. "
		fi
	else
		details+="Pod data-processor not found in crescent namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q3() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "cronjob" "nightly-backup" "twilight"; then
		((score += 2))

		local conc=$(kubectl get cronjob nightly-backup -n twilight -o jsonpath='{.spec.concurrencyPolicy}' 2>/dev/null)
		if [ "$conc" == "Forbid" ]; then
			((score += 3))
			details+="ConcurrencyPolicy is Forbid. "
		else
			details+="ConcurrencyPolicy is not Forbid ($conc). "
		fi
	else
		details+="Cronjob nightly-backup not found in twilight namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q4() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "legacy-app" "eclipse"; then
		((score += 2))

		local conts=$(kubectl get pod legacy-app -n eclipse -o jsonpath='{range .spec.containers[*]}{.name}{" "}{.image}{"\n"}{end}' 2>/dev/null)
		if echo "$conts" | grep -q "backend nginx:1.25"; then
			((score += 2))
			details+="Backend container correct. "
		fi
		if echo "$conts" | grep -q "proxy haproxy:2.8-alpine"; then
			((score += 2))
			details+="Proxy container correct. "
		fi
	else
		details+="Pod legacy-app not found in eclipse namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q5() {
	local score=0
	local max_points=5
	local details=""

	local rev=$(helm history api-release -n nebula -o json 2>/dev/null | jq -r '.[-1].description' 2>/dev/null)
	if [[ "$rev" == *"Rollback to 1"* ]]; then
		((score += 5))
		details+="Release rolled back to 1. "
	else
		details+="Release not rolled back to 1. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q6() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "slow-start-app" "shadow"; then
		((score += 2))

		local min_ready=$(kubectl get deployment slow-start-app -n shadow -o jsonpath='{.spec.minReadySeconds}' 2>/dev/null)
		if [ "$min_ready" == "20" ]; then
			((score += 3))
			details+="minReadySeconds is 20. "
		else
			details+="minReadySeconds is not 20 ($min_ready). "
		fi
	else
		details+="Deployment slow-start-app not found in shadow namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q7() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "critical-processor" "nightfall"; then
		local paused=$(kubectl get deployment critical-processor -n nightfall -o jsonpath='{.spec.paused}' 2>/dev/null)
		if [ "$paused" == "true" ]; then
			((score += 5))
			details+="Deployment is paused. "
		else
			details+="Deployment is not paused. "
		fi
	else
		details+="Deployment critical-processor not found in nightfall namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q8() {
	local score=0
	local max_points=6
	local details=""

	if [ -f "$EXAM_DIR/12/q8/kustomization.yaml" ] && [ -f "$EXAM_DIR/12/q8/patch.json" ]; then
		((score += 2))
		if grep -q "patch.json" "$EXAM_DIR/12/q8/kustomization.yaml"; then
			((score += 2))
			details+="patch.json referenced in kustomization. "
		fi
		if grep -q "production" "$EXAM_DIR/12/q8/patch.json" && grep -q "MODE" "$EXAM_DIR/12/q8/patch.json"; then
			((score += 2))
			details+="Patch contains MODE=production. "
		fi
	else
		details+="Files patch.json or kustomization.yaml missing. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q9() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "metrics-gatherer" "starlight"; then
		local img=$(kubectl get pod metrics-gatherer -n starlight -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		local status=$(kubectl get pod metrics-gatherer -n starlight -o jsonpath='{.status.phase}' 2>/dev/null)

		if [[ "$img" != *"non-existent"* ]]; then
			((score += 3))
			details+="Image corrected. "
		fi
		if [ "$status" == "Running" ]; then
			((score += 2))
			details+="Pod is running. "
		fi
	else
		details+="Pod metrics-gatherer not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q10() {
	local score=0
	local max_points=5
	local details=""

	if [ -f "$EXAM_DIR/12/q10/cpu-usage.txt" ]; then
		local content=$(cat "$EXAM_DIR/12/q10/cpu-usage.txt")
		if [[ -n "$content" ]]; then
			((score += 5))
			details+="Found CPU usage file. Content: $content. "
		fi
	else
		details+="cpu-usage.txt not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q11() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "logger" "lunar"; then
		((score += 2))
		local vols=$(kubectl get pod logger -n lunar -o jsonpath='{.spec.volumes[*].emptyDir}' 2>/dev/null)
		if [[ -n "$vols" ]]; then
			((score += 2))
			details+="EmptyDir volume used. "
		fi
		local cont_count=$(kubectl get pod logger -n lunar -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | wc -l 2>/dev/null)
		if [ "$cont_count" == "2" ]; then
			((score += 2))
			details+="Two containers found. "
		fi
	else
		details+="Pod logger not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q12() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "combined-app" "crescent"; then
		((score += 2))

		local vols=$(kubectl get pod combined-app -n crescent -o jsonpath='{.spec.volumes[*].projected.sources}' 2>/dev/null)
		if [[ "$vols" == *"db-creds"* ]]; then
			((score += 2))
			details+="Secret db-creds projected. "
		fi
		if [[ "$vols" == *"app-config"* ]]; then
			((score += 2))
			details+="ConfigMap app-config projected. "
		fi
	else
		details+="Pod combined-app not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q13() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "configmap" "static-config" "twilight"; then
		((score += 2))
		local immutable=$(kubectl get cm static-config -n twilight -o jsonpath='{.immutable}' 2>/dev/null)
		if [ "$immutable" == "true" ]; then
			((score += 2))
			details+="ConfigMap is immutable. "
		else
			details+="ConfigMap is not immutable. "
		fi
	else
		details+="ConfigMap static-config not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q14() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "secure-pod" "eclipse"; then
		((score += 2))

		local run_as=$(kubectl get pod secure-pod -n eclipse -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
		if [ "$run_as" == "1000" ]; then
			((score += 2))
			details+="runAsUser is 1000. "
		fi

		local no_priv=$(kubectl get pod secure-pod -n eclipse -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
		if [ "$no_priv" == "false" ]; then
			((score += 1))
			details+="allowPrivilegeEscalation is false. "
		fi

		local read_only=$(kubectl get pod secure-pod -n eclipse -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
		if [ "$read_only" == "true" ]; then
			((score += 1))
			details+="readOnlyRootFilesystem is true. "
		fi
	else
		details+="Pod secure-pod not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q15() {
	local score=0
	local max_points=5
	local details=""

	local val=$(kubectl get secret legacy-token -n shadow -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null)
	if [ "$val" == "super-secret-v2" ]; then
		((score += 5))
		details+="Token updated correctly. "
	else
		details+="Token not updated. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q16() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "resourcequota" "compute-quota" "nightfall"; then
		((score += 3))

		local pods=$(kubectl get resourcequota compute-quota -n nightfall -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
		local cpu=$(kubectl get resourcequota compute-quota -n nightfall -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
		local mem=$(kubectl get resourcequota compute-quota -n nightfall -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)

		if [ "$pods" == "4" ] && [ "$cpu" == "2" ] && [ "$mem" == "4Gi" ]; then
			((score += 3))
			details+="Quota limits correct. "
		else
			details+="Quota limits incorrect ($pods pods, $cpu cpu, $mem mem). "
		fi
	else
		details+="ResourceQuota compute-quota not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q17() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "networkpolicy" "deny-external" "dusk"; then
		((score += 2))

		local egress_ports=$(kubectl get netpol deny-external -n dusk -o jsonpath='{.spec.egress[*].ports[*].port}' 2>/dev/null)
		local egress_protos=$(kubectl get netpol deny-external -n dusk -o jsonpath='{.spec.egress[*].ports[*].protocol}' 2>/dev/null)

		if [ "$egress_ports" == "53" ] && [ "$egress_protos" == "UDP" ]; then
			((score += 3))
			details+="Egress allows UDP 53. "
		else
			details+="Egress rules incorrect. "
		fi
	else
		details+="NetworkPolicy deny-external not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q18() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "ingress" "star-ingress" "starlight"; then
		((score += 2))

		local paths=$(kubectl get ingress star-ingress -n starlight -o jsonpath='{range .spec.rules[*].http.paths[*]}{.path}{" "}{.backend.service.name}{"\n"}{end}' 2>/dev/null)
		if echo "$paths" | grep -q "/api api-svc"; then
			((score += 2))
			details+="/api path mapped. "
		fi
		if echo "$paths" | grep -q "/web web-svc"; then
			((score += 2))
			details+="/web path mapped. "
		fi
	else
		details+="Ingress star-ingress not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q19() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "service" "db-ext-svc" "nebula"; then
		((score += 2))

		local type=$(kubectl get svc db-ext-svc -n nebula -o jsonpath='{.spec.type}' 2>/dev/null)
		local ext_name=$(kubectl get svc db-ext-svc -n nebula -o jsonpath='{.spec.externalName}' 2>/dev/null)

		if [ "$type" == "ExternalName" ] && [ "$ext_name" == "database.external.example.com" ]; then
			((score += 3))
			details+="Type and ExternalName correct. "
		else
			details+="Type ($type) or ExternalName ($ext_name) incorrect. "
		fi
	else
		details+="Service db-ext-svc not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q20() {
	local score=0
	local max_points=6
	local details=""

	if [ -f "$EXAM_DIR/12/q20/nslookup.txt" ]; then
		local content=$(cat "$EXAM_DIR/12/q20/nslookup.txt")
		if echo "$content" | grep -q "kubernetes.default.svc.cluster.local"; then
			((score += 6))
			details+="nslookup output valid. "
		else
			details+="nslookup output invalid or missing default service string. "
		fi
	else
		details+="nslookup.txt not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
