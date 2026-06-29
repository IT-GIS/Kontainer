FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY services/worker/go.mod services/worker/go.sum* ./
RUN go mod download
COPY services/worker ./
RUN go build -o /out/worker ./cmd/worker

FROM alpine:3.20
RUN adduser -D -g '' appuser
WORKDIR /app
COPY --from=builder /out/worker /app/worker
USER appuser
CMD ["/app/worker"]
