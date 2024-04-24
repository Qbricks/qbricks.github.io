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

FROM debian:buster-20220418-slim

# Create users

USER root

RUN adduser --disabled-password --gecos '' opam

RUN usermod -aG sudo opam


# Installation: prerequisites

RUN apt-get update && apt-get -y install sudo

RUN sudo apt-get -y install opam=2.0.3-1+deb10u1 
RUN sudo apt-get -y install  libgmp-dev=2:6.1.2+dfsg-4+deb10u1 
RUN sudo apt-get -y install  pkg-config=0.29-6 adwaita-icon-theme=3.30.1-1 
RUN sudo apt-get -y install  libcairo2-dev=1.16.0-4+deb10u1 
RUN sudo apt-get -y install libexpat1-dev=2.2.6-2+deb10u7
RUN sudo apt-get -y install  libgtk-3-dev=3.24.5-1 libgtksourceview-3.0-dev=3.24.9-2 
RUN sudo apt-get -y install  libgtk2.0-dev=2.24.32-3 libgtksourceview2.0-dev=2.10.5-3 
RUN sudo apt-get -y install  wget=1.20.1-1.1 
RUN sudo apt-get -y install  libcanberra-gtk-module libcanberra-gtk3-module


# Installation: Why3 + Solvers

USER opam

RUN opam init -y --disable-sandboxing && opam update && \
  opam install -y depext.transition && opam depext conf-m4 && \
  opam install -y alt-ergo.2.4.1 why3 why3-ide && \
  opam install -y lablgtk3 lablgtk3-sourceview3 ocamlbuild.0.14.1

USER root

WORKDIR /home/opam

RUN apt-get update
RUN wget https://cs.nyu.edu/acsys/cvc3/releases/2.4.1/linux64/cvc3-2.4.1-optimized-static.tar.gz
RUN tar -xzf cvc3-2.4.1-optimized-static.tar.gz 
RUN sudo cp -R /home/opam/cvc3-2.4.1-optimized-static/* /usr/local/ 
RUN wget https://github.com/CVC4/CVC4-archived/releases/download/1.8/cvc4-1.8-x86_64-linux-opt 
RUN sudo mv cvc4-1.8-x86_64-linux-opt /usr/local/bin/cvc4 
RUN sudo chmod a+x /usr/local/bin/cvc4 
RUN wget https://github.com/cvc5/cvc5/releases/download/cvc5-1.0.0/cvc5-Linux 
RUN sudo mv cvc5-Linux /usr/local/bin/cvc5 
RUN sudo chmod a+x /usr/local/bin/cvc5 
RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.7.1/z3-4.7.1-x64-ubuntu-16.04.zip 
RUN unzip z3-4.7.1-x64-ubuntu-16.04.zip 
RUN sudo cp z3-4.7.1-x64-ubuntu-16.04/bin/z3 /usr/local/bin/z3-4.7.1 
RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.8.10/z3-4.8.10-x64-ubuntu-18.04.zip 
RUN unzip z3-4.8.10-x64-ubuntu-18.04.zip 
RUN sudo cp z3-4.8.10-x64-ubuntu-18.04/bin/z3 /usr/local/bin/z3-4.8.10 
RUN apt-get -y install python-pip=18.1-5  
RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.11.0/z3_solver-4.11.0.0-py2.py3-none-manylinux1_x86_64.whl 
RUN pip install z3_solver-4.11.0.0-py2.py3-none-manylinux1_x86_64.whl


# Installation: Qiskit

ENV PATH /opt/conda/bin:$PATH

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh && \
  mkdir -p /opt && \
  yes "yes" | bash Miniconda3-py39_4.12.0-Linux-x86_64.sh -b -p /opt/conda && \
  rm Miniconda3-py39_4.12.0-Linux-x86_64.sh && \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
  echo "conda activate base" >> ~/.bashrc && \
  find /opt/conda/ -follow -type f -name '*.a' -delete && \
  find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
  /opt/conda/bin/conda clean -afy && \
  conda update conda && conda create -n qiskit_env python=3 && \
  activate qiskit_env && \
  apt-get -y install curl python3-tk && curl https://bootstrap.pypa.io/get-pip.py | python && \
  pip install qiskit -U matplotlib==3.6.0 pylatexenc==2.10

RUN apt-get -y install bash-completion=1:2.8-6 

RUN rm -f z3-4.7.1-x64-ubuntu-16.04.zip z3-4.8.10-x64-ubuntu-18.04.zip cvc3-2.4.1-optimized-static.tar.gz

USER opam

CMD eval $(opam env) && why3 config detect &&\
  /bin/bash