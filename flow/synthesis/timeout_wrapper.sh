#!/bin/bash
#=============================================================================
# Timeout Wrapper for Synthesis
#=============================================================================
# Description: Wrapper script to add timeout protection to synthesis commands
#              Prevents synthesis from hanging indefinitely
# Author:      Vyges IP Development Team
# Date:        2025-08-02
# License:     Apache-2.0
#=============================================================================

TIMEOUT_SECONDS=$1
shift

# Run command with timeout
timeout $TIMEOUT_SECONDS "$@"

# Check exit status
if [ $? -eq 124 ]; then
    echo "Command timed out after ${TIMEOUT_SECONDS} seconds"
    exit 1
fi 