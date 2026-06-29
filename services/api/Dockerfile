FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY services/api/go.mod services/api/go.sum* ./
RUN go mod download
COPY services/api ./
RUN go build -o /out/api ./cmd/api

FROM alpine:3.20
RUN adduser -D -g '' appuser
WORKDIR /app
COPY --from=builder /out/api /app/api
COPY services/api/migrations /app/migrations
USER appuser
EXPOSE 8080
CMD ["/app/api"]
