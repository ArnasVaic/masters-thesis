# Locations inside the repository, independent of the working directory

from pathlib import Path


def repo_root() -> Path:
    """Root of the repository: the closest directory holding pyproject.toml and doc/.

    Searched upwards from this package (an editable install lives in the repo),
    then from the working directory.
    """
    for start in (Path(__file__).resolve().parent, Path.cwd().resolve()):
        for d in (start, *start.parents):
            if (d / "pyproject.toml").is_file() and (d / "doc").is_dir():
                return d

    raise FileNotFoundError("Could not locate the repository root")


def diagrams_dir() -> Path:
    """Directory for figures included in the thesis."""
    return repo_root() / "doc" / "assets" / "diagrams"
