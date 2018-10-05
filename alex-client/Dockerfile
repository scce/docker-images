FROM alpine/git as cloner
RUN git clone https://github.com/LearnLib/alex-cli.git --branch master --single-branch /alex-cli

FROM node:10.0.0
COPY --from=cloner /alex-cli /alex-cli
WORKDIR /alex-cli
RUN npm install -g
ENTRYPOINT ["/usr/local/bin/alex-cli"]
CMD ["--help"]
