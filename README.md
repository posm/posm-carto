# POSM Simple

A simple CartoCSS style for POSM.

## Installation

```bash
npm install
make .env
```

## Importing Data

This currently uses a Delaware extract from Geofabrik, mainly for its size.

```bash
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

## Rendering

```bash
npm start
```
