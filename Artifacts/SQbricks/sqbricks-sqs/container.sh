#  This file is part of SQbricks.
#
#  Copyright (C) 2022-2025
#  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
#  Université Paris-Saclay
#
#  you can redistribute it and/or modify it under the terms of the GNU
#  Lesser General Public License as published by the Free Software
#  Foundation, version 2.1.
#
#  It is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  See the GNU Lesser General Public License version 2.1
#  for more details (enclosed in the file licenses/LGPLv2.1).

#!/bin/bash

DEFAULT_IMAGE="sqbricks"
CUSTOM_IMAGE="jricc/sqbricks:latest"

use_custom_image=false

TEMP=$(getopt -o '' --long custom-image -n 'script.sh' -- "$@")
if [ $? -ne 0 ]; then
  echo "Terminating..." >&2
  exit 1
fi

eval set -- "$TEMP"

while true; do
  case "$1" in
  --custom-image)
    use_custom_image=true
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Option invalide"
    exit 1
    ;;
  esac
done

if [ "$use_custom_image" = true ]; then
  IMAGE=$CUSTOM_IMAGE
else
  IMAGE=$DEFAULT_IMAGE
fi

_pwd="$(pwd)"
docker create --name="sqbricks" -ti \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "${_pwd}/:/sqbricks/" \
  "$IMAGE"
