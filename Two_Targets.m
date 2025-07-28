clear;
clc;
close all;

f0 = 77e9;
c = 3e8; 
lambda = c / f0;
theta_true = [35, 40] * pi / 180;

dx = lambda / 4; % Spacing between antennas
delta_theta = 2 * pi / 180;
L = lambda / delta_theta;
N = floor(L / dx + 1);
n = -N/2:N/2-1;
n_space = n * dx;

fs = 4 * f0;
Nfft = 2^10;
f_axis = linspace(-1/(2*dx), 1/(2*dx), Nfft);
dt = 1 / fs; 

% Received Signal: Sum of Two Targets
fx_true = 2 * sin(theta_true) / lambda; % Spatial frequencies for targets
sR_demod = exp(1j * 2 * pi * fx_true(1) * dx * n) + exp(1j * 2 * pi * fx_true(2) * dx * n); % Demodulated signal

S_R = fftshift(fft(sR_demod, Nfft)) * dx; % FFT of demodulated signal
[peaks, idx_f_peak] = findpeaks(abs(S_R), 'MinPeakHeight', 0.5 * max(abs(S_R)));

% Verify and Estimate Angles
if numel(idx_f_peak) < 2
    disp('Targets are not resolvable due to insufficient angular separation or ambiguity.');
else
    f_peaks = f_axis(idx_f_peak(1:2));
    theta_estimates = asin((lambda * f_peaks) / 2);
    
    fprintf('True Angles (degrees): %.2f, %.2f\n', rad2deg(theta_true(1)), rad2deg(theta_true(2)));
    fprintf('Estimated Angles (degrees): %.2f, %.2f\n', rad2deg(theta_estimates(1)), rad2deg(theta_estimates(2)));
end

angles = asin(f_axis * lambda / 2);
angles_deg = rad2deg(angles);

% Visualization: FFT Spectrum with True and Estimated Targets
figure();
plot(angles_deg, abs(S_R), 'LineWidth', 2, 'DisplayName', 'FFT Spectrum');
hold on;
scatter(rad2deg(theta_true), peaks(1:2), 100, 'r', 'filled', 'DisplayName', 'True Targets'); % True targets with circles
if numel(idx_f_peak) >= 2
    scatter(rad2deg(theta_estimates), peaks(1:2), 80, 'g', 'filled', 's', 'DisplayName', 'Estimated Targets'); % Estimated targets with squares
end
xlabel('Angle (degrees)');
ylabel('Magnitude');
title('FFT Spectrum with True and Estimated Targets');
legend('show');
grid on;

[theta_mesh, freq_mesh] = meshgrid(angles_deg, f_axis); 
amplitude_mesh = repmat(abs(S_R), length(angles_deg), 1);

figure();
surf(freq_mesh, theta_mesh, amplitude_mesh', 'EdgeColor', 'none');
hold on;

% Mark True and Estimated Targets on Surface Plot
scatter3(fx_true, rad2deg(theta_true), max(abs(S_R)), 100, 'r', 'filled', 'DisplayName', 'True Targets');
if numel(idx_f_peak) >= 2
    scatter3(f_peaks, rad2deg(theta_estimates), peaks(1:2), 80, 'g', 'filled', 'DisplayName', 'Estimated Targets');
end

title('Surface Plot: Spatial Frequency vs Angle and Amplitude');
xlabel('Spatial Frequency (cycles/m)');
ylabel('Angle (degrees)');
zlabel('Amplitude');
colormap('jet');
colorbar;
legend('show');
grid on;