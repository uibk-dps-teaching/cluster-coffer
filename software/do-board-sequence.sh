#!/bin/sh

for script in [0-9][0-9]-*.sh; do
    echo "===== Running $script"
    ./$script "$@" || exit 1
done
