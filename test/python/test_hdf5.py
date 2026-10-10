import gc

import numpy as np
import pytest
import yag_model as yag
from yag_model import YAG, YAM


@pytest.fixture
def path(tmp_path):
    return str(tmp_path / "result.h5")


def test_hdf5_result_matches_in_memory(make_config, ic, params, path):
    in_memory = yag.solve(make_config(channels=YAM | YAG), ic, params)
    from_file = yag.solve(make_config(channels=YAM | YAG, sink=yag.hdf5_sink(path)), ic, params)

    assert isinstance(from_file, yag.HDF5Result)
    assert len(from_file) == len(in_memory)
    assert from_file.channels == in_memory.channels

    c_file, t_file = from_file.all()
    c_mem, t_mem = in_memory.all()
    np.testing.assert_array_equal(c_file, c_mem)
    np.testing.assert_array_equal(t_file, t_mem)


def test_hdf5_result_reopens_with_metadata(make_config, disc, ic, params, path):
    result = yag.solve(make_config(reducer=yag.reducers.total_mass(), sink=yag.hdf5_sink(path)), ic, params)
    expected = result.all().values.copy()
    del result
    gc.collect()

    reopened = yag.hdf5_result(path)
    meta = reopened.metadata

    assert meta.reducer == "total_mass"
    assert meta.frame_shape == [5]
    assert meta.discretization.mesh_resolution == disc.mesh_resolution
    assert meta.discretization.physical_size == disc.physical_size

    c_parts = [c for c, _ in reopened.batches(batch_size=8)]
    np.testing.assert_array_equal(np.concatenate(c_parts), expected)


def test_hdf5_batches_are_read_only(make_config, ic, params, path):
    result = yag.solve(make_config(sink=yag.hdf5_sink(path)), ic, params)
    assert not result.all().values.flags.writeable


def test_hdf5_overwrite_while_result_open_raises(make_config, ic, params, path):
    config = make_config(sink=yag.hdf5_sink(path))
    _open_result = yag.solve(config, ic, params)

    with pytest.raises(RuntimeError, match="still be open"):
        yag.solve(config, ic, params)


def test_hdf5_result_missing_file_raises(tmp_path):
    with pytest.raises(RuntimeError):
        yag.hdf5_result(str(tmp_path / "missing.h5"))
