#!/bin/bash

# See: `setup-areg.sh`

CONTAINER=$1

docker run -it --rm \
  -v /tmp/demo:/tmp/demo \
  -v /tmp/bold-dicom:/bold-dicom \
  $CONTAINER \
    auto_register.py \
      -s /tmp/demo/areg-work-dir \
      --input-mode directory \
      --watch-directory /bold-dicom \
      --disable-default-areg \
      --command /tmp/demo/scripts/recon.bash
