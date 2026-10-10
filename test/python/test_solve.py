import gc

import numpy as np
import pytest
import yag_model as yag
from yag_model import AL2O3, YAG, YAM


def test_batches_cover_all_frames(make_config, ic, params):
    result = yag.solve(make_config(), ic, params)
    c_all, t_all = result.all()

    batches = result.batches(batch_size=6)
    assert len(batches) == 4
    assert [len(b) for b in batches] == [6, 6, 6, 3]

    c_parts, t_parts = zip(*[(c, t) for c, t in result.batches(batch_size=6)])
    np.testing.assert_array_equal(np.concatenate(c_parts), c_all)
    np.testing.assert_array_equal(np.concatenate(t_parts), t_all)


def test_frames_are_frame_first_with_selected_channels(make_config, disc, ic, params):
    result = yag.solve(make_config(channels=YAM | YAG, trigger=yag.stride_trigger(every=5)), ic, params)
    c, t = result.all()

    # Steps 0, 5, 10, 15, 20
    assert len(result) == 5
    assert c.shape == (5, 2, *disc.shape)
    assert t.shape == (5,)
    assert result.channels == int(YAM | YAG)
    assert result.metadata.frame_shape == [2, *disc.shape]


def test_read_returns_a_frame_range(make_config, ic, params):
    result = yag.solve(make_config(), ic, params)
    c, t = result.read(begin=2, end=5)
    np.testing.assert_array_equal(t, result.all().times[2:5])


def test_in_memory_reads_are_zero_copy_and_read_only(make_config, ic, params):
    result = yag.solve(make_config(), ic, params)

    a, b = result.all().values, result.all().values
    assert np.shares_memory(a, b)
    assert not a.flags.writeable

    with pytest.raises(ValueError):
        a[0, 0, 0, 0] = 1.0


def test_views_keep_data_alive_after_result_is_gone(make_config, ic, params):
    result = yag.solve(make_config(), ic, params)
    c, t = result.all()
    expected = c.copy()

    del result
    gc.collect()

    np.testing.assert_array_equal(c, expected)


def test_scalar_reducers_match_field_quantities(make_config, disc, ic, params):
    q = yag.solve(make_config(reducer=yag.reducers.total_molar_quantity()), ic, params).all().values
    m = yag.solve(make_config(reducer=yag.reducers.total_mass()), ic, params).all().values

    assert q.shape == (21, 5)
    np.testing.assert_allclose(q[0], [yag.quantity(ic[i], disc) for i in range(5)])
    np.testing.assert_allclose(m, q * yag.MOLAR_MASSES)


def test_density_field_scales_by_molar_mass(make_config, ic, params):
    c = yag.solve(make_config(channels=AL2O3), ic, params).all().values
    rho = yag.solve(make_config(channels=AL2O3, reducer=yag.reducers.density_field()), ic, params).all().values
    np.testing.assert_allclose(rho, c * yag.MOLAR_MASSES[0])


def test_capacity_keeps_first_frames(make_config, ic, params):
    result = yag.solve(make_config(sink=yag.in_memory_sink(capacity=4)), ic, params)
    assert len(result) == 4
    np.testing.assert_allclose(result.all().times, [0.0, 0.001, 0.002, 0.003])


def test_last_frame_trigger_captures_only_final_state(make_config, ic, params):
    result = yag.solve(make_config(trigger=yag.last_frame_trigger()), ic, params)
    assert len(result) == 1
    assert result.all().times[0] == pytest.approx(0.02)


def test_reused_config_gives_independent_results(make_config, ic, params):
    config = make_config(trigger=yag.last_frame_trigger())
    first = yag.solve(config, ic, params)

    config.brake = yag.fixed_step_brake(last_step=5)
    second = yag.solve(config, ic, params)

    assert first.all().times[0] == pytest.approx(0.02)
    assert second.all().times[0] == pytest.approx(0.005)


def test_geometric_step_and_time_brake(disc, ic, params):
    config = yag.solver_config(
        discretization=disc,
        step=yag.geometric_step(dt_0=0.1, r=2.0),
        brake=yag.fixed_time_brake(final_time=1.0),
        capture=yag.capture_config(trigger=yag.last_frame_trigger()),
    )
    # 0.1 + 0.2 + 0.4 + 0.8 is the first time past 1.0
    assert yag.solve(config, ic, params).all().times[0] == pytest.approx(1.5)


def test_reagent_quantity_threshold_brake_initializes_from_ic(disc, ic, params):
    brake = yag.reagent_quantity_threshold_brake(threshold=0.99, every=1)
    config = yag.solver_config(discretization=disc, step=yag.fixed_step(dt=0.01), brake=brake)

    yag.solve(config, ic, params)

    assert brake.initial_reagent_quantity == pytest.approx(yag.reagent_quantity(ic, disc))


def test_simplified_stoichiometry_only_produces_yag(disc, ic, params):
    import yag_utils.stoichiometry

    config = yag.solver_config(
        discretization=disc,
        step=yag.fixed_step(dt=0.01),
        capture=yag.capture_config(reducer=yag.reducers.total_molar_quantity()),
        stoichiometry=yag_utils.stoichiometry.simplified,
    )
    q = yag.solve(config, ic, params).all().values

    assert q[-1, 4] > 0.0
    np.testing.assert_array_equal(q[:, 2:4], 0.0)


@pytest.mark.parametrize(
    "change, error",
    [
        (lambda c: setattr(c.capture, "channels", 0), ValueError),
        (lambda c: setattr(c, "stoichiometry", np.zeros((3, 3))), ValueError),
        (lambda c: setattr(c, "discretization", yag.discretization(mesh_resolution=(4, 4))), ValueError),
    ],
)
def test_invalid_configs_raise(make_config, ic, params, change, error):
    config = make_config()
    change(config)
    with pytest.raises(error):
        yag.solve(config, ic, params)


def test_invalid_model_params_raise(make_config, ic):
    with pytest.raises(ValueError):
        yag.solve(make_config(), ic, yag.model_params(D=[0.01] * 4, k=[1.0] * 3))


def test_zero_batch_size_raises(make_config, ic, params):
    with pytest.raises(ValueError):
        yag.solve(make_config(), ic, params).batches(batch_size=0)
