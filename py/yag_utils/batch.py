# Parallel, resumable batches of solves
#
# Tasks run in threads (solve releases the GIL), one per physical core by default. Results
# come back on the calling thread as each task ends, so they can be appended to a CSV right
# away and a rerun can skip the tasks already in it.

import csv
import os
import signal
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
from contextlib import contextmanager
from pathlib import Path
from typing import Callable, Iterator, Sequence, Generator

from tqdm.auto import tqdm

WORKERS = max(1, (os.cpu_count() or 2) // 2)


def load_rows(path: Path) -> list[dict[str, str]]:
    """Rows of a CSV file as written, none if it does not exist yet."""
    if not path.exists():
        return []
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


@contextmanager
def csv_appender(path: Path, fields: Sequence[str]) -> Iterator[Callable[[dict], None]]:
    """Yields append(row), which writes one row to the end of the file and flushes it.

    The header is written only to a new (empty) file.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        if f.tell() == 0:
            writer.writeheader()

        def append(row: dict) -> None:
            writer.writerow(row)
            f.flush()

        yield append


def run_batch(
        fn: Callable,
        tasks: Sequence[tuple],
        on_done: Callable[[tuple, object], None],
        workers: int = WORKERS) -> None:
    """Calls fn(*task) for every task in a thread pool, and on_done(task, result) as each one ends.

    Tasks start in the given order. on_done runs on the calling thread only, so it needs no
    locking. The first Ctrl+C drops the queued tasks and waits for the running ones, which are
    still reported; a second one stops waiting. Either way KeyboardInterrupt is raised after.
    """
    # Ctrl+C (or interrupting the kernel) only counts here and the loop below reacts to it. A
    # KeyboardInterrupt raised inside concurrent.futures can leave its locks held and deadlock.
    interrupts = 0

    def on_interrupt(signum, frame):
        nonlocal interrupts
        interrupts += 1

    executor = ThreadPoolExecutor(max_workers=workers)
    futures = {executor.submit(fn, *task): task for task in tasks}
    pending = set(futures)
    previous_handler = signal.signal(signal.SIGINT, on_interrupt)
    try:
        cancelled = False
        while pending:
            done, pending = wait(pending, timeout=0.5, return_when=FIRST_COMPLETED)
            for future in done:
                if not future.cancelled():
                    on_done(futures[future], future.result())

            if interrupts >= 1 and not cancelled:
                # Running tasks cannot be stopped mid-solve, so wait for them and report them too
                cancelled = True
                pending = {f for f in pending if not f.cancel()}
                tqdm.write(
                    f"Interrupted, saving the {len(pending)} tasks still running "
                    "(interrupt again to drop them)..."
                )
            if interrupts >= 2:
                tqdm.write(f"Dropped {len(pending)} running tasks")
                break
    finally:
        signal.signal(signal.SIGINT, previous_handler)
        executor.shutdown(wait=False, cancel_futures=True)

    if interrupts:
        raise KeyboardInterrupt
