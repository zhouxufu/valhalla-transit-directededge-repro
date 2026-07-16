#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"
CONTAINER="valhalla-transit-directededge-repro"
PORT="${PORT:-8015}"

cleanup() {
  docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}"
cp "${SCRIPT_DIR}/changchun-repro.osm.pbf" "${DATA_DIR}/"

docker run -d \
  --name "${CONTAINER}" \
  -p "${PORT}:8002" \
  -v "${DATA_DIR}:/custom_files" \
  -v "${SCRIPT_DIR}/gtfs:/gtfs_feeds:ro" \
  -e use_tiles_ignore_pbf=False \
  -e force_rebuild=True \
  -e build_transit=Force \
  -e build_tar=True \
  -e build_admins=True \
  -e build_time_zones=True \
  -e build_elevation=False \
  -e server_threads=4 \
  ghcr.io/valhalla/valhalla-scripted:3.8.2 >/dev/null

for attempt in $(seq 1 180); do
  if curl -fsS --max-time 2 "http://127.0.0.1:${PORT}/status" >/dev/null 2>&1; then
    break
  fi
  if [[ "$(docker inspect -f '{{.State.Running}}' "${CONTAINER}")" != "true" ]]; then
    docker logs "${CONTAINER}" >&2
    exit 1
  fi
  sleep 2
done

curl -sS -w '\nHTTP %{http_code}\n' \
  -X POST "http://127.0.0.1:${PORT}/locate" \
  -H 'Content-Type: application/json' \
  --data '{"locations":[{"lat":43.767374,"lon":125.438436}],"costing":"bicycle"}'
