# (**************************************************************************)
# (*  This file is part of QBRICKS.                                         *)
# (*                                                                        *)
# (*  Copyright (C) 2020-2022                                               *)
# (*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
# (*         alternatives)                                                  *)
# (*    Université Paris-Saclay                                             *)
# (*                                                                        *)
# (*  you can redistribute it and/or modify it under the terms of the GNU   *)
# (*  Lesser General Public License as published by the Free Software       *)
# (*  Foundation, version 2.1.                                              *)
# (*                                                                        *)
# (*  It is distributed in the hope that it will be useful,                 *)
# (*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
# (*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
# (*  GNU Lesser General Public License for more details.                   *)
# (*                                                                        *)
# (*  See the GNU Lesser General Public License version 2.1                 *)
# (*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
# (*                                                                        *)
# (**************************************************************************)

FROM ocaml/opam:ubuntu-24.04-ocaml-4.13

USER root

RUN apt-get install -y --no-install-recommends \
      python3 \
      python3-venv \
      python3-tk \
      python3-pip \
      build-essential \
      libgomp1 

RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip && \
    pip install \
    qiskit==2.1.1 \
    matplotlib==3.10.3 \
    pylatexenc==2.10 \
    qiskit-aer==0.17.1

RUN apt-get install -y --no-install-recommends\
  libffi-dev libssl-dev libblas-dev liblapack-dev libgmp-dev \
  libgmp-dev pkg-config adwaita-icon-theme libcairo2-dev libexpat1-dev \
  libgtk-3-dev libgtksourceview-3.0-dev wget bash-completion \
  libcanberra-gtk-module libcanberra-gtk3-module autoconf

RUN wget https://cs.nyu.edu/acsys/cvc3/releases/2.4.1/linux64/cvc3-2.4.1-optimized-static.tar.gz && \
  tar -xzf cvc3-2.4.1-optimized-static.tar.gz && \
  mv cvc3-2.4.1-optimized-static/bin/cvc3 /usr/local/bin/cvc3 && \
  chmod a+x /usr/local/bin/cvc3

RUN wget https://github.com/CVC4/CVC4-archived/releases/download/1.8/cvc4-1.8-x86_64-linux-opt && \
  mv cvc4-1.8-x86_64-linux-opt /usr/local/bin/cvc4 && \
  chmod a+x /usr/local/bin/cvc4 

RUN wget https://github.com/cvc5/cvc5/releases/download/cvc5-1.2.1/cvc5-Linux-x86_64-static.zip && \
  unzip cvc5-Linux-x86_64-static.zip && \
  mv cvc5-Linux-x86_64-static/bin/cvc5 /usr/local/bin/cvc5 && \
  chmod a+x /usr/local/bin/cvc5

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.6/z3-4.8.6-x64-ubuntu-16.04.zip && \
  unzip z3-4.8.6-x64-ubuntu-16.04.zip && \
  mv z3-4.8.6-x64-ubuntu-16.04/bin/z3 /usr/local/bin/z3-4.8.6 && \
  chmod a+x /usr/local/bin/z3-4.8.6

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip && \
  unzip z3-4.13.4-x64-glibc-2.35.zip && \
  mv z3-4.13.4-x64-glibc-2.35/bin/z3 /usr/local/bin/z3-4.13.4 && \
  chmod a+x /usr/local/bin/z3-4.13.4

RUN apt clean && apt-get clean 

USER opam

RUN opam init --disable-sandboxing -y 
RUN opam depext conf-m4
RUN opam install -y zarith conf-autoconf cmdliner alt-ergo.2.6.2 \
  why3.1.8.0 lablgtk3 lablgtk3-sourceview3 why3-ide.1.8.0 ocamlbuild 

RUN opam clean

WORKDIR /qbricks
COPY . /qbricks
RUN sudo chown -R opam:opam /qbricks
RUN chmod +x /qbricks/scripts/run_to_openqasm.sh

ENV DISPLAY=:0

CMD ["/bin/bash", "-c", "eval $(opam env) && why3 config detect && exec /bin/bash"]
