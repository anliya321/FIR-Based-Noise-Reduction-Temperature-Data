clc;
clear;
close all;

%% FIR BASED NOISE REDUCTION OF TEMPERATURE SENSOR DATA

%% 1. Select Dataset
[file,path] = uigetfile('*.csv','Select temperature dataset');

if isequal(file,0)
    return;
end

%% 2. Read Dataset
M = readmatrix(fullfile(path,file));

time = M(:,1);

% Temp_Inside_2 [°C] is Column 16
temperature = M(:,16);

valid = isfinite(time) & isfinite(temperature);

time = time(valid);
temperature = temperature(valid);

%% 3. Sampling Frequency
Ts = median(diff(time));
Fs = 1/Ts;

fprintf('Sampling Frequency = %.4f Hz\n',Fs);

%% 4. Input Temperature Signal
x = temperature;

%% FIGURE 1: INPUT SIGNAL

figure;

plot(time,x,'LineWidth',1);

grid on;
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Original Temperature Sensor Signal - Temp Inside 2');

%% 5. FIR Low Pass Filter
filterOrder = 200;
Fc = 0.001;

Wn = Fc/(Fs/2);

b = fir1(filterOrder,Wn,'low',hamming(filterOrder+1));

%% 6. Apply FIR Filter
x_filtered = filtfilt(b,1,x);

%% FIGURE 2: BEFORE AND AFTER

figure;

plot(time,x,'LineWidth',0.8);
hold on;

plot(time,x_filtered,'LineWidth',1.8);

grid on;
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Temperature Signal Before and After FIR Filtering');

legend('Before Filtering','After Filtering');

%% 7. FFT Analysis
N = length(x);

x_before = x - mean(x);
x_after = x_filtered - mean(x_filtered);

X_before = fft(x_before);
X_after = fft(x_after);

P_before = abs(X_before/N);
P_after = abs(X_after/N);

P_before = P_before(1:floor(N/2)+1);
P_after = P_after(1:floor(N/2)+1);

P_before(2:end-1) = 2*P_before(2:end-1);
P_after(2:end-1) = 2*P_after(2:end-1);

f = Fs*(0:floor(N/2))/N;

%% Normalize
P_before_norm = P_before/max(P_before);
P_after_norm = P_after/max(P_before);

%% FIGURE 3: FREQUENCY DOMAIN

figure;

subplot(2,1,1);

plot(f,P_before_norm,'LineWidth',1.2);
grid on;

xlabel('Frequency (Hz)');
ylabel('Normalized Amplitude');
title('Frequency Spectrum Before FIR Filtering');

xlim([0 0.01]);
ylim([0 1.05]);

subplot(2,1,2);

plot(f,P_after_norm,'LineWidth',1.2);
grid on;

xlabel('Frequency (Hz)');
ylabel('Normalized Amplitude');
title('Frequency Spectrum After FIR Filtering');

xlim([0 0.01]);
ylim([0 1.05]);

sgtitle('Frequency-Domain Comparison');

%% FIGURE 4: SAME GRAPH

figure;

plot(f,P_before_norm,'LineWidth',2);
hold on;

plot(f,P_after_norm,'LineWidth',1.5);

grid on;

xlabel('Frequency (Hz)');
ylabel('Normalized Amplitude');

title('Frequency Spectrum Before and After FIR Filtering');

legend('Before Filtering','After Filtering');

xlim([0 0.01]);
ylim([0 1.05]);
