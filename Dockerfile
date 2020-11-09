FROM amazonlinux:2 as builder

RUN yum update -y && \
    yum install git gcc sqlite-devel make gcc-c++ gmp-devel libtool autoconf m4 openssl-devel -y && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR $HOME/libsodium
RUN git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install 

RUN mkdir $HOME/.cargo && mkdir $HOME/.cargo/bin && \
    touch $HOME/.profile && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs --output $HOME/rustup-init.sh && \
    source $HOME/rustup-init.sh -y && \
    source $HOME/.cargo/env && \
    rustup install stable && \
    rustup default stable && \
    rustup update  

ENV CNCLI_VERSION="v0.2.0"
WORKDIR $HOME/
RUN git clone https://github.com/AndrewWestberg/cncli 
WORKDIR $HOME/cncli

RUN git checkout tags/$CNCLI_VERSION && \
    $HOME/.cargo/bin/cargo install --path . --force

FROM amazonlinux:2

RUN yum update -y && \
    yum install shadow-utils -y && \
    mkdir -p /srv/cardano/ && \
    useradd -c "Cardano cli user" \
            -d /srv/cardano/cardano-cli/ \
            -m \
            -r \
            -s /bin/nologin \
            cardano-cli 

RUN yum remove shadow-utils -y && \
    yum install sqlite-devel -y && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY --from=builder /usr/local/lib/libsodium.so.23.3.0 /usr/local/lib/libsodium.so.23.3.0
COPY --from=builder /usr/local/lib/libsodium.la /usr/local/lib/libsodium.la
COPY --from=builder /usr/local/lib/libsodium.a /usr/local/lib/libsodium.a
RUN ln -s /usr/local/lib/libsodium.so.23.3.0 /usr/local/lib/libsodium.so.23 && \
    ln -s /usr/local/lib/libsodium.so.23.3.0 /usr/local/lib/libsodium.so
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

COPY --from=builder /root/.cargo/bin/cncli /usr/local/bin/cncli
COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /srv/cardano/cardano-cli/storage
USER cardano-cli
WORKDIR /srv/cardano/cardano-cli

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]