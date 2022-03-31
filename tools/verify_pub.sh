#!/bin/bash

dart pub publish --dry-run
echo "--------------- verify pub score ---------------"
pana . --no-warning

