SHELL := /bin/bash
PATH := $(PATH):node_modules/.bin
PROJECT_NAME := posm-carto

define EXPAND_EXPORTS
export $(word 1, $(subst =, , $(1))) := $(word 2, $(subst =, , $(1)))
endef

# wrap Makefile body with a check for pgexplode
ifeq ($(shell test -f node_modules/.bin/pgexplode; echo $$?), 0)

# load .env
$(foreach a,$(shell cat .env 2> /dev/null),$(eval $(call EXPAND_EXPORTS,$(a))))
# expand PG* environment vars
$(foreach a,$(shell set -a && source .env 2> /dev/null; node_modules/.bin/pgexplode),$(eval $(call EXPAND_EXPORTS,$(a))))

default: project

.env:
	@echo DATABASE_URL=postgres:///simple > $@

link:
	test -e "${HOME}/Documents/MapBox/project" && \
	test -e "${HOME}/Documents/MapBox/project/$(PROJECT_NAME)" || \
	ln -sf "`pwd`" "${HOME}/Documents/MapBox/project/$(PROJECT_NAME)"

clean:
	@rm -f *.mml *.xml

## Generic Targets

%: %.mml
	@true

.PRECIOUS: %.mml

%.mml: %.yml vars.mss bg.mss road.mss label.mss poi_classic.mss hdm.mss
	@echo Building $@
	@cat $< | interp | js-yaml > $@.tmp && mv $@.tmp $@

.PRECIOUS: %.xml

%.xml: %.mml db/shapefiles db/natearth db/fonts
	@echo
	@echo Building $@
	@echo
	@carto $< > $@ || (rm -f $@; false)


.PHONY: DATABASE_URL

DATABASE_URL:
	@test "${$@}" || (echo "$@ is undefined" && false)

.PHONY: db

db: DATABASE_URL
	@psql -c "SELECT 1" > /dev/null 2>&1 || \
	createdb

.PHONY: db/postgis

db/postgis: db
	$(call create_extension)

define create_extension
@psql -c "\dx $(subst db/,,$@)" | grep $(subst db/,,$@) > /dev/null 2>&1 || \
	psql -v ON_ERROR_STOP=1 -qX1c "CREATE EXTENSION $(subst db/,,$@)"
endef

db/shapefiles: shp/water_polygons.shp \
	shp/water_polygons.dbf \
	shp/water_polygons.prj \
	shp/water_polygons.shx \
	shp/water_polygons.index

.SECONDARY: data/water_polygons.zip

# so the zip matches the shapefile name
data/water_polygons.zip:
	@mkdir -p $$(dirname $@)
	curl -Lf http://data.openstreetmapdata.com/water-polygons-split-3857.zip -z $@ -o $@

shp/%.shp \
shp/%.dbf \
shp/%.prj \
shp/%.shx: data/%.zip
	@mkdir -p $$(dirname $@)
	unzip -ju $< -d $$(dirname $@)

shp/water_polygons.index: shp/water_polygons.shp
	node_modules/.bin/mapnik-shapeindex.js $<

db/natearth: db/ne_10m_rivers_lake_centerlines_scale_rank \
		   db/ne_10m_admin_0_countries_lakes \
		   db/ne_10m_admin_0_boundary_lines_map_units \
		   db/ne_10m_roads \
		   db/ne_10m_lakes \
		   db/ne_10m_admin_0_boundary_lines_land \
		   db/ne_10m_admin_1_label_points \
		   db/ne_10m_admin_1_states_provinces_lines

define natural_earth
db/$(strip $(word 1, $(subst :, ,$(1)))): $(strip $(word 2, $(subst :, ,$(1)))) db/postgis
	@psql -c "\d $(strip $(word 1, $(subst :, ,$(1))))" > /dev/null 2>&1 || \
	ogr2ogr --config OGR_ENABLE_PARTIAL_REPROJECTION TRUE \
			--config SHAPE_ENCODING WINDOWS-1252 \
			--config PG_USE_COPY YES \
			-nln $$(subst db/,,$$@) \
			-t_srs EPSG:3857 \
			-lco ENCODING=UTF-8 \
			-nlt PROMOTE_TO_MULTI \
			-lco POSTGIS_VERSION=2.0 \
			-lco GEOMETRY_NAME=geom \
			-lco SRID=3857 \
			-lco PRECISION=NO \
			-clipsrc -180 -85.05112878 180 85.05112878 \
			-segmentize 1 \
			-skipfailures \
			-f PGDump /vsistdout/ \
			/vsizip/$$</$(strip $(word 3, $(subst :, ,$(1)))) | psql -q
