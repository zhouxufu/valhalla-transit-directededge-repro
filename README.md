# Valhalla transit DirectedEdge reproduction

This repository reproduces a bicycle `/locate` failure in Valhalla 3.8.2 after transit tiles are built from a minimal, validator-clean GTFS feed.

## Run

Requirements: Docker and curl.

```bash
chmod +x reproduce.sh
./reproduce.sh
```

Expected failure:

```text
GraphTile DirectedEdge index out of bounds: 771621,3,139 directededgecount= 14
HTTP 500
```

The script uses the official image:

```text
ghcr.io/valhalla/valhalla-scripted:3.8.2
sha256:3d7a08f7e78b356ee873b61711b743ad81bcc114b0ca5731217da8bba6ba39d1
```

The GTFS feed contains two stops, two trips, and one rail route. It has no `shapes.txt`. MobilityData GTFS Validator 8.0.1 reports zero errors and one metadata warning.

## Data attribution

`changchun-repro.osm.pbf` is a small extract derived from the Geofabrik Jilin OpenStreetMap extract downloaded on 2026-06-23.

SHA-256: `ebbbc73179fef2fcf44bc0d125112fa8793486030a07a90c1ed110baa2cac0d9`

- OpenStreetMap data: copyright OpenStreetMap contributors, available under the [ODbL](https://www.openstreetmap.org/copyright)
- Geofabrik download page: <https://download.geofabrik.de/asia/china/jilin.html>

The GTFS fixture is synthetic and contains no production transit data.
