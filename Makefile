####################
## Setup (public) ##
####################

## pandoc-slides official image
## Verify its signature before run `make container` ;)
OCI = ghcr.io/andros21/pandoc-slides:master

## Container engine to use
## Choose between docker or podman (rootless)
## (Defaults to docker)
CE := $(shell basename `which docker 2>/dev/null ||\
                        which podman 2>/dev/null || echo docker`)

## Working directory
## In case this doesn't work, set the path manually (use absolute paths).
WORKDIR = $(CURDIR)

## Pandoc
## (Defaults to docker/podman. To use pandoc directly, create an
## environment variable `PANDOC` pointing to the location of your
## pandoc installation.)
PANDOC ?= $(CE) exec pandoc-slides pandoc

## Source files
## (Adjust to your needs. Order of markdown files in $(SRC) matters!)
META    = metadata.yaml

SRC     = md/slides.md

CSS     = css/custom.css

TARGET  = index.html

####################
## Internal setup ##
####################

## Pandoc options
OPTIONS  = -f markdown
OPTIONS += --standalone
OPTIONS += -t revealjs

OPTIONS += --metadata-file=$(META)
OPTIONS += --filter pandoc-imagine
OPTIONS += --katex

OPTIONS += -V theme=white
OPTIONS += -V progress=true
OPTIONS += -V slideNumber=true
OPTIONS += -V history=true

OPTIONS += --css=$(CSS)

##################
## Main targets ##
##################

## Default
make: containerstart ${TARGET}

## Preview slides
http: slides.pid

## Create "pandoc-slides" container with pandoc
container:
ifeq ($(CE), podman)
	$(CE) create \
		--env HOME="/pandoc_slides" \
		--interactive \
		--name pandoc-slides \
		--network none \
		--user $(shell id -u):$(shell id -g) \
		--userns keep-id \
		--volume $(WORKDIR):/pandoc_slides:Z $(OCI)
endif
ifeq ($(CE), docker)
	$(CE) create \
		--env HOME="/pandoc_slides" \
		--interactive \
		--name pandoc-slides \
		--network none \
		--user $(shell stat . -c %u):$(shell stat . -c %g) \
		--volume $(WORKDIR):/pandoc_slides:Z $(OCI)
endif

#######################
## Auxiliary targets ##
#######################

## Build slides
${TARGET}: $(SRC) $(META) $(CSS)
	$(PANDOC) ${OPTIONS} -o $@ $(SRC)

slides.pid:
	@printf "Starting http.server ... "
	@xdg-open "http://localhost:8080/" &
	@{ python3 -m http.server -b 127.0.0.1 8080 >/dev/null 2>&1 \
		& echo $$! >$@; }
	@printf "done\n"
	@printf "Slides url: http://localhost:8080/\n"

stop: slides.pid
	@printf "Stopping http.server ... "
	@pkill -F slides.pid 2>/dev/null || exit 0
	@rm $^
	@printf "done\n"

## Start container or advice to setup it
containerstart:
	@$(CE) start pandoc-slides 2> /dev/null \
		|| (printf 'Error: no container `pandoc-slides` found, run `make container` before\n' && exit 1)

## Upgrade "pandoc-slides" image and setup new container
containerupgrade: containerclean imageclean container

## Clean-up: Remove temporary (generated) files
clean:
	rm -rf \?/ .cache/ .java/

## Clean-up: Remove also generated slides and images
distclean: clean
	rm -f $(TARGET)
	rm -fr pd-images/

## Clean-up: Stop and remove "pandoc-slides" container
containerclean:
	$(CE) stop pandoc-slides || exit 0
	$(CE) rm pandoc-slides || exit 0

## Clean-up: Remove "pandoc-slides" image
imageclean:
	$(CE) rmi $(OCI) || exit 0

##################################
## Declaration of phony targets ##
##################################

.PHONY: all container containerstart containerupgrade distclean containerclean imageclean
