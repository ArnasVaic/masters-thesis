# %%

import numpy as np
import yag_model as ym
from yag_utils.constants import P_TRUE
from yag_utils.optimization import evaluate, loss


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

    # mp holds physical parameters
    print(f"{'parameter':<12} {'value':<16}")
    print("-" * 30)
    for i, D in enumerate(mp.D):
        print(f"D_{i+1:<12} {D:<16.8e}")
    print("-" * 30)
    for i, k in enumerate(mp.k):
        print(f"k_{i+1:<12} {k:<16.8e}")
    print("-" * 30)

logD = [
    -15.520843103369195,
    -14.962864487926721,
    -14.08355774833853,
    -15.939166775886509,
    -15.064413562884312
]

logK = [
    -8.81287507930491,
    -8.171172197361324,
    -8.998608159571566
]

mp = ym.model_params(
    D=[ 10**d for d in logD ],
    k=[ 10**k for k in logK ]
)

p_pred = evaluate(mp)

print(f'loss: {loss(p_pred)}')
info(p_pred, mp)
# %%
