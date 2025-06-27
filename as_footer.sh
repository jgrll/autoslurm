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

source "$1"

case "$CLUSTER" in
    "test")
        cat <<EOF
EOF
        ;;

    *)
        echo "Warning: Unknown cluster '$CLUSTER'" >&2
        echo "No footer will be produced." >&2
        ;;
esac

echo "Leaving $(basename "$0")" >&2
