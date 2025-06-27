#!/bin/bash
#====================================================================
# Template Configuration Script
# Author: https://github.com/jgrll
# License: MIT License (see LICENSE file)
#
# This is a template script meant to be customized for specific
# cluster architectures and program configurations (see examples).
#====================================================================

echo "Entering $(basename "$0")" >&2

declare -A TEMPLATES

################################################
### ADD CONFIG FILES SECTION TEMPLATES BELOW ###
################################################

TEMPLATES["commentaries"]='#[commentaries]
# Please keep in mind that all sections are sourced in as_*.sh scripts.
# All variables in this file are global.
# Add keywords according to your needs.
'

TEMPLATES["HPC_cluster"]='#[HPC_section]
CLUSTER=                    # name of the machine, used in as_header.sh, as_footer.sh
PROGRAM=                    # keyword of the prog., used in as_header.sh (modules) and as_body.sh (instructions)
NODES=                      # SBATCH number of nodes
NTASKS_PER_NODE=            # SBATCH number of tasks
NCPUS_PER_TASK=             # SBATCH number of cpus (virtual) per task
MEM_IN_GB=                  # SBATCH requested memory PER node
TIME=hh:mm:ss               # SBATCH requested computation time
PARTITION=                  # SBATCH partition
JOB_NAME=                   # name appearing when squeue
EXECUTION_TYPE=serial       # "serial" or "parallel"
NBATCH=1                    # only meaningful for "serial" execution type
BATCH_PREFIX=batch          # each batch filelist will start by BATCH_PREFIX
'

TEMPLATES["inputs"]='#[inputs]
shopt -s nullglob          # handle empty lists
INPUT_FOLDERS=(all/relative/path/to/inputs)
INPUT_EXTENSION=.in        # with/without the point (.)
'

TEMPLATES["custom_section"]='#[custom_section]
# You may want to make sure each input is in its own folder.
# Otherwise distinct subfolders will be created.All variables in this file are global
# Add keywords according to your needs
ANY_VAR_YOU_NEED1=val1
ANY_VAR_YOU_NEED2=val2
'

######################################
### END OF THE TEMPLATES SECTION   ###
######################################

echo "Available sections: " >&2
echo "====================" >&2
for template_name in "${!TEMPLATES[@]}"; do
    echo -e "  - $template_name" >&2
    echo "${TEMPLATES[$template_name]}"
done
echo "====================" >&2

echo "Leaving $(basename "$0")" >&2
