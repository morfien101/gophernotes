FROM ubuntu:latest

ARG GOVERSION=1.19.4

# Add gophernotes
ADD . /go/src/github.com/gopherdata/gophernotes/

# Install Jupyter and gophernotes.
RUN set -x \
    # install python and dependencies
    && apt update \
    && apt-get install -y nala \
    && nala install -y \
    ca-certificates \
    curl \
    wget \
    vim \
    htop \
    g++ \
    gcc \
    git \
    libffi-dev \
    python3 python3-dev \
    python3-pip \
    python3-aiozmq \
    mercurial \
    mesa-common-dev \
    libzmq3-dev

# jupyter notebook
RUN pip3 install --upgrade pip==21.3.1 \
    && ln -s /usr/bin/python3.9 /usr/bin/python \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h \
    && pip3 install jupyter notebook pyzmq tornado ipykernel

# install Go
RUN curl -sSL https://go.dev/dl/go${GOVERSION}.linux-amd64.tar.gz -o go.tar.gz \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz \
    && ln -s /usr/local/go/bin/go /usr/local/bin/go \
    && echo PATH=PATH:/usr/local/go/bin/ >> /root/bashrc \
    rm -rf go.tar.gz

## install gophernotes
RUN cd /go/src/github.com/gopherdata/gophernotes \
    && GOPATH=/go GO111MODULE=on go install . \
    && cp /go/bin/gophernotes /usr/local/bin/ \
    && mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
    && cp -r ./kernel/* ~/.local/share/jupyter/kernels/gophernotes

# Set GOPATH.
ENV GOPATH /go

EXPOSE 8888
CMD [ "jupyter", "notebook", "--no-browser", "--allow-root", "--ip=0.0.0.0" ]
