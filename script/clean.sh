#!/usr/bin/env bash
# Clean build artifacts. Usually need to use after adding
# a new package because that causes linking errors.
rm -rf build
rm -rf cmake-build-debug