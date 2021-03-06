%% Automotive Adaptive Cruise Control Using FMCW Technology
% This example shows how to model an automotive adaptive cruise control
% system using the frequency modulated continuous wave (FMCW) technique.
% This example performs range and Doppler estimation of a moving vehicle.
% Unlike pulsed radar systems that are commonly seen in the defense
% industry, automotive radar systems often adopt FMCW technology. Compared
% to pulsed radars, FMCW radars are smaller, use less power, and are much
% cheaper to manufacture. As a consequence, FMCW radars can only monitor a
% much smaller distance.

%   Copyright 2012-2016 The MathWorks, Inc.

%% FMCW Waveform 
% Consider an automotive long range radar (LRR) used for adaptive cruise
% control (ACC). This kind of radar usually occupies the band around 77
% GHz, as indicated in [1]. The radar system constantly estimates the
% distance between the vehicle it is mounted on and the vehicle in front of
% it, and alerts the driver when the two become too close. The figure below
% shows a sketch of ACC.
%
% <<../FMCWExample_acc.png>>
%
% A popular waveform used in ACC system is FMCW. The principle of range
% measurement using the FMCW technique can be illustrated using the
% following figure.
%
% <<../FMCWExample_upsweep.png>>
%
% The received signal is a time-delayed copy of the transmitted signal
% where the delay, $\Delta t$, is related to the range. Because the signal
% is always sweeping through a frequency band, at any moment during the
% sweep, the frequency difference, $f_b$, is a constant between the
% transmitted signal and the received signal. $f_b$ is usually called the
% beat frequency. Because the sweep is linear, one can derive the time
% delay from the beat frequency and then translate the delay to the range.
%
% In an ACC setup, the maximum range the radar needs to monitor is around
% 200 m and the system needs to be able to distinguish two targets that are
% 1 meter apart. From these requirements, one can compute the waveform
% parameters.

fc = 77e9;
c = 3e8;
lambda = c/fc;

%%
% The sweep time can be computed based on the time needed for the signal to
% travel the unambiguous maximum range. In general, for an FMCW radar
% system, the sweep time should be at least 5 to 6 times the round trip
% time. This example uses a factor of 5.5.

t_chirp = 200e-6;
tm = 200e-6;

%%
% The sweep bandwidth can be determined according to the range resolution
% and the sweep slope is calculated using both sweep bandwidth and sweep
% time.

bw = 4e9;
sweep_slope = bw/tm;

%%
% Because an FMCW signal often occupies a huge bandwidth, setting the
% sample rate blindly to twice the bandwidth often stresses the capability
% of A/D converter hardware. To address this issue, one can often choose a
% lower sample rate. Two things can be considered here:
%
% # For a complex sampled signal, the sample rate can be set to the same as
% the bandwidth.
% # FMCW radars estimate the target range using the beat frequency embedded
% in the dechirped signal. The maximum beat frequency the radar needs to
% detect is the sum of the beat frequency corresponding to the maximum
% range and the maximum Doppler frequency. Hence, the sample rate only
% needs to be twice the maximum beat frequency.
%
% In this example, the beat frequency corresponding to the maximum range is
% given by

fr_max = 10e6;

%%
% In addition, the maximum speed of a traveling car is about 230 km/h.
% Hence the maximum Doppler shift and the maximum beat frequency can be
% computed as

v_max = 230*1000/3600;
fd_max = speed2dop(2*v_max,lambda);

fb_max = fr_max+fd_max;


%%
% This example adopts a sample rate of the larger of twice the maximum beat
% frequency and the bandwidth.

fs = max(2*fb_max,bw);

%%
% The following table summarizes the radar parameters.
% 
%  System parameters            Value
%  ----------------------------------
%  Operating frequency (GHz)    77
%  Maximum target range (m)     200
%  Range resolution (m)         1
%  Maximum target speed (km/h)  230
%  Sweep time (microseconds)    7.33
%  Sweep bandwidth (MHz)        150
%  Maximum beat frequency (MHz) 27.30
%  Sample rate (MHz)            150


%%
% With all the information above, one can set up the FMCW waveform used
% in the radar system.

waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw,...
    'SampleRate',fs);
sig = waveform();
subplot(211); plot(0:1/fs:tm-1/fs,real(sig));
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;
subplot(212); spectrogram(sig,32,16,32,fs,'yaxis');
title('FMCW signal spectrogram');