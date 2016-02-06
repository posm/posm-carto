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

%.xml: %.mml db/shapefiles db/fonts
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

.PHONY: db/shapefiles

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

.PHONY: db/fonts

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
	curl -Lf http://unifoundry.com/pub/unifont-8.0.01/font-builds/unifont-8.0.01.ttf -o $@

fonts/DejaVuSans.zip:
	@mkdir -p $$(dirname $@)
	curl -Lf http://sourceforge.net/projects/dejavu/files/dejavu/2.35/dejavu-fonts-ttf-2.35.zip -o $@



# complete wrapping
else
.DEFAULT:
	$(error Please install pgexplode: "npm install pgexplode")
endif
