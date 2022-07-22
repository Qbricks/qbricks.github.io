FROM debian:buster-20220418-slim

USER root

RUN adduser --disabled-password --gecos '' opam
RUN usermod -aG sudo opam

RUN apt-get update
RUN apt-get -y install sudo
RUN sudo apt-get -y install opam=2.0.3-1+deb10u1 \
  libgmp-dev=2:6.1.2+dfsg-4+deb10u1 \
  pkg-config=0.29-6 adwaita-icon-theme=3.30.1-1 \
  libcairo2-dev=1.16.0-4+deb10u1 libexpat1-dev=2.2.6-2+deb10u4 \
  libgtk-3-dev=3.24.5-1 libgtksourceview-3.0-dev=3.24.9-2 \
  libexpat1-dev=2.2.6-2+deb10u4 \
  libgtk2.0-dev=2.24.32-3 libgtksourceview2.0-dev=2.10.5-3 \
  wget=1.20.1-1.1

USER opam
RUN opam init -y --disable-sandboxing
RUN opam update
RUN opam install -y depext.transition
RUN opam depext conf-m4

USER root
WORKDIR /home/opam

RUN wget https://cs.nyu.edu/acsys/cvc3/releases/2.4.1/linux64/cvc3-2.4.1-optimized-static.tar.gz \
 && tar -xzf cvc3-2.4.1-optimized-static.tar.gz \
 && sudo cp -R /home/opam/cvc3-2.4.1-optimized-static/* /usr/local/

RUN sudo apt-get -y install cvc4=1.6-2+b1 -V

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.7.1/z3-4.7.1-x64-ubuntu-16.04.zip \
 && unzip z3-4.7.1-x64-ubuntu-16.04.zip \
 && sudo cp z3-4.7.1-x64-ubuntu-16.04/bin/z3 /usr/local/bin/z3-4.7.1

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.10/z3-4.8.10-x64-ubuntu-18.04.zip \
 && unzip z3-4.8.10-x64-ubuntu-18.04.zip \
 && sudo cp z3-4.8.10-x64-ubuntu-18.04/bin/z3 /usr/local/bin/z3-4.8.10

USER opam
RUN opam install -y alt-ergo.2.3.0
RUN opam install -y why3.1.2.0 why3-ide.1.2.0
RUN opam install -y ocamlbuild.0.14.0

USER root
RUN apt-get install bash-completion
RUN rm -rf cvc* z* *.tar.gz

USER opam

CMD eval $(opam env) && why3 config --detect &&\
/bin/bash