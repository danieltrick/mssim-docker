# Debian Version
ARG DEBIAN_VERSION=bookworm-20241111-slim

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stage #1
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM debian:$DEBIAN_VERSION AS build

# MSSIM Version
ARG MSSIM_COMMIT=ee21db0a941decd3cac67925ea3310873af60ab3

# Provide the 'install_packages' helper script
COPY bin/install_packages.sh /usr/sbin/install_packages

# Install build dependencies
RUN install_packages \
    autoconf-archive \
    automake \
    build-essential \
    ca-certificates \
    curl \
    gcc \
    git \
    libssl-dev \
    pkg-config

# Build ms-tpm-20-ref
RUN mkdir -p /tmp/ms-tpm-20-ref/TPMCmd \
    && curl --tlsv1.2 -sSfL https://github.com/microsoft/ms-tpm-20-ref/archive/${MSSIM_COMMIT}.tar.gz | tar -C /tmp/ms-tpm-20-ref --strip-components=1 -xzv \
    && cd /tmp/ms-tpm-20-ref/TPMCmd \
    && ./bootstrap \
    && ./configure --prefix=/opt/mssim \
    && make \
    && make install \
    && cd - \
    && rm -vfr /tmp/ms-tpm-20-ref

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stage #2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM debian:$DEBIAN_VERSION

# Provide the 'install_packages' helper script
COPY bin/install_packages.sh /usr/sbin/install_packages

# Install runtime dependencies
RUN install_packages \
    libssl3

# Copy the built binaries
COPY --from=build /opt/mssim/bin/tpm2-simulator /usr/bin/

# Copy startup script
COPY bin/entrypoint.sh /opt/

# Start TPM simulator
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["2321"]
