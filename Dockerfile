# ================================
# Build image
# ================================
FROM swift:5.6-focal
WORKDIR /app

## COPY . .

RUN apt-get update && apt-get install libsqlite3-dev

## RUN swift build

## RUN mkdir /app/bin
## RUN mv `swift build --show-bin-path` /app/bin

EXPOSE 8080
ENTRYPOINT swift run Run serve --env local --hostname 0.0.0.0
