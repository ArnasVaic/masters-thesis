#!/usr/bin/env bash
# Build Python buildings for C++ solver
pip install -e . --no-build-isolation

# Build stubs for better intellisense
# (I love that this exists)
# TODO: don't hardcode module name in case I wanna change it
cd py
pybind11-stubgen yag_model