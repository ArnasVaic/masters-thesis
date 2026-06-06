# %%

import numpy as np
import yag_model as ym
from core import P_TRUE, Scales, build_optimization_config, solve, get_p_pred

scales = Scales(L0=1e-6, C0 = 3.91e4, D_ref=1e-12)

def info(p_pred, mp):
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

    print(f"{'parameter':<12} {'value':<16}")
    print("-" * 30)
    for i, D in enumerate(mp.D):
        D_phys = D * scales.D_ref
        print(f"D_{i+1:<12} {D_phys:<16.8e}")
    print("-" * 30)
    for i, K in enumerate(mp.K):
        K_phys = K / (scales.C0 * scales.T0)
        print(f"K_{i+1:<12} {K_phys:<16.8e}")
    print("-" * 30)

logD = [
    -18.705183683895132,
    -17.98902755136912,
    -18.99733614615828
    ,-17.91290362917506,
    -17.214973064752815
]

logK = [
    -6.125272554342815,-7.900833099916853,-7.856737838978788
]

mp = ym.ModelParameters(
    [ 10**d for d in logD ],
    [ 10**k for k in logK ]
)

disc, _, _, _, _, cpt, ic = solve(mp, build_optimization_config, scales)
p_pred = get_p_pred(ic, disc, cpt)
info(p_pred, mp)
# %%
