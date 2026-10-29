import numpy as np
import pytest
import yag_model as yag
import yag_utils
from yag_utils import channels, constants, stoichiometry
from yag_utils import initial_conditions as ics


@pytest.fixture
def square_disc():
    return yag.discretization(mesh_resolution=(40, 40))


def test_random_squares_fills_mesh_with_reagents(square_disc):
    state = ics.random_squares(disc=square_disc, c1=0.1, c2=0.2, rng=np.random.default_rng(0))

    c1, c2 = state[0], state[1]
    assert c1.shape == square_disc.shape
    # Every cell holds exactly one reagent, half the blocks are c1 by default
    assert np.all((c1 > 0) != (c2 > 0))
    assert np.count_nonzero(c1) == c1.size // 2
    for i in range(2, 5):
        assert not state[i].any()


def test_random_squares_is_reproducible_with_seed(square_disc):
    a = ics.random_squares(square_disc, 1.0, 1.0, rng=np.random.default_rng(42))
    b = ics.random_squares(square_disc, 1.0, 1.0, rng=np.random.default_rng(42))
    np.testing.assert_array_equal(a[0], b[0])


def test_perlin_based_respects_fraction(square_disc):
    state = ics.perlin_based(square_disc, 1.0, 1.0, n=4, t=0.3, rng=np.random.default_rng(0))
    assert np.count_nonzero(state[0]) / state[0].size == pytest.approx(0.3, abs=0.02)


def test_checkerboard_matches_solver_builtin(square_disc):
    np.testing.assert_array_equal(
        ics.checkerboard(square_disc, 1.0, 2.0)[1],
        yag.checkerboard_initial_condition(square_disc, 1.0, 2.0)[1],
    )


def test_stoichiometries():
    np.testing.assert_array_equal(stoichiometry.default, yag.DEFAULT_STOICHIOMETRY)
    assert stoichiometry.simplified.shape == (5, 3)


def test_channels_and_constants():
    assert channels.labels(channels.YAM | channels.YAG) == ["$YAM$", "$YAG$"]
    assert constants.MOLAR_MASSES is yag.MOLAR_MASSES
    assert yag_utils.constants.P_TRUE.shape == (5,)


def test_scaling_round_trip():
    from yag_utils.scaling import Scales, to_dimensionless, to_physical

    scales = Scales(L0=1e-6, C0=3.91e4, D_ref=1e-7)
    assert scales.T0 == pytest.approx(1e-5)

    params = yag.model_params(D=[1e-15] * 5, k=[1e-8] * 3)
    nd = to_dimensionless(params, scales)
    np.testing.assert_allclose(nd.D, 1e-8)
    np.testing.assert_allclose(nd.k, 1e-8 * 3.91e4 * 1e-5)

    back = to_physical(nd, scales)
    np.testing.assert_allclose(back.D, params.D)
    np.testing.assert_allclose(back.k, params.k)


def test_scales_convert_units_both_ways():
    from yag_utils.scaling import Scales

    scales = Scales(L0=1e-6, C0=3.91e4, D_ref=1e-7)
    assert scales.Q0 == pytest.approx(3.91e4 * 1e-12)

    assert scales.dimensionless_length(2e-6) == pytest.approx(2.0)
    assert scales.dimensionless_time(3e-5) == pytest.approx(3.0)
    assert scales.dimensionless_concentration(3.91e4) == pytest.approx(1.0)
    assert scales.dimensionless_quantity(scales.Q0) == pytest.approx(1.0)

    x = np.array([0.5, 2.0])
    np.testing.assert_allclose(scales.dimensionless_length(scales.physical_length(x)), x)
    np.testing.assert_allclose(scales.dimensionless_time(scales.physical_time(x)), x)
    np.testing.assert_allclose(scales.dimensionless_concentration(scales.physical_concentration(x)), x)
    np.testing.assert_allclose(scales.dimensionless_quantity(scales.physical_quantity(x)), x)


def test_discretization_scaling_keeps_mesh():
    from yag_utils import physical
    from yag_utils.scaling import Scales, physical_discretization

    scales = Scales(L0=1e-6, C0=1.0, D_ref=1.0)
    disc = physical.discretization(scales, physical_size=(1e-6, 2e-6), mesh_resolution=(8, 6))

    assert disc.mesh_resolution == (8, 6)
    assert disc.physical_size == pytest.approx((1.0, 2.0))

    phys = physical_discretization(disc, scales)
    assert phys.mesh_resolution == (8, 6)
    assert phys.physical_size == pytest.approx((1e-6, 2e-6))


