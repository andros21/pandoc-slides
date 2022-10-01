# pandoc-slides.Dockerfile
# ========================
# setup from pandoc-slides apko base image
# ----------------------------------------

FROM ghcr.io/andros21/pandoc-slides:master-apko
RUN curl -sSf ${JAVA_TRIGGER_URL} | sh
RUN dot -c
RUN python3 -m venv --system-site-packages /opt/imagine
RUN /opt/imagine/bin/pip install git+${PANDOC_FILTERS_REPO}@${PANDOC_FILTERS_VERSION}
RUN /opt/imagine/bin/pip install git+${PANDOC_IMAGINE_REPO}@${PANDOC_IMAGINE_VERSION}
ENV PATH="/opt/imagine/bin/:${PATH}"
USER nonroot
ENTRYPOINT ["pandoc"]
