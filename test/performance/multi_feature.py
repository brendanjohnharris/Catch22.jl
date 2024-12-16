# PYTHON
import pycatch22
import os
import time
import numpy as np
from joblib import Parallel, delayed
import tracemalloc

n = 10000
N = 1000


def compute_features(x):
    res = pycatch22.catch22_all(x)
    return res  # just return the values


threads_to_use = os.cpu_count()
ts = []
ni = 10
tracemalloc.start()
for _i in range(ni):
    print(f"Running {_i+1}/{ni}")
    dataset = [np.random.randn(n).tolist() for _ in range(N)]
    start_time = time.time()
    results_list = Parallel(n_jobs=threads_to_use)(
        delayed(compute_features)(dataset[i]) for i in range(len(dataset))
    )
    joblib_time = time.time() - start_time
    ts.append(joblib_time)

print(f"Joblib method time: {np.median(joblib_time):.2f} seconds")  # * 8.83 seconds
current, peak = tracemalloc.get_traced_memory()
print(f"Current memory usage: {current / 10**6:.2f} MB")  # * 324 MB
print(f"Peak memory usage: {peak / 10**6:.2f} MB")  # * 644 MB
tracemalloc.stop()
