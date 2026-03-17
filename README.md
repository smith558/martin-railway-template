[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/ZJKGyS?referralCode=MtbmC4&utm_medium=integration&utm_source=template&utm_campaign=generic)
# Martin on Railway

Minimal Railway template seed for self-hosting [Martin](https://maplibre.org/martin/) against a PostGIS-backed PostgreSQL database.
This variant builds Martin from source with `unstable-rendering` enabled so it can expose style-rendered raster tiles.

## Included

- `Dockerfile`: custom Martin build with `unstable-rendering`
- `martin.yaml`: production-leaning config
- `railway.toml`: Docker build, pre-deploy validation, and `/health` health check

## Template defaults

- Binds to `0.0.0.0:${PORT}`
- Reads PostgreSQL connection from `DATABASE_URL`
- Disables the Martin web UI
- Enables style rendering by default with `MARTIN_STYLE_RENDERING=true`
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
MARTIN_STYLE_RENDERING=true
RUST_LOG=info
RUST_LOG_FORMAT=json
```

Use unquoted Railway values. For example, prefer `MARTIN_PUBLISH_SCHEMA=public` over `MARTIN_PUBLISH_SCHEMA="public"`.

Railway pre-deploy fails immediately with a clear error if `DATABASE_URL` is missing.
The container also exits immediately on startup if `DATABASE_URL` is missing.
If `PORT` is unset, the entrypoint defaults it to `3000`.
For external PostgreSQL providers, keep `DATABASE_URL` Martin-compatible. In testing against Neon, `sslmode=verify-full` worked without `channel_binding=require`, while `channel_binding=require` caused Martin startup to fail.
Set `MARTIN_WEB_UI=enable-for-all` if you want Martin's built-in web UI enabled.
This repo ships starter styles in [`styles/`](/home/stanley/repos/martin-railway-template/styles). They are copied to `/etc/martin/styles` during the image build so Martin can expose `/style/<style_id>` and `/style/<style_id>/{z}/{x}/{y}.png`.

Expose `Martin` with public networking if the service should be reachable from clients.

## Expected endpoints

- `/health`
- `/catalog`
- `/{sourceID}`
- `/{sourceID}/{z}/{x}/{y}`
- `/style/{style_id}`
- `/style/{style_id}/{z}/{x}/{y}.png`

Table source IDs default to `{table}` in this template, so a `public.Dataset` table publishes as `Dataset`.

## Intended usage

Keep user-managed spatial tables and MVT-returning functions in the `public` schema by default.

If you want a different schema, set `MARTIN_PUBLISH_SCHEMA`.

If you need to change publish rules, CORS, route prefixes, caching, or add other sources, edit `martin.yaml` and redeploy.
If you add new style files under `/etc/martin/styles`, restart Martin so they are picked up.

## Starter styles

Two example MapLibre styles are included:

- `basic-fill`
- `basic-line`

They are set up as transparent overlays so they can sit on top of terrain or other basemap tiles in Leaflet.

Before they will render correctly, update each style JSON to match your Martin source:

- replace the `tiles` URL with your actual Martin source ID path from `/catalog`
- replace `source-layer` with the actual vector tile layer name in that source

For example, if Martin publishes a source like `Dataset`, your style `tiles` value can point back at the same Martin instance:

```text
http://127.0.0.1:${PORT}/Dataset/{z}/{x}/{y}
```

In many setups, the vector `source-layer` matches the table name, so `Dataset` is a reasonable default. Verify that value against your actual tile metadata if rendering returns blank tiles.

Then Martin can render raster tiles from the style endpoint:

```text
/style/basic-fill/{z}/{x}/{y}.png
```
