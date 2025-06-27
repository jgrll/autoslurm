#!/bin/bash
#====================================================================
# Author: https://github.com/jgrll
# License: MIT License (see LICENSE file)
# THIS SCRIPT DO NOT NEED TO BE EDITED
#====================================================================

echo "Entering $(basename "$0")" >&2

CONFIG_FILE="$1"
FILES_LIST="$2"  # List of files belonging to a given batch

source "$CONFIG_FILE"
source "$FILES_LIST"

if [ "$EXECUTION_TYPE" == "serial" ]; then
    MASTER_SCRIPT="launch_serial_${FILES_LIST}.sh"

    as_header.sh "$CONFIG_FILE" > "$MASTER_SCRIPT"
    as_body.sh "$CONFIG_FILE" "$FILES_LIST" >> "$MASTER_SCRIPT"
    as_footer.sh "$CONFIG_FILE" >> "$MASTER_SCRIPT"

    chmod +x "$MASTER_SCRIPT"

    SBATCH_ALL_SCRIPT="launch_serial_all.sh"
    cat > "$SBATCH_ALL_SCRIPT" <<EOF
#!/bin/bash
scripts=(launch_serial_${BATCH_PREFIX}_*.sh)
for script in "\${scripts[@]}"; do
    sbatch "\$script"
done
EOF
    chmod +x "$SBATCH_ALL_SCRIPT"

elif [ "$EXECUTION_TYPE" == "parallel" ]; then
    MASTER_SCRIPT="launch_parallel_${FILES_LIST}.sh"
    PARTICULAR_SCRIPT="launch_this_job.sh"

    cat > "$MASTER_SCRIPT" <<EOF
#!/bin/bash

source "${FILES_LIST}"

for filepath in "\${BATCH_FILES[@]}"; do
    filedir=\$(dirname "\$filepath")
    (cd "\$filedir" && sbatch "$PARTICULAR_SCRIPT")
done
EOF
    chmod +x "$MASTER_SCRIPT"

    # Generate individual job scripts
    for filepath in "${BATCH_FILES[@]}"; do
        filedir=$(dirname "$filepath")
        PARTICULAR_SCRIPT_PATH="$filedir/$PARTICULAR_SCRIPT"

        as_header.sh "$CONFIG_FILE" > "$PARTICULAR_SCRIPT_PATH"
        as_body.sh "$CONFIG_FILE" "$FILES_LIST" >> "$PARTICULAR_SCRIPT_PATH"
        as_footer.sh "$CONFIG_FILE" >> "$PARTICULAR_SCRIPT_PATH"

        chmod +x "$PARTICULAR_SCRIPT_PATH"
    done

else
    echo "Warning: Unknown execution type '$EXECUTION_TYPE'" >&2
fi

echo "Leaving $(basename "$0")" >&2
