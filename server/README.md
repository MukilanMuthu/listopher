# Listopher server

Dart `shelf` + SQLite sync server. API: [ADR 8](../docs/adr/0008-server-api.md).

## Run
    dart pub get
    dart run bin/server.dart          # serves on :8080, db in ./listopher.db

Env: `PORT` (default 8080), `DB_PATH` (default `listopher.db`).

## Accounts (no public sign-up)
    dart run bin/server.dart add-user <username> <display name>   # asks password twice
    dart run bin/server.dart set-password <username>
    dart run bin/server.dart revoke-sessions <username>           # stolen phone

## Docker
Build from the repo root (the server needs `../core`):

    docker build -f server/Dockerfile -t listopher-server .
    docker run -d -p 8080:8080 -v listopher-data:/data listopher-server
    docker run -it --rm -v listopher-data:/data listopher-server add-user alice "Alice"

## HTTPS
The server speaks plain `http://`. Passwords and tokens are readable on the network.
Put a reverse proxy with HTTPS in front (e.g. Caddy: `caddy reverse-proxy --from your.host --to :8080`).

## Test
    dart test
