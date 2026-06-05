# %%

import numpy as np
import yag_model as ym
from core import P_TRUE, build_optimization_config, solve, get_p_pred

def info(p_pred):
    print(f"{'channel':<8} {'mass % (pred)':<16} {'mass % (true)':<16} {'rel. err. %':<16} ")
    print("-" * 56)
    pp_sum, pt_sum, rel_err_sum = 0, 0, 0
    for i, (pp, pt) in enumerate(zip(p_pred, P_TRUE)):
        pp_sum += pp
        pt_sum += pt
        rel_err = 100 * np.abs(pp - pt) / pt
        rel_err_sum += rel_err 
        print(f"c_{i+1:<8} {pp:<16.2f} {pt:<16.2f} {rel_err:<16.2f}")

    print("-" * 56)
    print(f"{'total':<8} {pp_sum:<16.2f} {pt_sum:<16.2f} {rel_err_sum:<16.2f}")

logD = [
    -5.951425472226097,
    -6.381854122397745,
    -6.796653711570672,
    -6.378758235770181,
    -5.190091649510689
]

logK = [
    10.990986955550355,
    10.483942406247088,
    9.04041247830719
]

mp = ym.ModelParameters(
    [ 10**d for d in logD ],
    [ 10**k for k in logK ]
)

disc, _, _, _, _, cpt, ic = solve(mp, build_optimization_config)
p_pred = get_p_pred(ic, disc, cpt)
info(p_pred)
# %%
