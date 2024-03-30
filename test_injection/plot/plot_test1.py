from plot_utils_injection import WaveformSection
import matplotlib.pyplot as plt
import os

Tmin = 1.5
Tmax = 50.0

fig = plt.figure(figsize=(12, 9))

wave_dir = '../injection_test_crust/OUTPUT_FILES'

sta_list = [f'TS{i:02d}' for i in range(1,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.Z.fkd') for sta in sta_list]

sec_fk = WaveformSection()

sec_fk.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))


wave_dir = '../injection_test_crust/OUTPUT_FILES'

sta_list = [f'TS{i:02d}' for i in range(1,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXZ.semd') for sta in sta_list]

sec = WaveformSection()

sec.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

sec_fk.filter((-1.0, 1.0/Tmin))
sec.filter((-1.0, 1.0/Tmin))

sec_diff = sec - sec_fk

offset = sec_fk.get_first_arrival_time()
print(offset)

print(sec_fk.difference_ratio(sec, offset=offset, time_range=(-10.0, 40.0)))
sec.plot_waveforms_fill('k', fig_num=fig.number, normalize=20.0, offset=offset, time_range=(-10.0, 40.0), fill=False, label="injection", linewidth=2)
sec_diff.plot_waveforms_fill('r--', fig_num=fig.number, normalize=200.0, offset=offset, norm_with=sec_fk, time_range=(-10.0, 40.0), fill=False, label="(injection-FK)X10", linewidth=2)
plt.ylim([-10.0, 40.0])
plt.xlim([0.0, 200.0])
plt.legend(prop={'size':20}, loc=4)
plt.xlabel('x (km)', fontsize=20)
plt.ylabel('t (s)', fontsize=20)
plt.gca().invert_yaxis()
plt.gca().tick_params(labelsize=20)
plt.text(-30.0, -10.0, '(a)', fontsize=20)
#plt.show()
plt.savefig("crust_Z.pdf")
