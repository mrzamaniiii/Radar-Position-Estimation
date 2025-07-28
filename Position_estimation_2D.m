clear;
clc;
close all;

f0 = 77*10^9;
c = 3*10^8;
B = 10^9;
r_true = 35; % True range of the target (m)

fs = 4*f0;
T = 1e-6;
t = 0:1/fs:T-1/fs;

% Transmitted signal
g_t = sinc(B*(t-T/2)) .*exp(1j*2*pi*f0*t);

% Received signal (delayed version of transmitted signal)
tau = 2 * r_true / c;
s_received = circshift(g_t, round(tau * fs)); % Apply time delay

% Range Estimation using Cross-Correlation
[R_corr, lags] = xcorr(s_received, g_t); % Cross-correlation with the transmitted signal
[~, idx_peak] = max(abs(R_corr)); % Find the peak of the cross-correlation
tau_estimated = lags(idx_peak) / fs; % Estimated time delay
r_estimated = c * tau_estimated / 2;

% Visualization
range_axis = lags / fs * c / 2; % Convert lags to range
figure;
plot(range_axis, abs(R_corr), 'LineWidth', 2);
hold on;
scatter(r_estimated, max(abs(R_corr)), 80, 'r', 'filled', 'DisplayName', 'Estimated Range');
xlabel('Range (m)');
ylabel('Magnitude');
title('Range Estimation using Cross-Correlation');
grid on;
legend('show');

% Display the result
fprintf('True Range (m): %.2f\n', r_true);
fprintf('Estimated Range (m): %.2f\n', r_estimated);
