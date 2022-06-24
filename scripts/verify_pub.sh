#!/bin/bash

echo "--------------- Format code ---------------"
flutter format .
echo "--------------- --dry-run ---------------"
dart pub publish --dry-run
echo "--------------- verify pub score ---------------"
pana . --no-warning

