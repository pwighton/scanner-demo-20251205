#!/bin/bash

OUTPUT_BASEDIR=/tmp/demo/freebrowse-data-dir
ORIG_NVD_TEMPLATE=/tmp/demo/nvd-templates/orig.nvd
SYNTHSEG_NVD_TEMPLATE=/tmp/demo/nvd-templates/synthseg.nvd
NUM_THREADS=8

DICOM_PATH=$1
NIFTI_PATH=$2

# We pipe though xargs to remove trailing whitespace
SUBJECT_NAME=`mri_probedicom --i ${DICOM_PATH} --t 10 10|xargs`
SERIES_NUM=`mri_probedicom --i ${DICOM_PATH} --t 20 11|xargs`
OUTPUT_DIR=$OUTPUT_BASEDIR/$SUBJECT_NAME

echo "DICOM_PATH:   ${DICOM_PATH}"
echo "NIFTI_PATH:   ${NIFTI_PATH}"
echo "SUBJECT_NAME: ${SUBJECT_NAME}"
echo "SERIES_NUM:   ${SERIES_NUM}"
echo "OUTPUT_DIR:   ${OUTPUT_DIR}"

mkdir -p $OUTPUT_DIR

# Copy the input nifti to the freebrowse data directory
ORIG_FILENAME="series-${SERIES_NUM}--orig.nii.gz"
cp $NIFTI_PATH ${OUTPUT_DIR}/${ORIG_FILENAME}

# Create a niivue document for the input file
ORIG_NVD_FILENAME="series-${SERIES_NUM}--orig.nvd"
cat $ORIG_NVD_TEMPLATE \
  | sed "s|__SUBJECT-NAME__|${SUBJECT_NAME}|g" \
  | sed "s|__INPUT-FILENAME__|${ORIG_FILENAME}|" \
  > ${OUTPUT_DIR}/${ORIG_NVD_FILENAME}

# run synthseg
SYTHNSEG_FILENAME="series-$SERIES_NUM--synthseg.nii.gz"

#echo "RUNNING SYNTHSEG..."
SYNTHSEG_STARTTIME=$SECONDS
mri_synthseg --threads 10 --i ${NIFTI_PATH} --o ${OUTPUT_DIR}/${SYTHNSEG_FILENAME}
SYNTHSEG_ENDTIME=$SECONDS
SYNTHSEG_ELAPASED_TIME=$((SYNTHSEG_ENDTIME - SYNTHSEG_STARTTIME))
echo "SYNTHSEG DONE; TOOK ${SYNTHSEG_ELAPASED_TIME} SECONDS"

# Create a niivue document for the synthseg output overlayed on the input
SYNTHSEG_NVD_FILENAME="series-$SERIES_NUM--synthseg.nvd"
cat $SYNTHSEG_NVD_TEMPLATE \
  | sed "s|__SUBJECT_NAME__|${SUBJECT_NAME}|g" \
  | sed "s|__INPUT-FILENAME__|${ORIG_FILENAME}|" \
  | sed "s|__SYNTHSEG-FILENAME__|${SYTHNSEG_FILENAME}|" \
  > ${OUTPUT_DIR}/${SYNTHSEG_NVD_FILENAME}
