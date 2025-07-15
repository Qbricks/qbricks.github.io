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

RUN sudo apt-get update && sudo apt install -y python3 
RUN sudo apt-get update && sudo apt install -y python3-pip 
RUN sudo apt-get update && sudo apt install -y python3-dev 
RUN sudo apt install -y build-essential 
RUN sudo apt install -y libffi-dev
RUN sudo apt install -y libssl-dev
RUN sudo apt install -y libblas-dev
RUN sudo apt install -y liblapack-dev
RUN sudo apt install -y libgmp-dev 
RUN sudo apt -y install libgmp-dev
RUN sudo apt -y install pkg-config adwaita-icon-theme
RUN sudo apt-get update && sudo apt -y install libcairo2-dev 
RUN sudo apt -y install libexpat1-dev
RUN sudo apt -y install libgtk-3-dev libgtksourceview-3.0-dev
RUN sudo apt -y install wget bash-completion
RUN sudo apt -y install libcanberra-gtk-module libcanberra-gtk3-module
RUN sudo apt -y install autoconf

RUN sudo apt clean 

RUN opam init --disable-sandboxing -y 
RUN opam depext conf-m4
RUN opam install -y dune
RUN opam install -y zarith
RUN opam install -y conf-autoconf
RUN opam install -y cmdliner
RUN opam install -y alt-ergo.2.6.2
RUN opam install -y why3.1.8.0
RUN opam install -y lablgtk3       
RUN opam install -y lablgtk3-sourceview3
RUN opam install -y why3-ide.1.8.0
RUN opam install -y ocamlbuild 

RUN opam env >> ~/.bashrc
ENV PATH="/home/opam/.opam/default/bin:$PATH"

RUN wget https://cs.nyu.edu/acsys/cvc3/releases/2.4.1/linux64/cvc3-2.4.1-optimized-static.tar.gz
RUN tar -xzf cvc3-2.4.1-optimized-static.tar.gz 
RUN sudo mv cvc3-2.4.1-optimized-static/bin/cvc3 /usr/local/bin/cvc3 
RUN sudo chmod a+x /usr/local/bin/cvc3

RUN wget https://github.com/CVC4/CVC4-archived/releases/download/1.8/cvc4-1.8-x86_64-linux-opt 
RUN sudo mv cvc4-1.8-x86_64-linux-opt /usr/local/bin/cvc4 
RUN sudo chmod a+x /usr/local/bin/cvc4 

RUN wget https://github.com/cvc5/cvc5/releases/download/cvc5-1.2.1/cvc5-Linux-x86_64-static.zip
RUN unzip cvc5-Linux-x86_64-static.zip 
RUN sudo mv cvc5-Linux-x86_64-static/bin/cvc5 /usr/local/bin/cvc5
RUN sudo chmod a+x /usr/local/bin/cvc5

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.6/z3-4.8.6-x64-ubuntu-16.04.zip 
RUN unzip z3-4.8.6-x64-ubuntu-16.04.zip 
RUN sudo mv z3-4.8.6-x64-ubuntu-16.04/bin/z3 /usr/local/bin/z3-4.8.6 
RUN sudo chmod a+x /usr/local/bin/z3-4.8.6


RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip
RUN unzip z3-4.13.4-x64-glibc-2.35.zip 
RUN sudo mv z3-4.13.4-x64-glibc-2.35/bin/z3 /usr/local/bin/z3-4.13.4 
RUN sudo chmod a+x /usr/local/bin/z3-4.13.4

RUN sudo apt-get install -y python3.12-venv python3-tk

RUN python3 -m venv py-env-qiskit &&\
  py-env-qiskit/bin/pip install qiskit==2.1.1 matplotlib==3.10.3 pylatexenc==2.10 qiskit-aer==0.17.1

WORKDIR /qbricks
COPY . /qbricks
RUN sudo chown -R opam:opam /qbricks
RUN chmod +x /qbricks/run_to_openqasm.sh

RUN eval $(opam env) && opam install . --deps-only -y
ENV DISPLAY=:0

CMD ["/bin/bash", "-c", "eval $(opam env) && why3 config detect && exec /bin/bash"]
