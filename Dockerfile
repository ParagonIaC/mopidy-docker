# -------------------------------------------------------------------
# Base image
# -------------------------------------------------------------------
ARG DEBIAN_CODENAME=bookworm
FROM debian:${DEBIAN_CODENAME}-slim

# Make the ARG available inside the build stage
ARG DEBIAN_CODENAME

ENV DEBIAN_FRONTEND=noninteractive \
    TZ="Europe/Berlin" \
    PIP_DISABLE_PIP_VERSION_CHECK=on

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# -------------------------------------------------------------------
# System packages + Mopidy repository + build dependencies
# -------------------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gpg wget curl ca-certificates \
        python3-pip python3-dev build-essential \
    \
    # Mopidy repository
    && install -d /etc/apt/keyrings \
    && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy.gpg \
    && wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/${DEBIAN_CODENAME}.list \
    && apt-get update \
    \
    # Install Mopidy core packages
    && apt-get install -y --no-install-recommends \
        mopidy \
        mopidy-mpd \
        mopidy-local \
    \
    # Upgrade pip and install Python packages
    && python3 -m pip install --upgrade pip --break-system-packages \
    && python3 -m pip install --no-cache-dir \
        Mopidy-Iris==3.70.0 \
        Mopidy-YouTube==3.7 \
        yt-dlp==2025.11.12 \
        pyopenssl==25.3.0 \
        --break-system-packages \
    \
    # Clean up build dependencies and cache
    && apt-get purge -y \
        build-essential gcc python3-dev python3-distutils python3-setuptools \
        wget gpg \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /root/.cache/pip

# -------------------------------------------------------------------
# Runtime setup
# -------------------------------------------------------------------
RUN mkdir -p /config \
    && chown -R mopidy:audio /config

USER mopidy

VOLUME ["/config"]

EXPOSE 6600 6680 5555/udp

HEALTHCHECK --interval=5s --timeout=3s --retries=20 \
    CMD curl --fail --silent http://localhost:6680/ || exit 1

ENTRYPOINT ["/usr/bin/mopidy"]
CMD ["--config", "/config/mopidy.conf"]
