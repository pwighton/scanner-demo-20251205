FROM pwighton/areg:20251112-min-temp

# Set the FreeSurfer-related environment variables.  Everything other than
# FREESURFER_HOME and SUBJECTS_DIR is what would get set by running
# `source $FREESURFER_HOME/SetUpFreeSurfer.sh`
ENV FREESURFER_HOME=/usr/local/freesurfer/8.1.0-1 \
    SUBJECTS_DIR=/usr/local/freesurfer/8.1.0-1/subjects \
    FIX_VERTEX_AREA= \
    FMRI_ANALYSIS_DIR=/usr/local/freesurfer/8.1.0-1/fsfast \
    FREESURFER=/usr/local/freesurfer/8.1.0-1 \
    FS_OVERRIDE=0 \
    FSF_OUTPUT_FORMAT=nii.gz \
    FSFAST_HOME=/usr/local/freesurfer/8.1.0-1/fsfast \
    FUNCTIONALS_DIR=/usr/local/freesurfer/8.1.0-1/sessions \
    LOCAL_DIR=/usr/local/freesurfer/8.1.0-1/local \
    MINC_BIN_DIR=/usr/local/freesurfer/8.1.0-1/mni/bin \
    MINC_LIB_DIR=/usr/local/freesurfer/8.1.0-1/mni/lib \
    MNI_DATAPATH=/usr/local/freesurfer/8.1.0-1/mni/data \
    MNI_DIR=/usr/local/freesurfer/8.1.0-1/mni \
    MNI_PERL5LIB=/usr/local/freesurfer/8.1.0-1/mni/share/perl5 \
    OS=Linux \
    PATH=/opt/auto-register/src:/usr/local/freesurfer/8.1.0-1/bin:/usr/local/freesurfer/8.1.0-1/fsfast/bin:/usr/local/freesurfer/8.1.0-1/tktools:/usr/local/freesurfer/8.1.0-1/mni/bin:${PATH} \
    PERL5LIB=/usr/local/freesurfer/8.1.0-1/mni/share/perl5
