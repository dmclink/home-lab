FROM golang:1.26-alpine AS builder

WORKDIR /app

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags="-s -w" -o main .

FROM alpine:3.23

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata

RUN addgroup -S appuser \
    && adduser -S -G appuser -H -s /sbin/nologin appuser

COPY --from=builder --chown=appuser:appuser /app/main /app/main

ENTRYPOINT ["/app/main"]
