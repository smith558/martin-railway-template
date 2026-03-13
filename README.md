[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/ZJKGyS?referralCode=MtbmC4&utm_medium=integration&utm_source=template&utm_campaign=generic)
# Martin on Railway

Minimal Railway template seed for self-hosting [Martin](https://maplibre.org/martin/) against a PostGIS-backed PostgreSQL database.

## Included

- `Dockerfile`: pinned Martin image
- `martin.yaml`: production-leaning config
- `railway.toml`: Docker build, pre-deploy validation, and `/health` health check

## Template defaults

- Binds to `0.0.0.0:${PORT}`
- Reads PostgreSQL connection from `DATABASE_URL`
- Disables the Martin web UI
- Fails startup on invalid config
- Auto-publishes only PostGIS sources in `MARTIN_PUBLISH_SCHEMA` or `public` by default

## Railway wiring

Create a Railway project with:

- a PostGIS-capable database service named `PostGIS`
- a service from this repo named `Martin`

Set these variables on `Martin`:

```env
DATABASE_URL=${{PostGIS.DATABASE_URL}}
MARTIN_PUBLISH_SCHEMA=public
MARTIN_WEB_UI=disable
RUST_LOG=info
RUST_LOG_FORMAT=json
```

Railway pre-deploy fails immediately with a clear error if `DATABASE_URL` is missing.
The container also exits immediately on startup if `DATABASE_URL` is missing.
If `PORT` is unset, the entrypoint defaults it to `3000`.
For external PostgreSQL providers, keep `DATABASE_URL` Martin-compatible. In testing against Neon, `sslmode=verify-full` worked without `channel_binding=require`, while `channel_binding=require` caused Martin startup to fail.
Set `MARTIN_WEB_UI=enable-for-all` if you want Martin's built-in web UI enabled.

Expose `Martin` with public networking if the service should be reachable from clients.

## Expected endpoints

- `/health`
- `/catalog`
- `/{sourceID}`
- `/{sourceID}/{z}/{x}/{y}`

Table source IDs default to `table.{schema}.{table}.{column}`.

## Intended usage

Keep user-managed spatial tables and MVT-returning functions in the `public` schema by default.

If you want a different schema, set `MARTIN_PUBLISH_SCHEMA`.

If you need to change publish rules, CORS, route prefixes, caching, or add other sources, edit `martin.yaml` and redeploy.
