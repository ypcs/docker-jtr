FROM ypcs/debian:buster

ENV JOHN_VERSION 1.8.0-jumbo-1
ENV JOHN_SHA256 XX

VOLUME /data
ENV WORDLIST_DIR /wordlists

RUN mkdir -p "${WORDLIST_DIR}"

RUN \
    /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get --assume-yes install \
        build-essential \
        libssl1.1 \
        libssl-dev \
        libkrb5-3 \
        libgmp10 \
        libgmp-dev \
        zlib1g-dev \
        libnss3-dev \
        libkrb5-dev \
        libgomp1 \
        pkg-config \
        git \
        nano \
        cewl \
        crunch \
        cupp3 \
        curl && \
    cd /usr/src && \
    git clone https://github.com/magnumripper/JohnTheRipper john && \
    cd john/src && \
    git describe && \
    ./configure && \
    make && \
    cd .. &&  \
    rm -rf .git && \
    cp -R run /usr/local/john && \
    cd ../.. && \
    rm -rf john-* && \
    apt-get --assume-yes remove \
        build-essential \
        libssl-dev \
        libgmp-dev \
        zlib1g-dev \
        libkrb5-dev \
        gcc \
        gcc-4.9 \
        dpkg-dev \
        libnss3-dev && \
    echo '#!/bin/sh\nset -e\n/usr/local/john/john $@' > /usr/bin/john && \
    chmod +x /usr/bin/john && \
    /usr/lib/docker-helpers/apt-cleanup

RUN \
    mkdir -p "${WORDLIST_DIR}" && \
    cd /usr/src && \
    curl -fSL "http://kaino.kotus.fi/sanat/nykysuomi/kotus-sanalista-v1.tar.gz" -o "kotus-sanalista-v1.tar.gz" && \
    tar xzf kotus-sanalista-v1.tar.gz && \
    sed -ne 's,.*<s>\(.*\)</s>.*,\1,p' kotus-sanalista_v1/kotus-sanalista_v1.xml > "${WORDLIST_DIR}/finnish.txt" && \
    rm -rf kotus-sanalista*

RUN \
    mkdir -p "${WORDLIST_DIR}/passwords" && \
    cd /usr/src && \
    curl -fSL "https://github.com/danielmiessler/SecLists/archive/master.tar.gz" -o "seclists.tar.gz" && \
    tar xzf "seclists.tar.gz" && \
    cp -R SecLists-master/Passwords/* "${WORDLIST_DIR}/passwords/" && \
    rm -rf SecLists-master seclists.tar.gz

RUN \
    mkdir -p "${WORDLIST_DIR}/rules"

COPY rules.d/* "${WORDLIST_DIR}/rules/"

WORKDIR /usr/local/john
