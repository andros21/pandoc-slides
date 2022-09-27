
###############################################################################
## Setup (public)
###############################################################################

## pandoc-slides official image
## Verify its signature before run `make container` ;)
OCI = ghcr.io/andros21/pandoc-slides:master


## Container engine to use
## Choose between docker or podman (rootless)
CE = $$(type -p docker 2>/dev/null || type -p podman 2>/dev/null)


## Working directory
## In case this doesn't work, set the path manually (use absolute paths).
WORKDIR                 = $(CURDIR)


## Pandoc
## (Defaults to docker/podman. To use pandoc directly, create an
## environment variable `PANDOC` pointing to the location of your
## pandoc installation.)
PANDOC                 ?= $(CE) exec pandoc-slides pandoc


## Source files
## (Adjust to your needs. Order of markdown files in $(SRC) matters!)
META                    = metadata.yaml

SRC                     = md/slides.md

TARGET                  = index.html

CSS                     = css/custom.css



###############################################################################
## Internal setup (do not change)
###############################################################################


## Pandoc options
OPTIONS                 = -f markdown
OPTIONS                += --standalone
OPTIONS                += -t revealjs

OPTIONS                += --metadata-file=$(META)
OPTIONS                += --filter pandoc-imagine
OPTIONS                += --katex

OPTIONS                += -V theme=white
OPTIONS                += -V progress=true
OPTIONS                += -V slideNumber=true
OPTIONS                += -V history=true

OPTIONS                += --css=$(CSS)



## Container script/repo setup variables
JAVA_TRIGGER_URL        = https://git.alpinelinux.org/aports/plain/community/java-common/java-common.trigger
JAVA_TRIGGER            = /tmp/java.trigger.sh

PANDOC_FILTERS_REPO     = https://github.com/jgm/pandocfilters.git
PANDOC_FILTERS_VERSION  = 1beda668a764c8aa8e1c4e0cebce4323d4181f92

PANDOC_IMAGINE_REPO     = https://github.com/andros21/imagine
PANDOC_IMAGINE_VERSION  = 1524710a663294c3ee82aebb8a4ab9bef1e4d4f4



###############################################################################
## Main targets (do not change)
###############################################################################


## Default
make: containerstart ${TARGET}


## Build slides
${TARGET}: $(SRC) $(META) $(CSS)
	$(PANDOC) ${OPTIONS} -o $@ $(SRC)


## Pull, run and setup "pandoc-slides" image containing pandoc
container:
	$(CE) run -it --detach --name pandoc-slides -v $(WORKDIR):/pandoc_slides:Z $(OCI)
	$(CE) exec -w / pandoc-slides curl -sSf $(JAVA_TRIGGER_URL) --output $(JAVA_TRIGGER)
	$(CE) exec -w / pandoc-slides dot -c
	$(CE) exec -w / pandoc-slides sh /tmp/java.trigger.sh
	$(CE) exec -w / pandoc-slides python3 -m pip install --root-user-action=ignore \
		git+$(PANDOC_FILTERS_REPO)@$(PANDOC_FILTERS_VERSION)
	$(CE) exec -w / pandoc-slides python3 -m pip install --root-user-action=ignore \
		git+$(PANDOC_IMAGINE_REPO)@$(PANDOC_IMAGINE_VERSION)
	$(CE) exec -w / pandoc-slides rm -fr .cache


## Preview slides
http: slides.pid

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


## Clean-up: Remove also generated slides and temp files
distclean:
	rm -f $(TARGET)
	rm -fr pd-images/ \?/


## Clean-up: Stop and remove "pandoc-slides" container
containerclean:
	$(CE) stop pandoc-slides
	$(CE) rm pandoc-slides


## Clean-up: Remove "pandoc-slides" image
imageclean:
	$(CE) rmi $(OCI)



###############################################################################
## Declaration of phony targets
###############################################################################


.PHONY: all container containerstart containerupgrade distclean containerclean imageclean
