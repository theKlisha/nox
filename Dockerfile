FROM rust:buster

WORKDIR /pwd

RUN rustup target add x86_64-unknown-none
# RUN rustup toolchain install nightly-x86_64-unknown-linux-gnu
# RUN rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu

RUN apt-get update

RUN apt-get install -y \
    binutils \
    grub-common \
    grub-pc-bin \
    mtools \
    xorriso \
    make
