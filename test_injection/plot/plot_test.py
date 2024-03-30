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


wave_dir = '../injection_test_crust_perturb/OUTPUT_FILES'

sta_list = [f'TS{i:02d}' for i in range(1,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXZ.semd') for sta in sta_list]

sec = WaveformSection()

sec.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

wave_dir = '../injection_test_crust_perturb2/OUTPUT_FILES'

sta_list = [f'TS{i:02d}' for i in range(1,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXZ.semd') for sta in sta_list]

sec_large = WaveformSection()

sec_large.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

sec_large.shift(-15.15773)

wave_dir = '../benchmark_stacey_crust_perturb/OUTPUT_FILES'

sta_list = [f'TS{i:02d}' for i in range(1,20)]

fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXZ.semd') for sta in sta_list]

sec_benchmark = WaveformSection()

sec_benchmark.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

sec_large.filter((-1.0, 1.0/Tmin))
sec_benchmark.filter((-1.0, 1.0/Tmin))
sec.filter((-1.0, 1.0/Tmin))

sec_diff = sec - sec_large
sec_diff_benchmark = sec_benchmark - sec_large
#wave_dir = '../injection_test_stacey_crust_subduction/OUTPUT_FILES'

#sta_list = [f'TS{i:02d}' for i in range(1,20)]

#fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXZ.semd') for sta in sta_list]

#sec_stacey = WaveformSection()

#sec_stacey.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

#wave_dir = '../benchmark_stacey_crust_subduction/OUTPUT_FILES'

#sta_list = [f'TS{i:02d}' for i in range(1,20)]

#fn_list = [os.path.join(wave_dir, 'TS.'+sta+'.BXX.semd') for sta in sta_list]

#sec_stacey = WaveformSection()

#sec_stacey.get_waveforms_from_specfem(fn_list=fn_list, fn_stations=os.path.join(wave_dir, 'STATIONS'))

#sec_fk.filter((1.0/Tmax, 1.0/Tmin))
#sec.filter((1.0/Tmax, 1.0/Tmin))

offset = sec_fk.get_first_arrival_time()
print(offset)

print(sec_large.difference_ratio(sec, offset=offset, time_range=(-10.0, 40.0)))
print(sec_large.difference_ratio(sec_benchmark, offset=offset, time_range=(-10.0, 40.0)))
#offset_large = [_+3.2032 for _ in offset]
#print(offset)

#offset_diff = [y-x for x, y in zip(offset, offset_large)]
#print(offset_diff)
#sec.plot_waveforms_fill('k', fig_num=fig.number, normalize=20.0, offset=offset, time_range=(-10.0, 40.0), label="PML")
#sec_fk.plot_waveforms_fill('g', fig_num=fig.number, normalize=20.0, offset=offset, time_range=(-10.0, 60.0), fill=False, label="FK")
sec.plot_waveforms_fill('k', fig_num=fig.number, normalize=20.0, offset=offset, time_range=(-10.0, 40.0), fill=False, label="PML", linewidth=2)
sec_diff.plot_waveforms_fill('r--', fig_num=fig.number, normalize=200.0, offset=offset, norm_with=sec_large, time_range=(-10.0, 40.0), fill=False, label="(PML-large)X10", linewidth=2)
sec_diff_benchmark.plot_waveforms_fill('b--', fig_num=fig.number, normalize=200.0, norm_with=sec_large, offset=offset, time_range=(-10.0, 40.0), fill=False, label="(Stacey-large)X10", linewidth=2)



#sec.plot_waveforms_fill('r', fig_num=fig.number, normalize=20.0, offset=offset, time_range=(-10.0, 60.0), norm_with=sec_large, fill=False, linewidth=2, label="PML")
#sec_stacey.plot_waveforms_fill('k--', fig_num=fig.number, norm_with=sec, normalize=20.0, offset=offset, time_range=(-10.0, 40.0), fill=False)
#sec.plot_waveforms_fill('k', fig_num=fig.number, normalize=20.0)
#sec_diff = sec - sec_stacey
#sec_diff.plot_waveforms_fill('k--', fig_num=fig.number, norm_with=sec, normalize=20.0, offset=offset, time_range=(-10.0, 40.0), fill=False, label="Stacey-PML")
#sec_diff.plot_waveforms_fill('k--', fig_num=fig.number, norm_with=sec, normalize=20.0, offset=offset, time_range=(-30.0, 60.0), fill=False, label="PML - Stacey")
plt.ylim([-10.0, 40.0])
plt.xlim([0.0, 200.0])
plt.legend(prop={'size':20}, loc=4)
plt.xlabel('x (km)', fontsize=20)
plt.ylabel('t (s)', fontsize=20)
plt.gca().invert_yaxis()
plt.gca().tick_params(labelsize=20)
plt.text(-30.0, -10.0, '(a)', fontsize=20)
#plt.show()
plt.savefig("crust_perturb_Z.pdf")