def test_physical_result_scales_by_reducer(make_config, ic, params, disc):
    from yag_utils.mass import field_masses
    from yag_utils.scaling import Scales, physical_discretization, physical_result, physical_values

    scales = Scales(L0=1e-6, C0=3.91e4, D_ref=1e-7)

    fields = yag.solve(make_config(), ic, params)
    masses = yag.solve(make_config(reducer=yag.reducers.total_mass()), ic, params)

    c, t = physical_result(fields, scales)
    m, _ = physical_result(masses, scales)

    np.testing.assert_allclose(c, fields.all().values * scales.C0)
    np.testing.assert_allclose(t, fields.all().times * scales.T0)
    # Physical fields on the physical mesh give the same masses as converted reducer output
    np.testing.assert_allclose(field_masses(c, physical_discretization(disc, scales)), m)

    with pytest.raises(ValueError):
        physical_values(c, "unknown", scales)


def test_physical_components_use_dimensionless_units(disc):
    from yag_utils import physical
    from yag_utils.scaling import Scales, to_dimensionless

    scales = Scales(L0=1e-6, C0=3.91e4, D_ref=1e-15)

    assert physical.fixed_step(scales, dt=1.0).dt == pytest.approx(1e-3)
    assert physical.fixed_time_brake(scales, final_time=6 * 60 * 60).final_time == pytest.approx(21.6)

    step = physical.geometric_step(scales, dt_0=10.0, r=1.1)
    assert (step.dt_0, step.r) == pytest.approx((1e-2, 1.1))

    step = physical.clamped_geometric_step(scales, dt_0=10.0, r=1.1, upper_bound=100.0, every=5)
    assert (step.dt_0, step.r, step.upper_bound) == pytest.approx((1e-2, 1.1, 0.1))
    assert step.every == 5

    params = physical.model_params(scales, D=[1e-15] * 5, k=[1e-8] * 3)
    expected = to_dimensionless(yag.model_params(D=[1e-15] * 5, k=[1e-8] * 3), scales)
    np.testing.assert_allclose(params.D, expected.D)
    np.testing.assert_allclose(params.k, expected.k)

    ic = physical.checkerboard_initial_condition(scales, disc, 3.91e4, 3 / 5 * 3.91e4)
    np.testing.assert_allclose(ic[0], yag.checkerboard_initial_condition(disc, 1.0, 0.6)[0])
    np.testing.assert_allclose(ic[1], yag.checkerboard_initial_condition(disc, 1.0, 0.6)[1])


def test_field_masses_match_total_mass_reducer(disc, ic, params):
    from yag_utils.mass import field_masses, total_mass

    def run(**capture):
        config = yag.solver_config(
            discretization=disc,
            step=yag.fixed_step(dt=0.001),
            brake=yag.fixed_step_brake(last_step=10),
            capture=yag.capture_config(**capture),
        )
        return yag.solve(config, ic, params).all().values

    mask = channels.Y2O3 | channels.YAG
    fields = run(channels=mask)
    masses = run(channels=mask, reducer=yag.reducers.total_mass())

    np.testing.assert_allclose(field_masses(fields, disc, mask), masses)
    assert run(reducer=yag.reducers.total_mass())[0].sum() == pytest.approx(total_mass(ic, disc))


def test_optimization_conserves_mass():
    from yag_utils.optimization import evaluate, loss

    params = yag.model_params(D=[1e-15] * 5, k=[1e-8] * 3)
    p_pred = evaluate(params)

    assert p_pred.shape == (5,)
    assert p_pred.sum() == pytest.approx(100.0, rel=1e-9)
    assert loss(p_pred) >= 0.0


def test_optimization_config_accepts_custom_capture():
    from yag_utils.optimization import optimization_config

    capture = yag.capture_config(trigger=yag.stride_trigger(every=100))
    config, ic = optimization_config(capture=capture)

    assert isinstance(config.capture.trigger, yag.StrideTrigger)
    assert ic[0].shape == config.discretization.shape


def test_config_info_prints_summary(capsys):
    from yag_utils.debug import config_info
    from yag_utils.optimization import DEFAULT_SCALES, optimization_config

    config, ic = optimization_config()
    config_info(config, ic, yag.model_params(D=[1.0] * 5, k=[1.0] * 3), DEFAULT_SCALES)

    out = capsys.readouterr().out
    assert "[mesh] resolution: 40 x 40" in out
    assert "[brake] approx steps: 21600" in out


def test_paths_locate_repository():
    from yag_utils.paths import diagrams_dir, repo_root

    assert (repo_root() / "pyproject.toml").is_file()
    assert diagrams_dir().is_dir()
