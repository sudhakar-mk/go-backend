# ---- Build stage ----
FROM golang:1.24.4-alpine AS build
WORKDIR /src

# copy go.mod only (if you don't have go.sum). If you do have go.sum, copy both:
# COPY go.mod go.sum ./
COPY go.mod ./

# download modules (will create a go.sum inside the build if not present)
RUN go mod download

# copy source and build a static linux binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /server main.go

# ---- Runtime stage ----
FROM alpine:3.18
# install ca-certificates if your app makes outbound TLS requests; small & safe
RUN apk add --no-cache ca-certificates

# create a non-root user (optional, recommended)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=build /server /app/server
RUN chown appuser:appgroup /app/server

USER appuser

EXPOSE 8080
CMD ["./server"]
