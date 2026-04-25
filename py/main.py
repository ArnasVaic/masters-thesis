# %%

import numpy as np
import matplotlib.pyplot as plt


# %%

def ic(c1, c2, ord, w, h):
    a = np.zeros((h, w))
    b = np.zeros((h, w))
    c = np.zeros((h, w))

    pn = 2 ** ord

    assert w % pn == 0
    assert h % pn == 0
    pw = int(w // pn)
    ph = int(h // pn)
    half_pw = int(pw // 2)
    half_ph = int(ph // 2)

    for i in range(h):
        for j in range(w):

            i1 = i // ph
            j1 = j // pw

            if (i1 % 2 == 0) ^ (j1 % 2 == 0):
                a[(i + half_ph) % h, (j + half_pw) % w] = c1

    return np.array([a, b, c])

img = ic(1.0, 1.0, 1, 40, 40)
plt.imshow(np.transpose(img, (1, 2, 0)))

# %%
