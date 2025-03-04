% Applies the bandpass filter to the data. Written by someone else.
function [filteredsignal, time] = filter_data(signal, samplingrate, type, n, fc, fmax)
  
  isOctave = exist('OCTAVE_VERSION', 'builtin') ~=0;
  if isOctave
  pkg load signal
  end
  
  if nargin==5
    fmax=[];
  end

  time = 0:(1/samplingrate):(length(signal)-1)/samplingrate;

  Wn = [fc fmax]/(samplingrate/2);
  
  if strcmp(type, 'lowpass')
    [b, a] = butter(n, Wn, 'low');
  elseif strcmp(type, 'highpass')
    [b, a] = butter(n, Wn, 'high');
  elseif strcmp(type, 'bandpass')
    [b, a] = butter(n, Wn);
  elseif strcmp(type, 'bandstop')
    [b, a] = butter(n, Wn, 'stop');
  end
  
  filteredsignal = filtfilt(b, a, signal);
    
  close all
  figure(1)
  
  plot(time, signal, 'k')
  hold on 
  plot(time, filteredsignal, 'r')
  
  axis([0 max(time) floor(min(signal))-0.1 ceil(max(signal))+0.1])
  
  h = get(gcf, 'currentaxes');
  set(h, 'fontsize', 16, 'linewidth', 0.5);
  xlabel('time (s)')
  ylabel('amplitude')
  
  legend('original signal', 'filtered signal')
      
    
  
  
  