from plot_utils_injection import WaveformSection
import matplotlib.pyplot as plt
import os
import numpy as np

Tmin = 1.5
Tmax = 50.0

fig, (ax1, ax2) = plt.subplots(2, 1, gridspec_kw={'height_ratios': [0.7, 3]}, figsize=(12, 12))


y = np.linspace(60.0, 140.0, 800)
z = np.linspace(-15.0, 0.0, 150)

Y, Z = np.meshgrid(y, z)

y0 = 100.0
z0 = -8.75
sigmay = 0.2
sigmaz = 0.2
s0 = 3.0
slip = s0 * np.exp(- ((Y-y0)/sigmay)**2 - ((Z-z0)/sigmaz)**2)

p = ax1.pcolormesh(Y, Z, slip, vmin=0.0, vmax=s0, cmap='Reds')
ax1.set_xlabel('Y(km)', fontsize=20)
ax1.set_ylabel('Z(km)', fontsize=20)
ax1.set_yticks([0.0, -5.0, -10.0, -15.0])
ax1.tick_params(labelsize=20)
ax1.set_aspect('equal')
cbar = fig.colorbar(p, ax=ax1, shrink=1.0, aspect=10, ticks=[0.0, 1.0, 2.0, 3.0])
cbar.set_label('slip(m)', fontsize=20)
cbar.ax.tick_params(labelsize=20)

wave_dir = '../kinematic_test/kinematic_test1'

sta_list = [f'TS{i:02d}' for i in range(10,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXY.semd') for sta in sta_list]

sec = WaveformSection()

#sec.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'), tstart=-8.0, dt=0.02, nt=5000)
sec.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'), tstart=-8.0)

sec.filter((-1.0, 1.0/Tmin))


wave_dir = '../kinematic_test_cmt/kinematic_test_cmt1'

sta_list = [f'TS{i:02d}' for i in range(10,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXY.semd') for sta in sta_list]

sec_cmt = WaveformSection()

sec_cmt.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

sec_cmt.scale(-1.0)
#sec_cmt.scale(-156.59049 / 1.8655313)
#sec_cmt.scale(-939.38403 / 1.8655313)
#sec_cmt.scale(0.025054558 / 3.4000101)
#sec_cmt.scale(0.0062866922 / 3.4000101)
#sec_cmt.scale(0.0012720939 / 3.4000101)

sec_cmt.filter((-1.0, 1.0/Tmin))

sec_cmt.plot_waveforms_ax_fill('k', ax=ax2, normalize=20, label='moment tensor', time_range=(-4.0, 50.0), is_time_axis_x=True, fill=False, linewidth=3)

sec.plot_waveforms_ax_fill('r--', ax=ax2, norm_with=sec_cmt, normalize=20, label='interface discontinuity',is_time_axis_x=True, time_range=(-4.0, 50.0), fill=False, linewidth=2)

ax2.set_xlim([-4.0, 50.0])
ax2.set_ylim([90.0, 200.0])
ax2.legend(prop={'size':20}, loc=2)
ax2.set_ylabel('X (km)', fontsize=20)
ax2.set_xlabel('t (s)', fontsize=20)
#ax2.invert_yaxis()
ax2.set_yticks(np.arange(100.0, 200.0, 20.0))
ax2.set_yticks(np.arange(100.0, 200.0, 10.0), minor=True)
ax2.tick_params(labelsize=20, right=True, labelright=False, which='both', length=8)
ax1.text(50.0, 2.0, '(b)', fontsize=20)
ax1.text(125.0, -3.0, 'Mw=4.8', fontsize=20)
#plt.show()
plt.savefig("kinematic_1.pdf")
