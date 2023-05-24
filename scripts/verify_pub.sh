#!/bin/bash

echo "--------------- Format code ---------------"
dart format .
echo "--------------- --dry-run ---------------"
dart pub publish --dry-run
echo "--------------- verify pub score ---------------"
pana . --no-warning

