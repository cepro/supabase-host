FROM graphile/postgraphile:4

# Copy our custom start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the entrypoint to use shell to execute our script
ENTRYPOINT ["/bin/sh", "/start.sh"]