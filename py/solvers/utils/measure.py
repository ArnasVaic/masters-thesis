from contextlib import contextmanager
import time

@contextmanager
def timed(msg="Elapsed"):
  start = time.perf_counter()
  yield lambda: time.perf_counter() - start
  end = time.perf_counter()
  print(f"{msg}: {end - start:.6f} seconds")