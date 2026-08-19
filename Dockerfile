FROM golang:1.26 AS builder

ENV GOTOOLCHAIN=local
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm && \
    rm -rf /var/lib/apt/lists/*

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN cd web && npm ci --registry=https://registry.npmjs.org --fetch-retries=5 \
    --fetch-retry-mintimeout=2000 --fetch-retry-maxtimeout=30000 && npm run build
RUN CGO_ENABLED=0 go build -o /bin/certgateway ./cmd/certgateway
RUN CGO_ENABLED=0 go build -o /bin/certupstream ./cmd/certupstream

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /bin/certgateway /app/certgateway
COPY --from=builder /bin/certupstream /app/certupstream
COPY --from=builder /app/web/dist /app/web/dist
COPY configs/ /app/configs/

ENV CERT_HTTP_ADDR=:52661
EXPOSE 52661

CMD ["/app/certgateway", "-config", "/app/configs/config.yaml"]
