# POSM Simple

A simple CartoCSS style for POSM.

## Installation

```bash
npm install
make .env
```

On macOS (with [Homebrew](http://brew.sh)):

```bash
brew bundle
```

## Importing Data

This currently uses a Delaware extract from Geofabrik, mainly for its size.

```bash
createdb simple
psql -d simple -c "create extension postgis"
psql -d simple -c "create extension hstore"

osm2pgsql \
  --unlogged \
  --number-processes 4 \
  -v \
  -c \
  -d simple \
  -H localhost \
  --hstore-all \
  --hstore-add-index \
  -x \
  delaware-20151208.osm.pbf
```

Once data has been imported, necessary disk space can be reduced by running:

```bash
make smaller
```

This will truncate source archives, preventing them from being re-downloaded when checking for the
existence of database tables.

## Rendering

```bash
npm start
```
