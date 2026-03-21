clear;
clc;
close all;

f0 = 77e9;
c = 3e8;
lambda = c / f0; 
theta_True = 20 * pi / 180; % 
d_virtual = lambda / 2; % Spacing between virtual elements

% Set N_Tx and N_Rx
N_Tx = 2; % Number of transmitting antennas
N_Rx = 29; % Number of receiving antennas

% Compute virtual positions
N_Tx_positions = (0:N_Tx-1) * d_virtual;
N_Rx_positions = (0:N_Rx-1) * d_virtual;
virtual_positions = [];
for tx = 1:N_Tx
    for rx = 1:N_Rx
        virtual_positions = [virtual_positions; N_Tx_positions(tx) + N_Rx_positions(rx)];
    end
end
disp(['Number of virtual antennas: ', num2str(length(virtual_positions))]);
disp(['Number of Tx antennas: ', num2str(N_Tx)]);
disp(['Number of Rx antennas: ', num2str(N_Rx)]);

% Simulate received signal
Signal_received = zeros(length(virtual_positions), 1);
for i = 1:length(virtual_positions)
    phase_shift = 2 * pi * (virtual_positions(i) * sin(theta_True) / lambda);
    Signal_received(i) = exp(1j * phase_shift);
end

% DoA estimation
Nfft = 2^10; % Ensure sufficient FFT resolution
fft_Recieved_Signal = fftshift(fft(Signal_received, Nfft));
f_axis = linspace(-1, 1, Nfft) / (2 * d_virtual); % Spatial frequency axis
[peak, idx_f_peak] = max(abs(fft_Recieved_Signal));
theta_estimate = asin(f_axis(idx_f_peak) * lambda);

% Range Estimation using Cross-Correlation**
B = 1e9; % Bandwidth of the transmitted signal
T = 1e-6; % Duration of the signal (1 microsecond)
fs = 4 * f0;
t = 0:1/fs:T-1/fs; % Time vector for transmitted signal

% Transmitted signal
g_t = sinc(B*(t-T/2)) .* exp(1j*2*pi*f0*t);

% Received signal (delayed version)
tau = 2 * 14 / c; % Round-trip time delay for true range
s_received = circshift(g_t, round(tau * fs)); % Apply time delay

% Cross-correlation for range estimation
[R_corr, lags] = xcorr(s_received, g_t); % Cross-correlation
[~, idx_peak] = max(abs(R_corr)); % Find peak of the cross-correlation
tau_estimated = lags(idx_peak) / fs; % Estimated time delay
r_estimated = c * tau_estimated / 2;

% Display results
disp(['True Angle: ', num2str(theta_True * 180 / pi)]);
disp(['Estimated Angle: ', num2str(theta_estimate * 180 / pi)]);
disp(['True Range: 14 m']);
disp(['Estimated Range: ', num2str(r_estimated), ' m']);

% Visualization
figure();
range_axis = lags / fs * c / 2; % Convert lags to range
plot(range_axis, abs(R_corr), 'LineWidth', 2);
hold on;
scatter(r_estimated, max(abs(R_corr)), 80, 'r', 'filled', 'DisplayName', 'Estimated Range');
xlabel('Range (m)');
ylabel('Magnitude');
title('Range Estimation using Cross-Correlation');
grid on;
legend('show');

% Enhanced Plot: FFT with True and Estimated Targets (Using Markers)
angles = asin(linspace(-1, 1, Nfft)); % Spatial frequency mapped to angles
angles_deg = rad2deg(angles);

figure();
plot(angles_deg, abs(fft_Recieved_Signal), 'LineWidth', 2, 'DisplayName', 'FFT Spectrum');
hold on;
scatter(rad2deg(theta_True), peak, 80, 'r', 'filled', 'DisplayName', 'True Target');
scatter(rad2deg(theta_estimate), peak, 80, 'g', 'filled', 's', 'DisplayName', 'Estimated Target');
grid on;
xlabel('Angle (degrees)');
ylabel('Magnitude');
title('Direction of Arrival (DoA) Estimation: True vs Estimated Target');
legend('show');
hold off;
