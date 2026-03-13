# Martin on Railway

This service runs [Martin](https://maplibre.org/martin/) on Railway and connects to a PostGIS database over Railway private networking.

## What gets published

Martin auto-publishes only PostGIS sources from the `tiles` schema.

- PostGIS tables with geometry columns
- PostgreSQL functions that return MVT

## Important URLs

- `/health` — basic health check
- `/catalog` — list of available sources
- `/{sourceID}` — TileJSON for a source
- `/{sourceID}/{z}/{x}/{y}` — tiles for a source

## Default source ID format

- Tables: `table.{schema}.{table}.{column}`
- Functions: `{schema}.{function}`

## Quick verification

After deployment, create a schema and test layer:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA IF NOT EXISTS tiles;

CREATE TABLE IF NOT EXISTS tiles.sample_points (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  geom geometry(Point, 4326) NOT NULL
);

INSERT INTO tiles.sample_points (name, geom)
VALUES
  ('London', ST_SetSRID(ST_MakePoint(-0.1276, 51.5072), 4326)),
  ('Ascot', ST_SetSRID(ST_MakePoint(-0.6718, 51.4108), 4326))
ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS sample_points_geom_gix
  ON tiles.sample_points
  USING GIST (geom);