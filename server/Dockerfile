# build from the repo root: docker build -f server/Dockerfile -t listopher-server .
# (server depends on ../core, so the context must hold both)
FROM dart:stable AS build
WORKDIR /app
COPY core ./core
COPY server ./server
WORKDIR /app/server
RUN dart pub get
# dart build cli, not dart compile exe: sqlite3 build hooks break compile exe
RUN dart build cli --target=bin/server.dart -o /out

# runtime: scratch + dart runtime libs only (per official dart image docs)
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /out/bundle/ /app/
ENV PORT=8080 DB_PATH=/data/listopher.db
EXPOSE 8080
VOLUME /data
ENTRYPOINT ["/app/bin/server"]
