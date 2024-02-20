ARG SHLINK_VERSION="3.7.3"

FROM shlinkio/shlink:${SHLINK_VERSION}

WORKDIR /etc/shlink

# Create data directories if they do not exist. This allows data dir to be mounted as an empty dir if needed
RUN mkdir -p data/cache \
             data/locks \
             data/log \
             data/proxies

COPY ./entrypoint.sh /etc/shlink/entrypoint.sh
COPY ./run-server.sh /etc/shlink/run-server.sh

EXPOSE 80/tcp

ENTRYPOINT ["/etc/shlink/entrypoint.sh"]

CMD ["sh /etc/shlink/run-server.sh"]
