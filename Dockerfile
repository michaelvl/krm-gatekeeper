FROM golang:1.23.1-alpine3.20 AS builder

WORKDIR /app

COPY gator.go go.mod go.sum ./
RUN go build -o main ./

####################
FROM alpine:3.20.0

WORKDIR /app

COPY --from=builder /app/main .

ENTRYPOINT ["/app/main"]
