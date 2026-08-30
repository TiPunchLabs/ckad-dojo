#!/bin/bash
exam_post_setup() {
  # Install Helm release for Q5
  helm repo add bitnami https://charts.bitnami.com/bitnami > /dev/null 2>&1
  helm repo update > /dev/null 2>&1
  helm install ocean-api bitnami/nginx --namespace current > /dev/null 2>&1
  
  # Generate some warning events for Q10
  kubectl run failing-pod --image=wrong-image-for-event --namespace depths > /dev/null 2>&1
  sleep 5
  kubectl delete pod failing-pod --namespace depths --force --grace-period=0 > /dev/null 2>&1

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course/15"
  
  mkdir -p "$BASE_DIR/q1"
  cat << 'EOF_FILE' > "$BASE_DIR/q1/Dockerfile"
FROM golang:1.20-alpine
COPY . /app
WORKDIR /app
RUN go build -o app main.go
CMD ["./app"]
EOF_FILE

  mkdir -p "$BASE_DIR/q10"
  
  mkdir -p "$BASE_DIR/q12/config-files"
  echo "key1=value1" > "$BASE_DIR/q12/config-files/app.conf"
  
  mkdir -p "$BASE_DIR/q8"
  
  return 0
}
