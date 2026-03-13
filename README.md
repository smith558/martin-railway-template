# Martin on Railway

Minimal Railway template seed for self-hosting [Martin](https://maplibre.org/martin/) against a PostGIS-backed PostgreSQL database.

## Included

- `Dockerfile`: pinned Martin image
- `martin.yaml`: production-leaning config
- `railway.toml`: Docker build and `/health` health check

## Template defaults

- Binds to `0.0.0.0:${PORT:-3000}`
- Reads PostgreSQL connection from `DATABASE_URL`
- Disables the Martin web UI
- Fails startup on invalid config
- Auto-publishes only PostGIS sources in the `tiles` schema

## Railway wiring

Create a Railway project with:

- a PostGIS-capable database service named `PostGIS`
- a service from this repo named `Martin`

Set these variables on `Martin`:

```env
DATABASE_URL=${{PostGIS.DATABASE_URL}}
RUST_LOG=info
RUST_LOG_FORMAT=json
```

The container exits immediately with a clear error if `DATABASE_URL` is missing.

Expose `Martin` with public networking if the service should be reachable from clients.

## Expected endpoints

- `/health`
- `/catalog`
- `/{sourceID}`
- `/{sourceID}/{z}/{x}/{y}`

Table source IDs default to `table.{schema}.{table}.{column}`.

## Intended usage

Keep user-managed spatial tables and MVT-returning functions in the `tiles` schema.

If you need to change publish rules, CORS, route prefixes, caching, or add other sources, edit `martin.yaml` and redeploy.
