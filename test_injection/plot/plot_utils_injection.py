import numpy as np
import sys, os
import matplotlib.pyplot as plt
from scipy import signal
from scipy.interpolate import interp1d

def split_line(line):
  # split line with continuous multiple spaces
  # return a list of strings
  return [_ for _ in line.strip().split(' ') if _ != '']

class WaveformSection:
  def __init__(self):
    self.waveforms = None
    self.t = None
    self.coord_list = None

  def __sub__(self, other):
    sub = other.interpolate(self.t)
    for i_wave in range(len(sub.waveforms)):
      sub.waveforms[i_wave] = self.waveforms[i_wave] - sub.waveforms[i_wave]
    return sub

  def shift(self, dt):
    self.t += dt

  def scale(self, fac):
    for i_wave in range(len(self.waveforms)):
      self.waveforms[i_wave] = self.waveforms[i_wave] * fac

  def difference_ratio(self, other, time_range=None, offset=None):
    if offset is None: offset = [0.0] * len(self.waveforms)
    if time_range is None: time_range = (self.t[0], self.t[-1])
    ratio_list = []
    sub = other.interpolate(self.t)
    for i_wave in range(len(sub.waveforms)):
      ind = np.logical_and((self.t-offset[i_wave] >= time_range[0]), (self.t-offset[i_wave] <= time_range[1]))
      diff = self.waveforms[i_wave][ind] - sub.waveforms[i_wave][ind]
      ratio = np.sum(diff * diff) / (
              np.sqrt(np.sum(self.waveforms[i_wave][ind] * self.waveforms[i_wave][ind]))*
              np.sqrt(np.sum(sub.waveforms[i_wave][ind] * sub.waveforms[i_wave][ind])))
      ratio_list.append(ratio)
    return ratio_list

  def time_shift(self, other, time_range=None, offset=None):
    if offset is None: offset = [0.0] * len(self.waveforms)
    if time_range is None: time_range = (self.t[0], self.t[-1])
    shift_list = []
    sub = other.interpolate(self.t)
    for i_wave in range(len(sub.waveforms)):
      ind = np.logical_and((self.t-offset[i_wave] >= time_range[0]), (self.t-offset[i_wave] <= time_range[1]))
      cc = signal.correlate(self.waveforms[i_wave][ind], sub.waveforms[i_wave][ind])
      dt = (np.argmax(cc) - (len(self.waveforms[i_wave][ind]) - 1)) * (self.t[1] - self.t[0])
      shift_list.append(dt)
    return shift_list

  def interpolate(self, t_new):
    """
    not in-place
    """
    sec_new = WaveformSection()
    sec_new.coord_list = self.coord_list
    sec_new.t = np.copy(t_new)
    sec_new.waveforms = []
    for wave in self.waveforms:
      f = interp1d(self.t, wave, fill_value="extrapolate")
      sec_new.waveforms.append(f(t_new))
    return sec_new

  def filter(self, freq_range, verbose=1):
    if (not isinstance(freq_range, tuple)):
      sys.exit(f"{freq_range} is not a tuple\n")
    if (len(freq_range)!=2):
      sys.exit(f"incorrect frequency range {freq_range}\n")
    if (verbose==1): print(f'apply filter {freq_range}\n')
    s = self.t[1] - self.t[0]
    if (not (freq_range[0] >= 0.0)):
      sos = signal.butter(4, freq_range[1] * s * 2, 'lowpass', output='sos')
    else:
      sos = signal.butter(4, [freq_range[0] * s * 2, freq_range[1] * s * 2], 'bandpass', output='sos')
    for i_wave in range(len(self.waveforms)):
      wave = self.waveforms[i_wave]
      self.waveforms[i_wave] = signal.sosfiltfilt(sos, wave, padtype=None)

  def get_max_time(self, time_range=None):
    if time_range is None: time_range = (self.t[0], self.t[-1])
    max_time_list = []
    max_amp_list = []
    for i_wave in range(len(self.waveforms)):
      wave = self.waveforms[i_wave]
      ind = np.logical_and((self.t >= time_range[0]), (self.t <= time_range[1]))
      wave_abs = np.absolute(wave)
      ind_max = np.argmax(wave_abs[ind])
      max_amp_list.append(np.amax(wave_abs[ind]))
      max_time_list.append(time_range[0] + ind_max * (self.t[1] - self.t[0]))
    return max_time_list, max_amp_list

  def get_first_arrival_time(self, threshold=0.1, time_range=None):
    if time_range is None: time_range = (self.t[0], self.t[-1])
    max_time_list, max_amp_list = self.get_max_time()
    first_arrival_time_list = []
    for i_wave in range(len(self.waveforms)):
      wave = self.waveforms[i_wave]
      ind = np.logical_and((self.t >= time_range[0]), (self.t <= time_range[1]))
      wave = wave[ind]
      wave_abs = np.absolute(wave)
      for it in range(1, len(wave)-1):
        if ((wave_abs[it] >= wave_abs[it-1]) and (wave_abs[it] >= wave_abs[it+1]) and (wave_abs[it]>=threshold*max_amp_list[i_wave])):
          arrival = time_range[0] + it * (self.t[1] - self.t[0])
          break
      first_arrival_time_list.append(arrival)
    return first_arrival_time_list


  def plot_waveforms_fill(self, *args, fig_num=0, time_range=None, offset=None,
                          x_axis_trans=(1,0, 0,0, 0,0, 0.0),
                          fill=True, fill_color=('blue', 'red'),
                          norm_with=None, normalize=1.0, label=None, **kwargs):
    fig = plt.figure(num=fig_num) # pull out the existed figure
    if offset is None: offset = [0.0] * len(self.waveforms)
    if time_range is None: time_range = (self.t[0], self.t[-1])
    if norm_with is None: norm_with = self
    max_val = 0.0
    for i_wave in range(len(self.waveforms)):
      wave = norm_with.waveforms[i_wave]
      ind = np.logical_and((norm_with.t-offset[i_wave] >= time_range[0]), (norm_with.t-offset[i_wave] <= time_range[1]))
      if (np.amax(np.absolute(wave)) > max_val):
        max_val = np.amax(np.absolute(wave[ind]))
    for i_wave in range(len(self.waveforms)):
      x_axis_val = x_axis_trans[0] * self.coord_list[i_wave][0] + \
                   x_axis_trans[1] * self.coord_list[i_wave][1] + \
                   x_axis_trans[2] * self.coord_list[i_wave][2] + \
                   x_axis_trans[3]
      ind = np.logical_and((self.t-offset[i_wave] >= time_range[0]), (self.t-offset[i_wave] <= time_range[1]))
      wave_norm = self.waveforms[i_wave][ind] / max_val * normalize + x_axis_val
      t_ind = self.t[ind] - offset[i_wave]
      if ((i_wave == 0) and (label is not None)):
        plt.plot(wave_norm, t_ind, *args, label=label, **kwargs)
      else:
        plt.plot(wave_norm, t_ind, *args, **kwargs)
      if fill:
        ax = plt.gca()
        zero = np.zeros_like(wave_norm) + x_axis_val
        ax.fill_betweenx(t_ind, wave_norm, zero, where=wave_norm >= zero , facecolor=fill_color[0])
        ax.fill_betweenx(t_ind, wave_norm, zero, where=wave_norm <= zero , facecolor=fill_color[1])

  def plot_waveforms_ax_fill(self, *args, ax=None, time_range=None, offset=None,
                          x_axis_trans=(1,0, 0,0, 0,0, 0.0),
                          is_time_axis_x = False,
                          fill=True, fill_color=('blue', 'red'),
                          norm_with=None, normalize=1.0, label=None, **kwargs):
    #fig = plt.figure(num=fig_num) # pull out the existed figure
    if ax is None: ax = plt.gca()
    if offset is None: offset = [0.0] * len(self.waveforms)
    if time_range is None: time_range = (self.t[0], self.t[-1])
    if norm_with is None: norm_with = self
    max_val = 0.0
    for i_wave in range(len(self.waveforms)):
      wave = norm_with.waveforms[i_wave]
      ind = np.logical_and((norm_with.t-offset[i_wave] >= time_range[0]), (norm_with.t-offset[i_wave] <= time_range[1]))
      if (np.amax(np.absolute(wave)) > max_val):
        max_val = np.amax(np.absolute(wave[ind]))
    for i_wave in range(len(self.waveforms)):
      x_axis_val = x_axis_trans[0] * self.coord_list[i_wave][0] + \
                   x_axis_trans[1] * self.coord_list[i_wave][1] + \
                   x_axis_trans[2] * self.coord_list[i_wave][2] + \
                   x_axis_trans[3]
      ind = np.logical_and((self.t-offset[i_wave] >= time_range[0]), (self.t-offset[i_wave] <= time_range[1]))
      wave_norm = self.waveforms[i_wave][ind] / max_val * normalize + x_axis_val
      t_ind = self.t[ind] - offset[i_wave]
      if ((i_wave == 0) and (label is not None)):
        if is_time_axis_x:
          ax.plot(t_ind, wave_norm, *args, label=label, **kwargs)
        else:
          ax.plot(wave_norm, t_ind, *args, label=label, **kwargs)
      else:
        if is_time_axis_x:
          ax.plot(t_ind, wave_norm, *args, **kwargs)
        else:
          ax.plot(wave_norm, t_ind, *args, **kwargs)
      if fill:
        #ax = plt.gca()
        zero = np.zeros_like(wave_norm) + x_axis_val
        if is_time_axis_x:
          ax.fill_between(t_ind, wave_norm, zero, where=wave_norm >= zero , facecolor=fill_color[0])
          ax.fill_between(t_ind, wave_norm, zero, where=wave_norm <= zero , facecolor=fill_color[1])
        else:
          ax.fill_betweenx(t_ind, wave_norm, zero, where=wave_norm >= zero , facecolor=fill_color[0])
          ax.fill_betweenx(t_ind, wave_norm, zero, where=wave_norm <= zero , facecolor=fill_color[1])

  def get_waveforms_from_specfem(self, fn_list, fn_stations,
                                 t=None, tstart=None, dt=None, nt=None,
                                 verbose=1):
    if (verbose==1): print('plotting waveforms from SPECFEM results\n')
    n_stations = len(fn_list)
    if (verbose==1): print(f'there are {n_stations} waveforms\n')
    if (verbose==1): print(f'reading station information from {fn_stations}\n')
    try:
      coord_list = [None] * n_stations
      with open(fn_stations, 'r') as f_stations:
        lines = f_stations.readlines()
      for line in lines:
        line_segs = split_line(line)
        nt_name = line_segs[0]
        sta_name = line_segs[1]
        sta_lat = float(line_segs[2])
        sta_lon = float(line_segs[3])
        sta_depth = float(line_segs[5])
        for i_fn in range(len(fn_list)):
          fn = os.path.split(fn_list[i_fn])[-1]
          if (fn.startswith(f'{nt_name}.{sta_name}') or fn.startswith(f'{sta_name}.{nt_name}')):
            if coord_list[i_fn] is not None:
              raise(ValueError('file list conflict'))
            coord_list[i_fn] = (sta_lon / 1000.0, sta_lat / 1000.0, sta_depth / 1000.0)
            break
      for i_fn in range(len(fn_list)):
        if coord_list[i_fn] is None:
          raise(ValueError(f'station does not exist for {fn_list[i_fn]}'))
    except Exception as e:
      sys.exit(f"{e}\n")
    self.coord_list = coord_list
    
    waveforms = []
    if t is not None:
      if (verbose==1): print(f'use time t0={t[0]}, dt={t[1]-t[0]}, nt={nt}\n')
    elif (tstart is not None) and (dt is not None) and (nt is not None):
      try:
        t = np.arange(0, nt, dtype=float) *dt + tstart
      except Exception as e:
        sys.exit(f"{e}\n")
      if (verbose==1): print(f'use time t0={t[0]}, dt={t[1]-t[0]}, nt={nt}\n')
    else:
      if (verbose==1): print('find time in waveform files\n')
    for i_fn in range(len(fn_list)):
      try:
        if (verbose==1): print(f'reading waveform file {fn_list[i_fn]}\n')
        wave = np.loadtxt(fn_list[i_fn])
        if t is None:
          if (tstart is None): tstart = wave[0,0]
          if (dt is None): dt = wave[1,0] - wave[0,0]
          if (nt is None): nt = len(wave)
          try:
            t = np.arange(0, nt, dtype=float) *dt + tstart
          except Exception as e:
            sys.exit(f"{e}\n")
          if (verbose==1): print(f'use time t0={t[0]}, dt={t[1]-t[0]}, nt={nt}\n')
        if (wave.shape[0] != len(t)):
          raise (ValueError(f'file length inconsistant: {fn_list[i_fn]}'))
        waveforms.append(wave[:,1])
      except Exception as e:
        sys.exit(f"{e}\n")
    self.waveforms = waveforms
    self.t = t                  
      
      
