import pytest
import yag_model as yag


@pytest.fixture
def disc():
    # Non-square so (ny, nx) vs (nx, ny) mix-ups show up
    return yag.discretization(mesh_resolution=(8, 6), physical_size=(1.0, 2.0))


@pytest.fixture
def params():
    return yag.model_params(D=[0.01] * 5, k=[1.0, 1.0, 1.0])


@pytest.fixture
def ic(disc):
    return yag.checkerboard_initial_condition(disc, 1.0, 1.0)


@pytest.fixture
def make_config(disc):
    def make(**capture):
        return yag.solver_config(
            discretization=disc,
            step=yag.fixed_step(dt=0.001),
            brake=yag.fixed_step_brake(last_step=20),
            capture=yag.capture_config(**capture),
        )

    return make
