#!/bin/bash

sudo rm -rf /tmp/demo/
sudo rm -rf /tmp/bold-dicom

mkdir -p /tmp/demo/containers
mkdir -p /tmp/demo/scripts
mkdir -p /tmp/demo/nvd-templates
mkdir -p /tmp/demo/areg-filters
mkdir -p /tmp/demo/areg-work-dir
mkdir -p /tmp/demo/freebrowse-data-dir
mkdir -p /tmp/bold-dicom
cp scripts/* /tmp/demo/scripts
cp nvd-templates/* /tmp/demo/nvd-templates
#cp /home/paul/lcn/git/scanner-demo-20251205/areg-filters/* /tmp/demo/areg-filters
