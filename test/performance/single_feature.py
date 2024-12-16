import pycatch22
import time
import numpy as np

n = 2000
N = 1000


def compute_features(x):
    res = pycatch22.PD_PeriodicityWang_th0_01(x)
    return res


ts = []
ni = 10
for _i in range(ni):
    print(f"Running {_i+1}/{ni}")
    dataset = [np.random.randn(n).tolist() for _ in range(N)]
    start_time = time.time()
    results_list = [compute_features(dataset[i]) for i in range(len(dataset))]
    joblib_time = time.time() - start_time
    ts.append(joblib_time)

print(f"Joblib method time: {np.median(joblib_time):.2f} seconds")  # * 1.09 seconds
