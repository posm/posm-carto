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

smaller: | data/water_polygons.zip data/ne/10m/physical/ne_10m_lakes.zip \
	data/ne/10m/physical/ne_10m_rivers_lake_centerlines_scale_rank.zip \
	data/ne/10m/cultural/ne_10m_admin_0_boundary_lines_land.zip \
	data/ne/10m/cultural/ne_10m_admin_1_states_provinces_lines.zip \
	data/ne/10m/cultural/ne_10m_admin_1_label_points.zip \
	data/ne/10m/cultural/ne_10m_admin_0_countries_lakes.zip data/ne/10m/cultural/ne_10m_roads.zip \
	data/ne/10m/cultural/ne_10m_admin_0_boundary_lines_map_units.zip fonts/DejaVuSans.zip \
	fonts/NotoSans.zip
	truncate -s 0 $|

.env:
	@echo DATABASE_URL=postgres:///simple > $@

link:
	test -e "${HOME}/Documents/MapBox/project" && \
	test -e "${HOME}/Documents/MapBox/project/$(PROJECT_NAME)" || \
	ln -sf "`pwd`" "${HOME}/Documents/MapBox/project/$(PROJECT_NAME)"

clean:
	@rm -f *.mml *.xml

distclean: clean
	rm -rf data/ shp/ fonts/

## Generic Targets

%: %.mml
	@true

.PRECIOUS: %.mml

%.mml: %.yml vars.mss bg.mss road.mss label.mss poi_classic.mss hdm.mss
	@echo Building $@
	@cat $< | interp | js-yaml > $@.tmp && mv $@.tmp $@

.PRECIOUS: %.xml

%.xml: %.mml db/naturalearth shp fonts
	@echo
	@echo Building $@
	@echo
	@carto -a 3.0.12 $< > $@ || (rm -f $@; false)


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
@psql -c "\dx $(notdir $@)" | grep $(notdir $@) > /dev/null 2>&1 || \
	psql -v ON_ERROR_STOP=1 -qX1c "CREATE EXTENSION $(notdir $@)"
endef

shp: shp/water_polygons.shp \
	shp/water_polygons.dbf \
	shp/water_polygons.prj \
	shp/water_polygons.index

.SECONDARY: data/water_polygons.zip

# so the zip matches the shapefile name
data/water_polygons.zip:
	@mkdir -p $(dir $@)
	curl -sfL http://data.openstreetmapdata.com/water-polygons-split-3857.zip -z $@ -o $@

shp/%.shp \
shp/%.dbf \
shp/%.prj: | data/%.zip
	@mkdir -p $(dir $@)
	unzip -qju $| -d $(dir $@)

shp/water_polygons.index: shp/water_polygons.shp
	node_modules/.bin/mapnik-shapeindex.js $<

db/naturalearth: db/ne_10m_rivers_lake_centerlines_scale_rank \
		   db/ne_10m_admin_0_countries_lakes \
		   db/ne_10m_admin_0_boundary_lines_map_units \
		   db/ne_10m_roads \
		   db/ne_10m_lakes \
		   db/ne_10m_admin_0_boundary_lines_land \
		   db/ne_10m_admin_1_label_points \
		   db/ne_10m_admin_1_states_provinces_lines

define natural_earth
db/$(strip $(word 1, $(subst :, ,$(1)))): | $(strip $(word 2, $(subst :, ,$(1)))) db/postgis
	@psql -c "\d $(strip $(word 1, $(subst :, ,$(1))))" > /dev/null 2>&1 || \
	ogr2ogr --config OGR_ENABLE_PARTIAL_REPROJECTION TRUE \
			--config SHAPE_ENCODING WINDOWS-1252 \
			--config PG_USE_COPY YES \
			-nln $$(basename $$(notdir $$(word 1, $$|))) \
			-t_srs EPSG:3857 \
			-lco DROP_TABLE=OFF \
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
			/vsizip/$$(word 1, $$|)/$(strip $(word 3, $(subst :, ,$(1)))) | psql -q
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
	curl -sfL http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/$(1)/$(2)/$$(@:data/ne/$(1)/$(2)/%=%) -o $$@

.SECONDARY: data/ne/$(1)/$(2)/%.zip

data/ne-stamen/$(1)/$(2)/%.zip:
	@mkdir -p $$(dir $$@)
	curl -sfL "https://github.com/stamen/natural-earth-vector/blob/master/zips/$(1)_$(2)/$$(@:data/ne-stamen/$(1)/$(2)/%=%)?raw=true" -o $$@
endef

scales=10m 50m 110m
themes=cultural physical raster

$(foreach a,$(scales),$(foreach b,$(themes),$(eval $(call natural_earth_sources,$(a),$(b)))))

fonts: fonts/NotoSans-Regular.ttf \
	fonts/NotoSans-Bold.ttf \
	fonts/NotoSans-BoldItalic.ttf \
	fonts/unifont-Medium.ttf \
	fonts/DejaVuSans.ttf \
	fonts/DejaVuSans-Bold.ttf \
	fonts/DejaVuSans-BoldOblique.ttf \
	fonts/DejaVuSans-Oblique.ttf

fonts/DejaVuSans.ttf fonts/DejaVuSans%.ttf: | fonts/DejaVuSans.zip
	unzip -qju $| *$(notdir $@) -d $(dir $@)

fonts/NotoSans%.ttf: | fonts/NotoSans.zip
	unzip -qju $| $(notdir $@) -d $(dir $@)

fonts/NotoSans.zip:
	@mkdir -p $(dir $@)
	curl -sLf https://noto-website.storage.googleapis.com/pkgs/Noto-unhinted.zip -o $@

fonts/unifont-Medium.ttf:
	@mkdir -p $(dir $@)
	curl -sfL http://posm.s3.amazonaws.com/resources/unifont-8.0.01.ttf -o $@

fonts/DejaVuSans.zip:
	@mkdir -p $(dir $@)
	curl -sfL http://sourceforge.net/projects/dejavu/files/dejavu/2.37/dejavu-fonts-ttf-2.37.zip -o $@



# complete wrapping
else
.DEFAULT:
	$(error Please install pgexplode: "npm install pgexplode")
endif
