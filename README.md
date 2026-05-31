[![GitHub Pages](https://github.com/ArnasVaic/masters-thesis/actions/workflows/deploy-thesis-doc.yml/badge.svg)](https://github.com/ArnasVaic/masters-thesis/actions/workflows/deploy-thesis-doc.yml)

# Master's thesis

This repository contains all documents and code related to my master's thesis.

## File structure

- `/doc` - thesis document source files
- `/src` - code source files

## Tech stack & used resources

- `typst` - markup-based typesetting system for the sciences
- [BibTeX Plain CSL](https://github.com/para-lipics/bibtex-plain-csl)
- MTDP template for Typst, [requirement table](doc/README.md) (self made)
- C++ for core solver, CLion for development
- Python bindinsgs

## Important dates

| Status | Action         | Date       |
| ------ | -------------- | ---------- |
| 🟢 Done | Choose a topic | 2025-12-18 |

## GitHub Pages

https://arnasvaic.github.io/masters-thesis/

## Requirements and general information for mid-term

- Defense will be held online
- Will need to upload proof of work during the first week of each month
- Grading: 30% from lectures, 70% from defense

## Development

Following instructions assume use of WSl.

### Prerequisites

Install miniconda:

https://www.anaconda.com/docs/getting-started/miniconda/install/linux-install

Install packages on WSL:

```bash
# CLion IDE dependency
sudo apt install libicu-dev
# CLion is extremely slow if connecting via WSL
# Solution: connect via SSH
sudo apt install openssh-server -y
# C++ tooling
sudo apt install clang-19 lldb-19 lld-19 cmake ninja-build gdb build-essential -y
```

Create conda environment (run from project root):

```bash
conda env create -f environment.yml
```

CLion won't see your conda environment by default. 

Activate the environment you created:

```bash
conda activate yag_model
```

Get the path to your conda environment:

```bash
echo $CONDA_PREFIX
```

Go to:

```
File > Settings > Build, Execution, Deployment > CMake
```

In field `CMake options` add:

```bash
# Replace <conda-prefix> with the path you got from running previous command
-DCMAKE_PREFIX_PATH=<conda-prefix>
```

In CLion you should now be able to succesfully reload CMake project.

## Workflow

You can either build the `yag_model` target with CMake via CLion or terminal, which will create a `.so` file in `cmake-wsl-debug` folder which contains  python bindings that can be directly imported in python using (note that this requires the `.so` file to be in the same directory as the python file):

```python
import yag_model
```

All methods and classes are placed under the namespace `yag_model`. To see how to use, check `py/solver_test.py`.

If you don't want to copy around the `.so` file, you can install the bindings as a package, this will build bindings (note that `yag_model` environment needs to be active in your shell):

```bash
pip install -e . --no-build-isolation
```

To launch Python code I use VSCode with Python & Jupyter extensions.