FROM golang:1.26

ENV GOTOOLCHAIN=local
WORKDIR /app

# Use the official Debian package source inherited from the golang image.
RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Download Go dependencies
COPY go.mod go.sum ./
RUN for attempt in 1 2 3 4 5; do go mod download && break; if [ "$attempt" -eq 5 ]; then exit 1; fi; sleep 5; done

# Install frontend dependencies and build
COPY web/package*.json ./web/
RUN cd web && npm ci --registry=https://registry.npmjs.org --fetch-retries=5 \
    --fetch-retry-mintimeout=2000 --fetch-retry-maxtimeout=30000

# Build Go and frontend
COPY . .
RUN go build ./...
RUN cd web && npm run type-check && npm run build

CMD ["bash"]