endef

# <name>:<source file>:[shapefile]
NATURAL_EARTH=ne_10m_rivers_lake_centerlines_scale_rank:data/ne/10m/physical/ne_10m_rivers_lake_centerlines_scale_rank.zip \
	ne_10m_admin_0_countries_lakes:data/ne/10m/cultural/ne_10m_admin_0_countries_lakes.zip \
	ne_10m_admin_0_boundary_lines_map_units:data/ne/10m/cultural/ne_10m_admin_0_boundary_lines_map_units.zip \
	ne_10m_roads:data/ne/10m/cultural/ne_10m_roads.zip \
	ne_10m_lakes:data/ne/10m/physical/ne_10m_lakes.zip \
	ne_10m_admin_0_boundary_lines_land:data/ne/10m/cultural/ne_10m_admin_0_boundary_lines_land.zip \
	ne_10m_admin_1_label_points:data/ne/10m/cultural/ne_10m_admin_1_label_points.zip \
	ne_10m_admin_1_states_provinces_lines:data/ne/10m/cultural/ne_10m_admin_1_states_provinces_lines.zip:ne_10m_admin_1_states_provinces_lines.shp

$(foreach shape,$(NATURAL_EARTH),$(eval $(call natural_earth,$(shape))))

define natural_earth_sources
.SECONDARY: data/ne/$(1)/$(2)/%.zip

data/ne/$(1)/$(2)/%.zip:
	@mkdir -p $$(dir $$@)
	curl -fL http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/$(1)/$(2)/$$(@:data/ne/$(1)/$(2)/%=%) -o $$@

.SECONDARY: data/ne/$(1)/$(2)/%.zip

data/ne-stamen/$(1)/$(2)/%.zip:
	@mkdir -p $$(dir $$@)
	curl -fL "https://github.com/stamen/natural-earth-vector/blob/master/zips/$(1)_$(2)/$$(@:data/ne-stamen/$(1)/$(2)/%=%)?raw=true" -o $$@
endef

scales=10m 50m 110m
themes=cultural physical raster

$(foreach a,$(scales),$(foreach b,$(themes),$(eval $(call natural_earth_sources,$(a),$(b)))))

db/fonts: fonts/NotoSans-Regular.ttf \
	fonts/unifont-Medium.ttf \
	fonts/DejaVuSans.ttf

fonts/%.ttf: fonts/%.zip
	unzip -ju $< -d $$(dirname $@)

fonts/NotoSans-Regular.zip:
	@mkdir -p $$(dirname $@)
	curl -Lf https://noto-website.storage.googleapis.com/pkgs/Noto-unhinted.zip -o $@

#fonts/OpenSans-Regular.zip:
	#@mkdir -p $$(dirname $@)
	#curl -Lf http://sourceforge.net/projects/dejavu/files/dejavu/2.35/dejavu-fonts-ttf-2.35.zip -o $@

#fonts/unifont-Medium.zip:
fonts/unifont-Medium.ttf:
	@mkdir -p $$(dirname $@)
	curl -Lf http://posm.s3.amazonaws.com/resources/unifont-8.0.01.ttf -o $@
	# curl -Lf http://unifoundry.com/pub/unifont-8.0.01/font-builds/unifont-8.0.01.ttf -o $@

fonts/DejaVuSans.zip:
	@mkdir -p $$(dirname $@)
	curl -Lf http://sourceforge.net/projects/dejavu/files/dejavu/2.35/dejavu-fonts-ttf-2.35.zip -o $@



# complete wrapping
else
.DEFAULT:
	$(error Please install pgexplode: "npm install pgexplode")
endif
