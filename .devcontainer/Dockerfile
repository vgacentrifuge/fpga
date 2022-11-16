FROM mcr.microsoft.com/devcontainers/base:jammy

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    autoconf \
    gcc \
    make \
    pkg-config \
    autoconf \
    automake \
    python3-docutils \
    libseccomp-dev \
    libjansson-dev \
    libyaml-dev \
    libxml2-dev \
    wget

RUN git clone https://github.com/universal-ctags/ctags.git && \
    cd ctags && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

RUN wget https://github.com/chipsalliance/verible/releases/download/v0.0-2479-g92928558/verible-v0.0-2479-g92928558-Ubuntu-22.04-jammy-x86_64.tar.gz && \
    tar -xf verible-v0.0-2479-g92928558-Ubuntu-22.04-jammy-x86_64.tar.gz && \
    cp -R verible-v0.0-2479-g92928558/bin/* /usr/bin/ && \
    rm -R verible-v0.0-2479-g92928558 && \
    rm verible-v0.0-2479-g92928558-Ubuntu-22.04-jammy-x86_64.tar.gz

# RUN wget https://github.com/bazelbuild/bazel/releases/download/5.3.2/bazel_5.3.2-linux-x86_64.deb && \
#     dpkg -i bazel_5.3.2-linux-x86_64.deb && \
#     rm https://github.com/bazelbuild/bazel/releases/download/5.3.2/bazel_5.3.2-linux-x86_64.deb

# RUN git clone -b v0.0-2479-g92928558 --single-branch https://github.com/chipsalliance/verible && \
#     cd verible && \
#     bazel run -c opt :install -- -s /usr/local/bin