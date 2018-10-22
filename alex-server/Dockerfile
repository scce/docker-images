FROM openjdk:8

WORKDIR /usr/src/alex

# Dependencies
RUN apt update && apt install -y --no-install-recommends \
        xvfb \
        unzip \
        libgconf-2-4 \
        libxss1 libappindicator1 libindicator7 fonts-liberation libappindicator3-1 lsb-release xdg-utils\
    && rm -rf /var/lib/apt/lists/*e

# Firefox
RUN apt-get remove firefox \
        && cd /usr/local \
        && wget http://ftp.mozilla.org/pub/firefox/releases/63.0b7/linux-x86_64/en-US/firefox-63.0b7.tar.bz2 \
        && tar xvjf firefox-63.0b7.tar.bz2 \
        && ln -s /usr/local/firefox/firefox /usr/bin/firefox

# Firefox driver executable
RUN wget "https://github.com/mozilla/geckodriver/releases/download/v0.22.0/geckodriver-v0.22.0-linux64.tar.gz" \
    && tar -xf geckodriver-v0.22.0-linux64.tar.gz \
    && rm geckodriver-v0.22.0-linux64.tar.gz \
    && chmod +x geckodriver

# ALEX
RUN wget -O alex.war "https://github.com/LearnLib/alex/releases/download/v1.6.0/alex-1.6.0.war"

# Export the server port for the virtual display
ENV DISPLAY :99

# per default, ALEX runs on port 8000
EXPOSE 8000

# run a virtual display with full hd resolution and start ALEX
ENTRYPOINT Xvfb :99 -screen 0 1920x1080x16 & java -jar alex.war "--geckoDriver=/usr/src/alex/geckodriver"