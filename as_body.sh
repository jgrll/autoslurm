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

CONFIG_FILE="$1"
FILES_LIST="$2"

source "$CONFIG_FILE"

case "$PROGRAM" in
    "test")
        if [ "$EXECUTION_TYPE" == "parallel" ]; then
            echo "PARALLEL mode selected." >&2
            cat <<EOF
EOF
        elif [ "$EXECUTION_TYPE" == "serial" ]; then
            echo "SERIAL mode selected." >&2
            cat <<EOF
EOF
        else
            echo "Warning: Unknown execution type '$EXECUTION_TYPE'" >&2
        fi
        ;;

    *)
        echo "Warning: Unknown program keyword '$PROGRAM'" >&2
        ;;
esac

echo "Leaving $(basename "$0")" >&2
