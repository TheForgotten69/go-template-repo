# Use the official golang image to create a binary.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang

FROM golang:1.19.3-buster as builder

ARG GITHUB_USER_TOKEN

RUN git config --global url."https://${GITHUB_USER_TOKEN}:x-oauth-basic@github.com/TheForgotten69".insteadOf "https://github.com/TheForgotten69"

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
RUN go build -mod=readonly -v -o server

# Use the official GCP distroless
# https://github.com/GoogleContainerTools/distroless
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM gcr.io/distroless/base

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/server /server

# Run the web service on container startup.
CMD ["/server"]