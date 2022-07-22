#!/bin/bash

_pwd="$(pwd)"

docker create -ti -e DISPLAY=$DISPLAY \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v ${_pwd}/../qbricks.github.io/Case_studies:/home/opam/qbricks/Case_studies \
 -v ${_pwd}/../qbricks.github.io/Qbricks:/home/opam/qbricks/Qbricks \
 -v ${_pwd}/../qbricks.github.io/math_libs:/home/opam/qbricks/math_libs \
 --name="container_qbricks" image_qbricks