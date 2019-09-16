FROM ubuntu:16.04 AS builder
RUN apt-get update -y && apt-get install -y bzip2
ENV RESTIC_VERSION 0.9.5
ADD https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2 /tmp/restic_linux_amd64.bz2
RUN bzip2 -dk /tmp/restic_linux_amd64.bz2
RUN chmod 755 /tmp/restic_linux_amd64

FROM ubuntu:16.04
COPY --from=builder /tmp/restic_linux_amd64 /usr/local/bin/restic
RUN apt-get update -y && apt-get install -y \
                                        postgresql-client \
                                        openssh-client
COPY ./backup.sh /usr/local/bin/backup
RUN chmod 755 /usr/local/bin/backup
ENTRYPOINT ["/usr/local/bin/backup"]
CMD ["--help"]