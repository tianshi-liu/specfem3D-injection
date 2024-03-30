import numpy as np
import matplotlib.pyplot as plt

plt.figure(figsize=(20,10))

stf = np.loadtxt('../kinematic_test/stf.txt')
stf_cmt = np.loadtxt('../kinematic_test_cmt/OUTPUT_FILES/plot_source_time_function.txt')

plt.plot(stf[:,0], stf[:,1], 'r')
plt.plot(stf_cmt[:,0], stf_cmt[:,1], 'b--')
plt.show()
