FROM golang:alpine AS build-env

# Add bash (if using alpine):
RUN apk add --no-cache --upgrade bash
# Add GCC (for dlv and CGO_ENABLED):
RUN apk add build-base

RUN go install github.com/cespare/reflex@latest
RUN go install github.com/go-delve/delve/cmd/dlv@latest


# Added since dlv kept refusing to be copied:
FROM build-env

# Since this is not a real image:
ADD reflex.conf /usr/local/etc/
ADD build.sh /usr/local/bin/
# Ensure build can be executed:
RUN chmod +x /usr/local/bin/build.sh

# Include dlv:
COPY --from=build-env /go/bin/reflex /
COPY --from=build-env /go/bin/dlv /

WORKDIR /app

VOLUME /go

# Build.sh will be executed every time that a change has been made!
CMD ["reflex", "-d", "none", "-c", "/usr/local/etc/reflex.conf"]
