FROM golang:1.21.6-alpine3.19 as builder

WORKDIR /app

COPY gator.go go.mod go.sum ./
RUN go build -o main ./

####################
FROM alpine:3.19.1

WORKDIR /app

COPY --from=builder /app/main .

ENTRYPOINT ["/app/main"]
