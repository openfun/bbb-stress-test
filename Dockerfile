# -- Base image --
FROM python:3.8-buster as base

# Upgrade pip to its latest release to speed up dependencies installation
RUN pip install --upgrade pip


# ---- Back-end builder image ----
FROM base as builder

WORKDIR /builder

# Copy required python dependencies
COPY setup.py setup.cfg MANIFEST.in /builder/
COPY ./src/bbb_stress_test /builder/src/bbb_stress_test/

RUN mkdir /install && \
    pip install --prefix=/install .

RUN ls -lR /install

# ---- Core application image ----
FROM base as core

# Install xvfb, espeak, fortunes
RUN apt-get update && \
    apt-get install -y \
    xvfb espeak fortunes && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome and Chromedriver
RUN apt-get update && \
    apt-get install -y gnupg wget curl unzip --no-install-recommends && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/chrome.list && \
    apt-get update -y && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/* && \
    CHROME_VERSION=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") && \
    DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION}") && \
    wget -q --continue "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip chromedriver* && \
    mv chromedriver /usr/local/bin/chromedriver && \
    rm chromedriver*.zip


# Copy installed python dependencies
COPY --from=builder /install /usr/local

# Copy runtime-required files
COPY ./docker/files/usr/local/share/names /usr/local/share/names
COPY ./docker/files/usr/local/bin/entrypoint /usr/local/bin/entrypoint
COPY ./docker/files/usr/local/bin/start-bbb-client /usr/local/bin/start-bbb-client

# Give the "root" group the same permissions as the "root" user on /etc/passwd
# to allow a user belonging to the root group to add new users; typically the
# docker user (see entrypoint).
RUN chmod g=u /etc/passwd

# Un-privileged user running the application
ARG DOCKER_USER
USER ${DOCKER_USER}

# We wrap commands run in this container by the following entrypoint that
# creates a user on-the-fly with the container user ID (see USER) and root group
# ID.
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
CMD ["/usr/local/bin/start-bbb-client" ]

# ---- Development image ----
FROM core as development

ENV PYTHONUNBUFFERED=1

# Switch back to the root user to install development dependencies
USER root:root

WORKDIR /app

# Copy all sources, not only runtime-required files
COPY . /app/

# Uninstall bbb-stress-test and re-install it in editable mode along with development
# dependencies
RUN pip uninstall -y bbb-stress-test
RUN pip install -e .[dev]

# Restore the un-privileged user running the application
ARG DOCKER_USER
USER ${DOCKER_USER}


# ---- Production image ----
FROM core as production

ENV PYTHONUNBUFFERED=1

WORKDIR /app
