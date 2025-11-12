#!/bin/bash

CONTAINER=$1

mkdir -p /tmp/demo/containers
mkdir -p /tmp/demo/scripts
mkdir -p /tmp/demo/nvd-templates
mkdir -p /tmp/demo/areg-filters
mkdir -p /tmp/demo/areg-work-dir
mkdir -p /tmp/demo/freebrowse-data-dir
mkdir -p /tmp/bold-dicom
cp /home/paul/lcn/git/scanner-demo-20251205/scripts/* /tmp/demo/scripts
cp /home/paul/lcn/git/scanner-demo-20251205/nvd-templates/* /tmp/demo/nvd-templates
#cp /home/paul/lcn/git/scanner-demo-20251205/areg-filters/* /tmp/demo/areg-filters

docker run -it --rm \
  --stop-timeout=120 \
  -v /tmp/demo:/tmp/demo \
  -v /tmp/bold-dicom:/bold-dicom \
  $CONTAINER \
    /tmp/demo/scripts/recon.bash \
      /tmp/bold-dicom/MR.1.3.12.2.1107.5.2.19.45407.2025110619233605969800737.dcm \
      /tmp/demo/areg-work-dir/img-00000.nii.gz
