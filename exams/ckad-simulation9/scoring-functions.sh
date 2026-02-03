#!/bin/bash
# CKAD Simulation 9 - Dojo Ryujin 🐲 - Scoring Functions
# Original Questions: https://github.com/dgkanatsios/CKAD-exercises

# Q1: Helm Create Chart (5 points)
score_q1() {
	local score=0
	local max_points=5
	local details=""

	local chart_dir="./exam/course/1/sea-app"

	if [[ -d "$chart_dir" ]]; then
		((score += 2))
		details+="Chart directory exists. "

		if [[ -f "$chart_dir/Chart.yaml" ]]; then
			((score += 1))
			details+="Chart.yaml exists. "
		else
			details+="Chart.yaml not found. "
		fi

		if [[ -f "$chart_dir/values.yaml" ]]; then
			((score += 1))
			details+="values.yaml exists. "
		else
			details+="values.yaml not found. "
		fi

		if [[ -d "$chart_dir/templates" ]]; then
			((score += 1))
			details+="templates directory exists. "
		else
			details+="templates directory not found. "
		fi
	else
		details+="Chart directory ./exam/course/1/sea-app not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q2: Helm Install with Custom Values (6 points)
score_q2() {
	local score=0
	local max_points=6
	local details=""

	local release_info
	release_info=$(helm list -n tide -o json 2>/dev/null | grep -o '"name":"my-release"' || true)

	if [[ -n "$release_info" ]]; then
		((score += 3))
		details+="Release my-release exists in tide namespace. "

		local replicas
		replicas=$(kubectl get deployment -n tide -l app.kubernetes.io/instance=my-release -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "2" ]]; then
			((score += 3))
			details+="replicaCount is 2. "
		else
			details+="replicaCount is $replicas (expected: 2). "
		fi
	else
		details+="Helm release my-release not found in tide namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q3: Helm Upgrade Release (5 points)
score_q3() {
	local score=0
	local max_points=5
	local details=""

	local release_info
	release_info=$(helm list -n tide -o json 2>/dev/null | grep -o '"name":"my-release"' || true)

	if [[ -n "$release_info" ]]; then
		((score += 2))
		details+="Release my-release exists. "

		local replicas
		replicas=$(kubectl get deployment -n tide -l app.kubernetes.io/instance=my-release -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "3" ]]; then
			((score += 3))
			details+="replicaCount upgraded to 3. "
		else
			details+="replicaCount is $replicas (expected: 3 after upgrade). "
		fi
	else
		details+="Helm release my-release not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q4: Helm Rollback (5 points)
score_q4() {
	local score=0
	local max_points=5
	local details=""

	local release_info
	release_info=$(helm list -n wave -o json 2>/dev/null | grep -o '"name":"rollback-app"' || true)

	if [[ -n "$release_info" ]]; then
		((score += 2))
		details+="Release rollback-app exists. "

		local revision
		revision=$(helm history rollback-app -n wave --max 1 -o json 2>/dev/null | grep -o '"revision":[0-9]*' | head -1 | grep -o '[0-9]*')
		if [[ "$revision" -ge 3 ]]; then
			((score += 3))
			details+="Rollback performed (revision $revision). "
		else
			details+="No rollback detected (revision $revision). "
		fi
	else
		details+="Helm release rollback-app not found in wave namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q5: PersistentVolume Creation (6 points)
score_q5() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pv" "sea-pv" ""; then
		((score += 2))
		details+="PV sea-pv exists. "

		local capacity
		capacity=$(kubectl get pv sea-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
		if [[ "$capacity" == "5Gi" ]]; then
			((score += 1))
			details+="Capacity is 5Gi. "
		else
			details+="Capacity is $capacity (expected: 5Gi). "
		fi

		local access_mode
		access_mode=$(kubectl get pv sea-pv -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
		if [[ "$access_mode" == "ReadWriteOnce" ]]; then
			((score += 1))
			details+="Access mode is ReadWriteOnce. "
		else
			details+="Access mode is $access_mode (expected: ReadWriteOnce). "
		fi

		local storage_class
		storage_class=$(kubectl get pv sea-pv -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
		if [[ "$storage_class" == "manual" ]]; then
			((score += 1))
			details+="Storage class is manual. "
		else
			details+="Storage class is $storage_class (expected: manual). "
		fi

		local host_path
		host_path=$(kubectl get pv sea-pv -o jsonpath='{.spec.hostPath.path}' 2>/dev/null)
		if [[ "$host_path" == "/data/sea" ]]; then
			((score += 1))
			details+="Host path is /data/sea. "
		else
			details+="Host path is $host_path (expected: /data/sea). "
		fi
	else
		details+="PV sea-pv not found. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q6: PersistentVolumeClaim (5 points)
score_q6() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pvc" "sea-pvc" "depths"; then
		((score += 2))
		details+="PVC sea-pvc exists in depths namespace. "

		local request
		request=$(kubectl get pvc sea-pvc -n depths -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
		if [[ "$request" == "2Gi" ]]; then
			((score += 1))
			details+="Storage request is 2Gi. "
		else
			details+="Storage request is $request (expected: 2Gi). "
		fi

		local access_mode
		access_mode=$(kubectl get pvc sea-pvc -n depths -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
		if [[ "$access_mode" == "ReadWriteOnce" ]]; then
			((score += 1))
			details+="Access mode is ReadWriteOnce. "
		else
			details+="Access mode is $access_mode (expected: ReadWriteOnce). "
		fi

		local storage_class
		storage_class=$(kubectl get pvc sea-pvc -n depths -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
		if [[ "$storage_class" == "manual" ]]; then
			((score += 1))
			details+="Storage class is manual. "
		else
			details+="Storage class is $storage_class (expected: manual). "
		fi
	else
		details+="PVC sea-pvc not found in depths namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q7: Pod with PVC (5 points)
score_q7() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "pvc-pod" "depths"; then
		((score += 2))
		details+="Pod pvc-pod exists in depths namespace. "

		local image
		image=$(kubectl get pod pvc-pod -n depths -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"busybox"* ]]; then
			((score += 1))
			details+="Image is busybox. "
		else
			details+="Image is $image (expected: busybox). "
		fi

		local pvc_name
		pvc_name=$(kubectl get pod pvc-pod -n depths -o jsonpath='{.spec.volumes[?(@.persistentVolumeClaim)].persistentVolumeClaim.claimName}' 2>/dev/null)
		if [[ "$pvc_name" == "sea-pvc" ]]; then
			((score += 1))
			details+="PVC sea-pvc is mounted. "
		else
			details+="PVC $pvc_name is mounted (expected: sea-pvc). "
		fi

		local mount_path
		mount_path=$(kubectl get pod pvc-pod -n depths -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		mount_path="${mount_path%/}"
		if [[ "$mount_path" == "/data" ]]; then
			((score += 1))
			details+="Mount path is /data. "
		else
			details+="Mount path is $mount_path (expected: /data). "
		fi
	else
		details+="Pod pvc-pod not found in depths namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q8: Pod with nodeName (5 points)
score_q8() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "pod" "direct-pod" "coral"; then
		((score += 2))
		details+="Pod direct-pod exists in coral namespace. "

		local image
		image=$(kubectl get pod direct-pod -n coral -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"nginx"* ]]; then
			((score += 1))
			details+="Image is nginx. "
		else
			details+="Image is $image (expected: nginx). "
		fi

		local node_name
		node_name=$(kubectl get pod direct-pod -n coral -o jsonpath='{.spec.nodeName}' 2>/dev/null)
		if [[ -n "$node_name" ]]; then
			((score += 2))
			details+="nodeName is set to $node_name. "
		else
			details+="nodeName not set. "
		fi
	else
		details+="Pod direct-pod not found in coral namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q9: Pod Lifecycle - Echo and Exit (4 points)
score_q9() {
	local score=0
	local max_points=4
	local details=""

	# Check if Pod exists or existed (could have completed)
	local pod_info
	pod_info=$(kubectl get pod echo-pod -n current -o json 2>/dev/null)

	if [[ -n "$pod_info" ]]; then
		((score += 2))
		details+="Pod echo-pod exists. "

		local phase
		phase=$(echo "$pod_info" | grep -o '"phase":"[^"]*"' | head -1 | cut -d'"' -f4)
		if [[ "$phase" == "Succeeded" || "$phase" == "Completed" ]]; then
			((score += 2))
			details+="Pod completed successfully. "
		elif [[ "$phase" == "Running" ]]; then
			details+="Pod still running (expected: Succeeded/Completed). "
		else
			details+="Pod phase is $phase. "
		fi
	else
		# Pod may have been auto-deleted with --rm flag
		details+="Pod echo-pod not found (may have completed with --rm). "
		# Give partial credit if logs show the pod ran
		((score += 2))
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q10: Get Pod YAML (4 points)
score_q10() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "pod" "inspect-pod" "abyss"; then
		((score += 2))
		details+="Pod inspect-pod exists in abyss namespace. "
	else
		details+="Pod inspect-pod not found in abyss namespace. "
	fi

	local yaml_file="./exam/course/10/pod.yaml"
	if file_exists_and_not_empty "$yaml_file"; then
		((score += 1))
		details+="YAML file exists. "

		if file_contains "$yaml_file" "kind: Pod" && file_contains "$yaml_file" "inspect-pod"; then
			((score += 1))
			details+="YAML contains Pod definition for inspect-pod. "
		else
			details+="YAML file does not contain expected Pod definition. "
		fi
	else
		details+="YAML file $yaml_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q11: Describe Pod and Find Events (5 points)
score_q11() {
	local score=0
	local max_points=5
	local details=""

	local events_file="./exam/course/11/events.txt"
	if file_exists_and_not_empty "$events_file"; then
		((score += 3))
		details+="Events file exists. "

		if file_contains "$events_file" "Events:" || file_contains "$events_file" "Type" || file_contains "$events_file" "Normal" || file_contains "$events_file" "Warning"; then
			((score += 2))
			details+="File contains event information. "
		else
			details+="File does not contain expected event format. "
		fi
	else
		details+="Events file $events_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q12: Execute Command in Pod (4 points)
score_q12() {
	local score=0
	local max_points=4
	local details=""

	if resource_exists "pod" "exec-pod" "storm"; then
		((score += 2))
		details+="Pod exec-pod exists in storm namespace. "
	else
		details+="Pod exec-pod not found in storm namespace. "
	fi

	local hostname_file="./exam/course/12/hostname.txt"
	if file_exists_and_not_empty "$hostname_file"; then
		((score += 2))
		details+="Hostname file exists and contains output. "
	else
		details+="Hostname file $hostname_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q13: Get Previous Container Logs (5 points)
score_q13() {
	local score=0
	local max_points=5
	local details=""

	local logs_file="./exam/course/13/previous.txt"
	if file_exists_and_not_empty "$logs_file"; then
		((score += 5))
		details+="Previous logs file exists and contains output. "
	else
		details+="Previous logs file $logs_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q14: Top Nodes (4 points)
score_q14() {
	local score=0
	local max_points=4
	local details=""

	local nodes_file="./exam/course/14/nodes.txt"
	if file_exists_and_not_empty "$nodes_file"; then
		((score += 2))
		details+="Nodes file exists. "

		if file_contains "$nodes_file" "CPU" || file_contains "$nodes_file" "MEMORY" || file_contains "$nodes_file" "%"; then
			((score += 2))
			details+="File contains node metrics. "
		else
			details+="File does not contain expected metrics format. "
		fi
	else
		details+="Nodes file $nodes_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q15: ConfigMap from .env File (5 points)
score_q15() {
	local score=0
	local max_points=5
	local details=""

	local env_file="./exam/course/15/config.env"
	if file_exists_and_not_empty "$env_file"; then
		((score += 1))
		details+=".env file exists. "

		if file_contains "$env_file" "DB_HOST" && file_contains "$env_file" "DB_PORT"; then
			((score += 1))
			details+=".env file has correct content. "
		else
			details+=".env file missing expected keys. "
		fi
	else
		details+=".env file $env_file not found or empty. "
	fi

	if resource_exists "configmap" "env-config" "voyage"; then
		((score += 2))
		details+="ConfigMap env-config exists in voyage namespace. "

		local db_host
		db_host=$(kubectl get configmap env-config -n voyage -o jsonpath='{.data.DB_HOST}' 2>/dev/null)
		local db_port
		db_port=$(kubectl get configmap env-config -n voyage -o jsonpath='{.data.DB_PORT}' 2>/dev/null)
		if [[ "$db_host" == "localhost" && "$db_port" == "5432" ]]; then
			((score += 1))
			details+="ConfigMap has correct values. "
		else
			details+="ConfigMap values incorrect (DB_HOST=$db_host, DB_PORT=$db_port). "
		fi
	else
		details+="ConfigMap env-config not found in voyage namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q16: Deployment Rollout to Specific Revision (5 points)
score_q16() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "deployment" "web-deploy" "tide"; then
		((score += 2))
		details+="Deployment web-deploy exists in tide namespace. "

		# Check if rollout undo was performed (revision should be > 3 after undo to 2)
		local current_revision
		current_revision=$(kubectl rollout history deployment/web-deploy -n tide 2>/dev/null | tail -1 | awk '{print $1}')
		if [[ "$current_revision" -ge 4 ]]; then
			((score += 3))
			details+="Rollout undo performed (current revision: $current_revision). "
		else
			details+="No rollout undo detected (revision: $current_revision). "
		fi
	else
		details+="Deployment web-deploy not found in tide namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q17: Check Rollout History Details (5 points)
score_q17() {
	local score=0
	local max_points=5
	local details=""

	local revision_file="./exam/course/17/revision.txt"
	if file_exists_and_not_empty "$revision_file"; then
		((score += 3))
		details+="Revision file exists. "

		if file_contains "$revision_file" "revision" || file_contains "$revision_file" "Containers:" || file_contains "$revision_file" "Image:"; then
			((score += 2))
			details+="File contains revision details. "
		else
			details+="File does not contain expected revision format. "
		fi
	else
		details+="Revision file $revision_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q18: Job with Perl Image (5 points)
score_q18() {
	local score=0
	local max_points=5
	local details=""

	if resource_exists "job" "pi-job" "coral"; then
		((score += 2))
		details+="Job pi-job exists in coral namespace. "

		local image
		image=$(kubectl get job pi-job -n coral -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"perl"* ]]; then
			((score += 2))
			details+="Image is perl. "
		else
			details+="Image is $image (expected: perl). "
		fi

		local command
		command=$(kubectl get job pi-job -n coral -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null)
		if [[ "$command" == *"bpi"* ]]; then
			((score += 1))
			details+="Command calculates Pi. "
		else
			details+="Command does not contain bpi. "
		fi
	else
		details+="Job pi-job not found in coral namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q19: Multi-Container Pod with Shared Volume (6 points)
score_q19() {
	local score=0
	local max_points=6
	local details=""

	if resource_exists "pod" "sidecar-pod" "abyss"; then
		((score += 1))
		details+="Pod sidecar-pod exists in abyss namespace. "

		local container_count
		container_count=$(kubectl get pod sidecar-pod -n abyss -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
		if [[ "$container_count" -ge 2 ]]; then
			((score += 1))
			details+="Pod has $container_count containers. "
		else
			details+="Pod has $container_count container(s) (expected: 2). "
		fi

		local app_container
		app_container=$(kubectl get pod sidecar-pod -n abyss -o jsonpath='{.spec.containers[?(@.name=="app")].name}' 2>/dev/null)
		if [[ "$app_container" == "app" ]]; then
			((score += 1))
			details+="Container app exists. "
		else
			details+="Container app not found. "
		fi

		local sidecar_container
		sidecar_container=$(kubectl get pod sidecar-pod -n abyss -o jsonpath='{.spec.containers[?(@.name=="sidecar")].name}' 2>/dev/null)
		if [[ "$sidecar_container" == "sidecar" ]]; then
			((score += 1))
			details+="Container sidecar exists. "
		else
			details+="Container sidecar not found. "
		fi

		local volume_name
		volume_name=$(kubectl get pod sidecar-pod -n abyss -o jsonpath='{.spec.volumes[0].name}' 2>/dev/null)
		local empty_dir
		empty_dir=$(kubectl get pod sidecar-pod -n abyss -o jsonpath='{.spec.volumes[0].emptyDir}' 2>/dev/null)
		if [[ -n "$volume_name" && -n "$empty_dir" ]]; then
			((score += 1))
			details+="emptyDir volume exists. "
		else
			details+="emptyDir volume not found. "
		fi

		local mount_path
		mount_path=$(kubectl get pod sidecar-pod -n abyss -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
		mount_path="${mount_path%/}"
		if [[ "$mount_path" == "/logs" ]]; then
			((score += 1))
			details+="Volume mounted at /logs. "
		else
			details+="Volume mount path is $mount_path (expected: /logs). "
		fi
	else
		details+="Pod sidecar-pod not found in abyss namespace. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q20: Resource Utilization of Pods (5 points)
score_q20() {
	local score=0
	local max_points=5
	local details=""

	local pods_file="./exam/course/20/top-pods.txt"
	if file_exists_and_not_empty "$pods_file"; then
		((score += 3))
		details+="Pods file exists. "

		if file_contains "$pods_file" "CPU" || file_contains "$pods_file" "MEMORY" || file_contains "$pods_file" "NAME"; then
			((score += 2))
			details+="File contains pod metrics. "
		else
			details+="File does not contain expected metrics format. "
		fi
	else
		details+="Pods file $pods_file not found or empty. "
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
