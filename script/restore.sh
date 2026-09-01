#!/usr/bin/env bash
# Restore dependencies, naming chosen after dotnet restore
# Use it when environment.yml file is updated.
conda env update -f environment.yml --prune