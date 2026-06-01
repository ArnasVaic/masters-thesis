import yag_model as ym

MOLAR_MASSES = [ 102.0, 225.8, 553.58, 163.89, 593.62 ]

def solve(mp, build_cfg):
    cfg = build_cfg(mp)
    ym.solve(*cfg)
    return cfg