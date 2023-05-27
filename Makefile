####################
## Setup (public) ##
####################

## pandoc-slides official image
## Verify its signature before run `make container` ;)
OCI ?= ghcr.io/andros21/pandoc-slides:latest

## Container name (from working dir)
CN := $(shell basename $$PWD)

## User id and group id using id command
## In case this doesn't work, set your UID and GID
UID ?= $(shell id -u)
GID ?= $(shell id -g)

## Container engine to use
## Choose between docker or podman (rootless)
## (Defaults to docker)
CE ?= $(shell basename `which docker 2>/dev/null ||\
                        which podman 2>/dev/null || echo docker`)
# User container as current user
docker_flags = --user $(UID):$(GID)
# Map current user as container user
podman_flags = --userns keep-id:uid=65532,gid=65532
ifeq ($(CE), podman)
	optional_flags=$(podman_flags)
else
	optional_flags=$(docker_flags)
endif

## Working directory
## In case this doesn't work, set the path manually (use absolute paths).
WORKDIR = $(CURDIR)

## Check OS (supported Linux, Darwin aka Mac)
## Disable selinux volume mount remap on Mac
UNAME := $(shell uname -s)
default_remap =
selinux_remap = :Z
ifeq ($(UNAME), Linux)
	remap=$(selinux_remap)
else
	remap=$(default_remap)
endif

## Pandoc
## (Defaults to docker/podman. To use pandoc directly, create an
## environment variable `PANDOC` pointing to the location of your
## pandoc installation.)
PANDOC ?= $(CE) exec $(CN) pandoc

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

example: containerstart example.html

## Create "pandoc-slides" container with pandoc
container:
	$(CE) run \
		--detach \
		--env HOME="/pandoc_slides" \
		--interactive \
		--name $(CN) \
		$(optional_flags) \
		--volume "$(WORKDIR)":/pandoc_slides$(remap) $(OCI)
	$(CE) exec -u 0 -w /tmp $(CN) sh -c 'curl -sSf $$JAVA_TRIGGER_URL | sh'
	$(CE) exec -u 0 -w /tmp $(CN) dot -c
	$(CE) exec -u 0 -w /tmp $(CN) python3 -m venv --system-site-packages /opt/imagine
	$(CE) exec -u 0 -w /tmp $(CN) sh -c '/opt/imagine/bin/pip install \
		--no-cache-dir --disable-pip-version-check \
		git+$$PANDOC_FILTERS_REPO@$$PANDOC_FILTERS_VERSION'
	$(CE) exec -u 0 -w /tmp $(CN) sh -c '/opt/imagine/bin/pip install \
		--no-cache-dir --disable-pip-version-check \
		git+$$PANDOC_IMAGINE_REPO@$$PANDOC_IMAGINE_VERSION'


#######################
## Auxiliary targets ##
#######################

## Build slides
${TARGET}: $(SRC) $(META) $(CSS)
	$(PANDOC) ${OPTIONS} -o $@ $(SRC)

## Build example
SRC_EXAMPLE=example/slides.md
META_EXAMPLE=example/metadata.yaml
example.html: $(SRC_EXAMPLE) $(META_EXAMPLE) $(CSS)
	$(PANDOC) ${OPTIONS} --metadata-file $(META_EXAMPLE) -o $@ $(SRC_EXAMPLE)

slides.pid:
	@printf "Starting http.server ... "
	@xdg-open "http://localhost:8080/" &
	@{ python3 -m http.server -b 127.0.0.1 8080 >/dev/null 2>&1 \
		& echo $$! >$@; }
	@printf "done\n"
	@printf "Slides url: http://localhost:8080/\n"

stop: *.pid
	@printf "Stopping http.server ... "
	@pkill -F slides.pid 2>/dev/null || exit 0
	@rm -f $^
	@printf "done\n"

## Start container or advice to setup it
containerstart:
	@$(CE) start $(CN) \
		|| (printf 'Error: no container `%s` found, run `make container` before\n' $(CN) && exit 1)

## Upgrade "pandoc-slides" image and setup new container
containerupgrade: containerclean imageclean container

## Clean-up: Remove temporary (generated) files
clean:
	rm -rf \?/ .cache/ .config/ .java/

## Clean-up: Remove also generated slides and images
distclean: clean
	rm -f $(TARGET)
	rm -fr pd-images/

## Clean-up: Stop and remove "pandoc-slides" container
containerclean:
	$(CE) stop $(CN) || exit 0
	$(CE) rm $(CN) || exit 0

## Clean-up: Remove "pandoc-slides" image
imageclean:
	$(CE) rmi $(OCI) || exit 0

##################################
## Declaration of phony targets ##
##################################

.PHONY: all container containerstart containerupgrade distclean containerclean imageclean
