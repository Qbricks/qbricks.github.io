# This file is part of SQbricks.
#
# Copyright (C) 2022-2026
# CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
# Université Paris-Saclay
#
# you can redistribute it and/or modify it under the terms of the GNU
# Lesser General Public License as published by the Free Software
# Foundation, version 2.1.
#
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# See the GNU Lesser General Public License version 2.1
# for more details (enclosed in the file licenses/LGPLv2.1).

FROM ocaml/opam:ubuntu-22.04-ocaml-5.1

RUN sudo apt-get update && sudo apt-get install -y \
  git \
  python3 \
  python3-pip \
  python3-tk \
  libgmp-dev pkg-config \
  bash-completion \
  && sudo apt-get clean 

RUN git clone https://github.com/Z3Prover/z3.git && \
  cd z3 && \
  git checkout z3-4.12.2 && \
  python3 scripts/mk_make.py

RUN cd z3/build && \
  sudo make -j$(nproc) && \
  sudo make install && \
  sudo ldconfig && \
  cd ../.. && rm -rf z3
RUN sudo apt-get update && sudo apt-get install -y libboost-regex1.74.0

RUN opam init --disable-sandboxing -y && \
  opam update && \
  opam install -y \
  dune \
  zarith \
  landmarks \
  benchmark \
  lwt \
  batteries \
  logs \
  menhir \
  landmarks-ppx \
  alcotest \
  odoc

RUN opam env >> ~/.bashrc
ENV PATH="/home/opam/.opam/default/bin:$PATH"

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

WORKDIR /sqbricks
COPY . /sqbricks
RUN sudo chown -R opam:opam /sqbricks
RUN chmod +x /sqbricks/scripts/benchmarks.sh

RUN sudo mv /usr/lib/libz3.so /usr/lib/libz3.so.4.12

RUN eval $(opam env) && opam install . --deps-only -y

RUN eval $(opam env) && dune build

CMD ["/bin/bash"]
