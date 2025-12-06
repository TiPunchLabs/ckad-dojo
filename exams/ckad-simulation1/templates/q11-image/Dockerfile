# Q11 Dockerfile - sun-cipher application
# User must modify this to expose port 80

FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY main.go .
RUN go build -o sun-cipher main.go

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/sun-cipher .

# EXPOSE 80  # User must uncomment this line

CMD ["./sun-cipher"]
