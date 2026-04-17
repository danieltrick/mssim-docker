# Alpine Version
ARG ALPINE_VERS=3.23.4@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stage #1
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM alpine:$ALPINE_VERS AS build

# MSSIM Version
ARG MSSIM_COMMIT=ee21db0a941decd3cac67925ea3310873af60ab3

# Install build dependencies
RUN apk add --no-cache \
    autoconf \
    autoconf-archive \
    automake \
    bash \
    build-base \
    curl \
    libtool \
    linux-headers \
    pkgconf

# Build OpenSSL 3.0 (latest version that is currently supported by ms-tpm-20-ref)
RUN mkdir -p /tmp/openssl-build \
    && curl --tlsv1.2 -sSfL https://github.com/openssl/openssl/releases/download/openssl-3.0.20/openssl-3.0.20.tar.gz | tar -C /tmp/openssl-build --strip-components=1 -xzv \
    && cd /tmp/openssl-build \
    && ./config no-tests no-shared -static \
    && make \
    && make install_sw \
    && cd - \
    && rm -vfr /tmp/openssl-build

# Copy patch file
COPY patch/no-buffering.diff /tmp/no-buffering.diff

# Build ms-tpm-20-ref
RUN mkdir -p /tmp/ms-tpm-20-ref/TPMCmd \
    && curl --tlsv1.2 -sSfL https://github.com/microsoft/ms-tpm-20-ref/archive/${MSSIM_COMMIT}.tar.gz | tar -C /tmp/ms-tpm-20-ref --strip-components=1 -xzv \
    && cd /tmp/ms-tpm-20-ref/TPMCmd \
    && patch -p2 < /tmp/no-buffering.diff \
    && ./bootstrap \
    && PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig ./configure --prefix=/opt/mssim \
    && make \
    && make install \
    && cd - \
    && rm -vfr /tmp/ms-tpm-20-ref

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stage #2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM alpine:$ALPINE_VERS

# Copy the built binaries
COPY --from=build /opt/mssim/bin/tpm2-simulator /usr/bin/

# Copy startup script
COPY bin/entrypoint.sh /opt/

# Start TPM simulator
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["2321"]
