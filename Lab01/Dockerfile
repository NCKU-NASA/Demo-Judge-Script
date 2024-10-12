FROM debian:latest

RUN apt update && apt install iproute2 iputils-ping openssh-client -y

RUN mkdir /lab && mkdir /workdir

WORKDIR /workdir
