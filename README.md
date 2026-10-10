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

You can either build the `yag_model` target with CMake via CLion or terminal, which will create a `.so` file in `cmake-wsl-debug` folder which contains  python bindings that can be directly imported in python using (note that this requires the `.so` file to be in the same directory as the python file, but you have to have specific python 3.11 version and numpy installed so it's preffered to use miniconda):

```python
import yag_model
```

All methods and classes are placed under the namespace `yag_model`. To see how to use, check `py/solver_test.py` and `sketch/ideal-python-api-design.txt`.

If you don't want to copy around the `.so` file, you can install the bindings as a package, this will build bindings and also install the pure-Python helpers `yag_utils` (`py/yag_utils`) so they can be imported from any working directory (note that `yag_model` environment needs to be active in your shell):

```bash
pip install -e . --no-build-isolation
```

Minimal example:

```python
import yag_model as yag
from yag_utils.initial_conditions import random_squares

config = yag.solver_config(
    step=yag.fixed_step(dt=1e-4),
    brake=yag.fixed_step_brake(last_step=1000),
    capture=yag.capture_config(
        reducer=yag.reducers.total_mass(),
        trigger=yag.stride_trigger(every=10),
        sink=yag.in_memory_sink(),  # or yag.hdf5_sink('result.h5')
    ),
)
ic = random_squares(config.discretization, c1=5.0, c2=3.0)
result = yag.solve(config, ic, yag.model_params(D=[1e-2] * 5, k=[10.0, 5.0, 1.0]))

c, t = result.all()                        # everything at once, frames first: (N, C, ...)
for c, t in result.batches(batch_size=50):  # or in batches
    ...

result = yag.hdf5_result('result.h5')      # reopen a file written by hdf5_sink
```

To launch Python code I use VSCode with Python & Jupyter extensions.

## Tests

```bash
# C++ (Catch2)
cmake --build build --target tests && ./build/tests
# Python API, requires the package to be installed (see above)
pytest
```