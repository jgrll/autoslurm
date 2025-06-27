#!/bin/bash
#====================================================================
# Author: https://github.com/jgrll
# License: MIT License (see LICENSE file)
# THIS SCRIPT DO NOT NEED TO BE EDITED
#====================================================================

echo "Entering $(basename "$0")" >&2

CONFIG_FILE="job.cfg"

update_files_single() {
    FILES_PROCESSED+=("$1")
}

update_files_multiple() {
    for filepath in "$@"; do
        local filename=$(basename "$filepath")
        local dirname=$(dirname "$filepath")
        local subdirname="${filename%.*}"
        local newdir="${dirname}/${subdirname}"
        mkdir -p "$newdir"
        mv "$filepath" "$newdir/"
        FILES_PROCESSED+=("$newdir/$filename")
    done
}

check_folders() {
    echo "=== Processing input folders ... ===" >&2
    for inputfolder_noformat in "$@"; do
        inputfolder="${inputfolder_noformat#/}"
        inputfiles=("${inputfolder}"/*."${INPUT_EXTENSION_FORMAT}")
        local len_files_found=${#inputfiles[@]}
        if [ "$len_files_found" -eq 0 ]; then
            echo "  ! ${inputfolder} : no .${INPUT_EXTENSION_FORMAT} file(s) found. Was it even a directory ?" >&2
        elif [ "$len_files_found" -eq 1 ]; then
            echo "  ${inputfolder} : $len_files_found .${INPUT_EXTENSION_FORMAT} file found." >&2
            update_files_single "${inputfiles[@]}"
        else
            echo "  ${inputfolder} : $len_files_found .${INPUT_EXTENSION_FORMAT} files found. Subdirectories will be created." >&2
            update_files_multiple "${inputfiles[@]}"
        fi
    done

    echo "=== All inputfiles below ===" >&2
    for file in "${FILES_PROCESSED[@]}"; do
        echo "  $file" >&2
    done
}

create_batches() {
    local filepaths=("$@")
    local total=${#filepaths[@]}
    local per_batch=$(( (total + NBATCH - 1) / NBATCH ))

    for ((i=0; i<NBATCH; i++)); do
        local start=$((i * per_batch))
        local batch_files=("${filepaths[@]:start:per_batch}")

        echo "BATCH_FILES=(" > "${BATCH_PREFIX}_${i}"
        printf "  %s\n" "${batch_files[@]}" >> "${BATCH_PREFIX}_${i}"
        echo ")" >> "${BATCH_PREFIX}_${i}"

        echo "=== ${BATCH_PREFIX}_${i} ===" >&2
        cat "${BATCH_PREFIX}_${i}" >&2
    done
}

if [ $# -eq 0 ]; then
    as_cfg.sh > "$CONFIG_FILE"
    echo "Created default config file: $CONFIG_FILE"
elif [[ $# -eq 1 && "$1" =~ \.cfg$ && -f "$1" ]]; then
    source "$1"

    INPUT_EXTENSION_FORMAT="${INPUT_EXTENSION#.}"
    FILES_PROCESSED=()

    check_folders "${INPUT_FOLDERS[@]}"
    create_batches "${FILES_PROCESSED[@]}"

    batches=("${BATCH_PREFIX}_"*)

    for batch in "${batches[@]}"; do
        echo "=== $batch ===" >&2
        as_complete.sh "$CONFIG_FILE" "$batch"
    done
else
    echo "Usage: $(basename "$0") [config_file.cfg]" >&2
    echo "  If no argument is provided, creates a default config file." >&2
    echo "  If a .cfg file is provided, processes the input files." >&2
fi

echo "Leaving $(basename "$0")" >&2
