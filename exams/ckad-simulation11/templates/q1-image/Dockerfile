# Single-stage Dockerfile (INEFFICIENT - produces large image)
# TODO: Convert this to a multi-stage build
# Stage 1 should build the Go binary using golang:1.21-alpine
# Stage 2 should copy only the binary into alpine:3.19

FROM golang:1.21-alpine
WORKDIR /app
COPY main.go .
RUN go build -o server main.go
EXPOSE 8080
CMD ["./server"]
