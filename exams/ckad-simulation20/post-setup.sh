#!/bin/bash
exam_post_setup() {
	local BASE_DIR="./exam/course"
	mkdir -p "$BASE_DIR/1" "$BASE_DIR/2" "$BASE_DIR/3" "$BASE_DIR/4" "$BASE_DIR/5" "$BASE_DIR/6" "$BASE_DIR/7" "$BASE_DIR/8/base" "$BASE_DIR/8/prod" "$BASE_DIR/10" "$BASE_DIR/12" "$BASE_DIR/13" "$BASE_DIR/14" "$BASE_DIR/15" "$BASE_DIR/16" "$BASE_DIR/17" "$BASE_DIR/18" "$BASE_DIR/19" "$BASE_DIR/20"

	cat <<'EOF2' >"$BASE_DIR/1/main.go"
package main
import "fmt"
func main() { fmt.Println("Hello Dojo") }
EOF2
	cat <<'EOF2' >"$BASE_DIR/1/Dockerfile"
FROM nginx:alpine
# TODO
EOF2

	for q in 2/multi-pod 6/deploy 7/canary 12/secure-pod 14/inject 19/svc 20/dns; do
		cat <<'EOF2' >"$BASE_DIR/${q}.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub
spec:
  containers:
  - name: c
    image: nginx
EOF2
	done

	mkdir -p "$BASE_DIR/5/my-chart"

	return 0
}
