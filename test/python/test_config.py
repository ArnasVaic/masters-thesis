import numpy as np
import pytest
import yag_model as yag
from yag_model import YAG, YAM


def test_discretization_uses_xy_tuples(disc):
    assert disc.mesh_resolution == (8, 6)
    assert disc.physical_size == (1.0, 2.0)
    assert (disc.nx, disc.ny) == (8, 6)
    assert disc.shape == (6, 8)
    assert disc.dx == pytest.approx(1.0 / 7)
    assert disc.dy == pytest.approx(2.0 / 5)


def test_discretization_rejects_degenerate_mesh():
    with pytest.raises(ValueError):
        yag.discretization(mesh_resolution=(1, 4))


def test_smallest_config_has_documented_defaults():
    config = yag.solver_config()

    assert config.discretization.mesh_resolution == (40, 40)
    assert config.discretization.physical_size == (1.0, 1.0)
    assert isinstance(config.step, yag.FixedTimeStep) and config.step.dt == 1.0
    assert isinstance(config.brake, yag.FixedStepBrake) and config.brake.last_step == 100
    assert isinstance(config.capture.reducer, yag.ConcentrationFieldReducer)
    assert isinstance(config.capture.trigger, yag.StrideTrigger) and config.capture.trigger.every == 1
    assert isinstance(config.capture.sink, yag.InMemorySink) and config.capture.sink.capacity is None
    assert config.capture.channels == yag.ALL
    np.testing.assert_array_equal(config.stoichiometry, yag.DEFAULT_STOICHIOMETRY)


def test_default_components_are_not_shared_between_configs():
    a, b = yag.solver_config(), yag.solver_config()
    assert a.capture.sink is not b.capture.sink
    assert a.step is not b.step


def test_factories_are_the_classes():
    assert isinstance(yag.stride_trigger(every=3), yag.StrideTrigger)
    assert isinstance(yag.geometric_step(dt_0=1.0, r=2.0), yag.GeometricTimeStep)
    assert isinstance(yag.in_memory_sink(capacity=5), yag.InMemorySink)
    assert isinstance(yag.reducers.total_mass(), yag.TotalMassReducer)
    assert yag.reducers.density_field().name == "density_field"


def test_channel_flags_combine():
    assert int(YAM | YAG) == 0b10100
    assert yag.channel_indices(YAM | YAG) == [2, 4]
    assert yag.capture_config(channels=YAG).channels == int(YAG)


def test_capture_config_is_mutable_in_place():
    config = yag.solver_config()
    config.capture.sink = yag.in_memory_sink(capacity=3)
    assert config.capture.sink.capacity == 3


def test_config_arguments_are_keyword_only():
    with pytest.raises(TypeError):
        yag.solver_config(yag.discretization())


def test_module_constants_are_read_only():
    with pytest.raises(ValueError):
        yag.MOLAR_MASSES[0] = 1.0


def test_solution_state_indexing(disc):
    state = yag.SolutionState(disc)
    assert len(state) == 5
    assert state[4].shape == disc.shape

    state[0] = np.ones(disc.shape)
    assert state[0].sum() == disc.nx * disc.ny

    with pytest.raises(IndexError):
        state[5]
