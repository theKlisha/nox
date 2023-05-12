FROM rust:buster

WORKDIR /pwd

RUN rustup target add x86_64-unknown-none

RUN apt-get update

RUN apt-get install -y \
    binutils \
    grub-common \
    grub-pc-bin \
    mtools \
    xorriso \
    make
