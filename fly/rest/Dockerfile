# Build PostgREST with IPv6 proxy support
FROM ubuntu:noble-20240801@sha256:35c4a2c15539c6c1e4e5fa4e554dac323ad0107d8eb5c582d6ff386b383b7dce

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    libpq-dev \
    zlib1g-dev \
    jq \
    gcc \
    libnuma-dev \
    socat \
    curl \
    xz-utils && \
    rm -rf /var/lib/apt/lists/*

# Download PostgREST binary (same version as Supabase)
RUN curl -L https://github.com/PostgREST/postgrest/releases/download/v12.2.3/postgrest-v12.2.3-linux-static-x64.tar.xz \
    -o postgrest.tar.xz && \
    tar -xf postgrest.tar.xz && \
    mv postgrest /usr/bin/postgrest && \
    chmod +x /usr/bin/postgrest && \
    rm postgrest.tar.xz

# Create user 1000 (same as original)
RUN useradd -u 1000 -m -s /bin/bash postgrest

# Copy startup script
COPY --chmod=755 start-with-proxy.sh /usr/local/bin/start-with-proxy.sh

USER 1000
EXPOSE 3000

CMD ["/usr/local/bin/start-with-proxy.sh"]