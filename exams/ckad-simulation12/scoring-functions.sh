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

	local built_id verified_id
	built_id=$(docker image inspect lunar-app:v1.0 --format '{{.Id}}' 2>/dev/null)
	verified_id=$(docker image inspect lunar-app:v1.0-verified --format '{{.Id}}' 2>/dev/null)

	if [ -n "$built_id" ]; then
		((score += 1))
		details+="Image lunar-app:v1.0 built. "
	else
		details+="Image lunar-app:v1.0 not found. "
	fi

	if [ -f "$EXAM_DIR/1/lunar-app.tar" ] && tar -tf "$EXAM_DIR/1/lunar-app.tar" 2>/dev/null | grep -q "manifest.json"; then
		((score += 2))
		details+="lunar-app.tar is a valid image archive. "
	else
		details+="lunar-app.tar missing or not an image archive. "
	fi

	if [ -z "$verified_id" ]; then
		details+="Image lunar-app:v1.0-verified not found. "
	elif [ "$verified_id" == "$built_id" ]; then
		((score += 1))
		details+="lunar-app:v1.0-verified is the loaded image. "
	else
		details+="lunar-app:v1.0-verified has a different image ID (rebuilt instead of loaded): incorrect. "
	fi

	if [ -f "$EXAM_DIR/1/run-output.txt" ] && grep -q "Tsukuyomi server running" "$EXAM_DIR/1/run-output.txt"; then
		((score += 2))
		details+="run-output.txt contains the container output. "
	else
		details+="run-output.txt missing or without the container output. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q2() {
	local score=0
	local max_points=5
	local details=""

	local mounts phase
	mounts=$(kubectl get pod config-pod -n crescent -o jsonpath='{range .spec.containers[*].volumeMounts[*]}{.mountPath}{" "}{.subPath}{"\n"}{end}' 2>/dev/null)
	phase=$(kubectl get pod config-pod -n crescent -o jsonpath='{.status.phase}' 2>/dev/null)
	if echo "$mounts" | grep -qx "/etc/app/app.conf app.conf" && [ "$phase" == "Running" ]; then
		((score += 2))
		details+="config-pod mounts app.conf via subPath. "
	else
		details+="config-pod not running with a subPath mount of app.conf at /etc/app/app.conf: missing. "
	fi

	if [ -f "$EXAM_DIR/2/before.txt" ] && grep -q "mode=production" "$EXAM_DIR/2/before.txt"; then
		((score += 1))
		details+="before.txt shows mode=production. "
	else
		details+="before.txt missing or incorrect. "
	fi

	if [ -f "$EXAM_DIR/2/after-no-restart.txt" ] && grep -q "mode=production" "$EXAM_DIR/2/after-no-restart.txt"; then
		((score += 1))
		details+="after-no-restart.txt still shows mode=production (subPath is not refreshed). "
	else
		details+="after-no-restart.txt missing or incorrect. "
	fi

	if [ -f "$EXAM_DIR/2/after-restart.txt" ] && grep -q "mode=staging" "$EXAM_DIR/2/after-restart.txt"; then
		((score += 1))
		details+="after-restart.txt shows mode=staging. "
	else
		details+="after-restart.txt missing or incorrect. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q3() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "cronjob" "nightly-backup" "twilight"; then
		((score += 1))
		details+="CronJob nightly-backup exists. "

		local schedule conc
		schedule=$(kubectl get cronjob nightly-backup -n twilight -o jsonpath='{.spec.schedule}' 2>/dev/null)
		if [ "$schedule" == "*/10 * * * *" ]; then
			((score += 1))
			details+="Schedule runs every 10 minutes. "
		else
			details+="Schedule incorrect ($schedule). "
		fi

		conc=$(kubectl get cronjob nightly-backup -n twilight -o jsonpath='{.spec.concurrencyPolicy}' 2>/dev/null)
		if [ "$conc" == "Forbid" ]; then
			((score += 1))
			details+="ConcurrencyPolicy is Forbid. "
		else
			details+="ConcurrencyPolicy is not Forbid ($conc): incorrect. "
		fi
	else
		details+="CronJob nightly-backup not found in twilight namespace. "
	fi

	local manual_ok
	manual_ok=$(kubectl get jobs -n twilight -o jsonpath='{range .items[*]}{.metadata.annotations.cronjob\.kubernetes\.io/instantiate}{" "}{.metadata.ownerReferences[0].name}{" "}{.status.succeeded}{"\n"}{end}' 2>/dev/null | grep -c "^manual nightly-backup 1$")
	if [ "$manual_ok" -ge 1 ]; then
		((score += 2))
		details+="Manual Job from nightly-backup completed. "
	else
		details+="Completed manual Job from nightly-backup not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q4() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "log-aggregator" "eclipse"; then
		((score += 1))
		details+="Pod log-aggregator exists. "

		local conts
		conts=$(kubectl get pod log-aggregator -n eclipse -o jsonpath='{range .spec.containers[*]}{.name}{" "}{.image}{"\n"}{end}' 2>/dev/null)
		if echo "$conts" | grep -qx "app nginx:1.25"; then
			((score += 1))
			details+="Container app uses nginx:1.25. "
		else
			details+="Container app with nginx:1.25 not found. "
		fi
		if echo "$conts" | grep -qx "log-tailer busybox:1.36"; then
			((score += 1))
			details+="Container log-tailer uses busybox:1.36. "
		else
			details+="Container log-tailer with busybox:1.36 not found. "
		fi

		local empty_vols app_vol tailer_vol
		empty_vols=$(kubectl get pod log-aggregator -n eclipse -o jsonpath='{range .spec.volumes[?(@.emptyDir)]}{.name}{"\n"}{end}' 2>/dev/null)
		app_vol=$(kubectl get pod log-aggregator -n eclipse -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.mountPath=="/var/log")].name}' 2>/dev/null)
		tailer_vol=$(kubectl get pod log-aggregator -n eclipse -o jsonpath='{.spec.containers[?(@.name=="log-tailer")].volumeMounts[?(@.mountPath=="/var/log")].name}' 2>/dev/null)
		if [ -n "$app_vol" ] && [ "$app_vol" == "$tailer_vol" ] && echo "$empty_vols" | grep -qx "$app_vol"; then
			((score += 2))
			details+="Both containers share an emptyDir at /var/log. "
		else
			details+="Shared emptyDir at /var/log missing. "
		fi

		if kubectl logs log-aggregator -c log-tailer -n eclipse --tail=20 2>/dev/null | grep -q "Request processed"; then
			((score += 1))
			details+="log-tailer streams the application logs. "
		else
			details+="log-tailer output missing Request processed lines. "
		fi
	else
		details+="Pod log-aggregator not found in eclipse namespace. "
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
		details+="Release not rolled back to 1: incorrect. "
	fi

	[ -z "$details" ] && details="Expected configuration not found."
	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q6() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "slow-start-app" "shadow"; then
		((score += 1))
		details+="Deployment slow-start-app exists. "

		local replicas image surge unavail min_ready
		replicas=$(kubectl get deployment slow-start-app -n shadow -o jsonpath='{.spec.replicas}' 2>/dev/null)
		image=$(kubectl get deployment slow-start-app -n shadow -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		surge=$(kubectl get deployment slow-start-app -n shadow -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
		unavail=$(kubectl get deployment slow-start-app -n shadow -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
		min_ready=$(kubectl get deployment slow-start-app -n shadow -o jsonpath='{.spec.minReadySeconds}' 2>/dev/null)

		if [ "$replicas" == "4" ] && [ "$image" == "nginx:1.24" ]; then
			((score += 1))
			details+="4 replicas of nginx:1.24. "
		else
			details+="Replicas or image incorrect ($replicas, $image). "
		fi
		# 25% of 4 replicas also rounds up to exactly one extra Pod
		if [ "$surge" == "1" ] || [ "$surge" == "25%" ]; then
			((score += 1))
			details+="At most one extra Pod during rollout. "
		else
			details+="maxSurge incorrect ($surge). "
		fi
		if [ "$unavail" == "0" ] || [ "$unavail" == "0%" ]; then
			((score += 1))
			details+="Capacity never drops below 4. "
		else
			details+="maxUnavailable incorrect ($unavail). "
		fi
		if [ "$min_ready" == "20" ]; then
			((score += 1))
			details+="minReadySeconds is 20. "
		else
			details+="minReadySeconds incorrect ($min_ready). "
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

	local file
	for file in before-pause during-pause; do
		if [ -f "$EXAM_DIR/7/$file.txt" ] && grep -q "critical-processor" "$EXAM_DIR/7/$file.txt" && ! grep -q "nginx:1.26" "$EXAM_DIR/7/$file.txt"; then
			((score += 1))
			details+="$file.txt shows no nginx:1.26 ReplicaSet. "
		else
			details+="$file.txt missing or incorrect. "
		fi
	done

	if [ -f "$EXAM_DIR/7/after-resume.txt" ] && grep -q "nginx:1.26" "$EXAM_DIR/7/after-resume.txt"; then
		((score += 1))
		details+="after-resume.txt shows the nginx:1.26 ReplicaSet. "
	else
		details+="after-resume.txt missing or incorrect. "
	fi

	if resource_exists "deployment" "critical-processor" "nightfall"; then
		local paused image replicas updated available
		paused=$(kubectl get deployment critical-processor -n nightfall -o jsonpath='{.spec.paused}' 2>/dev/null)
		image=$(kubectl get deployment critical-processor -n nightfall -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [ "$paused" != "true" ] && [ "$image" == "nginx:1.26" ]; then
			((score += 1))
			details+="Rollout resumed on nginx:1.26. "
		else
			details+="Deployment still paused or image incorrect ($image). "
		fi

		replicas=$(kubectl get deployment critical-processor -n nightfall -o jsonpath='{.spec.replicas}' 2>/dev/null)
		updated=$(kubectl get deployment critical-processor -n nightfall -o jsonpath='{.status.updatedReplicas}' 2>/dev/null)
		available=$(kubectl get deployment critical-processor -n nightfall -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
		if [ "$image" == "nginx:1.26" ] && [ -n "$replicas" ] && [ "$updated" == "$replicas" ] && [ "$available" == "$replicas" ]; then
			((score += 1))
			details+="nginx:1.26 rollout completed. "
		else
			details+="nginx:1.26 rollout not completed: failed. "
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

	if [ -f "$EXAM_DIR/8/kustomization.yaml" ] && [ -f "$EXAM_DIR/8/patch.json" ]; then
		((score += 2))
		if grep -q "patch.json" "$EXAM_DIR/8/kustomization.yaml"; then
			((score += 2))
			details+="patch.json referenced in kustomization. "
		fi
		if grep -q "production" "$EXAM_DIR/8/patch.json" && grep -q "MODE" "$EXAM_DIR/8/patch.json"; then
			((score += 2))
			details+="Patch contains MODE=production. "
		fi
	else
		details+="Files patch.json or kustomization.yaml missing. "
	fi

	[ -z "$details" ] && details="Expected configuration not found."
	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q9() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "metrics-gatherer" "starlight"; then
		local img status
		img=$(kubectl get pod metrics-gatherer -n starlight -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		status=$(kubectl get pod metrics-gatherer -n starlight -o jsonpath='{.status.phase}' 2>/dev/null)

		if [ -n "$img" ] && [ "$img" != "nginxxxxx:alpine" ]; then
			((score += 3))
			details+="Image corrected ($img). "
		else
			details+="Image still incorrect ($img). "
		fi
		if [ "$status" == "Running" ]; then
			((score += 2))
			details+="Pod is running. "
		else
			details+="Pod not running ($status): failed. "
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

	local content=""
	[ -f "$EXAM_DIR/10/cpu-usage.txt" ] && content=$(tr -d '[:space:]' <"$EXAM_DIR/10/cpu-usage.txt")

	if [ -n "$content" ]; then
		((score += 2))
		details+="cpu-usage.txt written ($content). "
		if resource_exists "pod" "$content" "kube-system"; then
			((score += 3))
			details+="$content is a kube-system Pod. "
		else
			details+="$content is not a kube-system Pod: incorrect. "
		fi
	else
		details+="cpu-usage.txt not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q11() {
	local score=0
	local max_points=6
	local details=""

	if [ -f "$EXAM_DIR/11/broken-deploy.yaml" ] && kubectl apply --dry-run=server -f "$EXAM_DIR/11/broken-deploy.yaml" &>/dev/null; then
		((score += 1))
		details+="broken-deploy.yaml applies without validation errors. "
	else
		details+="broken-deploy.yaml missing or failed validation. "
	fi

	if resource_exists "deployment" "broken-app" "lunar"; then
		((score += 1))
		details+="Deployment broken-app exists. "

		local probe replicas ready
		probe=$(kubectl get deployment broken-app -n lunar -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null)
		if [ -n "$probe" ]; then
			((score += 1))
			details+="Readiness probe kept. "
		else
			details+="Readiness probe missing. "
		fi

		replicas=$(kubectl get deployment broken-app -n lunar -o jsonpath='{.spec.replicas}' 2>/dev/null)
		ready=$(kubectl get deployment broken-app -n lunar -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
		if [ -n "$ready" ] && [ "$ready" == "$replicas" ]; then
			((score += 3))
			details+="All $replicas Pods are Ready. "
		else
			details+="Pods not Ready (${ready:-0}/$replicas): failed. "
		fi
	else
		details+="Deployment broken-app not found in lunar namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q12() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "secret-reader" "crescent"; then
		((score += 1))
		details+="Pod secret-reader exists. "

		local vol_name secret_name phase
		vol_name=$(kubectl get pod secret-reader -n crescent -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/secrets")].name}' 2>/dev/null)
		secret_name=$(kubectl get pod secret-reader -n crescent -o jsonpath="{.spec.volumes[?(@.name==\"$vol_name\")].secret.secretName}" 2>/dev/null)
		if [ -n "$vol_name" ] && [ "$secret_name" == "db-credentials" ]; then
			((score += 2))
			details+="Secret db-credentials mounted at /etc/secrets. "
		else
			details+="Secret db-credentials mount at /etc/secrets missing. "
		fi

		phase=$(kubectl get pod secret-reader -n crescent -o jsonpath='{.status.phase}' 2>/dev/null)
		if [ "$phase" == "Running" ]; then
			((score += 1))
			details+="Pod is running. "
		else
			details+="Pod not running ($phase): failed. "
		fi
	else
		details+="Pod secret-reader not found in crescent namespace. "
	fi

	local expected actual=""
	expected=$(kubectl get secret db-credentials -n crescent -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null)
	[ -f "$EXAM_DIR/12/password.txt" ] && actual=$(tr -d '[:space:]' <"$EXAM_DIR/12/password.txt")
	if [ -n "$expected" ] && [ "$actual" == "$expected" ]; then
		((score += 2))
		details+="password.txt holds the decoded password. "
	else
		details+="password.txt missing or incorrect. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q13() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "pod" "secure-runner" "twilight"; then
		local run_as pod_run_as drop add phase
		run_as=$(kubectl get pod secure-runner -n twilight -o jsonpath='{.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
		pod_run_as=$(kubectl get pod secure-runner -n twilight -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
		drop=$(kubectl get pod secure-runner -n twilight -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop[*]}' 2>/dev/null)
		add=$(kubectl get pod secure-runner -n twilight -o jsonpath='{.spec.containers[0].securityContext.capabilities.add[*]}' 2>/dev/null)
		phase=$(kubectl get pod secure-runner -n twilight -o jsonpath='{.status.phase}' 2>/dev/null)

		if [ "${run_as:-$pod_run_as}" == "2000" ]; then
			((score += 1))
			details+="Runs as user 2000. "
		else
			details+="runAsUser incorrect (${run_as:-$pod_run_as}). "
		fi
		if [ "$drop" == "ALL" ]; then
			((score += 1))
			details+="All capabilities dropped. "
		else
			details+="Capabilities drop ALL missing. "
		fi
		if [ "$add" == "NET_ADMIN" ]; then
			((score += 1))
			details+="Only NET_ADMIN added back. "
		else
			details+="Added capabilities incorrect ($add). "
		fi
		if [ "$drop" == "ALL" ] && [ "$phase" == "Running" ]; then
			((score += 1))
			details+="Hardened Pod is running. "
		else
			details+="Hardened Pod not running: failed. "
		fi
	else
		details+="Pod secure-runner not found in twilight namespace. "
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

	[ -z "$details" ] && details="Expected configuration not found."
	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q15() {
	local score=0
	local max_points=5
	local details=""

	local before="" after="" val phase
	[ -f "$EXAM_DIR/15/before.txt" ] && before=$(tr -d '[:space:]' <"$EXAM_DIR/15/before.txt")
	[ -f "$EXAM_DIR/15/after.txt" ] && after=$(tr -d '[:space:]' <"$EXAM_DIR/15/after.txt")

	if [ "$before" == "super-secret-v1" ]; then
		((score += 1))
		details+="before.txt shows the old token. "
	else
		details+="before.txt missing or incorrect. "
	fi

	val=$(kubectl get secret legacy-token -n shadow -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null)
	if [ "$val" == "super-secret-v2" ]; then
		((score += 2))
		details+="Secret token updated. "
	else
		details+="Secret token not updated: incorrect. "
	fi

	if [ "$after" == "super-secret-v2" ]; then
		((score += 1))
		details+="after.txt shows the new token. "
	else
		details+="after.txt missing or incorrect. "
	fi

	local created before_mtime=0
	phase=$(kubectl get pod token-reader -n shadow -o jsonpath='{.status.phase}' 2>/dev/null)
	created=$(date -d "$(kubectl get pod token-reader -n shadow -o jsonpath='{.metadata.creationTimestamp}' 2>/dev/null)" +%s 2>/dev/null || echo 0)
	[ -f "$EXAM_DIR/15/before.txt" ] && before_mtime=$(stat -c %Y "$EXAM_DIR/15/before.txt")
	if [ "$phase" == "Running" ] && [ "$before_mtime" -gt 0 ] && [ "$created" -gt "$before_mtime" ]; then
		((score += 1))
		details+="Pod token-reader recreated and running. "
	else
		details+="Pod token-reader not recreated after the first capture: missing. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q16() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "resourcequota" "compute-quota" "dusk"; then
		((score += 3))

		local pods=$(kubectl get resourcequota compute-quota -n dusk -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
		local cpu=$(kubectl get resourcequota compute-quota -n dusk -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
		local mem=$(kubectl get resourcequota compute-quota -n dusk -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)

		if [ "$pods" == "4" ] && [ "$cpu" == "2" ] && [ "$mem" == "4Gi" ]; then
			((score += 3))
			details+="Quota limits correct. "
		else
			details+="Quota limits incorrect ($pods pods, $cpu cpu, $mem mem). "
		fi
	else
		details+="ResourceQuota compute-quota not found. "
	fi

	[ -z "$details" ] && details="Expected configuration not found."
	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q17() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "networkpolicy" "frontend-policy" "dusk"; then
		((score += 1))
		details+="NetworkPolicy frontend-policy exists. "

		local selector from_app from_ns types egress
		selector=$(kubectl get netpol frontend-policy -n dusk -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
		from_app=$(kubectl get netpol frontend-policy -n dusk -o jsonpath='{.spec.ingress[*].from[*].podSelector.matchLabels.app}' 2>/dev/null)
		from_ns=$(kubectl get netpol frontend-policy -n dusk -o jsonpath='{.spec.ingress[*].from[*].namespaceSelector}' 2>/dev/null)
		types=$(kubectl get netpol frontend-policy -n dusk -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
		egress=$(kubectl get netpol frontend-policy -n dusk -o jsonpath='{.spec.egress}' 2>/dev/null)

		if [ "$selector" == "frontend" ]; then
			((score += 1))
			details+="Policy selects app=frontend. "
		else
			details+="podSelector incorrect ($selector). "
		fi
		if [ "$from_app" == "backend" ] && [ -z "$from_ns" ]; then
			((score += 2))
			details+="Ingress allowed only from app=backend. "
		else
			details+="Ingress source incorrect ($from_app). "
		fi
		if [[ "$types" != *Egress* ]] || [ "$egress" == "[{}]" ]; then
			((score += 1))
			details+="Egress left unrestricted. "
		else
			details+="Egress restricted: incorrect. "
		fi
	else
		details+="NetworkPolicy frontend-policy not found in dusk namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q18() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "ingress" "star-ingress" "starlight"; then
		((score += 1))
		details+="Ingress star-ingress exists. "

		local ingress_class hosts paths
		ingress_class=$(kubectl get ingress star-ingress -n starlight -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)
		hosts=$(kubectl get ingress star-ingress -n starlight -o jsonpath='{.spec.rules[*].host}' 2>/dev/null)
		paths=$(kubectl get ingress star-ingress -n starlight -o jsonpath='{range .spec.rules[*].http.paths[*]}{.path}{" "}{.pathType}{" "}{.backend.service.name}{" "}{.backend.service.port.number}{"\n"}{end}' 2>/dev/null)

		if [ "$ingress_class" == "nginx" ]; then
			((score += 1))
			details+="Ingress class is nginx. "
		else
			details+="ingressClassName incorrect ($ingress_class). "
		fi
		if [ "$hosts" == "star.local" ]; then
			((score += 1))
			details+="Rules limited to host star.local. "
		else
			details+="Host incorrect ($hosts). "
		fi
		if echo "$paths" | grep -qE '^/api/? [A-Za-z]+ api-svc 8080$'; then
			((score += 1))
			details+="/api routes to api-svc:8080. "
		else
			details+="/api path to api-svc:8080 missing. "
		fi
		if echo "$paths" | grep -qE '^/web/? [A-Za-z]+ web-svc 80$'; then
			((score += 1))
			details+="/web routes to web-svc:80. "
		else
			details+="/web path to web-svc:80 missing. "
		fi
		# Only Prefix gives segment-based matching on every controller
		if [ -n "$paths" ] && ! echo "$paths" | awk '{print $2}' | grep -qv "^Prefix$"; then
			((score += 1))
			details+="Both paths use pathType Prefix. "
		else
			details+="pathType incorrect: segment matching needs Prefix. "
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

	[ -z "$details" ] && details="Expected configuration not found."
	echo "$score/$max_points"
	echo "DETAILS:$details"
}

score_q20() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "deployment" "api-deploy-canary" "void"; then
		((score += 1))
		details+="Deployment api-deploy-canary exists. "

		local replicas image version
		replicas=$(kubectl get deployment api-deploy-canary -n void -o jsonpath='{.spec.replicas}' 2>/dev/null)
		image=$(kubectl get deployment api-deploy-canary -n void -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		version=$(kubectl get deployment api-deploy-canary -n void -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
		if [ "$replicas" == "1" ] && [ "$image" == "nginx:1.25" ]; then
			((score += 1))
			details+="Canary runs 1 replica of nginx:1.25. "
		else
			details+="Canary replicas or image incorrect ($replicas, $image). "
		fi
		if [ "$version" == "canary" ]; then
			((score += 1))
			details+="Canary Pods labelled version=canary. "
		else
			details+="Canary Pod label version=canary missing. "
		fi
	else
		details+="Deployment api-deploy-canary not found in void namespace. "
	fi

	local backends
	backends=$(kubectl get endpointslices -n void -l kubernetes.io/service-name=void-svc -o jsonpath='{range .items[*].endpoints[*]}{.targetRef.name}{"\n"}{end}' 2>/dev/null)
	if echo "$backends" | grep -q "^api-deploy-canary-"; then
		((score += 1))
		details+="void-svc routes to the canary Pods. "
	else
		details+="void-svc endpoints missing the canary Pods. "
	fi
	if echo "$backends" | grep -q "^api-deploy-canary-" && echo "$backends" | grep -v "^api-deploy-canary-" | grep -q "^api-deploy-"; then
		((score += 1))
		details+="void-svc routes to both canary and api-deploy Pods. "
	else
		details+="void-svc not routing to both canary and api-deploy Pods: missing. "
	fi

	local stable_image stable_replicas
	stable_image=$(kubectl get deployment api-deploy -n void -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
	stable_replicas=$(kubectl get deployment api-deploy -n void -o jsonpath='{.spec.replicas}' 2>/dev/null)
	if resource_exists "deployment" "api-deploy-canary" "void" && [ "$stable_image" == "nginx:1.25" ] && [ "$stable_replicas" == "2" ]; then
		((score += 1))
		details+="api-deploy left unchanged. "
	else
		details+="No canary yet, or api-deploy modified: incorrect. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
